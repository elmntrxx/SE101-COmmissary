// lib/services/sync/descriptors/items_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for Items table sync (Commissary version)
/// 
/// Tier 2: Depends on Organizations, Categories
/// Push: Commissary manages master items
/// Pull: Commissary sees ALL items in network
final itemsDescriptor = TableSyncDescriptor(
  tableName: 'items',
  cloudTableName: 'items',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 2,
  incrementalSync: false, // Full refresh - commissary needs all items
  pullLimit: 1000, // Higher limit for commissary
  softDeleteField: 'is_deleted',
  
  // Commissary can create master items
  canPush: (orgType) => orgType == 'commissary',
  
  // No organization filter - commissary sees ALL items
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
      localField: 'categoryId',
      cloudField: 'category_id',
      referenceTable: 'categories',
      required: false, // Items can be uncategorized
      cloudUsesUuid: true,
    ),
    ForeignKeyMapping(
      localField: 'masterItemId',
      cloudField: 'master_item_id',
      referenceTable: 'items',
      required: false, // Self-reference, only for franchisee copies
      cloudUsesUuid: true,
    ),
  ],
  
  fieldMappings: [
    FieldMapping.simple('name', 'name'),
    FieldMapping.simple('description', 'description'),
    FieldMapping.integer('stock', 'stock'),
    FieldMapping.integer('criticalLevel', 'critical_level'),
    FieldMapping.integer('sold', 'sold'),
    FieldMapping.integer('spoilage', 'spoilage'),
    FieldMapping.real('price', 'price'),
    FieldMapping.real('cost', 'cost'),
    FieldMapping.boolean('isActive', 'is_active'),
    FieldMapping.boolean('isDeleted', 'is_deleted'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('updatedAt', 'last_updated'),
  ],
);
