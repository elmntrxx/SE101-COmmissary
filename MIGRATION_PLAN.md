# Commissary App: Service Role Key Removal - Implementation Plan

## Executive Summary

This document details the migration of the SE101-Commissary app from using a Supabase service role key (which bypasses Row Level Security) to using authenticated user sessions with proper RLS policies. This eliminates a **critical security vulnerability** where the privileged key was exposed in client-side code.

---

## 1. Current State Analysis

### Security Issue Identified

The commissary app previously used a service role key in client-side code:

```dart
// ❌ DANGEROUS - Key exposed in app binary
static String get serviceRoleKey => dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';

// Creates a separate client that bypasses ALL RLS
_serviceRoleClient = SupabaseClient(
  SupabaseConfig.url,
  SupabaseConfig.serviceRoleKey,
  authOptions: const AuthClientOptions(autoRefreshToken: false),
);
```

**Risks:**
- Service role key can be extracted from APK/IPA/executable
- Full database access (read/write/delete any data)
- No audit trail (actions not tied to users)
- Privilege escalation attacks possible

### Tables Affected

| Table | Push | Pull | Notes |
|-------|------|------|-------|
| `organizations` | ✅ | ✅ | Commissary creates franchisees |
| `roles` | ✅ | ✅ | System-wide roles |
| `categories` | ✅ | ✅ | Global categories |
| `users` | ✅ | ✅ | Network-wide users |
| `items` | ✅ | ✅ | Master items + branch copies |
| `ingredients` | ✅ | ✅ | Commissary-only |
| `stock_replenishment_requests` | ✅ | ✅ | Cross-org requests |
| `stock_change_requests` | ✅ | ✅ | Franchisee changes |
| `branch_item_stock` | ✅ | ✅ | Branch inventory levels |

---

## 2. Security Architecture Design

### New Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Commissary Flutter App                       │
├─────────────────────────────────────────────────────────────────┤
│  SupabaseClient (anon key) + User Auth Session                  │
│  ↓                                                              │
│  All requests include JWT with auth.uid()                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Supabase Backend                            │
├─────────────────────────────────────────────────────────────────┤
│  RLS Policies check:                                            │
│  - auth.uid() → users.auth_user_id                              │
│  - users.organization_id → commissary org                       │
│  - is_commissary_user() → org.type = 'commissary'               │
│  - is_in_commissary_network(target_org) → parent check          │
└─────────────────────────────────────────────────────────────────┘
```

### Key Functions (from 002_fix_rls_for_branch_operations.sql)

```sql
-- Get current user's organization
get_current_user_organization_id() → UUID

-- Get organization type
get_current_user_organization_type() → 'commissary' | 'franchisee'

-- Check if user is commissary
is_commissary_user() → BOOLEAN

-- Check network membership
is_in_commissary_network(target_org_id UUID) → BOOLEAN
```

---

## 3. RLS Policy Design

### New Policies (003_commissary_rls_policies.sql)

#### Ingredients (Commissary-only CRUD)
```sql
-- Commissary sees all; franchisee sees their commissary's ingredients
CREATE POLICY ingredients_select ON ingredients
    FOR SELECT TO authenticated
    USING (
        CASE 
            WHEN is_commissary_user() THEN true
            ELSE commissary_id = get_parent_commissary_id(get_current_user_organization_id())::text
        END
    );

-- Only commissary can manage
CREATE POLICY ingredients_insert/update/delete ON ingredients
    WITH CHECK (is_commissary_user() AND commissary_id = get_current_user_organization_id()::text);
```

#### Stock Replenishment Requests
```sql
-- Commissary sees requests targeting them; franchisee sees their requests
CREATE POLICY stock_replenishment_requests_select ON stock_replenishment_requests
    FOR SELECT TO authenticated
    USING (
        commissary_id = get_current_user_organization_id()
        OR franchisee_id = get_current_user_organization_id()
    );
