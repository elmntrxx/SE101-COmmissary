// lib/services/sync/descriptors/stock_requests_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for StockReplenishmentRequests table sync (Commissary version)
/// 
/// Tier 4: Depends on Organizations, Items, Users
/// Push: Commissary can approve/reject requests
/// Pull: Commissary sees requests targeting them
/// Conflict: Status-aware (more advanced status wins)
final replenishmentRequestsDescriptor = TableSyncDescriptor(
  tableName: 'stock_replenishment_requests',
  cloudTableName: 'stock_replenishment_requests',
  conflictResolution: ConflictResolution.statusAware, // Status hierarchy wins
  dependencyTier: 4,
  statusField: 'status',
  softDeleteField: 'is_deleted',
  incrementalSync: true, // Incremental for requests
  pullLimit: 500,
  
  // Commissary can approve/reject requests
  canPush: (orgType) => orgType == 'commissary',
  
  // No organization filter - RLS handles this
  organizationField: null,
  
  foreignKeys: [
    ForeignKeyMapping(
      localField: 'franchiseeId',
      cloudField: 'franchisee_id',
      referenceTable: 'organizations',
      required: true,
      cloudUsesUuid: true,
    ),
    ForeignKeyMapping(
      localField: 'commissaryId',
      cloudField: 'commissary_id',
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
    ForeignKeyMapping(
      localField: 'requestedBy',
      cloudField: 'requested_by',
      referenceTable: 'users',
      required: true,
      cloudUsesUuid: true,
    ),
    ForeignKeyMapping(
      localField: 'reviewedBy',
      cloudField: 'reviewed_by',
      referenceTable: 'users',
      required: false, // Null until reviewed
      cloudUsesUuid: true,
    ),
  ],
  
  fieldMappings: [
    FieldMapping.integer('quantityRequested', 'quantity_requested'),
    FieldMapping.simple('status', 'status'),
    FieldMapping.dateTime('requestedAt', 'requested_at'),
    FieldMapping.dateTime('reviewedAt', 'reviewed_at'),
    FieldMapping.dateTime('deliveryDate', 'delivery_date'),
    FieldMapping.simple('franchiseeNotes', 'franchisee_notes'),
    FieldMapping.simple('commissaryNotes', 'commissary_notes'),
    FieldMapping.boolean('isDeleted', 'is_deleted'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('lastUpdated', 'last_updated'),
  ],
);

/// Descriptor for StockChangeRequests table sync
/// 
/// Tier 4: Depends on Organizations, Items, Users
/// Push: Commissary can view/review change requests
/// Pull: Commissary sees change requests from their franchisees
/// Conflict: Status-aware
final changeRequestsDescriptor = TableSyncDescriptor(
  tableName: 'stock_change_requests',
  cloudTableName: 'stock_change_requests',
  conflictResolution: ConflictResolution.statusAware,
  dependencyTier: 4,
  statusField: 'status',
  softDeleteField: 'is_deleted',
  incrementalSync: true,
  pullLimit: 500,
  
  // Commissary can review change requests
  canPush: (orgType) => orgType == 'commissary',
  
  // No organization filter
  organizationField: null,
  
  foreignKeys: [
    ForeignKeyMapping(
      localField: 'franchiseeId',
      cloudField: 'franchisee_id',
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
    ForeignKeyMapping(
      localField: 'requestedBy',
      cloudField: 'requested_by',
      referenceTable: 'users',
      required: true,
      cloudUsesUuid: true,
    ),
    ForeignKeyMapping(
      localField: 'reviewedBy',
      cloudField: 'reviewed_by',
      referenceTable: 'users',
      required: false,
      cloudUsesUuid: true,
    ),
  ],
  
  fieldMappings: [
    FieldMapping.simple('changeType', 'change_type'),
    FieldMapping.integer('previousQuantity', 'previous_quantity'),
    FieldMapping.integer('newQuantity', 'new_quantity'),
    FieldMapping.simple('reason', 'reason'),
    FieldMapping.simple('status', 'status'),
    FieldMapping.simple('notes', 'notes'),
    FieldMapping.boolean('isDeleted', 'is_deleted'),
    FieldMapping.dateTime('requestedAt', 'requested_at'),
    FieldMapping.dateTime('reviewedAt', 'reviewed_at'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('lastUpdated', 'last_updated'),
  ],
);
