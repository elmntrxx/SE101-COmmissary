// lib/services/sync/descriptors/roles_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for Roles table sync
/// 
/// Tier 1: No FK dependencies
/// Push: Commissary can manage roles
/// Pull: Everyone can read roles
final rolesDescriptor = TableSyncDescriptor(
  tableName: 'roles',
  cloudTableName: 'roles',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 1,
  incrementalSync: false, // Full refresh for FK resolution
  pullLimit: 100,
  
  // Commissary manages roles
  canPush: (orgType) => orgType == 'commissary',
  
  // No organization filter - roles are global
  organizationField: null,
  
  foreignKeys: [], // No FKs
  
  fieldMappings: [
    FieldMapping.simple('name', 'name'),
    FieldMapping.simple('description', 'description'),
    FieldMapping.boolean('canViewInventory', 'can_view_inventory'),
    FieldMapping.boolean('canManageInventory', 'can_manage_inventory'),
    FieldMapping.boolean('canManageUsers', 'can_manage_employees'),
    FieldMapping.boolean('canManageRoles', 'can_manage_roles'),
    FieldMapping.boolean('canViewReports', 'can_view_reports'),
    FieldMapping.boolean('canManageBranches', 'can_manage_branches'),
    FieldMapping.boolean('isSystemRole', 'is_system_role'),
    FieldMapping.boolean('isActive', 'is_active'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('updatedAt', 'last_updated'),
  ],
);
