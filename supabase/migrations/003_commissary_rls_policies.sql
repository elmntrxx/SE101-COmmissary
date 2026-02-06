-- ============================================================================
-- COMMISSARY RLS POLICIES - Complete RLS for Service Role Key Removal
-- ============================================================================
-- This migration adds missing RLS policies for tables not covered in
-- 002_fix_rls_for_branch_operations.sql, enabling the commissary app to
-- operate without a service role key.
--
-- Tables covered:
-- - ingredients (commissary-only CRUD)
-- - stock_replenishment_requests (commissary/franchisee based on role)
-- - stock_change_requests (commissary/franchisee based on role)
-- - branch_item_stock (commissary sees network, franchisee sees own)
-- - recipe_ingredients (commissary manages, everyone reads)
--
-- ============================================================================
-- PREREQUISITES:
-- This migration requires that SE_101 migrations have been run first:
-- - 002_star_topology_rls.sql (helper functions)
-- - 008_multi_branch_inventory.sql (branch_item_stock table)
-- 
-- The migration is IDEMPOTENT - safe to run multiple times.
-- Uses DROP POLICY IF EXISTS before CREATE POLICY.
-- ============================================================================

-- ============================================================================
-- PREREQUISITE CHECK: Verify branch_item_stock table exists
-- ============================================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'branch_item_stock') THEN
        RAISE EXCEPTION 'PREREQUISITE FAILED: branch_item_stock table does not exist. Please run SE_101 migration 008_multi_branch_inventory.sql first.';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'is_commissary_user') THEN
        RAISE EXCEPTION 'PREREQUISITE FAILED: is_commissary_user() function does not exist. Please run SE_101 migration 002_star_topology_rls.sql first.';
    END IF;
END $$;

-- ============================================================================
-- INGREDIENTS TABLE RLS
-- Only commissary can manage ingredients
-- Note: commissary_id is stored as TEXT (UUID string)
-- ============================================================================

-- Enable RLS on ingredients
ALTER TABLE ingredients ENABLE ROW LEVEL SECURITY;

-- Drop existing policies (both SE_101 _star_ naming and commissary naming)
DROP POLICY IF EXISTS ingredients_select ON ingredients;
DROP POLICY IF EXISTS ingredients_insert ON ingredients;
DROP POLICY IF EXISTS ingredients_update ON ingredients;
DROP POLICY IF EXISTS ingredients_delete ON ingredients;
-- SE_101 uses _star_ naming convention
DROP POLICY IF EXISTS ingredients_star_select ON ingredients;
DROP POLICY IF EXISTS ingredients_star_insert ON ingredients;
DROP POLICY IF EXISTS ingredients_star_update ON ingredients;
DROP POLICY IF EXISTS ingredients_star_delete ON ingredients;
-- Legacy naming
DROP POLICY IF EXISTS ingredients_select_policy ON ingredients;
DROP POLICY IF EXISTS ingredients_insert_policy ON ingredients;
DROP POLICY IF EXISTS ingredients_update_policy ON ingredients;
DROP POLICY IF EXISTS ingredients_delete_policy ON ingredients;

-- Commissary can see all ingredients; franchisee can see ingredients from their commissary
CREATE POLICY ingredients_select ON ingredients
    FOR SELECT TO authenticated
    USING (
        CASE 
            WHEN is_commissary_user() THEN
                -- Commissary sees all ingredients (they manage them)
                true
            ELSE
                -- Franchisee sees ingredients from their parent commissary
                commissary_id::TEXT = get_parent_commissary_id(get_current_user_organization_id())::TEXT
        END
    );

-- Only commissary can create ingredients
CREATE POLICY ingredients_insert ON ingredients
    FOR INSERT TO authenticated
    WITH CHECK (
        is_commissary_user()
        AND commissary_id::TEXT = get_current_user_organization_id()::TEXT
    );

-- Only commissary can update their ingredients
CREATE POLICY ingredients_update ON ingredients
    FOR UPDATE TO authenticated
    USING (
        is_commissary_user()
        AND commissary_id::TEXT = get_current_user_organization_id()::TEXT
    )
    WITH CHECK (
        is_commissary_user()
        AND commissary_id::TEXT = get_current_user_organization_id()::TEXT
    );

-- Only commissary can delete ingredients
CREATE POLICY ingredients_delete ON ingredients
    FOR DELETE TO authenticated
    USING (
        is_commissary_user()
        AND commissary_id::TEXT = get_current_user_organization_id()::TEXT
    );

