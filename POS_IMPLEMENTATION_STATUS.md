# POS Implementation Status

## ✅ Completed (Commissary App)

### Step 2: Data Model for POS - DONE ✅

1. **DailySalesSummary Drift Table** ✅
   - File: `lib/database/tables/daily_sales_summary.dart`
   - All required columns matching Supabase schema
   - Unique constraint on `(organization_id, item_id, summary_date)`
   - cloud_id as TEXT UUID for sync
   
2. **DailySalesSummary DAO** ✅
   - File: `lib/database/daos/daily_sales_summary_dao.dart`
   - Complete CRUD operations
   - `recordSale()` method for POS integration
   - `recordSpoilage()` method for spoilage tracking
   - Sync methods: `upsertFromCloud()`, `markAsSynced()`, `getUnsyncedSummaries()`
   - Query methods for reporting by date range
   
3. **Database Migration to v3** ✅
   - Updated `app_database.dart` schema version: 2 → 3
   - Added DailySalesSummary table and DAO to database
   - Created indexes for optimal query performance:
     - `idx_daily_sales_org_date`
     - `idx_daily_sales_item_date`
     - `idx_daily_sales_date`

4. **DailySalesSummary Sync Descriptor** ✅
   - File: `lib/services/sync/descriptors/daily_sales_summary_descriptor.dart`
   - All field mappings configured
   - Foreign key mappings for organizationId and itemId
   - Registered in sync barrel file

5. **Sync Integration** ✅
   - Added `_syncDailySalesSummary()` method to `supabase_sync_service_v2.dart`
   - Integrated into Tier 3 sync alongside branch_item_stock
   - Added to UUID cache initialization
   - Push and pull operations configured

## 🚧 In Progress / Next Steps

### Priority 1: Fix Schema Mismatches (Critical for Sync)

#### Step 1.1: Fix branch_item_stock Schema Alignment
**Current Issue**: Local uses `IntColumn` for `organizationId`/`itemId`, but Supabase uses TEXT UUIDs.

**Files to update**:
- `lib/database/tables/branch_item_stock.dart` (Commissary)
- `SE_101/lib/database/tables/branch_item_stock.dart` (Franchisee)

**Changes needed**:
```dart
// Current (WRONG):
IntColumn get organizationId => integer().references(Organizations, #id)();
IntColumn get itemId => integer().references(Items, #id)();

// Should be (CORRECT):
TextColumn get organizationId => text()();
TextColumn get itemId => text()();

// Optional: Add local FK columns for joins if needed
IntColumn get localOrganizationId => integer().nullable()();
IntColumn get localItemId => integer().nullable()();
```

**Impact**: This is a **breaking schema change**. Need migration strategy:
- Option A: Drop and recreate table (lose local data, re-sync from cloud)
- Option B: Add new columns, migrate data, drop old columns (complex but preserves data)

**Recommended**: Option A for simplicity since this is still in development.

#### Step 1.2: Fix branch_stock_descriptor Mappings
**File**: `lib/services/sync/descriptors/branch_stock_descriptor.dart`

Ensure field mappings handle TEXT UUIDs ↔ local integer ID resolution.

### Priority 3: Franchisee App (SE_101) - POS Implementation

#### Step 3: Implement POS Service
**File to create**: `SE_101/lib/services/pos_service.dart`

Key methods:
```dart
class POSService {
  Future<void> recordSale({
    required String organizationId,
    required String itemId,
    required int quantity,
  });
  
  Future<void> recordSpoilage({
    required String organizationId,
    required String itemId,
    required int quantity,
  });
}
```

Logic:
1. Get branch_item_stock row
2. Validate stock availability
3. Get effective price/cost (COALESCE branch price, item price)
4. **Transaction**:
   - Update branch_item_stock (stock, sold/spoilage)
   - Upsert daily_sales_summary
5. Mark dirty for sync

#### Step 4: Create POS UI
**Files to create**:
- `SE_101/lib/screens/pos/pos_screen.dart`
- `SE_101/lib/screens/pos/widgets/...` (optional)

UI Requirements:
- Item selector (from branch stock)
- Quantity input
- "Record Sale" button
- "Record Spoilage" button
- Current stock display
- Today's summary (optional)

### Priority 4: Commissary Reports Update

#### Step 5: Update reports_page.dart
**File**: `lib/screens/reports/reports_page.dart`

