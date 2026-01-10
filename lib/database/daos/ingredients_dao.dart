// lib/database/daos/ingredients_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/ingredients.dart';

part 'ingredients_dao.g.dart';

/// Sort order for ingredients
enum IngredientSortOrder {
  nameAsc,
  nameDesc,
  stockAsc,
  stockDesc,
  costAsc,
  costDesc,
  newestFirst,
  oldestFirst,
}

@DriftAccessor(tables: [Ingredients])
class IngredientsDao extends DatabaseAccessor<AppDatabase>
    with _$IngredientsDaoMixin {
  IngredientsDao(super.db);

  // ============================================================================
  // QUERIES
  // ============================================================================

  /// Get all ingredients with optional sorting and filtering
  Future<List<Ingredient>> getAllIngredients({
    String? searchQuery,
    IngredientSortOrder sortOrder = IngredientSortOrder.nameAsc,
    bool activeOnly = true,
  }) async {
    final query = select(ingredients);
    
    if (activeOnly) {
      query.where((i) => i.isActive.equals(true));
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where((i) => i.name.contains(searchQuery));
    }
    
    query.orderBy([
      (t) {
        switch (sortOrder) {
          case IngredientSortOrder.nameAsc:
            return OrderingTerm(expression: t.name, mode: OrderingMode.asc);
          case IngredientSortOrder.nameDesc:
            return OrderingTerm(expression: t.name, mode: OrderingMode.desc);
          case IngredientSortOrder.stockAsc:
            return OrderingTerm(expression: t.stock, mode: OrderingMode.asc);
          case IngredientSortOrder.stockDesc:
            return OrderingTerm(expression: t.stock, mode: OrderingMode.desc);
          case IngredientSortOrder.costAsc:
            return OrderingTerm(expression: t.costPerUnit, mode: OrderingMode.asc);
          case IngredientSortOrder.costDesc:
            return OrderingTerm(expression: t.costPerUnit, mode: OrderingMode.desc);
          case IngredientSortOrder.newestFirst:
            return OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc);
          case IngredientSortOrder.oldestFirst:
            return OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc);
        }
      },
    ]);
    
    return query.get();
  }

  /// Watch all active ingredients
  Stream<List<Ingredient>> watchAllIngredients({bool activeOnly = true}) {
    final query = select(ingredients);
    if (activeOnly) {
      query.where((i) => i.isActive.equals(true));
    }
    query.orderBy([(t) => OrderingTerm(expression: t.name)]);
    return query.watch();
  }

  /// Get ingredients by commissary
  Future<List<Ingredient>> getIngredientsByCommissary(int commissaryId) {
    return (select(ingredients)
          ..where((i) => i.commissaryId.equals(commissaryId))
          ..where((i) => i.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  /// Watch ingredients by commissary
  Stream<List<Ingredient>> watchIngredientsByCommissary(int commissaryId) {
    return (select(ingredients)
          ..where((i) => i.commissaryId.equals(commissaryId))
          ..where((i) => i.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  /// Get ingredient by ID
  Future<Ingredient?> getIngredientById(int id) {
    return (select(ingredients)..where((i) => i.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get ingredient by cloud ID
  Future<Ingredient?> getIngredientByCloudId(String cloudId) {
    return (select(ingredients)..where((i) => i.cloudId.equals(cloudId)))
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

  /// Watch low stock ingredients
  Stream<List<Ingredient>> watchLowStockIngredients(int commissaryId) {
    return customSelect(
      'SELECT * FROM ingredients WHERE commissary_id = ? AND stock <= critical_level AND is_active = 1',
      variables: [Variable.withInt(commissaryId)],
      readsFrom: {ingredients},
    ).map((row) => ingredients.map(row.data)).watch();
  }

  /// Search ingredients by name
  Future<List<Ingredient>> searchIngredients(String query, {int? commissaryId}) {
    final q = select(ingredients)
      ..where((i) => i.name.contains(query))
      ..where((i) => i.isActive.equals(true));
    
    if (commissaryId != null) {
      q.where((i) => i.commissaryId.equals(commissaryId));
    }
    
    return q.get();
  }

  /// Get total value of ingredient inventory
  Future<double> getTotalInventoryValue(int commissaryId) async {
    final result = await customSelect(
      'SELECT SUM(stock * cost_per_unit) as total_value FROM ingredients WHERE commissary_id = ? AND is_active = 1',
      variables: [Variable.withInt(commissaryId)],
      readsFrom: {ingredients},
    ).getSingle();
    return result.data['total_value'] as double? ?? 0.0;
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

  /// Adjust stock (add or subtract)
  Future<int> adjustStock(int id, double adjustment) async {
    final ingredient = await getIngredientById(id);
    if (ingredient == null) return 0;
    
    final newStock = ingredient.stock + adjustment;
    return updateStock(id, newStock < 0 ? 0 : newStock);
  }

  /// Update cost per unit
  Future<int> updateCostPerUnit(int id, double newCost) {
    return (update(ingredients)..where((i) => i.id.equals(id))).write(
      IngredientsCompanion(
        costPerUnit: Value(newCost),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Batch update cost per unit for multiple ingredients
  Future<void> batchUpdateCosts(Map<int, double> costUpdates) async {
    await transaction(() async {
      for (final entry in costUpdates.entries) {
        await updateCostPerUnit(entry.key, entry.value);
      }
    });
  }

  /// Deduct stock for production
  Future<bool> deductStockForProduction(int id, double quantity) async {
    final ingredient = await getIngredientById(id);
    if (ingredient == null) return false;
    
    if (ingredient.stock < quantity) return false;
    
    await updateStock(id, ingredient.stock - quantity);
    return true;
  }

  /// Batch deduct stock for production (used when producing items)
  Future<bool> batchDeductStock(Map<int, double> deductions) async {
    // First verify all ingredients have sufficient stock
    for (final entry in deductions.entries) {
      final ingredient = await getIngredientById(entry.key);
      if (ingredient == null || ingredient.stock < entry.value) {
        return false;
      }
    }
    
    // Deduct all in a transaction
    await transaction(() async {
      for (final entry in deductions.entries) {
        final ingredient = await getIngredientById(entry.key);
        if (ingredient != null) {
          await updateStock(entry.key, ingredient.stock - entry.value);
        }
      }
    });
    
    return true;
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

  /// Soft delete ingredient (alias for deactivateIngredient)
  Future<int> softDeleteIngredient(int id) => deactivateIngredient(id);

  /// Reactivate ingredient
  Future<int> reactivateIngredient(int id) {
    return (update(ingredients)..where((i) => i.id.equals(id))).write(
      IngredientsCompanion(
        isActive: const Value(true),
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
