// lib/services/sync/descriptors/users_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for Users table sync
/// 
/// Tier 2: Depends on Organizations, Roles
/// Push: Commissary can create/manage users in network
/// Pull: Commissary sees all users in network
final usersDescriptor = TableSyncDescriptor(
  tableName: 'users',
  cloudTableName: 'users',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 2,
  incrementalSync: false, // Full refresh
  pullLimit: 500,
  
  // Commissary can manage users
  canPush: (orgType) => orgType == 'commissary',
  
  // No organization filter - commissary sees all in network
  organizationField: null,
  
  foreignKeys: [
    ForeignKeyMapping(
      localField: 'organizationId',
      cloudField: 'organization_id',
      referenceTable: 'organizations',
      required: true,
      cloudUsesUuid: true,
    ),
    ForeignKeyMapping(
      localField: 'roleId',
      cloudField: 'role_id',
      referenceTable: 'roles',
      required: true,
      cloudUsesUuid: true,
    ),
  ],
  
  fieldMappings: [
    FieldMapping.simple('email', 'email'),
    FieldMapping.simple('username', 'username'),
    FieldMapping.simple('authUserId', 'auth_user_id'),
    FieldMapping.simple('passwordHash', 'password'),
    FieldMapping.boolean('isActive', 'is_active'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('updatedAt', 'last_updated'),
  ],
);
