// lib/database/daos/stock_replenishment_requests_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/stock_replenishment_requests.dart';
import '../tables/items.dart';
import '../tables/organizations.dart';

part 'stock_replenishment_requests_dao.g.dart';

/// StockReplenishmentRequestsDao - Commissary manages franchisee stock requests
///
/// Business Flow:
/// 1. Franchisee creates request (status: pending)
/// 2. Commissary reviews and approves/rejects
/// 3. If approved, commissary transfers stock (reduces own, adds to branch)
/// 4. Mark as delivered when physically delivered
@DriftAccessor(tables: [StockReplenishmentRequests, Items, Organizations])
class StockReplenishmentRequestsDao extends DatabaseAccessor<AppDatabase>
    with _$StockReplenishmentRequestsDaoMixin {
  StockReplenishmentRequestsDao(super.db);

  // ============================================================================
  // QUERIES
  // ============================================================================

  /// Get all requests for commissary (to review)
  Future<List<StockReplenishmentRequest>> getRequestsForCommissary(
      int commissaryId) {
    return (select(stockReplenishmentRequests)
          ..where((r) => r.commissaryId.equals(commissaryId))
          ..where((r) => r.isDeleted.equals(false))
          ..orderBy([
            (r) => OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// Get pending requests for commissary
  Future<List<StockReplenishmentRequest>> getPendingRequestsForCommissary(
      int commissaryId) {
    return (select(stockReplenishmentRequests)
          ..where((r) => r.commissaryId.equals(commissaryId))
          ..where((r) => r.status.equals('pending'))
          ..where((r) => r.isDeleted.equals(false))
          ..orderBy([
            (r) => OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// Watch pending requests for commissary (real-time updates)
  Stream<List<StockReplenishmentRequest>> watchPendingRequests(
      int commissaryId) {
    return (select(stockReplenishmentRequests)
          ..where((r) => r.commissaryId.equals(commissaryId))
          ..where((r) => r.status.equals('pending'))
          ..where((r) => r.isDeleted.equals(false))
          ..orderBy([
            (r) => OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  /// Get requests by franchisee
  Future<List<StockReplenishmentRequest>> getRequestsByFranchisee(
      int franchiseeId) {
    return (select(stockReplenishmentRequests)
          ..where((r) => r.franchiseeId.equals(franchiseeId))
          ..where((r) => r.isDeleted.equals(false))
          ..orderBy([
            (r) => OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// Get request by ID
  Future<StockReplenishmentRequest?> getRequestById(int id) {
    return (select(stockReplenishmentRequests)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get request by cloud ID
  Future<StockReplenishmentRequest?> getRequestByCloudId(String cloudId) {
    return (select(stockReplenishmentRequests)
          ..where((r) => r.cloudId.equals(cloudId)))
        .getSingleOrNull();
  }

  // ============================================================================
  // MUTATIONS
  // ============================================================================

  /// Create a new request
  Future<int> createRequest(StockReplenishmentRequestsCompanion request) =>
      into(stockReplenishmentRequests).insert(request);

  /// Update a request
  Future<bool> updateRequest(StockReplenishmentRequest request) =>
      update(stockReplenishmentRequests).replace(request);

  /// Approve a request (commissary)
  Future<bool> approveRequest({
    required int requestId,
    required int reviewedBy,
    String? commissaryNotes,
    DateTime? deliveryDate,
  }) async {
    final rows = await (update(stockReplenishmentRequests)
          ..where((r) => r.id.equals(requestId)))
        .write(
      StockReplenishmentRequestsCompanion(
        status: const Value('approved'),
        reviewedBy: Value(reviewedBy),
        reviewedAt: Value(DateTime.now()),
        commissaryNotes: Value(commissaryNotes),
        deliveryDate: Value(deliveryDate),
        lastUpdated: Value(DateTime.now()),
        isSynced: const Value(false),
      ),
    );
    return rows > 0;
  }

  /// Reject a request (commissary)
  Future<bool> rejectRequest({
    required int requestId,
    required int reviewedBy,
    required String reason,
  }) async {
    final rows = await (update(stockReplenishmentRequests)
          ..where((r) => r.id.equals(requestId)))
        .write(
      StockReplenishmentRequestsCompanion(
        status: const Value('rejected'),
        reviewedBy: Value(reviewedBy),
        reviewedAt: Value(DateTime.now()),
        commissaryNotes: Value(reason),
        lastUpdated: Value(DateTime.now()),
        isSynced: const Value(false),
      ),
    );
    return rows > 0;
  }

  /// Mark as delivered
  Future<bool> markAsDelivered(int requestId) async {
    final rows = await (update(stockReplenishmentRequests)
          ..where((r) => r.id.equals(requestId)))
        .write(
      StockReplenishmentRequestsCompanion(
        status: const Value('delivered'),
        deliveryDate: Value(DateTime.now()),
        lastUpdated: Value(DateTime.now()),
        isSynced: const Value(false),
      ),
    );
    return rows > 0;
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// Get unsynced requests
  Future<List<StockReplenishmentRequest>> getUnsyncedRequests() {
    return (select(stockReplenishmentRequests)
          ..where((r) => r.isSynced.equals(false)))
        .get();
  }

  /// Mark as synced
  Future<bool> markAsSynced(int id, String? cloudId) async {
    final rows = await (update(stockReplenishmentRequests)
          ..where((r) => r.id.equals(id)))
        .write(
      StockReplenishmentRequestsCompanion(
        isSynced: const Value(true),
        cloudId: cloudId != null ? Value(cloudId) : const Value.absent(),
      ),
    );
    return rows > 0;
  }

  /// Upsert from cloud (SyncEngine provides camelCase keys with resolved local IDs)
  Future<void> upsertFromCloud(Map<String, dynamic> data) async {
    // SyncEngine uses 'cloudId' (camelCase), not 'cloud_id'
    final cloudId = (data['cloudId'] ?? data['cloud_id']) as String?;
    if (cloudId == null) throw ArgumentError('cloudId is required');
    
    // Check if exists
    final existing = await getRequestByCloudId(cloudId);
    
    // SyncEngine resolves FKs to local IDs with camelCase keys
    final franchiseeId = data['franchiseeId'] as int?;
    final commissaryId = data['commissaryId'] as int?;
    final itemId = data['itemId'] as int?;
    final requestedBy = data['requestedBy'] as int?;
    final reviewedBy = data['reviewedBy'] as int?;
    
    final companion = StockReplenishmentRequestsCompanion(
      franchiseeId: Value(franchiseeId ?? existing?.franchiseeId ?? 0),
      commissaryId: Value(commissaryId ?? existing?.commissaryId ?? 0),
      itemId: Value(itemId ?? existing?.itemId ?? 0),
      quantityRequested: Value((data['quantityRequested'] as num?)?.toInt() ?? existing?.quantityRequested ?? 0),
      status: Value(data['status'] as String? ?? existing?.status ?? 'pending'),
      requestedBy: Value(requestedBy ?? existing?.requestedBy ?? 0),
      requestedAt: data['requestedAt'] != null
          ? Value(data['requestedAt'] is DateTime 
              ? data['requestedAt'] as DateTime 
              : DateTime.parse(data['requestedAt'] as String))
          : (existing?.requestedAt != null ? Value(existing!.requestedAt) : Value(DateTime.now())),
      reviewedBy: reviewedBy != null
          ? Value(reviewedBy)
          : const Value.absent(),
      reviewedAt: data['reviewedAt'] != null
          ? Value(data['reviewedAt'] is DateTime 
              ? data['reviewedAt'] as DateTime 
              : DateTime.parse(data['reviewedAt'] as String))
          : const Value.absent(),
      deliveryDate: data['deliveryDate'] != null
          ? Value(data['deliveryDate'] is DateTime 
              ? data['deliveryDate'] as DateTime 
              : DateTime.parse(data['deliveryDate'] as String))
          : const Value.absent(),
      franchiseeNotes: data['franchiseeNotes'] != null
          ? Value(data['franchiseeNotes'] as String)
          : const Value.absent(),
      commissaryNotes: data['commissaryNotes'] != null
          ? Value(data['commissaryNotes'] as String)
          : const Value.absent(),
      isDeleted: Value(data['isDeleted'] as bool? ?? false),
      createdAt: data['createdAt'] != null
          ? Value(data['createdAt'] is DateTime 
              ? data['createdAt'] as DateTime 
              : DateTime.parse(data['createdAt'] as String))
          : Value(DateTime.now()),
      lastUpdated: data['lastUpdated'] != null
          ? Value(data['lastUpdated'] is DateTime 
              ? data['lastUpdated'] as DateTime 
              : DateTime.parse(data['lastUpdated'] as String))
          : Value(DateTime.now()),
      isSynced: const Value(true),
      cloudId: Value(cloudId),
    );

    if (existing != null) {
      if (!existing.isSynced) {
        // Protect local unsynced changes (e.g. just approved/rejected) from being overwritten
        // by stale cloud data, especially since we do Push-First now.
        return;
      }
      await (update(stockReplenishmentRequests)
            ..where((r) => r.id.equals(existing.id)))
          .write(companion);
    } else {
      await into(stockReplenishmentRequests).insert(companion);
    }
  }

  /// Batch upsert from cloud (for SyncEngine compatibility)
  Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> cloudDataList) async {
    for (final cloudData in cloudDataList) {
      await upsertFromCloud(cloudData);
    }
  }
}
