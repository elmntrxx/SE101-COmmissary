// lib/database/daos/branch_item_stock_dao.dart
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/branch_item_stock.dart';
import '../tables/items.dart';
import '../tables/categories.dart';
import '../models/item_with_branch_stock.dart';

part 'branch_item_stock_dao.g.dart';

/// Data Access Object for BranchItemStock table
///
/// Handles all branch-specific inventory operations:
/// - CRUD for branch stock records
/// - Stock updates (receive, sell, spoil)
/// - Sync with Supabase
@DriftAccessor(tables: [BranchItemStock, Items, Categories])
class BranchItemStockDao extends DatabaseAccessor<AppDatabase>
    with _$BranchItemStockDaoMixin {
  BranchItemStockDao(super.db);

  // ============================================================================
  // JOINED QUERIES - Items with Branch Stock
  // ============================================================================

  /// Get all master items with branch-specific stock for a branch
  Future<List<ItemWithBranchStock>> getItemsWithStockForBranch(
    int branchId,
    int commissaryId,
  ) async {
    // Get master items from commissary (items where org = commissary AND master_item_id IS NULL)
    final query = select(db.items).join([
      leftOuterJoin(
        branchItemStock,
        branchItemStock.itemId.equalsExp(db.items.id) &
            branchItemStock.organizationId.equals(branchId) &
            branchItemStock.isDeleted.equals(false),
      ),
      leftOuterJoin(
        db.categories,
        db.categories.id.equalsExp(db.items.categoryId),
      ),
    ])
      ..where(db.items.organizationId.equals(commissaryId))
      ..where(db.items.masterItemId.isNull()) // Only master items
      ..where(db.items.isActive.equals(true))
      ..orderBy([OrderingTerm.asc(db.items.name)]);

    final results = await query.get();

    return results.map((row) {
      final item = row.readTable(db.items);
      final stock = row.readTableOrNull(branchItemStock);
      final category = row.readTableOrNull(db.categories);

      return ItemWithBranchStock(
        item: item,
        branchStock: stock,
        category: category,
      );
    }).toList();
  }

  /// Watch items with branch stock (reactive stream)
  Stream<List<ItemWithBranchStock>> watchItemsWithStockForBranch(
    int branchId,
    int commissaryId,
  ) {
    final query = select(db.items).join([
      leftOuterJoin(
        branchItemStock,
        branchItemStock.itemId.equalsExp(db.items.id) &
            branchItemStock.organizationId.equals(branchId) &
            branchItemStock.isDeleted.equals(false),
      ),
      leftOuterJoin(
        db.categories,
        db.categories.id.equalsExp(db.items.categoryId),
      ),
    ])
      ..where(db.items.organizationId.equals(commissaryId))
      ..where(db.items.masterItemId.isNull())
      ..where(db.items.isActive.equals(true))
      ..orderBy([OrderingTerm.asc(db.items.name)]);

    return query.watch().map((results) {
      return results.map((row) {
        final item = row.readTable(db.items);
        final stock = row.readTableOrNull(branchItemStock);
        final category = row.readTableOrNull(db.categories);

        return ItemWithBranchStock(
          item: item,
          branchStock: stock,
          category: category,
        );
      }).toList();
    });
  }

  /// Get low stock items for a branch (items below minimum threshold)
  Future<List<ItemWithBranchStock>> getLowStockItemsForBranch(
    int branchId,
    int commissaryId,
  ) async {
    final allItems = await getItemsWithStockForBranch(branchId, commissaryId);
    return allItems.where((item) => item.isLowStock).toList();
  }

  /// Get out of stock items for a branch
  Future<List<ItemWithBranchStock>> getOutOfStockItemsForBranch(
    int branchId,
    int commissaryId,
  ) async {
    final allItems = await getItemsWithStockForBranch(branchId, commissaryId);
    return allItems.where((item) => item.isOutOfStock).toList();
  }

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  /// Get all stock records for an organization
  Future<List<BranchItemStockData>> getStockByOrganization(int orgId) {
    return (select(branchItemStock)
          ..where((s) => s.organizationId.equals(orgId))
          ..where((s) => s.isDeleted.equals(false))
          ..orderBy([(s) => OrderingTerm.asc(s.itemId)]))
        .get();
  }

  /// Get stock for a specific item at a specific branch
  Future<BranchItemStockData?> getStockForItem(int orgId, int itemId) {
    return (select(branchItemStock)
          ..where((s) => s.organizationId.equals(orgId))
          ..where((s) => s.itemId.equals(itemId))
          ..where((s) => s.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Get all stock records (for sync)
  Future<List<BranchItemStockData>> getAllStock() {
    return (select(branchItemStock)
          ..where((s) => s.isDeleted.equals(false)))
        .get();
  }

  /// Get unsynced stock records
  Future<List<BranchItemStockData>> getUnsyncedStock({
    int limit = 50,
    int offset = 0,
  }) {
    return (select(branchItemStock)
          ..where((s) => s.isSynced.equals(false))
          ..limit(limit, offset: offset))
        .get();
  }

  /// Get low stock items for a branch
  Future<List<BranchItemStockData>> getLowStockItems(int orgId) {
    return customSelect(
      '''
      SELECT * FROM branch_item_stock 
      WHERE organization_id = ? 
        AND is_deleted = 0
        AND minimum_stock IS NOT NULL 
        AND stock <= minimum_stock
      ORDER BY stock ASC
      ''',
      variables: [Variable.withInt(orgId)],
      readsFrom: {branchItemStock},
    ).map((row) => branchItemStock.map(row.data)).get();
  }

  /// Watch stock changes for a branch (reactive)
  Stream<List<BranchItemStockData>> watchStockByOrganization(int orgId) {
    return (select(branchItemStock)
          ..where((s) => s.organizationId.equals(orgId))
          ..where((s) => s.isDeleted.equals(false))
          ..orderBy([(s) => OrderingTerm.asc(s.itemId)]))
        .watch();
  }

  // ============================================================================
  // CREATE OPERATIONS
  // ============================================================================

  /// Create a new stock record
  Future<int> createStock(BranchItemStockCompanion stock) {
    // Auto-generate cloud_id if missing (critical for sync)
    if (stock.cloudId == const Value.absent() || stock.cloudId.value == null) {
      stock = stock.copyWith(cloudId: Value(const Uuid().v4()));
    }
    return into(branchItemStock).insert(stock);
  }

  /// Initialize stock for a branch (create records for all master items)
  Future<int> initializeStockForBranch(int branchId, int commissaryId) async {
    // Get all master items from commissary
    final masterItems = await db.itemsDao.getMasterItems(commissaryId);
    
    int created = 0;
    for (final item in masterItems) {
      // Check if stock already exists
      final existing = await getStockForItem(branchId, item.id);
      if (existing == null) {
        await createStock(BranchItemStockCompanion(
          organizationId: Value(branchId),
          itemId: Value(item.id),
          stock: const Value(0),
          sold: const Value(0),
          spoilage: const Value(0),
          isSynced: const Value(false),
        ));
        created++;
      }
    }
    return created;
  }

  // ============================================================================
  // UPDATE OPERATIONS
  // ============================================================================

  /// Update stock record
  Future<bool> updateStock(int id, BranchItemStockCompanion stock) {
    return (update(branchItemStock)..where((s) => s.id.equals(id)))
        .write(stock.copyWith(
          lastUpdated: Value(DateTime.now()),
          isSynced: const Value(false),
        ))
        .then((rows) => rows > 0);
  }

  /// Receive items (add to stock)
  Future<bool> receiveItems(int stockId, int quantity) async {
    final existing = await (select(branchItemStock)
          ..where((s) => s.id.equals(stockId)))
        .getSingleOrNull();

    if (existing == null) return false;

    return (update(branchItemStock)..where((s) => s.id.equals(stockId)))
        .write(BranchItemStockCompanion(
          stock: Value(existing.stock + quantity),
          lastReceivedAt: Value(DateTime.now()),
          lastReceivedQuantity: Value(quantity),
          lastUpdated: Value(DateTime.now()),
          isSynced: const Value(false),
        ))
        .then((rows) => rows > 0);
  }

  /// Record sale (decrease stock, increase sold)
  Future<bool> recordSale(int stockId, int quantity) async {
    final existing = await (select(branchItemStock)
          ..where((s) => s.id.equals(stockId)))
        .getSingleOrNull();

    if (existing == null) return false;
    if (existing.stock < quantity) return false; // Not enough stock

    return (update(branchItemStock)..where((s) => s.id.equals(stockId)))
        .write(BranchItemStockCompanion(
          stock: Value(existing.stock - quantity),
          sold: Value(existing.sold + quantity),
          lastUpdated: Value(DateTime.now()),
          isSynced: const Value(false),
        ))
        .then((rows) => rows > 0);
  }

  /// Record spoilage (decrease stock, increase spoilage)
  Future<bool> recordSpoilage(int stockId, int quantity) async {
    final existing = await (select(branchItemStock)
          ..where((s) => s.id.equals(stockId)))
        .getSingleOrNull();

    if (existing == null) return false;
    if (existing.stock < quantity) return false; // Not enough stock

    return (update(branchItemStock)..where((s) => s.id.equals(stockId)))
        .write(BranchItemStockCompanion(
          stock: Value(existing.stock - quantity),
          spoilage: Value(existing.spoilage + quantity),
          lastUpdated: Value(DateTime.now()),
          isSynced: const Value(false),
        ))
        .then((rows) => rows > 0);
  }

  /// Update branch-specific price
  Future<bool> updatePrice(int stockId, double price, {double? costPrice}) {
    return (update(branchItemStock)..where((s) => s.id.equals(stockId)))
        .write(BranchItemStockCompanion(
          price: Value(price),
          costPrice: costPrice != null ? Value(costPrice) : const Value.absent(),
          lastUpdated: Value(DateTime.now()),
          isSynced: const Value(false),
        ))
        .then((rows) => rows > 0);
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// Mark records as synced
  Future<void> markAsSynced(List<int> ids, {Map<int, String>? cloudIds}) async {
    for (final id in ids) {
      final companion = BranchItemStockCompanion(
        isSynced: const Value(true),
        cloudId: cloudIds?[id] != null ? Value(cloudIds![id]) : const Value.absent(),
      );
      await (update(branchItemStock)..where((s) => s.id.equals(id)))
          .write(companion);
    }
  }

  /// Upsert from cloud (for sync)
  /// SyncEngine provides camelCase keys with resolved local IDs
  Future<void> upsertFromCloud(Map<String, dynamic> data) async {
    final cloudId = (data['cloudId'] ?? data['cloud_id']) as String?;
    if (cloudId == null) throw ArgumentError('cloudId is required');

    // Check if exists by cloud_id
    var existing = await (select(branchItemStock)
          ..where((s) => s.cloudId.equals(cloudId)))
        .getSingleOrNull();

    // SyncEngine already resolves FKs to local IDs with camelCase keys
    final orgId = data['organizationId'] as int?;
    final itemId = data['itemId'] as int?;

    // If not found by cloud_id, try finding by matching composite key (org + item)
    // This handles linking local records that haven't synced their cloud_id yet
    if (existing == null && orgId != null && itemId != null) {
       existing = await (select(branchItemStock)
             ..where((s) => s.organizationId.equals(orgId))
             ..where((s) => s.itemId.equals(itemId)))
           .getSingleOrNull();
    }

    // Protection: Don't overwrite local changes that haven't synced yet (Push-First strategy)
    if (existing != null && !existing.isSynced) {
      return; 
    }

    final companion = BranchItemStockCompanion(
      organizationId: Value(orgId ?? existing?.organizationId ?? 0),
      itemId: Value(itemId ?? existing?.itemId ?? 0),
      stock: Value((data['stock'] as num?)?.toInt() ?? 0),
      sold: Value((data['sold'] as num?)?.toInt() ?? 0),
      spoilage: Value((data['spoilage'] as num?)?.toInt() ?? 0),
      price: data['price'] != null ? Value((data['price'] as num).toDouble()) : const Value.absent(),
      costPrice: data['costPrice'] != null ? Value((data['costPrice'] as num).toDouble()) : const Value.absent(),
      minimumStock: data['minimumStock'] != null ? Value((data['minimumStock'] as num).toInt()) : const Value.absent(),
      lastReceivedAt: data['lastReceivedAt'] != null 
          ? Value(data['lastReceivedAt'] is DateTime 
              ? data['lastReceivedAt'] as DateTime 
              : DateTime.parse(data['lastReceivedAt'] as String))
          : const Value.absent(),
      lastReceivedQuantity: data['lastReceivedQuantity'] != null 
          ? Value((data['lastReceivedQuantity'] as num).toInt())
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
      await (update(branchItemStock)..where((s) => s.id.equals(existing!.id)))
          .write(companion);
    } else {
      await into(branchItemStock).insert(companion);
    }
  }

  /// Batch upsert from cloud
  Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> dataList) async {
    await batch((b) async {
      for (final data in dataList) {
        await upsertFromCloud(data);
      }
    });
  }

  /// Get by cloud ID (for SyncEngine compatibility)
  Future<BranchItemStockData?> getByCloudId(String cloudId) {
    return (select(branchItemStock)..where((s) => s.cloudId.equals(cloudId)))
        .getSingleOrNull();
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  /// Soft delete a stock record
  Future<bool> softDelete(int id) {
    return (update(branchItemStock)..where((s) => s.id.equals(id)))
        .write(const BranchItemStockCompanion(
          isDeleted: Value(true),
          lastUpdated: Value.absent(),
          isSynced: Value(false),
        ))
        .then((rows) => rows > 0);
  }

  /// Hard delete synced soft-deleted records
  Future<int> cleanupDeleted() {
    return (delete(branchItemStock)
          ..where((s) => s.isDeleted.equals(true))
          ..where((s) => s.isSynced.equals(true)))
        .go();
  }
}
