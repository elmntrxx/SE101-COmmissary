// lib/database/daos/recipe_ingredients_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/recipe_ingredients.dart';
import '../tables/items.dart';
import '../tables/ingredients.dart';
import '../models/recipe_ingredient_detail.dart';

part 'recipe_ingredients_dao.g.dart';

/// RecipeIngredientsDao - Manage recipe compositions (what ingredients make up each item)
///
/// Business Logic:
/// - Links Items (final products) to Ingredients (raw materials)
/// - Tracks quantity of each ingredient needed per item
/// - Used to calculate ingredient requirements when producing items
/// - Used to check if enough ingredients are available
@DriftAccessor(tables: [RecipeIngredients, Items, Ingredients])
class RecipeIngredientsDao extends DatabaseAccessor<AppDatabase>
    with _$RecipeIngredientsDaoMixin {
  RecipeIngredientsDao(super.db);

  // ============================================================================
  // QUERIES
  // ============================================================================

  /// Get all recipe ingredients for an item
  Future<List<RecipeIngredient>> getRecipeIngredients(int itemId) {
    return (select(recipeIngredients)
          ..where((r) => r.itemId.equals(itemId)))
        .get();
  }

  /// Watch recipe ingredients for an item
  Stream<List<RecipeIngredient>> watchRecipeIngredients(int itemId) {
    return (select(recipeIngredients)
          ..where((r) => r.itemId.equals(itemId)))
        .watch();
  }

  /// Get recipe ingredient by ID
  Future<RecipeIngredient?> getRecipeIngredientById(int id) {
    return (select(recipeIngredients)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get recipe ingredients with full ingredient details
  Future<List<RecipeIngredientDetail>> getRecipeWithDetails(int itemId) async {
    final query = select(recipeIngredients).join([
      innerJoin(ingredients, ingredients.id.equalsExp(recipeIngredients.ingredientId)),
    ])..where(recipeIngredients.itemId.equals(itemId));

    final results = await query.get();

    return results.map((row) {
      final recipe = row.readTable(recipeIngredients);
      final ingredient = row.readTable(ingredients);
      return RecipeIngredientDetail(
        recipeIngredient: recipe,
        ingredient: ingredient,
      );
    }).toList();
  }

  /// Watch recipe with details
  Stream<List<RecipeIngredientDetail>> watchRecipeWithDetails(int itemId) {
    final query = select(recipeIngredients).join([
      innerJoin(ingredients, ingredients.id.equalsExp(recipeIngredients.ingredientId)),
    ])..where(recipeIngredients.itemId.equals(itemId));

    return query.watch().map((results) {
      return results.map((row) {
        final recipe = row.readTable(recipeIngredients);
        final ingredient = row.readTable(ingredients);
        return RecipeIngredientDetail(
          recipeIngredient: recipe,
          ingredient: ingredient,
        );
      }).toList();
    });
  }

  /// Get items that use a specific ingredient
  Future<List<Item>> getItemsUsingIngredient(int ingredientId) async {
    final query = select(recipeIngredients).join([
      innerJoin(items, items.id.equalsExp(recipeIngredients.itemId)),
    ])..where(recipeIngredients.ingredientId.equals(ingredientId));

    final results = await query.get();
    return results.map((row) => row.readTable(items)).toList();
  }

  /// Check if ingredient is used in any recipe
  Future<bool> isIngredientUsed(int ingredientId) async {
    final result = await (select(recipeIngredients)
          ..where((r) => r.ingredientId.equals(ingredientId))
          ..limit(1))
        .get();
    return result.isNotEmpty;
  }

  /// Calculate total cost of a recipe
  Future<double> calculateRecipeCost(int itemId) async {
    final result = await customSelect(
      '''
      SELECT COALESCE(SUM(ri.quantity * i.cost_per_unit), 0) as total_cost
      FROM recipe_ingredients ri
      JOIN ingredients i ON ri.ingredient_id = i.id
      WHERE ri.item_id = ?
      ''',
      variables: [Variable.withInt(itemId)],
      readsFrom: {recipeIngredients, ingredients},
    ).getSingle();
    
    return result.data['total_cost'] as double? ?? 0.0;
  }

  /// Get cost breakdown for a recipe
  Future<List<CostBreakdownItem>> getCostBreakdown(int itemId) async {
    final details = await getRecipeWithDetails(itemId);
    final totalCost = details.fold(0.0, (sum, d) => sum + d.totalCost);

    return details.map((detail) {
      return CostBreakdownItem(
        ingredientName: detail.ingredientName,
        quantity: detail.quantity,
        unit: detail.unit,
        costPerUnit: detail.costPerUnit,
        totalCost: detail.totalCost,
        percentageOfTotal: totalCost > 0
            ? (detail.totalCost / totalCost) * 100
            : 0,
      );
    }).toList();
  }

  /// Check if ingredients are sufficient for production
  Future<bool> canProduce(int itemId, int quantity) async {
    final details = await getRecipeWithDetails(itemId);
    if (details.isEmpty) return true;

    return details.every((detail) => detail.hasEnoughStock(quantity));
  }

  /// Get insufficient ingredients for production
  Future<List<IngredientStockAlert>> getInsufficientIngredients(
    int itemId,
    int quantity,
  ) async {
    final details = await getRecipeWithDetails(itemId);
    final alerts = <IngredientStockAlert>[];

    for (final detail in details) {
      final requiredQuantity = detail.quantity * quantity;
      if (detail.currentStock < requiredQuantity) {
        alerts.add(IngredientStockAlert(
          ingredient: detail.ingredient,
          requiredQuantity: requiredQuantity,
          shortfall: requiredQuantity - detail.currentStock,
        ));
      }
    }

    return alerts;
  }

  /// Get maximum production quantity based on ingredient availability
  Future<int> getMaxProductionQuantity(int itemId) async {
    final details = await getRecipeWithDetails(itemId);
    if (details.isEmpty) return 0;

    return details
        .map((detail) => detail.maxProductionQuantity())
        .reduce((a, b) => a < b ? a : b);
  }

  // ============================================================================
  // MUTATIONS
  // ============================================================================

  /// Create a recipe ingredient
  Future<int> createRecipeIngredient(RecipeIngredientsCompanion companion) {
    return into(recipeIngredients).insert(companion);
  }

  /// Delete all recipe ingredients for an item
  Future<int> deleteRecipeForItem(int itemId) {
    return (delete(recipeIngredients)
          ..where((r) => r.itemId.equals(itemId)))
        .go();
  }

  /// Add ingredient to recipe
  Future<int> addIngredientToRecipe({
    required int itemId,
    required int ingredientId,
    required double quantity,
    required String cloudId,
  }) async {
    final id = await into(recipeIngredients).insert(
      RecipeIngredientsCompanion.insert(
        cloudId: cloudId,
        itemId: itemId,
        ingredientId: ingredientId,
        quantity: quantity,
      ),
    );

    // Update item cost after adding ingredient
    await db.itemsDao.updateItemCost(itemId);

    return id;
  }

  /// Update ingredient quantity in recipe
  Future<int> updateRecipeIngredient({
    required int id,
    required double quantity,
  }) async {
    final recipe = await getRecipeIngredientById(id);
    if (recipe == null) return 0;

    final result = await (update(recipeIngredients)
          ..where((r) => r.id.equals(id)))
        .write(RecipeIngredientsCompanion(
      quantity: Value(quantity),
      updatedAt: Value(DateTime.now()),
      needsSync: const Value(true),
    ));

    // Update item cost after modifying recipe
    await db.itemsDao.updateItemCost(recipe.itemId);

    return result;
  }

  /// Remove ingredient from recipe
  Future<int> removeIngredientFromRecipe(int id) async {
    final recipe = await getRecipeIngredientById(id);
    if (recipe == null) return 0;

    final itemId = recipe.itemId;
    final result = await (delete(recipeIngredients)
          ..where((r) => r.id.equals(id)))
        .go();

    // Update item cost after removing ingredient
    await db.itemsDao.updateItemCost(itemId);

    return result;
  }

  /// Clear all ingredients from a recipe
  Future<int> clearRecipe(int itemId) async {
    final result = await (delete(recipeIngredients)
          ..where((r) => r.itemId.equals(itemId)))
        .go();

    // Update item cost after clearing recipe
    await db.itemsDao.updateItemCost(itemId);

    return result;
  }

  /// Batch add ingredients to recipe
  Future<void> setRecipeIngredients({
    required int itemId,
    required List<RecipeIngredientInput> ingredientInputs,
  }) async {
    await transaction(() async {
      // Clear existing recipe
      await (delete(recipeIngredients)
            ..where((r) => r.itemId.equals(itemId)))
          .go();

      // Add new ingredients
      for (final input in ingredientInputs) {
        await into(recipeIngredients).insert(
          RecipeIngredientsCompanion.insert(
            cloudId: input.cloudId,
            itemId: itemId,
            ingredientId: input.ingredientId,
            quantity: input.quantity,
          ),
        );
      }
    });

    // Update item cost
    await db.itemsDao.updateItemCost(itemId);
  }

  /// Deduct ingredients for production
  Future<bool> deductIngredientsForProduction(int itemId, int quantity) async {
    final details = await getRecipeWithDetails(itemId);
    if (details.isEmpty) return true;

    // Check if all ingredients have sufficient stock
    for (final detail in details) {
      if (!detail.hasEnoughStock(quantity)) {
        return false;
      }
    }

    // Deduct ingredients
    final deductions = <int, double>{};
    for (final detail in details) {
      deductions[detail.ingredient.id] = detail.quantity * quantity;
    }

    return db.ingredientsDao.batchDeductStock(deductions);
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// Get unsynced recipe ingredients
  Future<List<RecipeIngredient>> getUnsyncedRecipeIngredients() {
    return (select(recipeIngredients)
          ..where((r) => r.needsSync.equals(true)))
        .get();
  }

  /// Mark as synced
  Future<int> markAsSynced(int id, DateTime syncTime) {
    return (update(recipeIngredients)..where((r) => r.id.equals(id))).write(
      RecipeIngredientsCompanion(
        lastSyncedAt: Value(syncTime),
        needsSync: const Value(false),
      ),
    );
  }
}

/// Input model for recipe ingredient
class RecipeIngredientInput {
  final int ingredientId;
  final double quantity;
  final String cloudId;

  RecipeIngredientInput({
    required this.ingredientId,
    required this.quantity,
    required this.cloudId,
  });
}
