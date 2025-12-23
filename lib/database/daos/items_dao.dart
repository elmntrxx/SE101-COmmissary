// lib/database/daos/items_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/items.dart';

part 'items_dao.g.dart';

@DriftAccessor(tables: [Items])
class ItemsDao extends DatabaseAccessor<AppDatabase> with _$ItemsDaoMixin {
  ItemsDao(super.db);

  // ============================================================================
  // QUERIES
  // ============================================================================

  /// Get all items
  Future<List<Item>> getAllItems() => select(items).get();

  /// Watch all items
  Stream<List<Item>> watchAllItems() => select(items).watch();

  /// Get items by organization
  Future<List<Item>> getItemsByOrganization(int organizationId) {
    return (select(items)
          ..where((i) => i.organizationId.equals(organizationId))
          ..where((i) => i.isActive.equals(true)))
        .get();
  }

  /// Watch items by organization
  Stream<List<Item>> watchItemsByOrganization(int organizationId) {
    return (select(items)
          ..where((i) => i.organizationId.equals(organizationId))
          ..where((i) => i.isActive.equals(true)))
        .watch();
  }

  /// Get master items only (commissary items without masterItemId)
  Future<List<Item>> getMasterItems(int commissaryOrgId) {
    return (select(items)
          ..where((i) => i.organizationId.equals(commissaryOrgId))
          ..where((i) => i.masterItemId.isNull())
          ..where((i) => i.isActive.equals(true)))
        .get();
  }

  /// Get item by ID
  Future<Item?> getItemById(int id) {
    return (select(items)..where((i) => i.id.equals(id))).getSingleOrNull();
  }

  /// Get item by cloud ID
  Future<Item?> getItemByCloudId(String cloudId) {
    return (select(items)..where((i) => i.cloudId.equals(cloudId)))
        .getSingleOrNull();
  }

  /// Get items with low stock (at or below critical level)
  Future<List<Item>> getLowStockItems(int organizationId) {
    return customSelect(
      'SELECT * FROM items WHERE organization_id = ? AND stock <= critical_level AND is_active = 1',
      variables: [Variable.withInt(organizationId)],
      readsFrom: {items},
    ).map((row) => items.map(row.data)).get();
  }

  // ============================================================================
  // MUTATIONS
  // ============================================================================

  /// Create a new item
  Future<int> createItem(ItemsCompanion item) => into(items).insert(item);

  /// Update an item
  Future<bool> updateItem(Item item) => update(items).replace(item);

  /// Update stock
  Future<int> updateStock(int id, int newStock) {
    return (update(items)..where((i) => i.id.equals(id))).write(
      ItemsCompanion(
        stock: Value(newStock),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Record a sale
  Future<void> recordSale(int id, int quantity) async {
    final item = await getItemById(id);
    if (item == null) return;

    await (update(items)..where((i) => i.id.equals(id))).write(
      ItemsCompanion(
        stock: Value(item.stock - quantity),
        sold: Value(item.sold + quantity),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Record spoilage
  Future<void> recordSpoilage(int id, int quantity) async {
    final item = await getItemById(id);
    if (item == null) return;

    await (update(items)..where((i) => i.id.equals(id))).write(
      ItemsCompanion(
        stock: Value(item.stock - quantity),
        spoilage: Value(item.spoilage + quantity),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Deactivate item (soft delete)
  Future<int> deactivateItem(int id) {
    return (update(items)..where((i) => i.id.equals(id))).write(
      ItemsCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Get unsynced items
  Future<List<Item>> getUnsyncedItems() {
    return (select(items)..where((i) => i.needsSync.equals(true))).get();
  }

  /// Mark as synced
  Future<int> markAsSynced(int id, DateTime syncTime) {
    return (update(items)..where((i) => i.id.equals(id))).write(
      ItemsCompanion(
        lastSyncedAt: Value(syncTime),
        needsSync: const Value(false),
      ),
    );
  }
}
