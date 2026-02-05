// lib/services/sync/descriptors/ingredients_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for Ingredients table sync
/// 
/// Tier 2: Depends on Organizations
/// Push: Commissary manages ingredients
/// Pull: Commissary sees all ingredients
final ingredientsDescriptor = TableSyncDescriptor(
  tableName: 'ingredients',
  cloudTableName: 'ingredients',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 2,
  incrementalSync: false, // Full refresh
  pullLimit: 500,
  
  // Commissary manages ingredients
  canPush: (orgType) => orgType == 'commissary',
  
  // No organization filter
  organizationField: null,
  
  foreignKeys: [
    ForeignKeyMapping(
      localField: 'commissaryId',
      cloudField: 'commissary_id',
      referenceTable: 'organizations',
      required: true,
      cloudUsesUuid: true,
    ),
  ],
  
  fieldMappings: [
    FieldMapping.simple('name', 'name'),
    FieldMapping.simple('unit', 'unit'),
    FieldMapping.real('stock', 'stock'),
    FieldMapping.real('criticalLevel', 'critical_level'),
    FieldMapping.real('costPerUnit', 'cost_per_unit'),
    FieldMapping.boolean('isActive', 'is_active'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('updatedAt', 'last_updated'),
  ],
);