-- ============================================================================
-- STOCK_REPLENISHMENT_REQUESTS TABLE RLS
-- Commissary sees requests where they are the target
-- Franchisee sees requests they created
-- Note: commissary_id and franchisee_id are UUIDs stored as TEXT in this table
-- ============================================================================

-- Enable RLS
ALTER TABLE stock_replenishment_requests ENABLE ROW LEVEL SECURITY;

-- Drop existing policies (all naming conventions)
DROP POLICY IF EXISTS stock_replenishment_requests_select ON stock_replenishment_requests;
DROP POLICY IF EXISTS stock_replenishment_requests_insert ON stock_replenishment_requests;
DROP POLICY IF EXISTS stock_replenishment_requests_update ON stock_replenishment_requests;
DROP POLICY IF EXISTS stock_replenishment_requests_delete ON stock_replenishment_requests;
-- SE_101 uses _star_ naming
DROP POLICY IF EXISTS replenishment_star_select ON stock_replenishment_requests;
DROP POLICY IF EXISTS replenishment_star_insert ON stock_replenishment_requests;
DROP POLICY IF EXISTS replenishment_star_update ON stock_replenishment_requests;
DROP POLICY IF EXISTS replenishment_star_delete ON stock_replenishment_requests;
-- Legacy naming
DROP POLICY IF EXISTS replenishment_select_policy ON stock_replenishment_requests;
DROP POLICY IF EXISTS replenishment_insert_policy ON stock_replenishment_requests;
DROP POLICY IF EXISTS replenishment_update_policy ON stock_replenishment_requests;
DROP POLICY IF EXISTS replenishment_delete_policy ON stock_replenishment_requests;

-- Both commissary and franchisee can see their relevant requests
CREATE POLICY stock_replenishment_requests_select ON stock_replenishment_requests
    FOR SELECT TO authenticated
    USING (
        -- Commissary sees requests targeting them (compare as TEXT)
        commissary_id::TEXT = get_current_user_organization_id()::TEXT
        -- Franchisee sees requests they created
        OR franchisee_id::TEXT = get_current_user_organization_id()::TEXT
    );

-- Franchisee can create requests to their commissary
CREATE POLICY stock_replenishment_requests_insert ON stock_replenishment_requests
    FOR INSERT TO authenticated
    WITH CHECK (
        -- Franchisee creates request from their org to their commissary
        (NOT is_commissary_user() 
            AND franchisee_id::TEXT = get_current_user_organization_id()::TEXT
            AND commissary_id::TEXT = get_parent_commissary_id(get_current_user_organization_id())::TEXT)
        -- Commissary can also create requests (for testing/manual entry)
        OR (is_commissary_user() AND commissary_id::TEXT = get_current_user_organization_id()::TEXT)
    );

-- Commissary can update (approve/reject) requests targeting them
-- Franchisee can update their pending requests (e.g., cancel)
CREATE POLICY stock_replenishment_requests_update ON stock_replenishment_requests
    FOR UPDATE TO authenticated
    USING (
        -- Commissary can update requests they received
        (is_commissary_user() AND commissary_id::TEXT = get_current_user_organization_id()::TEXT)
        -- Franchisee can update their own pending requests
        OR (NOT is_commissary_user() AND franchisee_id::TEXT = get_current_user_organization_id()::TEXT)
    )
    WITH CHECK (
        (is_commissary_user() AND commissary_id::TEXT = get_current_user_organization_id()::TEXT)
        OR (NOT is_commissary_user() AND franchisee_id::TEXT = get_current_user_organization_id()::TEXT)
    );

-- Soft delete via is_deleted flag - same rules as update
CREATE POLICY stock_replenishment_requests_delete ON stock_replenishment_requests
    FOR DELETE TO authenticated
    USING (
        (is_commissary_user() AND commissary_id::TEXT = get_current_user_organization_id()::TEXT)
        OR (NOT is_commissary_user() AND franchisee_id::TEXT = get_current_user_organization_id()::TEXT)
    );

-- ============================================================================
-- STOCK_CHANGE_REQUESTS TABLE RLS
-- Franchisee creates change requests, commissary can view all in network
-- Note: franchisee_id is UUID stored as TEXT
-- ============================================================================

-- Enable RLS
ALTER TABLE stock_change_requests ENABLE ROW LEVEL SECURITY;

