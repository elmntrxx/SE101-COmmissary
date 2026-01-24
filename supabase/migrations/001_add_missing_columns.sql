-- ============================================================================
-- ADD MISSING COLUMNS TO MATCH LOCAL DRIFT SCHEMA
-- Run this on your Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- ORGANIZATIONS TABLE - Add missing columns
-- ============================================================================
ALTER TABLE organizations 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS last_synced_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS needs_sync BOOLEAN DEFAULT TRUE;

-- ============================================================================
-- ROLES TABLE - Add missing columns
-- ============================================================================
ALTER TABLE roles 
ADD COLUMN IF NOT EXISTS can_manage_branches BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS last_synced_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS needs_sync BOOLEAN DEFAULT TRUE;

-- ============================================================================
-- USERS TABLE - Add missing columns
-- ============================================================================
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS password_hash TEXT,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS last_synced_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS needs_sync BOOLEAN DEFAULT TRUE;

-- ============================================================================
-- CATEGORIES TABLE - Add missing columns (if exists)
-- ============================================================================
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'categories') THEN
        ALTER TABLE categories 
        ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW(),
        ADD COLUMN IF NOT EXISTS last_synced_at TIMESTAMPTZ,
        ADD COLUMN IF NOT EXISTS needs_sync BOOLEAN DEFAULT TRUE;
    END IF;
END $$;

-- ============================================================================
-- ITEMS TABLE - Add missing columns (if exists)
-- ============================================================================
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'items') THEN
        ALTER TABLE items 
        ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW(),
        ADD COLUMN IF NOT EXISTS last_synced_at TIMESTAMPTZ,
        ADD COLUMN IF NOT EXISTS needs_sync BOOLEAN DEFAULT TRUE;
    END IF;
END $$;

-- ============================================================================
-- INGREDIENTS TABLE - Add missing columns (if exists)
-- ============================================================================
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ingredients') THEN
        ALTER TABLE ingredients 
        ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW(),
        ADD COLUMN IF NOT EXISTS last_synced_at TIMESTAMPTZ,
        ADD COLUMN IF NOT EXISTS needs_sync BOOLEAN DEFAULT TRUE;
    END IF;
END $$;

-- ============================================================================
-- Create updated_at trigger function
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- Apply triggers to auto-update updated_at
-- ============================================================================
DROP TRIGGER IF EXISTS update_organizations_updated_at ON organizations;
CREATE TRIGGER update_organizations_updated_at
    BEFORE UPDATE ON organizations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_roles_updated_at ON roles;
CREATE TRIGGER update_roles_updated_at
    BEFORE UPDATE ON roles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- DONE - Refresh schema cache
-- ============================================================================
-- After running this, you may need to:
-- 1. Go to Supabase Dashboard > Settings > API
-- 2. Click "Reload Schema" or wait a few minutes for cache to refresh
