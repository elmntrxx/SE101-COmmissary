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
}
