// lib/database/tables/daily_sales_summary.dart
import 'package:drift/drift.dart';

/// DailySalesSummary table - Per-branch, per-item, per-day sales aggregates
///
/// Purpose:
/// This table stores aggregated sales data for each item at each branch for each day.
/// It replaces the need to track sales/spoilage as cumulative counters in branch_item_stock.
///
/// Business Flow:
/// 1. Branch records a sale → update branch_item_stock AND upsert daily_sales_summary
/// 2. Branch records spoilage → update branch_item_stock AND upsert daily_sales_summary
/// 3. Commissary queries this table (or views) to see network-wide sales reports
/// 4. Stock transfers do NOT update this table (only branch_item_stock)
///
/// Data Model:
/// - One row per (organization_id, item_id, summary_date) combination
/// - Aggregates: quantity_sold, quantity_spoiled, revenue, cost, profit, transaction_count
/// - Stock reconciliation: opening_stock, closing_stock
///
/// Sync Strategy:
/// - Uses cloud_id as PK for sync (UUID v4)
/// - Unique constraint on (organization_id, item_id, summary_date)
/// - Upsert by cloud_id on conflict
/// - Never recompute revenue/cost from updated prices (snapshot at sale time)
class DailySalesSummary extends Table {
  /// Local primary key
  IntColumn get id => integer().autoIncrement()();

  /// Cloud sync key (UUID v4) - generated once on first create, reused on updates
  TextColumn get cloudId => text().unique()();

  /// Which branch this summary belongs to (TEXT UUID to match Supabase)
  TextColumn get organizationId => text()();

  /// Which item this summary is for (TEXT UUID to match Supabase)
  TextColumn get itemId => text()();

  /// The date this summary covers (date only, no time component)
  /// Must be normalized to midnight UTC or local date for consistency
  DateTimeColumn get summaryDate => dateTime()();

  // ============================================================================
  // Sales Metrics
  // ============================================================================

  /// Total quantity sold on this date
  IntColumn get quantitySold => integer().withDefault(const Constant(0))();

  /// Total quantity spoiled on this date
  IntColumn get quantitySpoiled => integer().withDefault(const Constant(0))();

  /// Total revenue from sales (sum of quantity * unit_price at sale time)
  RealColumn get revenue => real().withDefault(const Constant(0.0))();

  /// Total cost of goods sold and spoiled (sum of quantity * unit_cost at transaction time)
  RealColumn get costOfGoodsSold => real().withDefault(const Constant(0.0))();

  /// Gross profit = revenue - cost_of_goods_sold
  /// Note: Spoilage decreases this (cost without revenue)
  RealColumn get grossProfit => real().withDefault(const Constant(0.0))();

  /// Number of sale transactions (not spoilage) on this date
  IntColumn get transactionCount => integer().withDefault(const Constant(0))();

  // ============================================================================
  // Stock Reconciliation
  // ============================================================================

  /// Stock level at the beginning of this date (before first transaction)
  /// Set on first sale/spoilage event of the day
  IntColumn get openingStock => integer().nullable()();

  /// Stock level at the end of this date (after all transactions)
  /// Updated after each sale/spoilage event
  IntColumn get closingStock => integer().nullable()();

  // ============================================================================
  // Timestamps
  // ============================================================================

  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  DateTimeColumn get lastUpdated =>
      dateTime().clientDefault(() => DateTime.now())();

  // ============================================================================
  // Sync Fields
  // ============================================================================

  /// Whether this record has been synced to cloud
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// Soft delete flag
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Ensure one summary per item per branch per day
  @override
  List<Set<Column>> get uniqueKeys => [
        {organizationId, itemId, summaryDate},
      ];
}
