// lib/database/models/ingredient_usage.dart
import '../app_database.dart';

/// Model representing ingredient usage in items
class IngredientUsage {
  final Ingredient ingredient;
  final List<ItemUsage> usedInItems;

  IngredientUsage({
    required this.ingredient,
    required this.usedInItems,
  });

  /// Total quantity used across all items
  double get totalQuantityUsed {
    return usedInItems.fold(0.0, (sum, usage) => sum + usage.quantityNeeded);
  }

  /// Check if this ingredient is used in any item
  bool get isUsedInRecipes => usedInItems.isNotEmpty;

  /// Get the number of items using this ingredient
  int get itemCount => usedInItems.length;
}

/// Model for item usage details
class ItemUsage {
  final Item item;
  final double quantityNeeded;

  ItemUsage({
    required this.item,
    required this.quantityNeeded,
  });
}

/// Model for price history tracking
class IngredientPriceHistory {
  final int ingredientId;
  final String ingredientName;
  final double oldPrice;
  final double newPrice;
  final DateTime changedAt;
  final String? changedBy;

  IngredientPriceHistory({
    required this.ingredientId,
    required this.ingredientName,
    required this.oldPrice,
    required this.newPrice,
    required this.changedAt,
    this.changedBy,
  });

  double get priceChange => newPrice - oldPrice;

  double get priceChangePercentage {
    if (oldPrice == 0) return 0;
    return (priceChange / oldPrice) * 100;
  }
}
