// lib/services/sync/descriptors/branch_stock_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for BranchItemStock table sync
/// 
/// Tier 3: Depends on Organizations, Items
/// Push: Each org manages their own stock
/// Pull: Commissary sees all branch stock in network
final branchItemStockDescriptor = TableSyncDescriptor(
  tableName: 'branch_item_stock',
  cloudTableName: 'branch_item_stock',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 3,
  incrementalSync: true,
  pullLimit: 1000, // Higher for commissary - sees all branches
  
  // Commissary can manage stock
  canPush: (orgType) => orgType == 'commissary',
  
  // No organization filter - commissary sees all
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
      localField: 'itemId',
      cloudField: 'item_id',
      referenceTable: 'items',
      required: true,
      cloudUsesUuid: true,
    ),
  ],
  
  fieldMappings: [
    FieldMapping.integer('currentStock', 'current_stock'),
    FieldMapping.integer('minStock', 'min_stock'),
    FieldMapping.integer('maxStock', 'max_stock'),
    FieldMapping.integer('reorderPoint', 'reorder_point'),
    FieldMapping.dateTime('lastRestocked', 'last_restocked'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('lastUpdated', 'last_updated'),
  ],
);
