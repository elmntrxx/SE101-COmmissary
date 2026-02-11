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

  /// Get ingredient by name (case-insensitive)
  Future<Ingredient?> getIngredientByName(
    String name, {
    int? commissaryId,
  }) async {
    final query = select(ingredients)
      ..where((i) => i.name.lower().equals(name.toLowerCase()) & i.isActive.equals(true));

    if (commissaryId != null) {
      query.where((i) => i.commissaryId.equals(commissaryId));
    }

    return query.getSingleOrNull();
  }

  /// Create a new ingredient
  /// Throws an exception if an ingredient with the same name already exists
  Future<int> createIngredient(IngredientsCompanion ingredient) async {
    // Check for duplicate ingredient name
    final name = ingredient.name.value;
    final commissaryId = ingredient.commissaryId.value;
    
    final existingIngredient = await getIngredientByName(
      name,
      commissaryId: commissaryId,
    );
    if (existingIngredient != null) {
      throw Exception('An ingredient with the name "$name" already exists');
    }
    
    return into(ingredients).insert(ingredient);
  }

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

  // ============================================================================
  // SYNC METHODS (for SyncEngine compatibility)
  // ============================================================================

  /// Upsert a single ingredient from cloud data
  /// SyncEngine provides camelCase keys with resolved local IDs
  Future<int> upsertFromCloud(Map<String, dynamic> cloudData) async {
    final cloudId = (cloudData['cloudId'] ?? cloudData['cloud_id']) as String?;
    if (cloudId == null) throw ArgumentError('cloudId is required');

    final existing = await getIngredientByCloudId(cloudId);

    // Protect local unsynced changes from being overwritten
    if (existing != null && existing.needsSync) {
      return existing.id;
    }

    // SyncEngine already resolves FKs to local IDs with camelCase keys
    final commId = cloudData['commissaryId'] as int?;

    final companion = IngredientsCompanion(
      cloudId: Value(cloudId),
      commissaryId: Value(commId ?? existing?.commissaryId ?? 0),
      name: Value(cloudData['name'] as String? ?? 'Unknown'),
      unit: Value(cloudData['unit'] as String? ?? 'pcs'),
      stock: Value((cloudData['stock'] as num?)?.toDouble() ?? 0.0),
      costPerUnit: Value((cloudData['costPerUnit'] as num?)?.toDouble() ?? 0.0),
      criticalLevel: Value((cloudData['criticalLevel'] as num?)?.toDouble() ?? 10.0),
      isActive: Value(cloudData['isActive'] as bool? ?? true),
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
      await (update(ingredients)..where((i) => i.id.equals(existing.id))).write(companion);
      return existing.id;
    } else {
      return into(ingredients).insert(companion);
    }
  }

  /// Upsert batch of ingredients from cloud data
  Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> cloudDataList) async {
    for (final cloudData in cloudDataList) {
      await upsertFromCloud(cloudData);
    }
  }
}
