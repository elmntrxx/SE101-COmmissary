// lib/database/daos/daily_sales_summary_dao.dart
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/daily_sales_summary.dart';

part 'daily_sales_summary_dao.g.dart';

/// Data Access Object for DailySalesSummary table
///
/// Handles all daily sales summary operations:
/// - CRUD for summary records
/// - Upsert logic for accumulating daily sales
/// - Sync with Supabase
/// - Queries for reporting
@DriftAccessor(tables: [DailySalesSummary])
class DailySalesSummaryDao extends DatabaseAccessor<AppDatabase>
    with _$DailySalesSummaryDaoMixin {
  DailySalesSummaryDao(super.db);

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  /// Get summary for a specific organization, item, and date
  Future<DailySalesSummaryData?> getSummary({
    required String organizationId,
    required String itemId,
    required DateTime date,
  }) {
    final dateOnly = _dateOnly(date);
    return (select(dailySalesSummary)
          ..where((s) => s.organizationId.equals(organizationId))
          ..where((s) => s.itemId.equals(itemId))
          ..where((s) => s.summaryDate.equals(dateOnly))
          ..where((s) => s.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Get all summaries for an organization within a date range
  Future<List<DailySalesSummaryData>> getSummariesByOrganization({
    required String organizationId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = _dateOnly(startDate);
    final end = _dateOnly(endDate);
    return (select(dailySalesSummary)
          ..where((s) => s.organizationId.equals(organizationId))
          ..where((s) => s.summaryDate.isBiggerOrEqualValue(start))
          ..where((s) => s.summaryDate.isSmallerOrEqualValue(end))
          ..where((s) => s.isDeleted.equals(false))
          ..orderBy([
            (s) => OrderingTerm.desc(s.summaryDate),
            (s) => OrderingTerm.asc(s.itemId),
          ]))
        .get();
  }

  /// Get all summaries within a date range (for network-wide reports)
  Future<List<DailySalesSummaryData>> getSummariesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = _dateOnly(startDate);
    final end = _dateOnly(endDate);
    return (select(dailySalesSummary)
          ..where((s) => s.summaryDate.isBiggerOrEqualValue(start))
          ..where((s) => s.summaryDate.isSmallerOrEqualValue(end))
          ..where((s) => s.isDeleted.equals(false))
          ..orderBy([
            (s) => OrderingTerm.desc(s.summaryDate),
          ]))
        .get();
  }

  /// Get today's summary for an organization and item
  Future<DailySalesSummaryData?> getTodaySummary({
    required String organizationId,
    required String itemId,
  }) {
    return getSummary(
      organizationId: organizationId,
      itemId: itemId,
      date: DateTime.now(),
    );
  }

  /// Get unsynced summaries (for sync engine)
  Future<List<DailySalesSummaryData>> getUnsyncedSummaries({
    int limit = 50,
    int offset = 0,
  }) {
    return (select(dailySalesSummary)
          ..where((s) => s.isSynced.equals(false))
          ..where((s) => s.isDeleted.equals(false))
          ..limit(limit, offset: offset))
        .get();
  }

  /// Get by cloud ID (for sync engine)
  Future<DailySalesSummaryData?> getByCloudId(String cloudId) {
    return (select(dailySalesSummary)
          ..where((s) => s.cloudId.equals(cloudId)))
        .getSingleOrNull();
  }

  // ============================================================================
  // CREATE/UPDATE OPERATIONS (UPSERT for POS)
  // ============================================================================

  /// Upsert a daily sales summary
  /// If a row exists for (organization_id, item_id, date), update it.
  /// Otherwise, create a new row with a new cloud_id.
  Future<DailySalesSummaryData> upsertSummary(
    DailySalesSummaryCompanion summary,
  ) async {
    // If an ID is provided, it's an update
    if (summary.id.present && summary.id.value != null) {
      await (update(dailySalesSummary)
            ..where((s) => s.id.equals(summary.id.value!)))
          .write(summary.copyWith(
        lastUpdated: Value(DateTime.now()),
        isSynced: const Value(false),
      ));
      return (await (select(dailySalesSummary)
                ..where((s) => s.id.equals(summary.id.value!)))
              .getSingle());
    }

    // Otherwise, try to find existing by composite key
    if (summary.organizationId.present &&
        summary.itemId.present &&
        summary.summaryDate.present) {
      final existing = await getSummary(
        organizationId: summary.organizationId.value,
        itemId: summary.itemId.value,
        date: summary.summaryDate.value,
      );

      if (existing != null) {
        // Update existing
        await (update(dailySalesSummary)
              ..where((s) => s.id.equals(existing.id)))
            .write(summary.copyWith(
          id: const Value.absent(), // Don't overwrite ID
          cloudId: Value(existing.cloudId), // Preserve cloud_id
          lastUpdated: Value(DateTime.now()),
          isSynced: const Value(false),
        ));
        return (await (select(dailySalesSummary)
                  ..where((s) => s.id.equals(existing.id)))
                .getSingle());
      }
    }

    // Insert new record
    final companionWithDefaults = summary.copyWith(
      cloudId: summary.cloudId.present && summary.cloudId.value != null
          ? summary.cloudId
          : Value(const Uuid().v4()),
      createdAt: Value(DateTime.now()),
      lastUpdated: Value(DateTime.now()),
      isSynced: const Value(false),
    );

    final id = await into(dailySalesSummary).insert(companionWithDefaults);
    return (await (select(dailySalesSummary)..where((s) => s.id.equals(id)))
        .getSingle());
  }

  /// Record a sale event - add to daily summary
  /// This is called by the POS service after updating branch_item_stock
  Future<DailySalesSummaryData> recordSale({
    required String organizationId,
    required String itemId,
    required DateTime date,
    required int quantity,
    required double unitPrice,
    required double unitCost,
    required int newStock,
  }) async {
    final dateOnly = _dateOnly(date);
    final existing = await getSummary(
      organizationId: organizationId,
      itemId: itemId,
      date: dateOnly,
    );

    if (existing == null) {
      // First transaction of the day - create new summary
      return upsertSummary(DailySalesSummaryCompanion.insert(
        cloudId: const Uuid().v4(),
        organizationId: organizationId,
        itemId: itemId,
        summaryDate: dateOnly,
        quantitySold: Value(quantity),
        quantitySpoiled: const Value(0),
        revenue: Value(quantity * unitPrice),
        costOfGoodsSold: Value(quantity * unitCost),
        grossProfit: Value(quantity * (unitPrice - unitCost)),
        transactionCount: const Value(1),
        openingStock: Value(newStock + quantity), // Stock before this sale
        closingStock: Value(newStock),
      ));
    } else {
      // Update existing summary
      return upsertSummary(DailySalesSummaryCompanion(
        id: Value(existing.id),
        quantitySold: Value(existing.quantitySold + quantity),
        revenue: Value(existing.revenue + (quantity * unitPrice)),
        costOfGoodsSold: Value(existing.costOfGoodsSold + (quantity * unitCost)),
        grossProfit: Value(existing.grossProfit + (quantity * (unitPrice - unitCost))),
        transactionCount: Value(existing.transactionCount + 1),
        closingStock: Value(newStock),
      ));
    }
  }

  /// Record a spoilage event - add to daily summary
  /// This is called by the POS service after updating branch_item_stock
  Future<DailySalesSummaryData> recordSpoilage({
    required String organizationId,
    required String itemId,
    required DateTime date,
    required int quantity,
    required double unitCost,
    required int newStock,
  }) async {
    final dateOnly = _dateOnly(date);
    final existing = await getSummary(
      organizationId: organizationId,
      itemId: itemId,
      date: dateOnly,
    );

    if (existing == null) {
      // First transaction of the day - create new summary
      return upsertSummary(DailySalesSummaryCompanion.insert(
        cloudId: const Uuid().v4(),
        organizationId: organizationId,
        itemId: itemId,
        summaryDate: dateOnly,
        quantitySold: const Value(0),
        quantitySpoiled: Value(quantity),
        revenue: const Value(0.0),
        costOfGoodsSold: Value(quantity * unitCost),
        grossProfit: Value(-(quantity * unitCost)), // Spoilage decreases profit
        transactionCount: const Value(0), // Spoilage doesn't count as transaction
        openingStock: Value(newStock + quantity), // Stock before spoilage
        closingStock: Value(newStock),
      ));
    } else {
      // Update existing summary
      return upsertSummary(DailySalesSummaryCompanion(
        id: Value(existing.id),
        quantitySpoiled: Value(existing.quantitySpoiled + quantity),
        costOfGoodsSold: Value(existing.costOfGoodsSold + (quantity * unitCost)),
        grossProfit: Value(existing.grossProfit - (quantity * unitCost)),
        closingStock: Value(newStock),
        // Do NOT update transaction_count for spoilage
      ));
    }
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// Mark records as synced
  Future<void> markAsSynced(List<int> ids, {Map<int, String>? cloudIds}) async {
    for (final id in ids) {
      final cloudId = cloudIds?[id];
      final companion = DailySalesSummaryCompanion(
        isSynced: const Value(true),
        cloudId: cloudId != null ? Value(cloudId) : const Value.absent(),
      );
      await (update(dailySalesSummary)..where((s) => s.id.equals(id)))
          .write(companion);
    }
  }

  /// Upsert from cloud (for sync engine)
  Future<void> upsertFromCloud(Map<String, dynamic> data) async {
    final cloudId = (data['cloudId'] ?? data['cloud_id']) as String?;
    if (cloudId == null) throw ArgumentError('cloudId is required');

    // Check if exists by cloud_id
    var existing = await getByCloudId(cloudId);

    // If not found by cloud_id, try finding by composite key
    if (existing == null &&
        data['organizationId'] != null &&
        data['itemId'] != null &&
        data['summaryDate'] != null) {
      existing = await getSummary(
        organizationId: data['organizationId'] as String,
        itemId: data['itemId'] as String,
        date: data['summaryDate'] is DateTime
            ? data['summaryDate'] as DateTime
            : DateTime.parse(data['summaryDate'] as String),
      );
    }

    // Protection: Don't overwrite local unsynced changes
    if (existing != null && !existing.isSynced) {
      return;
    }

    final companion = DailySalesSummaryCompanion(
      organizationId: Value(data['organizationId'] as String),
      itemId: Value(data['itemId'] as String),
      summaryDate: Value(data['summaryDate'] is DateTime
          ? data['summaryDate'] as DateTime
          : DateTime.parse(data['summaryDate'] as String)),
      quantitySold: Value((data['quantitySold'] as num?)?.toInt() ?? 0),
      quantitySpoiled: Value((data['quantitySpoiled'] as num?)?.toInt() ?? 0),
      revenue: Value((data['revenue'] as num?)?.toDouble() ?? 0.0),
      costOfGoodsSold:
          Value((data['costOfGoodsSold'] as num?)?.toDouble() ?? 0.0),
      grossProfit: Value((data['grossProfit'] as num?)?.toDouble() ?? 0.0),
      transactionCount:
          Value((data['transactionCount'] as num?)?.toInt() ?? 0),
      openingStock: data['openingStock'] != null
          ? Value((data['openingStock'] as num).toInt())
          : const Value.absent(),
      closingStock: data['closingStock'] != null
          ? Value((data['closingStock'] as num).toInt())
          : const Value.absent(),
      lastUpdated: data['lastUpdated'] != null
          ? Value(data['lastUpdated'] is DateTime
              ? data['lastUpdated'] as DateTime
              : DateTime.parse(data['lastUpdated'] as String))
          : Value(DateTime.now()),
      isDeleted: Value(data['isDeleted'] as bool? ?? false),
      isSynced: const Value(true),
      cloudId: Value(cloudId),
    );

    if (existing != null) {
      await (update(dailySalesSummary)..where((s) => s.id.equals(existing!.id)))
          .write(companion);
    } else {
      await into(dailySalesSummary).insert(companion);
    }
  }

  /// Batch upsert from cloud
  Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> dataList) async {
    await db.batch((b) async {
      for (final data in dataList) {
        await upsertFromCloud(data);
      }
    });
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  /// Soft delete a summary record
  Future<bool> softDelete(int id) {
    return (update(dailySalesSummary)..where((s) => s.id.equals(id)))
        .write(const DailySalesSummaryCompanion(
          isDeleted: Value(true),
          isSynced: Value(false),
        ))
        .then((rows) => rows > 0);
  }

  /// Hard delete synced soft-deleted records
  Future<int> cleanupDeleted() {
    return (delete(dailySalesSummary)
          ..where((s) => s.isDeleted.equals(true))
          ..where((s) => s.isSynced.equals(true)))
        .go();
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  /// Normalize DateTime to date-only (midnight UTC)
  DateTime _dateOnly(DateTime dt) {
    return DateTime.utc(dt.year, dt.month, dt.day);
  }
}
