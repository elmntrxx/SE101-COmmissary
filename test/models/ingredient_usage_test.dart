import 'package:flutter_test/flutter_test.dart';
import 'package:commissary_app/database/models/ingredient_usage.dart';
import 'package:commissary_app/database/app_database.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes for database models
class MockIngredient extends Mock implements Ingredient {}
class MockItem extends Mock implements Item {}

void main() {
  group('ItemUsage', () {
    // ========================================================================
    // POSITIVE TEST CASES
    // ========================================================================

    test('should create ItemUsage with valid item and quantity', () {
      final mockItem = MockItem();
      when(() => mockItem.name).thenReturn('Test Item');
      
      final usage = ItemUsage(item: mockItem, quantityNeeded: 5.0);
      
      expect(usage.item, equals(mockItem));
      expect(usage.quantityNeeded, equals(5.0));
    });

    test('should allow zero quantity', () {
      final mockItem = MockItem();
      final usage = ItemUsage(item: mockItem, quantityNeeded: 0.0);
      
      expect(usage.quantityNeeded, equals(0.0));
    });

    test('should allow decimal quantity', () {
      final mockItem = MockItem();
      final usage = ItemUsage(item: mockItem, quantityNeeded: 2.5);
      
      expect(usage.quantityNeeded, equals(2.5));
    });
  });

  group('IngredientUsage', () {
    late MockIngredient mockIngredient;

    setUp(() {
      mockIngredient = MockIngredient();
      when(() => mockIngredient.name).thenReturn('Test Ingredient');
    });

    // ========================================================================
    // POSITIVE TEST CASES
    // ========================================================================

    test('should create IngredientUsage with ingredient and usedInItems', () {
      final mockItem = MockItem();
      final itemUsages = [ItemUsage(item: mockItem, quantityNeeded: 5.0)];
      
      final usage = IngredientUsage(
        ingredient: mockIngredient,
        usedInItems: itemUsages,
      );
      
      expect(usage.ingredient, equals(mockIngredient));
      expect(usage.usedInItems.length, equals(1));
    });

    test('totalQuantityUsed should sum all item usages', () {
      final mockItem1 = MockItem();
      final mockItem2 = MockItem();
      final itemUsages = [
        ItemUsage(item: mockItem1, quantityNeeded: 5.0),
        ItemUsage(item: mockItem2, quantityNeeded: 3.0),
      ];
      
      final usage = IngredientUsage(
        ingredient: mockIngredient,
        usedInItems: itemUsages,
      );
      
      expect(usage.totalQuantityUsed, equals(8.0));
    });

    test('isUsedInRecipes should return true when used in items', () {
      final mockItem = MockItem();
      final itemUsages = [ItemUsage(item: mockItem, quantityNeeded: 5.0)];
      
      final usage = IngredientUsage(
        ingredient: mockIngredient,
        usedInItems: itemUsages,
      );
      
      expect(usage.isUsedInRecipes, isTrue);
    });

    test('itemCount should return correct number of items', () {
      final mockItem1 = MockItem();
      final mockItem2 = MockItem();
      final mockItem3 = MockItem();
      final itemUsages = [
        ItemUsage(item: mockItem1, quantityNeeded: 5.0),
        ItemUsage(item: mockItem2, quantityNeeded: 3.0),
        ItemUsage(item: mockItem3, quantityNeeded: 2.0),
      ];
      
      final usage = IngredientUsage(
        ingredient: mockIngredient,
        usedInItems: itemUsages,
      );
      
      expect(usage.itemCount, equals(3));
    });

    // ========================================================================
    // NEGATIVE TEST CASES
    // ========================================================================

    test('isUsedInRecipes should return false when not used in any items', () {
      final usage = IngredientUsage(
        ingredient: mockIngredient,
        usedInItems: [],
      );
      
      expect(usage.isUsedInRecipes, isFalse);
    });

    test('totalQuantityUsed should be zero with empty usedInItems', () {
      final usage = IngredientUsage(
        ingredient: mockIngredient,
        usedInItems: [],
      );
      
      expect(usage.totalQuantityUsed, equals(0.0));
    });

    test('itemCount should be zero when no items use the ingredient', () {
      final usage = IngredientUsage(
        ingredient: mockIngredient,
        usedInItems: [],
      );
      
      expect(usage.itemCount, equals(0));
    });
  });

  group('IngredientPriceHistory', () {
    // ========================================================================
    // POSITIVE TEST CASES
    // ========================================================================

    test('should create IngredientPriceHistory with valid data', () {
      final history = IngredientPriceHistory(
        ingredientId: 1,
        ingredientName: 'Salt',
        oldPrice: 10.0,
        newPrice: 12.0,
        changedAt: DateTime(2026, 1, 28),
        changedBy: 'Admin',
      );
      
      expect(history.ingredientId, equals(1));
      expect(history.ingredientName, equals('Salt'));
      expect(history.oldPrice, equals(10.0));
      expect(history.newPrice, equals(12.0));
      expect(history.changedBy, equals('Admin'));
    });

    test('priceChange should return positive value for price increase', () {
      final history = IngredientPriceHistory(
        ingredientId: 1,
        ingredientName: 'Salt',
        oldPrice: 10.0,
        newPrice: 15.0,
        changedAt: DateTime.now(),
      );
      
      expect(history.priceChange, equals(5.0));
    });

    test('priceChangePercentage should return correct percentage for increase', () {
      final history = IngredientPriceHistory(
        ingredientId: 1,
        ingredientName: 'Salt',
        oldPrice: 100.0,
        newPrice: 125.0,
        changedAt: DateTime.now(),
      );
      
      expect(history.priceChangePercentage, equals(25.0));
    });

    // ========================================================================
    // NEGATIVE TEST CASES
    // ========================================================================

    test('priceChange should return negative value for price decrease', () {
      final history = IngredientPriceHistory(
        ingredientId: 1,
        ingredientName: 'Salt',
        oldPrice: 15.0,
        newPrice: 10.0,
        changedAt: DateTime.now(),
      );
      
      expect(history.priceChange, equals(-5.0));
    });

    test('priceChangePercentage should handle zero old price', () {
      final history = IngredientPriceHistory(
        ingredientId: 1,
        ingredientName: 'Salt',
        oldPrice: 0.0,
        newPrice: 10.0,
        changedAt: DateTime.now(),
      );
      
      expect(history.priceChangePercentage, equals(0));
    });

    test('changedBy should be nullable', () {
      final history = IngredientPriceHistory(
        ingredientId: 1,
        ingredientName: 'Salt',
        oldPrice: 10.0,
        newPrice: 12.0,
        changedAt: DateTime.now(),
      );
      
      expect(history.changedBy, isNull);
    });
  });
}
