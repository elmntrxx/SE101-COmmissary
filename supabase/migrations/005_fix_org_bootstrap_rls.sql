-- ============================================================================
-- FIX ORGANIZATION BOOTSTRAP RLS - Allow login after fresh install
-- ============================================================================
-- This migration fixes a circular dependency in the organizations RLS policy
-- that prevented users from logging in after deleting their local database.
--
-- Problem:
-- 1. User authenticates with Supabase Auth
-- 2. App tries to pull user's organization from cloud
-- 3. organizations_star_select policy calls is_commissary_user()
-- 4. is_commissary_user() needs to query organizations to check type
-- 5. But we can't read organizations yet (circular dependency)
-- 6. Result: "Organization not found in cloud" error
--
-- ROOT CAUSE:
-- The helper functions only check auth_user_id = auth.uid(), but if the user
-- record was created before Supabase Auth integration, auth_user_id is NULL!
-- The users RLS has email fallback, but the helper functions didn't.
--
-- Solution:
-- 1. Fix helper functions to use email as fallback (like users RLS does)
-- 2. Add bootstrap clause to organizations policy
-- ============================================================================

-- ============================================================================
-- STEP 1: Fix helper functions to use email as fallback
-- ============================================================================

-- Function to get current user's organization_id (with email fallback)
CREATE OR REPLACE FUNCTION get_current_user_organization_id()
RETURNS UUID AS $$
DECLARE
    org_id UUID;
BEGIN
    -- Try auth_user_id first, then email as fallback
    SELECT organization_id INTO org_id
    FROM users
    WHERE auth_user_id = auth.uid()
       OR email = auth.email()
    LIMIT 1;
    RETURN org_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Function to get current user's organization type (with email fallback)
CREATE OR REPLACE FUNCTION get_current_user_organization_type()
RETURNS TEXT AS $$
DECLARE
    org_type TEXT;
BEGIN
    SELECT o.type INTO org_type
    FROM users u
    JOIN organizations o ON u.organization_id = o.cloud_id
    WHERE u.auth_user_id = auth.uid()
       OR u.email = auth.email()
    LIMIT 1;
    RETURN org_type;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ============================================================================
-- STEP 2: Fix organizations select policy with bootstrap clause
-- ============================================================================

DROP POLICY IF EXISTS organizations_star_select ON organizations;

CREATE POLICY organizations_star_select ON organizations
    FOR SELECT TO authenticated
    USING (
        -- BOOTSTRAP: Always allow user to read their own organization (for login flow)
        -- Uses email fallback in case auth_user_id is not yet set
        cloud_id = (
            SELECT organization_id FROM users 
            WHERE auth_user_id = auth.uid() OR email = auth.email() 
            LIMIT 1
        )
        -- Normal role-based visibility
        OR CASE 
            WHEN is_commissary_user() THEN
                -- Commissary sees: self + all child franchisees
                cloud_id = get_current_user_organization_id()
                OR parent_commissary_id = get_current_user_organization_id()
            ELSE
                -- Franchisee sees: self + parent commissary
                cloud_id = get_current_user_organization_id()
                OR cloud_id = get_parent_commissary_id(get_current_user_organization_id())
        END
    );

-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- After running this migration:
-- 1. Delete local database (if needed)
-- 2. Restart app
-- 3. Login should work - user's org will be pulled from cloud
-- ============================================================================