**Changes**:
1. Replace local `branch_item_stock.sold/spoilage` computation
2. Add `ReportsService` to query Supabase views:
   - `network_daily_sales` view
   - `branch_sales_summary` view
   - `daily_sales_summary` table
3. Wire date range picker to queries
4. Display metrics:
   - Total sales (sum revenue)
   - Total profit (sum gross_profit)
   - Total spoilage (sum quantity_spoiled)
   - Per-branch breakdown

**Create**: `lib/services/reports_service.dart`

### Priority 5: Testing

#### Step 6: Add Contract Tests
**File to create**: `test/sync/pos_sync_contract_test.dart`

Test scenarios:
- branch_item_stock sync with TEXT UUIDs
- daily_sales_summary sync round-trip
- Offline multi-day scenario
- Price change while offline
- Cloud_id collision handling

## Database Schema Status

### Commissary App (SE101-COmmissary)
- ✅ Schema version: 3
- ✅ DailySalesSummary table exists
- ⚠️ BranchItemStock table uses INTEGER FKs (needs TEXT update)

### Franchisee App (SE_101)
- ❓ Schema version: (unknown, needs check)
- ❓ DailySalesSummary table: needs to be added
- ⚠️ BranchItemStock table: needs TEXT FK update

### Supabase Cloud
- ✅ daily_sales_summary table exists (migration 005)
- ✅ branch_item_stock table exists (migration 008)
- ✅ Views exist:
  - network_daily_sales
  - branch_sales_summary
- ✅ RLS policies configured

## Code Generation Required

After schema changes, run:
```bash
# In commissary app
cd C:\RJ\Coding\FlutterProjects\SE101-COmmissary
dart run build_runner build --delete-conflicting-outputs

# In franchisee app
cd C:\RJ\Coding\FlutterProjects\SE_101
dart run build_runner build --delete-conflicting-outputs
```

## Critical Path to MVP

1. **Fix branch_item_stock schema** (both apps) - Required for all sync
2. **Create daily_sales_summary descriptor** (commissary) - Required for POS sync
3. **Copy daily_sales_summary table/DAO to franchisee app** - Required for POS
4. **Implement POS service** (franchisee app) - Core POS logic
5. **Create simple POS UI** (franchisee app) - User interaction
6. **Update reports page** (commissary app) - Visibility
7. **Test end-to-end** - Validation

## Estimated Effort

- Remaining work: ~16-20 hours of development
  - Schema fixes: 2-3 hours
  - Descriptors: 2-3 hours
  - POS service: 3-4 hours
  - POS UI: 4-5 hours
  - Reports update: 2-3 hours
  - Testing: 3-4 hours

## Key Design Decisions Implemented

1. ✅ Daily sales summary uses date-only (midnight UTC) for consistency
2. ✅ Opening/closing stock tracked for reconciliation
3. ✅ Revenue/cost computed at sale time (never recomputed)
4. ✅ Spoilage tracked separately, doesn't count as transaction
5. ✅ Cloud_id generated once, reused on updates (stable identity)
6. ✅ Upsert logic protects local unsynced changes
7. ✅ Stock transfers do NOT update daily_sales_summary

## Files Created (This Session)

1. `lib/database/tables/daily_sales_summary.dart` - Table definition
2. `lib/database/daos/daily_sales_summary_dao.dart` - DAO with business logic
3. `lib/database/app_database.dart` - Updated (schema v3, migration added)
4. `lib/services/sync/descriptors/daily_sales_summary_descriptor.dart` - Sync descriptor
5. `lib/services/sync/sync.dart` - Updated (exported new descriptor)
6. `lib/services/supabase_sync_service_v2.dart` - Updated (added sync method)
7. `POS_IMPLEMENTATION_STATUS.md` - This file

## Next Agent Instructions

If another agent continues this work:

1. Start with Priority 1 (create sync descriptor)
2. Then tackle Priority 2 (fix schema mismatches) - this requires careful migration
3. Copy daily_sales_summary files to SE_101 app
4. Implement POS service and UI in SE_101
5. Update commissary reports

See `FinalPOSImplementation.md` for the full specification.

## Questions / Decisions Needed

1. **Schema migration strategy**: Drop-recreate vs. data-preserving migration for branch_item_stock?
2. **Franchisee app status**: What's the current schema version? Does it already have POS prep work?
3. **Deployment**: Test branches first, or full rollout?
4. **Backfill**: Do we need to backfill historical sold/spoilage data into daily_sales_summary?