-- Drop existing policies (all naming conventions)
DROP POLICY IF EXISTS stock_change_requests_select ON stock_change_requests;
DROP POLICY IF EXISTS stock_change_requests_insert ON stock_change_requests;
DROP POLICY IF EXISTS stock_change_requests_update ON stock_change_requests;
DROP POLICY IF EXISTS stock_change_requests_delete ON stock_change_requests;
-- SE_101 uses _star_ naming
DROP POLICY IF EXISTS stock_changes_star_select ON stock_change_requests;
DROP POLICY IF EXISTS stock_changes_star_insert ON stock_change_requests;
DROP POLICY IF EXISTS stock_changes_star_update ON stock_change_requests;
DROP POLICY IF EXISTS stock_changes_star_delete ON stock_change_requests;
-- Legacy naming
DROP POLICY IF EXISTS stock_changes_select_policy ON stock_change_requests;
DROP POLICY IF EXISTS stock_changes_insert_policy ON stock_change_requests;
DROP POLICY IF EXISTS stock_changes_update_policy ON stock_change_requests;
DROP POLICY IF EXISTS stock_changes_delete_policy ON stock_change_requests;

-- Commissary sees all change requests from their franchisees
-- Franchisee sees their own change requests
CREATE POLICY stock_change_requests_select ON stock_change_requests
    FOR SELECT TO authenticated
    USING (
        -- Commissary sees change requests from their network
        (is_commissary_user() AND is_in_commissary_network(franchisee_id::UUID))
        -- Franchisee sees their own requests
        OR (NOT is_commissary_user() AND franchisee_id::TEXT = get_current_user_organization_id()::TEXT)
    );

-- Franchisee can create change requests for their stock
CREATE POLICY stock_change_requests_insert ON stock_change_requests
    FOR INSERT TO authenticated
    WITH CHECK (
        NOT is_commissary_user() 
        AND franchisee_id::TEXT = get_current_user_organization_id()::TEXT
    );

-- Both can update (franchisee edits pending, commissary reviews)
CREATE POLICY stock_change_requests_update ON stock_change_requests
    FOR UPDATE TO authenticated
    USING (
        (is_commissary_user() AND is_in_commissary_network(franchisee_id::UUID))
        OR (NOT is_commissary_user() AND franchisee_id::TEXT = get_current_user_organization_id()::TEXT)
    )
    WITH CHECK (
        (is_commissary_user() AND is_in_commissary_network(franchisee_id::UUID))
        OR (NOT is_commissary_user() AND franchisee_id::TEXT = get_current_user_organization_id()::TEXT)
    );

-- Soft delete follows update rules
CREATE POLICY stock_change_requests_delete ON stock_change_requests
    FOR DELETE TO authenticated
    USING (
        (is_commissary_user() AND is_in_commissary_network(franchisee_id::UUID))
        OR (NOT is_commissary_user() AND franchisee_id::TEXT = get_current_user_organization_id()::TEXT)
    );

-- ============================================================================
-- BRANCH_ITEM_STOCK TABLE RLS
-- Commissary sees all branch stock in their network
-- Franchisee sees their own branch stock
-- ============================================================================

-- Enable RLS (table created by SE_101 008_multi_branch_inventory.sql)
ALTER TABLE branch_item_stock ENABLE ROW LEVEL SECURITY;

-- Drop existing policies (all naming conventions)
DROP POLICY IF EXISTS branch_item_stock_select ON branch_item_stock;
DROP POLICY IF EXISTS branch_item_stock_insert ON branch_item_stock;
DROP POLICY IF EXISTS branch_item_stock_update ON branch_item_stock;
DROP POLICY IF EXISTS branch_item_stock_delete ON branch_item_stock;
-- SE_101 named policies from 008_multi_branch_inventory.sql
DROP POLICY IF EXISTS "branch_item_stock_select" ON branch_item_stock;
DROP POLICY IF EXISTS "branch_item_stock_insert" ON branch_item_stock;
DROP POLICY IF EXISTS "branch_item_stock_update" ON branch_item_stock;
DROP POLICY IF EXISTS "branch_item_stock_delete" ON branch_item_stock;

-- Commissary sees all branch stock in network; franchisee sees own
CREATE POLICY branch_item_stock_select ON branch_item_stock
    FOR SELECT TO authenticated
    USING (
        (is_commissary_user() AND is_in_commissary_network(organization_id::UUID))
        OR (NOT is_commissary_user() AND organization_id = get_current_user_organization_id()::TEXT)
    );

-- Both can insert stock records for their own organization
CREATE POLICY branch_item_stock_insert ON branch_item_stock
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = get_current_user_organization_id()::TEXT
    );

-- Both can update their own stock records
CREATE POLICY branch_item_stock_update ON branch_item_stock
    FOR UPDATE TO authenticated
    USING (organization_id = get_current_user_organization_id()::TEXT)
    WITH CHECK (organization_id = get_current_user_organization_id()::TEXT);

