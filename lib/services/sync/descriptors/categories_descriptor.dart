// lib/services/sync/descriptors/categories_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for Categories table sync
/// 
/// Tier 1: No FK dependencies
/// Push: Commissary manages categories
/// Pull: Everyone can read categories
final categoriesDescriptor = TableSyncDescriptor(
  tableName: 'categories',
  cloudTableName: 'categories',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 1,
  incrementalSync: false, // Full refresh for FK resolution
  pullLimit: 200,
  softDeleteField: 'is_deleted',
  
  // Commissary manages categories
  canPush: (orgType) => orgType == 'commissary',
  
  // No organization filter - categories are global
  organizationField: null,
  
  foreignKeys: [], // No FKs
  
  fieldMappings: [
    FieldMapping.simple('name', 'name'),
    FieldMapping.simple('description', 'description'),
    FieldMapping.boolean('isDeleted', 'is_deleted'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('updatedAt', 'updated_at'),
  ],
);
