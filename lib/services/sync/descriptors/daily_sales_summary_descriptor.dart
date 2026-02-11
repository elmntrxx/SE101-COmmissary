// lib/services/sync/descriptors/daily_sales_summary_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for DailySalesSummary table sync
///
/// Tier 3: Depends on Organizations, Items
/// Push: Franchisees push their daily summaries; Commissary can also push
/// Pull: Commissary sees all summaries across network; Franchisees see only their own
///
/// Key Features:
/// - Unique per (organization_id, item_id, summary_date)
/// - Idempotent upsert by cloud_id
/// - Never recompute revenue/cost from updated prices (snapshot at sale time)
/// - Protects local unsynced changes during pull
final dailySalesSummaryDescriptor = TableSyncDescriptor(
  tableName: 'daily_sales_summary',
  cloudTableName: 'daily_sales_summary',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 3,
  incrementalSync: true,
  pullLimit: 1000, // Higher for commissary - sees all branches
  
  // Both commissary and franchisees can push
  canPush: (orgType) => true,
  
  // No organization filter for commissary (RLS handles it)
  // Franchisees will only see their own via RLS
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
    // Business key (part of unique constraint)
    FieldMapping.dateTime('summaryDate', 'summary_date'),
    
    // Sales metrics
    FieldMapping.integer('quantitySold', 'quantity_sold'),
    FieldMapping.integer('quantitySpoiled', 'quantity_spoiled'),
    FieldMapping.real('revenue', 'revenue'),
    FieldMapping.real('costOfGoodsSold', 'cost_of_goods_sold'),
    FieldMapping.real('grossProfit', 'gross_profit'),
    FieldMapping.integer('transactionCount', 'transaction_count'),
    
    // Stock reconciliation
    FieldMapping.integer('openingStock', 'opening_stock'),
    FieldMapping.integer('closingStock', 'closing_stock'),
    
    // Timestamps (standard sync fields)
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('lastUpdated', 'last_updated'),
    
    // Soft delete
    FieldMapping.boolean('isDeleted', 'is_deleted'),
  ],
  
  softDeleteField: 'is_deleted',
);