-- Soft delete for own organization
CREATE POLICY branch_item_stock_delete ON branch_item_stock
    FOR DELETE TO authenticated
    USING (organization_id = get_current_user_organization_id()::TEXT);

-- ============================================================================
-- RECIPE_INGREDIENTS TABLE RLS (if exists)
-- Commissary manages recipes; everyone can read
-- ============================================================================

DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'recipe_ingredients') THEN
        -- Enable RLS
        EXECUTE 'ALTER TABLE recipe_ingredients ENABLE ROW LEVEL SECURITY';
        
        -- Drop existing policies (all naming conventions)
        DROP POLICY IF EXISTS recipe_ingredients_select ON recipe_ingredients;
        DROP POLICY IF EXISTS recipe_ingredients_insert ON recipe_ingredients;
        DROP POLICY IF EXISTS recipe_ingredients_update ON recipe_ingredients;
        DROP POLICY IF EXISTS recipe_ingredients_delete ON recipe_ingredients;
        -- SE_101 uses _star_ naming
        DROP POLICY IF EXISTS recipe_ingredients_star_select ON recipe_ingredients;
        DROP POLICY IF EXISTS recipe_ingredients_star_insert ON recipe_ingredients;
        DROP POLICY IF EXISTS recipe_ingredients_star_update ON recipe_ingredients;
        DROP POLICY IF EXISTS recipe_ingredients_star_delete ON recipe_ingredients;
        -- Legacy naming
        DROP POLICY IF EXISTS recipe_ingredients_select_policy ON recipe_ingredients;
        DROP POLICY IF EXISTS recipe_ingredients_insert_policy ON recipe_ingredients;
        DROP POLICY IF EXISTS recipe_ingredients_update_policy ON recipe_ingredients;
        DROP POLICY IF EXISTS recipe_ingredients_delete_policy ON recipe_ingredients;
        
        -- Everyone can read recipes
        EXECUTE 'CREATE POLICY recipe_ingredients_select ON recipe_ingredients FOR SELECT TO authenticated USING (true)';
        
        -- Only commissary can manage recipes
        EXECUTE 'CREATE POLICY recipe_ingredients_insert ON recipe_ingredients FOR INSERT TO authenticated WITH CHECK (is_commissary_user())';
        EXECUTE 'CREATE POLICY recipe_ingredients_update ON recipe_ingredients FOR UPDATE TO authenticated USING (is_commissary_user())';
        EXECUTE 'CREATE POLICY recipe_ingredients_delete ON recipe_ingredients FOR DELETE TO authenticated USING (is_commissary_user())';
    END IF;
END $$;

-- ============================================================================
-- REALTIME PUBLICATION
-- Ensure tables are enabled for realtime (required for WebSocket subscriptions)
-- ============================================================================

-- Check and add tables to realtime publication if not already added
DO $$ 
BEGIN
    -- stock_replenishment_requests (critical for request notifications)
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
        AND tablename = 'stock_replenishment_requests'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE stock_replenishment_requests;
    END IF;
    
    -- stock_change_requests
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
        AND tablename = 'stock_change_requests'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE stock_change_requests;
    END IF;
EXCEPTION 
    WHEN undefined_object THEN
        -- Publication doesn't exist, skip
        NULL;
END $$;

-- ============================================================================
-- SUMMARY
-- ============================================================================
-- 
-- INGREDIENTS:
--   - SELECT: Commissary all; Franchisee their commissary's ingredients
--   - INSERT/UPDATE/DELETE: Commissary only
--
-- STOCK_REPLENISHMENT_REQUESTS:
--   - SELECT: Commissary where commissary_id=self; Franchisee where franchisee_id=self
--   - INSERT: Franchisee to their commissary; Commissary for manual entry
--   - UPDATE: Commissary approves/rejects; Franchisee edits pending
--   - DELETE: Same as update (soft delete)
--
-- STOCK_CHANGE_REQUESTS:
--   - SELECT: Commissary sees network; Franchisee sees own
--   - INSERT: Franchisee only
--   - UPDATE/DELETE: Commissary for network; Franchisee for own
--
-- BRANCH_ITEM_STOCK:
--   - SELECT: Commissary sees network; Franchisee sees own
--   - INSERT/UPDATE/DELETE: Own organization only
--
-- RECIPE_INGREDIENTS:
--   - SELECT: Everyone
--   - INSERT/UPDATE/DELETE: Commissary only
--
-- ============================================================================
