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
  Future<Category?> getCategoryById(int id) {
    return (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// Get category by cloud ID
  Future<Category?> getCategoryByCloudId(String cloudId) {
    return (select(categories)..where((c) => c.cloudId.equals(cloudId)))
        .getSingleOrNull();
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
}
