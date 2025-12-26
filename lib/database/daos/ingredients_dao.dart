// lib/database/daos/ingredients_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/ingredients.dart';

part 'ingredients_dao.g.dart';

@DriftAccessor(tables: [Ingredients])
class IngredientsDao extends DatabaseAccessor<AppDatabase>
    with _$IngredientsDaoMixin {
  IngredientsDao(super.db);

  // ============================================================================
  // QUERIES
  // ============================================================================

  /// Get all ingredients
  Future<List<Ingredient>> getAllIngredients() => select(ingredients).get();

  /// Watch all ingredients
  Stream<List<Ingredient>> watchAllIngredients() => select(ingredients).watch();

  /// Get ingredients by commissary
  Future<List<Ingredient>> getIngredientsByCommissary(int commissaryId) {
    return (select(ingredients)
          ..where((i) => i.commissaryId.equals(commissaryId))
          ..where((i) => i.isActive.equals(true)))
        .get();
  }

  /// Watch ingredients by commissary
  Stream<List<Ingredient>> watchIngredientsByCommissary(int commissaryId) {
    return (select(ingredients)
          ..where((i) => i.commissaryId.equals(commissaryId))
          ..where((i) => i.isActive.equals(true)))
        .watch();
  }

  /// Get ingredient by ID
  Future<Ingredient?> getIngredientById(int id) {
    return (select(ingredients)..where((i) => i.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get low stock ingredients
  Future<List<Ingredient>> getLowStockIngredients(int commissaryId) {
    return customSelect(
      'SELECT * FROM ingredients WHERE commissary_id = ? AND stock <= critical_level AND is_active = 1',
      variables: [Variable.withInt(commissaryId)],
      readsFrom: {ingredients},
    ).map((row) => ingredients.map(row.data)).get();
  }

  // ============================================================================
  // MUTATIONS
  // ============================================================================

  /// Create a new ingredient
  Future<int> createIngredient(IngredientsCompanion ingredient) =>
      into(ingredients).insert(ingredient);

  /// Update an ingredient
  Future<bool> updateIngredient(Ingredient ingredient) =>
      update(ingredients).replace(ingredient);

  /// Update stock
  Future<int> updateStock(int id, double newStock) {
    return (update(ingredients)..where((i) => i.id.equals(id))).write(
      IngredientsCompanion(
        stock: Value(newStock),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Deactivate ingredient (soft delete)
  Future<int> deactivateIngredient(int id) {
    return (update(ingredients)..where((i) => i.id.equals(id))).write(
      IngredientsCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Get unsynced ingredients
  Future<List<Ingredient>> getUnsyncedIngredients() {
    return (select(ingredients)..where((i) => i.needsSync.equals(true))).get();
  }

  /// Mark as synced
  Future<int> markAsSynced(int id, DateTime syncTime) {
    return (update(ingredients)..where((i) => i.id.equals(id))).write(
      IngredientsCompanion(
        lastSyncedAt: Value(syncTime),
        needsSync: const Value(false),
      ),
    );
  }
}
