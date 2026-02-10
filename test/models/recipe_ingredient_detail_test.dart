import 'package:flutter_test/flutter_test.dart';
import 'package:commissary_app/database/models/recipe_ingredient_detail.dart';
import 'package:commissary_app/database/app_database.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockRecipeIngredient extends Mock implements RecipeIngredient {}
class MockIngredient extends Mock implements Ingredient {}
class MockItem extends Mock implements Item {}

void main() {
  group('RecipeIngredientDetail', () {
    late MockRecipeIngredient mockRecipeIngredient;
    late MockIngredient mockIngredient;

    setUp(() {
      mockRecipeIngredient = MockRecipeIngredient();
      mockIngredient = MockIngredient();

      // Default mock values
      when(() => mockRecipeIngredient.quantity).thenReturn(2.0);
      when(() => mockIngredient.costPerUnit).thenReturn(10.0);
      when(() => mockIngredient.name).thenReturn('Flour');
      when(() => mockIngredient.unit).thenReturn('kg');
      when(() => mockIngredient.stock).thenReturn(50.0);
    });

    // ========================================================================
    // POSITIVE TEST CASES
    // ========================================================================

    test('should create RecipeIngredientDetail with valid data', () {
      final detail = RecipeIngredientDetail(
        recipeIngredient: mockRecipeIngredient,
        ingredient: mockIngredient,
      );

      expect(detail.recipeIngredient, equals(mockRecipeIngredient));
      expect(detail.ingredient, equals(mockIngredient));
    });

    test('quantity getter should return recipeIngredient quantity', () {
      final detail = RecipeIngredientDetail(
        recipeIngredient: mockRecipeIngredient,
        ingredient: mockIngredient,
      );

      expect(detail.quantity, equals(2.0));
    });

    test('costPerUnit getter should return ingredient costPerUnit', () {
      final detail = RecipeIngredientDetail(
        recipeIngredient: mockRecipeIngredient,
        ingredient: mockIngredient,
      );

      expect(detail.costPerUnit, equals(10.0));
    });

    test('totalCost should calculate quantity * costPerUnit', () {
      final detail = RecipeIngredientDetail(
        recipeIngredient: mockRecipeIngredient,
        ingredient: mockIngredient,
      );

      // 2.0 * 10.0 = 20.0
      expect(detail.totalCost, equals(20.0));
    });

    test('ingredientName getter should return ingredient name', () {
      final detail = RecipeIngredientDetail(
        recipeIngredient: mockRecipeIngredient,
        ingredient: mockIngredient,
      );

      expect(detail.ingredientName, equals('Flour'));
    });

    test('unit getter should return ingredient unit', () {
      final detail = RecipeIngredientDetail(
        recipeIngredient: mockRecipeIngredient,
        ingredient: mockIngredient,
      );

      expect(detail.unit, equals('kg'));
    });

    test('currentStock getter should return ingredient stock', () {
      final detail = RecipeIngredientDetail(
        recipeIngredient: mockRecipeIngredient,
        ingredient: mockIngredient,
      );

      expect(detail.currentStock, equals(50.0));
    });

    test('hasEnoughStock should return true when stock is sufficient', () {
      final detail = RecipeIngredientDetail(
        recipeIngredient: mockRecipeIngredient,
        ingredient: mockIngredient,
      );

      // Stock (50) >= quantity (2.0) * production (10) = 20
      expect(detail.hasEnoughStock(10), isTrue);
    });

    test('maxProductionQuantity should calculate correct value', () {
      final detail = RecipeIngredientDetail(
        recipeIngredient: mockRecipeIngredient,
        ingredient: mockIngredient,
      );

      // Stock (50) / quantity (2.0) = 25
      expect(detail.maxProductionQuantity(), equals(25));
    });

    // ========================================================================
    // NEGATIVE TEST CASES
    // ========================================================================

    test('hasEnoughStock should return false when stock is insufficient', () {
      when(() => mockIngredient.stock).thenReturn(10.0);

      final detail = RecipeIngredientDetail(
        recipeIngredient: mockRecipeIngredient,
        ingredient: mockIngredient,
      );

      // Stock (10) < quantity (2.0) * production (10) = 20
      expect(detail.hasEnoughStock(10), isFalse);
    });

    test('maxProductionQuantity should return 0 when quantity is zero', () {
      when(() => mockRecipeIngredient.quantity).thenReturn(0.0);

      final detail = RecipeIngredientDetail(
        recipeIngredient: mockRecipeIngredient,
        ingredient: mockIngredient,
      );

      expect(detail.maxProductionQuantity(), equals(0));
    });

    test('totalCost should be zero when costPerUnit is zero', () {
      when(() => mockIngredient.costPerUnit).thenReturn(0.0);

      final detail = RecipeIngredientDetail(
        recipeIngredient: mockRecipeIngredient,
        ingredient: mockIngredient,
      );

      expect(detail.totalCost, equals(0.0));
    });
  });

  group('ItemWithRecipe', () {
    late MockItem mockItem;
    late MockRecipeIngredient mockRecipeIngredient1;
    late MockRecipeIngredient mockRecipeIngredient2;
    late MockIngredient mockIngredient1;
    late MockIngredient mockIngredient2;

    setUp(() {
      mockItem = MockItem();
      mockRecipeIngredient1 = MockRecipeIngredient();
      mockRecipeIngredient2 = MockRecipeIngredient();
      mockIngredient1 = MockIngredient();
      mockIngredient2 = MockIngredient();

      when(() => mockItem.price).thenReturn(100.0);

      // Ingredient 1: 2.0 quantity * 10.0 cost = 20.0 total
      when(() => mockRecipeIngredient1.quantity).thenReturn(2.0);
      when(() => mockIngredient1.costPerUnit).thenReturn(10.0);
      when(() => mockIngredient1.name).thenReturn('Flour');
      when(() => mockIngredient1.unit).thenReturn('kg');
      when(() => mockIngredient1.stock).thenReturn(100.0);

      // Ingredient 2: 3.0 quantity * 5.0 cost = 15.0 total
      when(() => mockRecipeIngredient2.quantity).thenReturn(3.0);
      when(() => mockIngredient2.costPerUnit).thenReturn(5.0);
      when(() => mockIngredient2.name).thenReturn('Sugar');
      when(() => mockIngredient2.unit).thenReturn('kg');
      when(() => mockIngredient2.stock).thenReturn(50.0);
    });

    // ========================================================================
    // POSITIVE TEST CASES
    // ========================================================================

    test('should create ItemWithRecipe with item and recipe details', () {
      final recipeDetails = [
        RecipeIngredientDetail(
          recipeIngredient: mockRecipeIngredient1,
          ingredient: mockIngredient1,
        ),
      ];

      final itemWithRecipe = ItemWithRecipe(
        item: mockItem,
        recipeDetails: recipeDetails,
      );

      expect(itemWithRecipe.item, equals(mockItem));
      expect(itemWithRecipe.recipeDetails.length, equals(1));
    });

    test('calculatedCost should sum all ingredient costs', () {
      final recipeDetails = [
        RecipeIngredientDetail(
          recipeIngredient: mockRecipeIngredient1,
          ingredient: mockIngredient1,
        ),
        RecipeIngredientDetail(
          recipeIngredient: mockRecipeIngredient2,
          ingredient: mockIngredient2,
        ),
      ];

      final itemWithRecipe = ItemWithRecipe(
        item: mockItem,
        recipeDetails: recipeDetails,
      );

      // 20.0 + 15.0 = 35.0
      expect(itemWithRecipe.calculatedCost, equals(35.0));
    });

    test('sellingPrice should return item price', () {
      final itemWithRecipe = ItemWithRecipe(
        item: mockItem,
        recipeDetails: [],
      );

      expect(itemWithRecipe.sellingPrice, equals(100.0));
    });

    test('profitMargin should calculate correctly', () {
      final recipeDetails = [
        RecipeIngredientDetail(
          recipeIngredient: mockRecipeIngredient1,
          ingredient: mockIngredient1,
        ),
        RecipeIngredientDetail(
          recipeIngredient: mockRecipeIngredient2,
          ingredient: mockIngredient2,
        ),
      ];

      final itemWithRecipe = ItemWithRecipe(
        item: mockItem,
        recipeDetails: recipeDetails,
      );

      // sellingPrice (100) - calculatedCost (35) = 65
      expect(itemWithRecipe.profitMargin, equals(65.0));
    });

    test('profitMarginPercentage should calculate correctly', () {
      final recipeDetails = [
        RecipeIngredientDetail(
          recipeIngredient: mockRecipeIngredient1,
          ingredient: mockIngredient1,
        ),
        RecipeIngredientDetail(
          recipeIngredient: mockRecipeIngredient2,
          ingredient: mockIngredient2,
        ),
      ];

      final itemWithRecipe = ItemWithRecipe(
        item: mockItem,
        recipeDetails: recipeDetails,
      );

      // profitMargin (65) / sellingPrice (100) * 100 = 65%
      expect(itemWithRecipe.profitMarginPercentage, equals(65.0));
    });

    test('canProduce should return true when all ingredients have enough stock', () {
      final recipeDetails = [
        RecipeIngredientDetail(
          recipeIngredient: mockRecipeIngredient1,
          ingredient: mockIngredient1,
        ),
        RecipeIngredientDetail(
          recipeIngredient: mockRecipeIngredient2,
          ingredient: mockIngredient2,
        ),
      ];

      final itemWithRecipe = ItemWithRecipe(
        item: mockItem,
        recipeDetails: recipeDetails,
      );

      // Can produce 10 units? 
      // Ingredient1: 100 stock >= 2.0 * 10 = 20 ✓
      // Ingredient2: 50 stock >= 3.0 * 10 = 30 ✓
      expect(itemWithRecipe.canProduce(10), isTrue);
    });

    test('canProduce should return true when recipe is empty', () {
      final itemWithRecipe = ItemWithRecipe(
        item: mockItem,
        recipeDetails: [],
      );

      expect(itemWithRecipe.canProduce(100), isTrue);
    });

    // ========================================================================
    // NEGATIVE TEST CASES
    // ========================================================================

    test('canProduce should return false when an ingredient has insufficient stock', () {
      when(() => mockIngredient2.stock).thenReturn(5.0); // Only 5 in stock

      final recipeDetails = [
        RecipeIngredientDetail(
          recipeIngredient: mockRecipeIngredient1,
          ingredient: mockIngredient1,
        ),
        RecipeIngredientDetail(
          recipeIngredient: mockRecipeIngredient2,
          ingredient: mockIngredient2,
        ),
      ];

      final itemWithRecipe = ItemWithRecipe(
        item: mockItem,
        recipeDetails: recipeDetails,
      );

      // Ingredient2: 5 stock < 3.0 * 10 = 30 ✗
      expect(itemWithRecipe.canProduce(10), isFalse);
    });

    test('profitMarginPercentage should return 0 when selling price is 0', () {
      when(() => mockItem.price).thenReturn(0.0);

      final itemWithRecipe = ItemWithRecipe(
        item: mockItem,
        recipeDetails: [],
      );

      expect(itemWithRecipe.profitMarginPercentage, equals(0.0));
    });

    test('maxProductionQuantity should return 0 when recipe is empty', () {
      final itemWithRecipe = ItemWithRecipe(
        item: mockItem,
        recipeDetails: [],
      );

      expect(itemWithRecipe.maxProductionQuantity(), equals(0));
    });

    test('getInsufficientIngredients should return list of insufficient ingredients', () {
      when(() => mockIngredient2.stock).thenReturn(5.0);

      final recipeDetails = [
        RecipeIngredientDetail(
          recipeIngredient: mockRecipeIngredient1,
          ingredient: mockIngredient1,
        ),
        RecipeIngredientDetail(
          recipeIngredient: mockRecipeIngredient2,
          ingredient: mockIngredient2,
        ),
      ];

      final itemWithRecipe = ItemWithRecipe(
        item: mockItem,
        recipeDetails: recipeDetails,
      );

      final insufficient = itemWithRecipe.getInsufficientIngredients(10);
      expect(insufficient.length, equals(1));
      expect(insufficient.first.ingredientName, equals('Sugar'));
    });
  });

  group('CostBreakdownItem', () {
    test('should create CostBreakdownItem with valid data', () {
      final item = CostBreakdownItem(
        ingredientName: 'Flour',
        quantity: 2.0,
        unit: 'kg',
        costPerUnit: 10.0,
        totalCost: 20.0,
        percentageOfTotal: 50.0,
      );

      expect(item.ingredientName, equals('Flour'));
      expect(item.quantity, equals(2.0));
      expect(item.unit, equals('kg'));
      expect(item.costPerUnit, equals(10.0));
      expect(item.totalCost, equals(20.0));
      expect(item.percentageOfTotal, equals(50.0));
    });

    test('toString should return formatted string', () {
      final item = CostBreakdownItem(
        ingredientName: 'Flour',
        quantity: 2.0,
        unit: 'kg',
        costPerUnit: 10.0,
        totalCost: 20.0,
        percentageOfTotal: 50.0,
      );

      expect(item.toString(), contains('2.0 kg Flour'));
      expect(item.toString(), contains('10.0'));
      expect(item.toString(), contains('20.00'));
      expect(item.toString(), contains('50.0%'));
    });
  });

  group('IngredientStockAlert', () {
    late MockIngredient mockIngredient;

    setUp(() {
      mockIngredient = MockIngredient();
      when(() => mockIngredient.name).thenReturn('Flour');
      when(() => mockIngredient.unit).thenReturn('kg');
      when(() => mockIngredient.stock).thenReturn(10.0);
    });

    test('should create IngredientStockAlert with valid data', () {
      final alert = IngredientStockAlert(
        ingredient: mockIngredient,
        requiredQuantity: 20.0,
        shortfall: 10.0,
      );

      expect(alert.ingredient, equals(mockIngredient));
      expect(alert.requiredQuantity, equals(20.0));
      expect(alert.shortfall, equals(10.0));
    });

    test('alertMessage should contain ingredient name and quantities', () {
      final alert = IngredientStockAlert(
        ingredient: mockIngredient,
        requiredQuantity: 20.0,
        shortfall: 10.0,
      );

      expect(alert.alertMessage, contains('Flour'));
      expect(alert.alertMessage, contains('20.0'));
      expect(alert.alertMessage, contains('10'));
    });
  });
}
