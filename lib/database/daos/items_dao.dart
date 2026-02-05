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

  /// Get item by name (case-insensitive)
  Future<Item?> getItemByName(
    String name, {
    int? organizationId,
  }) async {
    final query = select(items)
      ..where((i) => i.name.lower().equals(name.toLowerCase()) & i.isActive.equals(true));

    if (organizationId != null) {
      query.where((i) => i.organizationId.equals(organizationId));
    }

    return query.getSingleOrNull();
  }

  /// Create a new item
  /// Throws an exception if an item with the same name already exists in the organization
  Future<int> createItem(ItemsCompanion item) async {
    // Check for duplicate item name within the organization
    final name = item.name.value;
    final organizationId = item.organizationId.value;
    
    final existingItem = await getItemByName(
      name,
      organizationId: organizationId,
    );
    if (existingItem != null) {
      throw Exception('A product with the name "$name" already exists');
    }
    
    return into(items).insert(item);
  }

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

  /// Permanently delete item from database
  Future<int> permanentlyDeleteItem(int id) async {
    // Delete from local database
    return (delete(items)..where((i) => i.id.equals(id))).go();
  }

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

  // ============================================================================
  // SYNC METHODS (for SyncEngine compatibility)
  // ============================================================================

  /// Upsert a single item from cloud data
  /// SyncEngine provides camelCase keys with resolved local IDs
  Future<int> upsertFromCloud(Map<String, dynamic> cloudData) async {
    // SyncEngine uses 'cloudId' (camelCase), not 'cloud_id'
    final cloudId = (cloudData['cloudId'] ?? cloudData['cloud_id']) as String?;
    if (cloudId == null) throw ArgumentError('cloudId is required');

    final existing = await getItemByCloudId(cloudId);

    // SyncEngine already resolves FKs to local IDs with camelCase keys
    final orgId = cloudData['organizationId'] as int?;
    final catId = cloudData['categoryId'] as int?;
    final masterItemId = cloudData['masterItemId'] as String?;

    final companion = ItemsCompanion(
      cloudId: Value(cloudId),
      organizationId: Value(orgId ?? existing?.organizationId ?? 0),
      categoryId: Value(catId),
      masterItemId: Value(masterItemId),
      name: Value(cloudData['name'] as String? ?? 'Unknown'),
      description: Value(cloudData['description'] as String?),
      stock: Value((cloudData['stock'] as num?)?.toInt() ?? 0),
      price: Value((cloudData['price'] as num?)?.toDouble() ?? 0.0),
      cost: Value((cloudData['cost'] as num?)?.toDouble() ?? 0.0),
      sold: Value((cloudData['sold'] as num?)?.toInt() ?? 0),
      spoilage: Value((cloudData['spoilage'] as num?)?.toInt() ?? 0),
      criticalLevel: Value((cloudData['criticalLevel'] as num?)?.toInt() ?? 10),
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
      // Protect local unsynced changes from being overwritten
      if (existing.needsSync) {
        return existing.id;
      }
      await (update(items)..where((i) => i.id.equals(existing.id))).write(companion);
      return existing.id;
    } else {
      return into(items).insert(companion);
    }
  }

  /// Upsert batch of items from cloud data
  Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> cloudDataList) async {
    for (final cloudData in cloudDataList) {
      await upsertFromCloud(cloudData);
    }
  }
}

