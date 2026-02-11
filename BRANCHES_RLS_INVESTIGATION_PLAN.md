# Branches/Branch Admins Not Showing  Investigation & Fix Plan

## Context
The Branches page pulls data from the local Drift DB:
- Commissary org: `organizationsDao.getCommissary()`
- Branches: `organizationsDao.getFranchisees(commissary.cloudId)`
- Branch admins: `usersDao.getUsersByOrganization(branch.id)`

If local orgs or users arent present (or parent IDs dont match), the page shows nothing.

## Likely Causes (ranked)
1. Parent commissary ID mapping bug
- `organizationsDescriptor` treats `parentCommissaryId` as a foreign key and converts UUID  local int.
- Local `parentCommissaryId` column is `TEXT` (expects UUID), so comparisons against `commissary.cloudId` fail.
2. Organizations push drops parent ID
- `_syncOrganizations` sets `parentCommissaryId: null` in the push map, so cloud records may lose parent linkage.
3. RLS blocks organizations/users pull
- If `users.auth_user_id` is NULL or email mismatch, helper functions may return NULL and RLS denies reads.
4. Schema mismatch: `last_updated` vs `updated_at`
- Pull queries filter on `last_updated`, but some migrations only add `updated_at`.

## Investigation Steps
1. Check local DB contents
- Verify commissary exists locally and branches have matching `parent_commissary_id`.
- Queries (local `inventory.db`):
- `SELECT id, cloud_id, type, parent_commissary_id FROM organizations;`
- `SELECT id, cloud_id, organization_id, role_id FROM users;`
2. Confirm cloud schema fields
- In Supabase SQL editor, verify `organizations.last_updated` exists and is updated.
- Confirm `parent_commissary_id` is populated for franchisees.
3. Validate RLS for commissary
- Ensure the logged-in user row has `auth_user_id` or email set.
- Check `is_commissary_user()` returns true for the commissary account.
4. Check sync logs
- Confirm `organizations` and `users` pull counts are non-zero during full sync.

## Proposed Fixes (if confirmed)
1. Fix org parent mapping
- Remove FK mapping for `parentCommissaryId` in `organizationsDescriptor`.
- Add `FieldMapping.simple('parentCommissaryId', 'parent_commissary_id')`.
2. Fix org push data
- In `_syncOrganizations`, send `parentCommissaryId: org.parentCommissaryId` instead of `null`.
3. Align sync timestamps
- If cloud uses `updated_at` only, update pull query or add `last_updated` column/trigger in Supabase.

## Validation Checklist
1. Full sync completes with non-zero `organizations`/`users` pulled.
2. Local DB shows franchisees with `parent_commissary_id == commissary.cloud_id`.
3. Branches page shows branches and admins.
