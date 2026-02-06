// lib/database/daos/categories_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  // ============================================================================
  // QUERIES
  // ============================================================================

  /// Get all categories
  Future<List<Category>> getAllCategories() =>
      (select(categories)..where((c) => c.isDeleted.equals(false))).get();

  /// Watch all categories
  Stream<List<Category>> watchAllCategories() =>
      (select(categories)..where((c) => c.isDeleted.equals(false))).watch();

  /// Get category by ID
  Future<Category?> getCategoryById(int id) async {
    final results = await (select(categories)
          ..where((c) => c.id.equals(id))
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  /// Get category by cloud ID
  Future<Category?> getCategoryByCloudId(String cloudId) async {
    final results = await (select(categories)
          ..where((c) => c.cloudId.equals(cloudId))
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  // ============================================================================
  // MUTATIONS
  // ============================================================================

  /// Create a new category
  Future<int> createCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  /// Update a category
  Future<bool> updateCategory(Category category) =>
      update(categories).replace(category);

  /// Soft delete a category
  Future<int> deleteCategory(int id) {
    return (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Get unsynced categories
  Future<List<Category>> getUnsyncedCategories() {
    return (select(categories)..where((c) => c.needsSync.equals(true))).get();
  }

  /// Mark as synced
  Future<int> markAsSynced(int id, DateTime syncTime) {
    return (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        lastSyncedAt: Value(syncTime),
        needsSync: const Value(false),
      ),
    );
  }

  // ============================================================================
  // SYNC METHODS (for SyncEngine compatibility)
  // ============================================================================

  /// Upsert a single category from cloud data
  /// SyncEngine provides camelCase keys
  Future<int> upsertFromCloud(Map<String, dynamic> cloudData) async {
    final cloudId = (cloudData['cloudId'] ?? cloudData['cloud_id']) as String?;
    if (cloudId == null) throw ArgumentError('cloudId is required');

    final existing = await getCategoryByCloudId(cloudId);

    // Protect local unsynced changes from being overwritten
    if (existing != null && existing.needsSync) {
      return existing.id;
    }

    final companion = CategoriesCompanion(
      cloudId: Value(cloudId),
      name: Value(cloudData['name'] as String? ?? 'Unknown'),
      description: Value(cloudData['description'] as String?),
      isDeleted: Value(cloudData['isDeleted'] as bool? ?? false),
      createdAt: cloudData['createdAt'] != null
          ? Value(cloudData['createdAt'] is DateTime 
              ? cloudData['createdAt'] as DateTime 
              : DateTime.parse(cloudData['createdAt'] as String))
          : Value(DateTime.now()),
      updatedAt: cloudData['updatedAt'] != null
          ? Value(cloudData['updatedAt'] is DateTime 
              ? cloudData['updatedAt'] as DateTime 
              : DateTime.parse(cloudData['updatedAt'] as String))
          : Value(DateTime.now()),
      lastSyncedAt: Value(DateTime.now()),
      needsSync: const Value(false),
    );

    if (existing != null) {
      await (update(categories)..where((c) => c.id.equals(existing.id))).write(companion);
      return existing.id;
    } else {
      return into(categories).insert(companion);
    }
  }

  /// Upsert batch of categories from cloud data
  Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> cloudDataList) async {
    for (final cloudData in cloudDataList) {
      await upsertFromCloud(cloudData);
    }
  }
}
