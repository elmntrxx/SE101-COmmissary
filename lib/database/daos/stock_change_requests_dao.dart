// lib/database/daos/stock_change_requests_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/stock_change_requests.dart';

part 'stock_change_requests_dao.g.dart';

@DriftAccessor(tables: [StockChangeRequests])
class StockChangeRequestsDao extends DatabaseAccessor<AppDatabase>
    with _$StockChangeRequestsDaoMixin {
  StockChangeRequestsDao(super.db);

  // ============================================================================
  // QUERIES
  // ============================================================================

  /// Get all stock changes for a franchisee
  Future<List<StockChangeRequest>> getChangesByFranchisee(int franchiseeId) {
    return (select(stockChangeRequests)
          ..where((r) => r.franchiseeId.equals(franchiseeId))
          ..orderBy([
            (r) => OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// Watch pending changes for a franchisee
  Stream<List<StockChangeRequest>> watchPendingChanges(int franchiseeId) {
    return (select(stockChangeRequests)
          ..where((r) => r.franchiseeId.equals(franchiseeId))
          ..where((r) => r.status.equals('pending'))
          ..orderBy([
            (r) => OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  /// Get changes for an item
  Future<List<StockChangeRequest>> getChangesByItem(int itemId) {
    return (select(stockChangeRequests)
          ..where((r) => r.itemId.equals(itemId))
          ..orderBy([
            (r) => OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// Get request by ID
  Future<StockChangeRequest?> getRequestById(int id) {
    return (select(stockChangeRequests)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get all changes across all franchisees (for commissary reports)
  Future<List<StockChangeRequest>> getAllChanges() {
    return (select(stockChangeRequests)
          ..orderBy([
            (r) => OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // ============================================================================
  // MUTATIONS
  // ============================================================================

  /// Create a new change request
  Future<int> createChangeRequest(StockChangeRequestsCompanion request) =>
      into(stockChangeRequests).insert(request);

  /// Update a request
  Future<bool> updateRequest(StockChangeRequest request) =>
      update(stockChangeRequests).replace(request);

  /// Approve a change request
  Future<int> approveRequest(int id, int processedBy) {
    return (update(stockChangeRequests)..where((r) => r.id.equals(id))).write(
      StockChangeRequestsCompanion(
        status: const Value('approved'),
        processedBy: Value(processedBy),
        processedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Reject a change request
  Future<int> rejectRequest(int id, int processedBy, {String? reason}) {
    return (update(stockChangeRequests)..where((r) => r.id.equals(id))).write(
      StockChangeRequestsCompanion(
        status: const Value('rejected'),
        reason: Value(reason),
        processedBy: Value(processedBy),
        processedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Get unsynced requests
  Future<List<StockChangeRequest>> getUnsyncedRequests() {
    return (select(stockChangeRequests)
          ..where((r) => r.needsSync.equals(true)))
        .get();
  }

  /// Mark as synced
  Future<int> markAsSynced(int id, DateTime syncTime) {
    return (update(stockChangeRequests)..where((r) => r.id.equals(id))).write(
      StockChangeRequestsCompanion(
        lastSyncedAt: Value(syncTime),
        needsSync: const Value(false),
      ),
    );
  }

  /// Get by cloud ID (for SyncEngine compatibility)
  Future<StockChangeRequest?> getRequestByCloudId(String cloudId) {
    return (select(stockChangeRequests)..where((r) => r.cloudId.equals(cloudId)))
        .getSingleOrNull();
  }

  // ============================================================================
  // SYNC METHODS (for SyncEngine compatibility)
  // ============================================================================

  /// Upsert a single change request from cloud data
  /// SyncEngine provides camelCase keys with resolved local IDs
  Future<int> upsertFromCloud(Map<String, dynamic> cloudData) async {
    // SyncEngine uses 'cloudId' (camelCase), not 'cloud_id'
    final cloudId = (cloudData['cloudId'] ?? cloudData['cloud_id']) as String?;
    if (cloudId == null) throw ArgumentError('cloudId is required');

    final existing = await getRequestByCloudId(cloudId);

    // SyncEngine already resolves FKs to local IDs with camelCase keys
    final franchiseeId = cloudData['franchiseeId'] as int?;
    final itemId = cloudData['itemId'] as int?;
    final requestedBy = cloudData['requestedBy'] as int?;
    final reviewedBy = cloudData['reviewedBy'] as int?;

    final companion = StockChangeRequestsCompanion(
      cloudId: Value(cloudId),
      franchiseeId: Value(franchiseeId ?? existing?.franchiseeId ?? 0),
      itemId: Value(itemId ?? existing?.itemId ?? 0),
      changeType: Value(cloudData['changeType'] as String? ?? 'adjustment'),
      quantityChange: Value((cloudData['previousQuantity'] as num?)?.toInt() ?? 0),
      previousStock: Value((cloudData['previousQuantity'] as num?)?.toInt() ?? 0),
      newStock: Value((cloudData['newQuantity'] as num?)?.toInt() ?? 0),
      reason: Value(cloudData['reason'] as String?),
      status: Value(cloudData['status'] as String? ?? 'pending'),
      requestedBy: Value(requestedBy ?? existing?.requestedBy ?? 0),
      processedBy: reviewedBy != null ? Value(reviewedBy) : const Value.absent(),
      processedAt: cloudData['reviewedAt'] != null
          ? Value(cloudData['reviewedAt'] is DateTime 
              ? cloudData['reviewedAt'] as DateTime 
              : DateTime.parse(cloudData['reviewedAt'] as String))
          : const Value.absent(),
      createdAt: Value(cloudData['createdAt'] != null
          ? (cloudData['createdAt'] is DateTime 
              ? cloudData['createdAt'] as DateTime 
              : DateTime.parse(cloudData['createdAt'] as String))
          : DateTime.now()),
      updatedAt: Value(cloudData['lastUpdated'] != null
          ? (cloudData['lastUpdated'] is DateTime 
              ? cloudData['lastUpdated'] as DateTime 
              : DateTime.parse(cloudData['lastUpdated'] as String))
          : DateTime.now()),
      lastSyncedAt: Value(DateTime.now()),
      needsSync: const Value(false),
    );

    if (existing != null) {
      // Protect local unsynced changes from being overwritten
      if (existing.needsSync) {
        return existing.id;
      }
      await (update(stockChangeRequests)..where((r) => r.id.equals(existing.id))).write(companion);
      return existing.id;
    } else {
      return into(stockChangeRequests).insert(companion);
    }
  }

  /// Upsert batch of change requests from cloud data
  Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> cloudDataList) async {
    for (final cloudData in cloudDataList) {
      await upsertFromCloud(cloudData);
    }
  }
}
