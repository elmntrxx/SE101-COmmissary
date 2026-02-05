-- ============================================================================
-- ROLLBACK: Commissary RLS Policies
-- ============================================================================
-- Run this if you need to revert the RLS changes from 003_commissary_rls_policies.sql
-- This disables RLS and drops the policies, allowing unrestricted access.
--
-- ⚠️ WARNING: Only run this in emergency situations. This will remove
-- security controls from your database.
-- ============================================================================

-- INGREDIENTS
DROP POLICY IF EXISTS ingredients_select ON ingredients;
DROP POLICY IF EXISTS ingredients_insert ON ingredients;
DROP POLICY IF EXISTS ingredients_update ON ingredients;
DROP POLICY IF EXISTS ingredients_delete ON ingredients;
ALTER TABLE ingredients DISABLE ROW LEVEL SECURITY;

-- STOCK_REPLENISHMENT_REQUESTS
DROP POLICY IF EXISTS stock_replenishment_requests_select ON stock_replenishment_requests;
DROP POLICY IF EXISTS stock_replenishment_requests_insert ON stock_replenishment_requests;
DROP POLICY IF EXISTS stock_replenishment_requests_update ON stock_replenishment_requests;
DROP POLICY IF EXISTS stock_replenishment_requests_delete ON stock_replenishment_requests;
ALTER TABLE stock_replenishment_requests DISABLE ROW LEVEL SECURITY;

-- STOCK_CHANGE_REQUESTS
DROP POLICY IF EXISTS stock_change_requests_select ON stock_change_requests;
DROP POLICY IF EXISTS stock_change_requests_insert ON stock_change_requests;
DROP POLICY IF EXISTS stock_change_requests_update ON stock_change_requests;
DROP POLICY IF EXISTS stock_change_requests_delete ON stock_change_requests;
ALTER TABLE stock_change_requests DISABLE ROW LEVEL SECURITY;

-- BRANCH_ITEM_STOCK
DROP POLICY IF EXISTS branch_item_stock_select ON branch_item_stock;
DROP POLICY IF EXISTS branch_item_stock_insert ON branch_item_stock;
DROP POLICY IF EXISTS branch_item_stock_update ON branch_item_stock;
DROP POLICY IF EXISTS branch_item_stock_delete ON branch_item_stock;
ALTER TABLE branch_item_stock DISABLE ROW LEVEL SECURITY;

-- RECIPE_INGREDIENTS (if exists)
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'recipe_ingredients') THEN
        DROP POLICY IF EXISTS recipe_ingredients_select ON recipe_ingredients;
        DROP POLICY IF EXISTS recipe_ingredients_insert ON recipe_ingredients;
        DROP POLICY IF EXISTS recipe_ingredients_update ON recipe_ingredients;
        DROP POLICY IF EXISTS recipe_ingredients_delete ON recipe_ingredients;
        EXECUTE 'ALTER TABLE recipe_ingredients DISABLE ROW LEVEL SECURITY';
    END IF;
END $$;

-- ============================================================================
-- NOTE: This does NOT rollback the policies from 002_fix_rls_for_branch_operations.sql
-- Those policies (organizations, roles, users, items, categories) remain intact.
-- ============================================================================
