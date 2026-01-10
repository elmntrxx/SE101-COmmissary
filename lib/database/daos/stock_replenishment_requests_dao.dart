// lib/database/daos/stock_replenishment_requests_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/stock_replenishment_requests.dart';

part 'stock_replenishment_requests_dao.g.dart';

@DriftAccessor(tables: [StockReplenishmentRequests])
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
          ..orderBy([
            (r) => OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// Watch pending requests for commissary
  Stream<List<StockReplenishmentRequest>> watchPendingRequests(
      int commissaryId) {
    return (select(stockReplenishmentRequests)
          ..where((r) => r.commissaryId.equals(commissaryId))
          ..where((r) => r.status.equals('pending'))
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

  // ============================================================================
  // MUTATIONS
  // ============================================================================

  /// Create a new request
  Future<int> createRequest(StockReplenishmentRequestsCompanion request) =>
      into(stockReplenishmentRequests).insert(request);

  /// Update a request
  Future<bool> updateRequest(StockReplenishmentRequest request) =>
      update(stockReplenishmentRequests).replace(request);

  /// Approve a request
  Future<int> approveRequest(int id, int approvedQuantity, int processedBy,
      {String? notes}) {
    return (update(stockReplenishmentRequests)..where((r) => r.id.equals(id)))
        .write(
      StockReplenishmentRequestsCompanion(
        status: const Value('approved'),
        quantityApproved: Value(approvedQuantity),
        processedBy: Value(processedBy),
        processedAt: Value(DateTime.now()),
        approverNotes: Value(notes),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Reject a request
  Future<int> rejectRequest(int id, int processedBy, {String? notes}) {
    return (update(stockReplenishmentRequests)..where((r) => r.id.equals(id)))
        .write(
      StockReplenishmentRequestsCompanion(
        status: const Value('rejected'),
        processedBy: Value(processedBy),
        processedAt: Value(DateTime.now()),
        approverNotes: Value(notes),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Get unsynced requests
  Future<List<StockReplenishmentRequest>> getUnsyncedRequests() {
    return (select(stockReplenishmentRequests)
          ..where((r) => r.needsSync.equals(true)))
        .get();
  }

  /// Mark as synced
  Future<int> markAsSynced(int id, DateTime syncTime) {
    return (update(stockReplenishmentRequests)..where((r) => r.id.equals(id)))
        .write(
      StockReplenishmentRequestsCompanion(
        lastSyncedAt: Value(syncTime),
        needsSync: const Value(false),
      ),
    );
  }
}
