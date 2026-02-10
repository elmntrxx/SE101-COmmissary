import 'package:flutter_test/flutter_test.dart';
import 'package:commissary_app/database/models/item_with_category.dart';
import 'package:commissary_app/database/app_database.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockItem extends Mock implements Item {}
class MockCategory extends Mock implements Category {}

void main() {
  group('ItemWithCategory', () {
    late MockItem mockItem;
    late MockCategory mockCategory;

    setUp(() {
      mockItem = MockItem();
      mockCategory = MockCategory();

      // Default mock values for Item
      when(() => mockItem.id).thenReturn(1);
      when(() => mockItem.name).thenReturn('Test Item');
      when(() => mockItem.stock).thenReturn(100);
      when(() => mockItem.price).thenReturn(50.0);
      when(() => mockItem.cost).thenReturn(30.0);
      when(() => mockItem.sold).thenReturn(25);
      when(() => mockItem.spoilage).thenReturn(5);
      when(() => mockItem.isActive).thenReturn(true);

      // Default mock values for Category
      when(() => mockCategory.name).thenReturn('Test Category');
    });

    // ========================================================================
    // POSITIVE TEST CASES
    // ========================================================================

    test('should create ItemWithCategory with item and category', () {
      final itemWithCategory = ItemWithCategory(
        item: mockItem,
        category: mockCategory,
      );

      expect(itemWithCategory.item, equals(mockItem));
      expect(itemWithCategory.category, equals(mockCategory));
    });

    test('categoryName should return category name when category exists', () {
      final itemWithCategory = ItemWithCategory(
        item: mockItem,
        category: mockCategory,
      );

      expect(itemWithCategory.categoryName, equals('Test Category'));
    });

    test('id getter should return item id', () {
      final itemWithCategory = ItemWithCategory(
        item: mockItem,
        category: mockCategory,
      );

      expect(itemWithCategory.id, equals(1));
    });

    test('name getter should return item name', () {
      final itemWithCategory = ItemWithCategory(
        item: mockItem,
        category: mockCategory,
      );

      expect(itemWithCategory.name, equals('Test Item'));
    });

    test('stock getter should return item stock', () {
      final itemWithCategory = ItemWithCategory(
        item: mockItem,
        category: mockCategory,
      );

      expect(itemWithCategory.stock, equals(100));
    });

    test('price getter should return item price', () {
      final itemWithCategory = ItemWithCategory(
        item: mockItem,
        category: mockCategory,
      );

      expect(itemWithCategory.price, equals(50.0));
    });

    test('cost getter should return item cost', () {
      final itemWithCategory = ItemWithCategory(
        item: mockItem,
        category: mockCategory,
      );

      expect(itemWithCategory.cost, equals(30.0));
    });

    test('sold getter should return item sold count', () {
      final itemWithCategory = ItemWithCategory(
        item: mockItem,
        category: mockCategory,
      );

      expect(itemWithCategory.sold, equals(25));
    });

    test('spoilage getter should return item spoilage count', () {
      final itemWithCategory = ItemWithCategory(
        item: mockItem,
        category: mockCategory,
      );

      expect(itemWithCategory.spoilage, equals(5));
    });

    test('isActive getter should return item active status', () {
      final itemWithCategory = ItemWithCategory(
        item: mockItem,
        category: mockCategory,
      );

      expect(itemWithCategory.isActive, isTrue);
    });

    test('profitMargin should calculate correct margin', () {
      final itemWithCategory = ItemWithCategory(
        item: mockItem,
        category: mockCategory,
      );

      // price (50) - cost (30) = 20
      expect(itemWithCategory.profitMargin, equals(20.0));
    });

    test('profitPercentage should calculate correct percentage', () {
      final itemWithCategory = ItemWithCategory(
        item: mockItem,
        category: mockCategory,
      );

      // profitMargin (20) / price (50) * 100 = 40%
      expect(itemWithCategory.profitPercentage, equals(40.0));
    });

    // ========================================================================
    // NEGATIVE TEST CASES
    // ========================================================================

    test('categoryName should return "Uncategorized" when category is null', () {
      final itemWithCategory = ItemWithCategory(
        item: mockItem,
        category: null,
      );

      expect(itemWithCategory.categoryName, equals('Uncategorized'));
    });

    test('profitPercentage should return 0 when price is zero', () {
      when(() => mockItem.price).thenReturn(0.0);
      when(() => mockItem.cost).thenReturn(30.0);

      final itemWithCategory = ItemWithCategory(
        item: mockItem,
        category: mockCategory,
      );

      expect(itemWithCategory.profitPercentage, equals(0.0));
    });

    test('profitMargin should be negative when cost exceeds price', () {
      when(() => mockItem.price).thenReturn(20.0);
      when(() => mockItem.cost).thenReturn(30.0);

      final itemWithCategory = ItemWithCategory(
        item: mockItem,
        category: mockCategory,
      );

      expect(itemWithCategory.profitMargin, equals(-10.0));
    });
  });
}
