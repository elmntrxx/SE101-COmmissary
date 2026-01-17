// lib/database/models/recipe_ingredient_detail.dart
import '../app_database.dart';

/// Model representing a recipe ingredient with full ingredient details
/// Used to display recipe composition with cost breakdown
class RecipeIngredientDetail {
  final RecipeIngredient recipeIngredient;
  final Ingredient ingredient;

  RecipeIngredientDetail({
    required this.recipeIngredient,
    required this.ingredient,
  });

  /// Quantity of ingredient needed for one unit of the item
  double get quantity => recipeIngredient.quantity;

  /// Cost per unit of this ingredient
  double get costPerUnit => ingredient.costPerUnit;

  /// Total cost contribution of this ingredient to the recipe
  double get totalCost => quantity * costPerUnit;

  /// Ingredient name
  String get ingredientName => ingredient.name;

  /// Unit of measurement
  String get unit => ingredient.unit;

  /// Current stock of this ingredient
  double get currentStock => ingredient.stock;

  /// Check if there's enough stock to produce the given quantity
  bool hasEnoughStock(int productionQuantity) {
    return currentStock >= (quantity * productionQuantity);
  }

  /// Calculate how many units can be produced with current stock
  int maxProductionQuantity() {
    if (quantity == 0) return 0;
    return (currentStock / quantity).floor();
  }
}

/// Model representing a complete item with its recipe and cost breakdown
class ItemWithRecipe {
  final Item item;
  final List<RecipeIngredientDetail> recipeDetails;

  ItemWithRecipe({
    required this.item,
    required this.recipeDetails,
  });

  /// Calculate total cost based on recipe ingredients
  double get calculatedCost {
    return recipeDetails.fold(0.0, (sum, detail) => sum + detail.totalCost);
  }

  /// Get the selling price
  double get sellingPrice => item.price;

  /// Calculate profit margin
  double get profitMargin => sellingPrice - calculatedCost;

  /// Calculate profit margin percentage
  double get profitMarginPercentage {
    if (sellingPrice == 0) return 0;
    return (profitMargin / sellingPrice) * 100;
  }

  /// Check if all ingredients have sufficient stock
  bool canProduce(int quantity) {
    if (recipeDetails.isEmpty) return true;
    return recipeDetails.every((detail) => detail.hasEnoughStock(quantity));
  }

  /// Get the maximum quantity that can be produced
  int maxProductionQuantity() {
    if (recipeDetails.isEmpty) return 0;
    return recipeDetails
        .map((detail) => detail.maxProductionQuantity())
        .reduce((a, b) => a < b ? a : b);
  }

  /// Get list of ingredients with insufficient stock
  List<RecipeIngredientDetail> getInsufficientIngredients(int quantity) {
    return recipeDetails
        .where((detail) => !detail.hasEnoughStock(quantity))
        .toList();
  }

  /// Get cost breakdown as a formatted list
  List<CostBreakdownItem> getCostBreakdown() {
    return recipeDetails.map((detail) {
      return CostBreakdownItem(
        ingredientName: detail.ingredientName,
        quantity: detail.quantity,
        unit: detail.unit,
        costPerUnit: detail.costPerUnit,
        totalCost: detail.totalCost,
        percentageOfTotal: calculatedCost > 0
            ? (detail.totalCost / calculatedCost) * 100
            : 0,
      );
    }).toList();
  }
}

/// Model for displaying cost breakdown
class CostBreakdownItem {
  final String ingredientName;
  final double quantity;
  final String unit;
  final double costPerUnit;
  final double totalCost;
  final double percentageOfTotal;

  CostBreakdownItem({
    required this.ingredientName,
    required this.quantity,
    required this.unit,
    required this.costPerUnit,
    required this.totalCost,
    required this.percentageOfTotal,
  });

  @override
  String toString() {
    return '$quantity $unit $ingredientName @ ₱$costPerUnit = ₱${totalCost.toStringAsFixed(2)} (${percentageOfTotal.toStringAsFixed(1)}%)';
  }
}

/// Model for ingredient stock alerts
class IngredientStockAlert {
  final Ingredient ingredient;
  final double requiredQuantity;
  final double shortfall;

  IngredientStockAlert({
    required this.ingredient,
    required this.requiredQuantity,
    required this.shortfall,
  });

  String get alertMessage {
    return '${ingredient.name}: Need $requiredQuantity ${ingredient.unit}, but only ${ingredient.stock} available (short by ${shortfall.toStringAsFixed(2)})';
  }
}