```

---

## 4. Migration Strategy

### Phase 1: Database (Run migrations on Supabase)

1. **Apply migration 003_commissary_rls_policies.sql**
   - Run in Supabase SQL Editor
   - Adds policies for: ingredients, stock_replenishment_requests, stock_change_requests, branch_item_stock, recipe_ingredients
   - Enables realtime publication for request tables

2. **Test policies in Supabase Dashboard**
   - Log in as commissary user
   - Verify SELECT/INSERT/UPDATE/DELETE operations work
   - Verify franchisee cannot access commissary-only data

### Phase 2: Client Code

1. **Remove service role key from config**
   - File: `lib/config/supabase_config.dart`
   - Remove `serviceRoleKey` and `hasServiceRoleKey`

2. **Switch to SupabaseSyncServiceV2**
   - New file: `lib/services/supabase_sync_service_v2.dart`
   - Uses SyncEngine pattern with authenticated client
   - No service role client

3. **Update app initialization**
   - Replace old sync service with v2
   - Set organization context after login

4. **Remove service role key from .env**
   ```
   # .env - BEFORE
   SUPABASE_URL=...
   SUPABASE_ANON_KEY=...
   SUPABASE_SERVICE_ROLE_KEY=...  # ← REMOVE THIS

   # .env - AFTER
   SUPABASE_URL=...
   SUPABASE_ANON_KEY=...
   ```

---

## 5. Implementation Steps Completed

### Files Created

| File | Purpose |
|------|---------|
| `supabase/migrations/003_commissary_rls_policies.sql` | RLS policies for remaining tables |
| `supabase/migrations/004_rollback_rls_policies.sql` | Emergency rollback script |
| `lib/services/sync/sync_conflict.dart` | Conflict types and resolution |
| `lib/services/sync/table_sync_descriptor.dart` | Declarative table sync config |
| `lib/services/sync/sync_engine.dart` | Generic push/pull with caching |
| `lib/services/sync/sync.dart` | Barrel export |
| `lib/services/sync/descriptors/*.dart` | 9 table descriptors |
| `lib/services/supabase_sync_service_v2.dart` | New sync service using engine |

### Files Modified

| File | Change |
|------|--------|
| `lib/config/supabase_config.dart` | Removed service role key |
| `lib/services/supabase_sync_service.dart` | Marked as @deprecated |
| `lib/database/daos/roles_dao.dart` | Added upsertFromCloud, upsertBatchFromCloud |
| `lib/database/daos/categories_dao.dart` | Added upsertFromCloud, upsertBatchFromCloud |
| `lib/database/daos/items_dao.dart` | Added upsertFromCloud, upsertBatchFromCloud |
| `lib/database/daos/ingredients_dao.dart` | Added upsertFromCloud, upsertBatchFromCloud |
| `lib/database/daos/recipe_ingredients_dao.dart` | Added getByCloudId, upsertFromCloud, upsertBatchFromCloud |
| `lib/database/daos/stock_change_requests_dao.dart` | Added getRequestByCloudId, upsertFromCloud, upsertBatchFromCloud |
| `lib/database/daos/stock_replenishment_requests_dao.dart` | Added upsertBatchFromCloud |
| `lib/database/daos/branch_item_stock_dao.dart` | Added getByCloudId |
| `lib/database/daos/organizations_dao.dart` | Added getByCloudId alias |

---

## 6. SyncEngine Pattern Benefits

### Before (Old Sync Service)
- ~1,079 lines of repetitive code
- Per-record FK lookups (slow)
- No retry logic
- No conflict detection
- Sequential sync

### After (New SyncEngine)
- ~500 lines with declarative descriptors
- O(1) FK resolution via UUID caching
- Exponential backoff retries
- Status-aware conflict resolution
- Tier-based parallel sync

### Tier-Based Sync Order

```
Tier 1: organizations, roles, categories     (parallel, no deps)
         ↓ rebuild caches
Tier 2: users, items, ingredients            (parallel, depends on Tier 1)
         ↓ rebuild caches
Tier 3: recipe_ingredients, branch_item_stock (parallel, depends on Tier 2)
         ↓ rebuild caches
Tier 4: replenishment_requests, change_requests (parallel, depends on Tier 2/3)
```

---

## 7. WebSocket / Realtime Configuration

### Realtime Publication

The migration adds tables to supabase_realtime publication:

```sql
ALTER PUBLICATION supabase_realtime ADD TABLE stock_replenishment_requests;
ALTER PUBLICATION supabase_realtime ADD TABLE stock_change_requests;
```

### Realtime + RLS

Supabase Realtime respects RLS policies. The commissary will receive realtime events for:
- INSERT on `stock_replenishment_requests` where `commissary_id` matches
- UPDATE on `stock_replenishment_requests` where `commissary_id` matches

---

## 8. Testing & Validation

### Test Cases

| Test | Expected Result |
|------|-----------------|
| Commissary login | Can authenticate and sync |
| Commissary creates item | Pushed to Supabase successfully |
| Commissary pulls franchisee data | Receives all network data |
| Commissary approves request | Status updated, synced |
| Franchisee creates request | Commissary receives realtime event |
| Extract key from APK | No service role key present |

### Verification Commands

```bash
# Test sync after changes
flutter run -d windows

# Check for service role key in compiled app
strings app.exe | grep "service_role"  # Should return nothing
```

---

## 9. Edge Cases & Error Handling

### FK Resolution Failures
- If a foreign key can't be resolved during push, the record is skipped
- Logged with details for debugging
- Record remains in `needsSync = true` state for next sync

### Conflict Resolution
- `lastWriteWins`: Most recent `last_updated` wins
- `statusAware`: More advanced status wins (approved > pending > draft)
- `manual`: Logged for review, local takes precedence

### Offline Scenarios
- App works offline via local Drift database
- Sync automatically triggers when connectivity returns
- `canSync` guard prevents sync without authentication

---

## 10. Rollback Plan

If issues arise after deployment:

### Immediate Rollback (Supabase)
```sql
-- Run 004_rollback_rls_policies.sql
-- This disables RLS on the affected tables
```

### Client Rollback
1. Revert to previous version of app
2. Re-add service role key to .env
3. Switch back to old SupabaseSyncService

### Re-enable Security (After Fix)
```sql
-- Re-run 003_commissary_rls_policies.sql
ALTER TABLE ingredients ENABLE ROW LEVEL SECURITY;
-- etc.
```

---

## 11. Deployment Checklist

- [ ] Run `003_commissary_rls_policies.sql` on Supabase
- [ ] Test policies with commissary user in Supabase Dashboard
- [ ] Remove `SUPABASE_SERVICE_ROLE_KEY` from `.env`
- [ ] Update app to use `SupabaseSyncServiceV2`
- [ ] Test login → sync → operations flow
- [ ] Test realtime notifications
- [ ] Build and deploy updated app
- [ ] Verify no service role key in binary

---

## 12. Free Tier Limitations (Supabase)

| Resource | Limit | Mitigation |
|----------|-------|------------|
| Realtime connections | 200 concurrent | Adaptive polling fallback |
| Database size | 500 MB | Soft delete + periodic cleanup |
| API requests | 2M/month | Batched sync operations |
| Storage | 1 GB | Not used for sync |

The implementation uses adaptive polling (5-30s intervals) as a fallback when realtime is unavailable, which is already in place from the previous implementation.

---

## Summary

This migration:
1. **Removes** the service role key from client code
2. **Adds** RLS policies for remaining tables (ingredients, requests, stock)
3. **Refactors** sync to use authenticated client with SyncEngine pattern
4. **Enables** proper audit trails via `auth.uid()` tracking
5. **Maintains** all existing functionality with better security

The commissary app is now secure by design, with access control enforced at the database level rather than relying on a privileged key that could be compromised.
