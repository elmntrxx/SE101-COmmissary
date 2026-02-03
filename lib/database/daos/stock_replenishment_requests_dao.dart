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
    int commissaryId,
  ) {
    return (select(stockReplenishmentRequests)
          ..where((r) => r.commissaryId.equals(commissaryId))
          ..where((r) => r.isDeleted.equals(false))
          ..orderBy([
            (r) =>
                OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Get pending requests for commissary
  Future<List<StockReplenishmentRequest>> getPendingRequestsForCommissary(
    int commissaryId,
  ) {
    return (select(stockReplenishmentRequests)
          ..where((r) => r.commissaryId.equals(commissaryId))
          ..where((r) => r.status.equals('pending'))
          ..where((r) => r.isDeleted.equals(false))
          ..orderBy([
            (r) =>
                OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Watch pending requests for commissary (real-time updates)
  Stream<List<StockReplenishmentRequest>> watchPendingRequests(
    int commissaryId,
  ) {
    return (select(stockReplenishmentRequests)
          ..where((r) => r.commissaryId.equals(commissaryId))
          ..where((r) => r.status.equals('pending'))
          ..where((r) => r.isDeleted.equals(false))
          ..orderBy([
            (r) =>
                OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Watch all requests for commissary (real-time updates)
  Stream<List<StockReplenishmentRequest>> watchAllRequests(int commissaryId) {
    return (select(stockReplenishmentRequests)
          ..where((r) => r.commissaryId.equals(commissaryId))
          ..where((r) => r.isDeleted.equals(false))
          ..orderBy([
            (r) =>
                OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Get requests by franchisee
  Future<List<StockReplenishmentRequest>> getRequestsByFranchisee(
    int franchiseeId,
  ) {
    return (select(stockReplenishmentRequests)
          ..where((r) => r.franchiseeId.equals(franchiseeId))
          ..where((r) => r.isDeleted.equals(false))
          ..orderBy([
            (r) =>
                OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Get request by ID
  Future<StockReplenishmentRequest?> getRequestById(int id) {
    return (select(
      stockReplenishmentRequests,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  /// Get request by cloud ID
  Future<StockReplenishmentRequest?> getRequestByCloudId(String cloudId) {
    return (select(
      stockReplenishmentRequests,
    )..where((r) => r.cloudId.equals(cloudId))).getSingleOrNull();
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
    final rows =
        await (update(
          stockReplenishmentRequests,
        )..where((r) => r.id.equals(requestId))).write(
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
    final rows =
        await (update(
          stockReplenishmentRequests,
        )..where((r) => r.id.equals(requestId))).write(
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
    final rows =
        await (update(
          stockReplenishmentRequests,
        )..where((r) => r.id.equals(requestId))).write(
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
    return (select(
      stockReplenishmentRequests,
    )..where((r) => r.isSynced.equals(false))).get();
  }

  /// Mark as synced
  Future<bool> markAsSynced(int id, String? cloudId) async {
    final rows =
        await (update(
          stockReplenishmentRequests,
        )..where((r) => r.id.equals(id))).write(
          StockReplenishmentRequestsCompanion(
            isSynced: const Value(true),
            cloudId: cloudId != null ? Value(cloudId) : const Value.absent(),
          ),
        );
    return rows > 0;
  }

  /// Upsert from cloud
  Future<void> upsertFromCloud(Map<String, dynamic> data) async {
    final cloudId = data['cloud_id'] as String;

    // Check if exists
    final existing = await getRequestByCloudId(cloudId);

    final companion = StockReplenishmentRequestsCompanion(
      franchiseeId: Value(data['franchisee_id'] as int),
      commissaryId: Value(data['commissary_id'] as int),
      itemId: Value(data['item_id'] as int),
      quantityRequested: Value(data['quantity_requested'] as int),
      status: Value(data['status'] as String? ?? 'pending'),
      requestedBy: Value(data['requested_by'] as int),
      requestedAt: data['requested_at'] != null
          ? Value(DateTime.parse(data['requested_at'] as String))
          : Value(DateTime.now()),
      reviewedBy: data['reviewed_by'] != null
          ? Value(data['reviewed_by'] as int)
          : const Value.absent(),
      reviewedAt: data['reviewed_at'] != null
          ? Value(DateTime.parse(data['reviewed_at'] as String))
          : const Value.absent(),
      deliveryDate: data['delivery_date'] != null
          ? Value(DateTime.parse(data['delivery_date'] as String))
          : const Value.absent(),
      franchiseeNotes: data['franchisee_notes'] != null
          ? Value(data['franchisee_notes'] as String)
          : const Value.absent(),
      commissaryNotes: data['commissary_notes'] != null
          ? Value(data['commissary_notes'] as String)
          : const Value.absent(),
      isDeleted: Value(data['is_deleted'] as bool? ?? false),
      createdAt: data['created_at'] != null
          ? Value(DateTime.parse(data['created_at'] as String))
          : Value(DateTime.now()),
      lastUpdated: data['last_updated'] != null
          ? Value(DateTime.parse(data['last_updated'] as String))
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
      await (update(
        stockReplenishmentRequests,
      )..where((r) => r.id.equals(existing.id))).write(companion);
    } else {
      await into(stockReplenishmentRequests).insert(companion);
    }
  }
}
