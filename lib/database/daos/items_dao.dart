// lib/database/daos/items_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/items.dart';
import '../tables/categories.dart';
import '../tables/ingredients.dart';
import '../tables/recipe_ingredients.dart';
import '../models/item_with_category.dart';
import '../models/recipe_ingredient_detail.dart';

part 'items_dao.g.dart';

/// Sort order for items
enum ItemSortOrder {
  nameAsc,
  nameDesc,
  stockAsc,
  stockDesc,
  priceAsc,
  priceDesc,
  costAsc,
  costDesc,
  newestFirst,
  oldestFirst,
}

@DriftAccessor(tables: [Items, Categories, Ingredients, RecipeIngredients])
class ItemsDao extends DatabaseAccessor<AppDatabase> with _$ItemsDaoMixin {
  ItemsDao(super.db);

  // ============================================================================
  // QUERIES
  // ============================================================================

  /// Get all items with optional sorting and filtering
  Future<List<Item>> getAllItems({
    String? searchQuery,
    int? categoryId,
    ItemSortOrder sortOrder = ItemSortOrder.nameAsc,
    bool activeOnly = true,
  }) async {
    final query = select(items);
    
    if (activeOnly) {
      query.where((i) => i.isActive.equals(true));
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where((i) => i.name.contains(searchQuery));
    }
    
    if (categoryId != null) {
      query.where((i) => i.categoryId.equals(categoryId));
    }
    
    query.orderBy([
      (t) {
        switch (sortOrder) {
          case ItemSortOrder.nameAsc:
            return OrderingTerm(expression: t.name, mode: OrderingMode.asc);
          case ItemSortOrder.nameDesc:
            return OrderingTerm(expression: t.name, mode: OrderingMode.desc);
          case ItemSortOrder.stockAsc:
            return OrderingTerm(expression: t.stock, mode: OrderingMode.asc);
          case ItemSortOrder.stockDesc:
            return OrderingTerm(expression: t.stock, mode: OrderingMode.desc);
          case ItemSortOrder.priceAsc:
            return OrderingTerm(expression: t.price, mode: OrderingMode.asc);
          case ItemSortOrder.priceDesc:
            return OrderingTerm(expression: t.price, mode: OrderingMode.desc);
          case ItemSortOrder.costAsc:
            return OrderingTerm(expression: t.cost, mode: OrderingMode.asc);
          case ItemSortOrder.costDesc:
            return OrderingTerm(expression: t.cost, mode: OrderingMode.desc);
          case ItemSortOrder.newestFirst:
            return OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc);
          case ItemSortOrder.oldestFirst:
            return OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc);
        }
      },
    ]);
    
    return query.get();
  }

  /// Watch all items
  Stream<List<Item>> watchAllItems({bool activeOnly = true}) {
    final query = select(items);
    if (activeOnly) {
      query.where((i) => i.isActive.equals(true));
    }
    query.orderBy([(t) => OrderingTerm(expression: t.name)]);
    return query.watch();
  }

  /// Get items by organization
  Future<List<Item>> getItemsByOrganization(int organizationId) {
    return (select(items)
          ..where((i) => i.organizationId.equals(organizationId))
          ..where((i) => i.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  /// Watch items by organization
  Stream<List<Item>> watchItemsByOrganization(int organizationId) {
    return (select(items)
          ..where((i) => i.organizationId.equals(organizationId))
          ..where((i) => i.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  /// Get master items only (commissary items without masterItemId)
  Future<List<Item>> getMasterItems(int commissaryOrgId) {
    return (select(items)
          ..where((i) => i.organizationId.equals(commissaryOrgId))
          ..where((i) => i.masterItemId.isNull())
          ..where((i) => i.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
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

  /// Watch low stock items
  Stream<List<Item>> watchLowStockItems(int organizationId) {
    return customSelect(
      'SELECT * FROM items WHERE organization_id = ? AND stock <= critical_level AND is_active = 1',
      variables: [Variable.withInt(organizationId)],
      readsFrom: {items},
    ).map((row) => items.map(row.data)).watch();
  }

  /// Get items with categories
  Future<List<ItemWithCategory>> getItemsWithCategories({
    int? organizationId,
    String? searchQuery,
    int? categoryId,
    bool activeOnly = true,
  }) async {
    final query = select(items).join([
      leftOuterJoin(categories, categories.id.equalsExp(items.categoryId)),
    ]);

    if (activeOnly) {
      query.where(items.isActive.equals(true));
    }

    if (organizationId != null) {
      query.where(items.organizationId.equals(organizationId));
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where(items.name.contains(searchQuery));
    }

    if (categoryId != null) {
      query.where(items.categoryId.equals(categoryId));
    }

    query.orderBy([OrderingTerm(expression: items.name)]);

    final results = await query.get();
    return results.map((row) {
      final item = row.readTable(items);
      final category = row.readTableOrNull(categories);
      return ItemWithCategory(item: item, category: category);
    }).toList();
  }

  /// Watch items with categories
  Stream<List<ItemWithCategory>> watchItemsWithCategories({
    int? organizationId,
    bool activeOnly = true,
  }) {
    final query = select(items).join([
      leftOuterJoin(categories, categories.id.equalsExp(items.categoryId)),
    ]);

    if (activeOnly) {
      query.where(items.isActive.equals(true));
    }

    if (organizationId != null) {
      query.where(items.organizationId.equals(organizationId));
    }

    query.orderBy([OrderingTerm(expression: items.name)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final item = row.readTable(items);
        final category = row.readTableOrNull(categories);
        return ItemWithCategory(item: item, category: category);
      }).toList();
    });
  }

  /// Get item with full recipe details
  Future<ItemWithRecipe?> getItemWithRecipe(int itemId) async {
    final item = await getItemById(itemId);
    if (item == null) return null;

    final recipeQuery = select(recipeIngredients).join([
      innerJoin(ingredients, ingredients.id.equalsExp(recipeIngredients.ingredientId)),
    ])..where(recipeIngredients.itemId.equals(itemId));

    final results = await recipeQuery.get();

    final recipeDetails = results.map((row) {
      final recipe = row.readTable(recipeIngredients);
      final ingredient = row.readTable(ingredients);
      return RecipeIngredientDetail(
        recipeIngredient: recipe,
        ingredient: ingredient,
      );
    }).toList();

    return ItemWithRecipe(item: item, recipeDetails: recipeDetails);
  }

  /// Watch item with recipe
  Stream<ItemWithRecipe?> watchItemWithRecipe(int itemId) {
    final itemStream = (select(items)..where((i) => i.id.equals(itemId))).watchSingleOrNull();
    final recipeStream = (select(recipeIngredients).join([
      innerJoin(ingredients, ingredients.id.equalsExp(recipeIngredients.ingredientId)),
    ])..where(recipeIngredients.itemId.equals(itemId))).watch();

    return itemStream.asyncMap((item) async {
      if (item == null) return null;

      final results = await recipeStream.first;
      final recipeDetails = results.map((row) {
        final recipe = row.readTable(recipeIngredients);
        final ingredient = row.readTable(ingredients);
        return RecipeIngredientDetail(
          recipeIngredient: recipe,
          ingredient: ingredient,
        );
      }).toList();

      return ItemWithRecipe(item: item, recipeDetails: recipeDetails);
    });
  }

  // ============================================================================
  // COST CALCULATION
  // ============================================================================

  /// Calculate item cost from recipe
  Future<double> calculateItemCost(int itemId) async {
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

  /// Update item cost based on recipe
  Future<void> updateItemCost(int itemId) async {
    final cost = await calculateItemCost(itemId);
    await (update(items)..where((i) => i.id.equals(itemId))).write(
      ItemsCompanion(
        cost: Value(cost),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Recalculate costs for all items using a specific ingredient
  Future<void> recalculateCostsForIngredient(int ingredientId) async {
    final affectedItems = await customSelect(
      'SELECT DISTINCT item_id FROM recipe_ingredients WHERE ingredient_id = ?',
      variables: [Variable.withInt(ingredientId)],
      readsFrom: {recipeIngredients},
    ).get();

    for (final row in affectedItems) {
      final itemId = row.data['item_id'] as int;
      await updateItemCost(itemId);
    }
  }

  /// Get items affected by ingredient price change
  Future<List<Item>> getItemsUsingIngredient(int ingredientId) async {
    final itemIds = await customSelect(
      'SELECT DISTINCT item_id FROM recipe_ingredients WHERE ingredient_id = ?',
      variables: [Variable.withInt(ingredientId)],
      readsFrom: {recipeIngredients},
    ).get();

    if (itemIds.isEmpty) return [];

    final ids = itemIds.map((r) => r.data['item_id'] as int).toList();
    return (select(items)..where((i) => i.id.isIn(ids))).get();
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

  /// Adjust stock (add or subtract)
  Future<int> adjustStock(int id, int adjustment) async {
    final item = await getItemById(id);
    if (item == null) return 0;
    
    final newStock = item.stock + adjustment;
    return updateStock(id, newStock < 0 ? 0 : newStock);
  }

  /// Update price
  Future<int> updatePrice(int id, double newPrice) {
    return (update(items)..where((i) => i.id.equals(id))).write(
      ItemsCompanion(
        price: Value(newPrice),
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

  /// Get total sales value
  Future<double> getTotalSalesValue(int organizationId) async {
    final result = await customSelect(
      'SELECT SUM(sold * price) as total_sales FROM items WHERE organization_id = ? AND is_active = 1',
      variables: [Variable.withInt(organizationId)],
      readsFrom: {items},
    ).getSingle();
    return result.data['total_sales'] as double? ?? 0.0;
  }

  /// Get total spoilage cost
  Future<double> getTotalSpoilageCost(int organizationId) async {
    final result = await customSelect(
      'SELECT SUM(spoilage * cost) as total_spoilage FROM items WHERE organization_id = ? AND is_active = 1',
      variables: [Variable.withInt(organizationId)],
      readsFrom: {items},
    ).getSingle();
    return result.data['total_spoilage'] as double? ?? 0.0;
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

  /// Soft delete item (alias for deactivateItem)
  Future<int> softDeleteItem(int id) => deactivateItem(id);

  /// Reactivate item
  Future<int> reactivateItem(int id) {
    return (update(items)..where((i) => i.id.equals(id))).write(
      ItemsCompanion(
        isActive: const Value(true),
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

