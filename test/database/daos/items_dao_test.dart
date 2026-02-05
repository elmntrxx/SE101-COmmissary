import 'package:flutter_test/flutter_test.dart';
import 'package:commissary_app/database/daos/items_dao.dart';

void main() {
  group('ItemSortOrder enum', () {
    // ========================================================================
    // POSITIVE TEST CASES
    // ========================================================================

    test('should have nameAsc sort order', () {
      expect(ItemSortOrder.nameAsc, isNotNull);
      expect(ItemSortOrder.values.contains(ItemSortOrder.nameAsc), isTrue);
    });

    test('should have nameDesc sort order', () {
      expect(ItemSortOrder.nameDesc, isNotNull);
      expect(ItemSortOrder.values.contains(ItemSortOrder.nameDesc), isTrue);
    });

    test('should have stockAsc sort order', () {
      expect(ItemSortOrder.stockAsc, isNotNull);
      expect(ItemSortOrder.values.contains(ItemSortOrder.stockAsc), isTrue);
    });

    test('should have stockDesc sort order', () {
      expect(ItemSortOrder.stockDesc, isNotNull);
      expect(ItemSortOrder.values.contains(ItemSortOrder.stockDesc), isTrue);
    });

    test('should have priceAsc sort order', () {
      expect(ItemSortOrder.priceAsc, isNotNull);
      expect(ItemSortOrder.values.contains(ItemSortOrder.priceAsc), isTrue);
    });

    test('should have priceDesc sort order', () {
      expect(ItemSortOrder.priceDesc, isNotNull);
      expect(ItemSortOrder.values.contains(ItemSortOrder.priceDesc), isTrue);
    });

    test('should have costAsc sort order', () {
      expect(ItemSortOrder.costAsc, isNotNull);
      expect(ItemSortOrder.values.contains(ItemSortOrder.costAsc), isTrue);
    });

    test('should have costDesc sort order', () {
      expect(ItemSortOrder.costDesc, isNotNull);
      expect(ItemSortOrder.values.contains(ItemSortOrder.costDesc), isTrue);
    });

    test('should have newestFirst sort order', () {
      expect(ItemSortOrder.newestFirst, isNotNull);
      expect(ItemSortOrder.values.contains(ItemSortOrder.newestFirst), isTrue);
    });

    test('should have oldestFirst sort order', () {
      expect(ItemSortOrder.oldestFirst, isNotNull);
      expect(ItemSortOrder.values.contains(ItemSortOrder.oldestFirst), isTrue);
    });

    test('should contain exactly 10 sort order values', () {
      expect(ItemSortOrder.values.length, equals(10));
    });

    test('nameAsc and nameDesc should be different', () {
      expect(ItemSortOrder.nameAsc, isNot(equals(ItemSortOrder.nameDesc)));
    });

    test('all sort orders should have unique index', () {
      final indices = ItemSortOrder.values.map((e) => e.index).toSet();
      expect(indices.length, equals(ItemSortOrder.values.length));
    });

    // ========================================================================
    // NEGATIVE TEST CASES
    // ========================================================================

    test('nameAsc should not equal stockAsc', () {
      expect(ItemSortOrder.nameAsc == ItemSortOrder.stockAsc, isFalse);
    });

    test('priceAsc should not equal costAsc', () {
      expect(ItemSortOrder.priceAsc == ItemSortOrder.costAsc, isFalse);
    });

    test('newestFirst should not equal oldestFirst', () {
      expect(ItemSortOrder.newestFirst == ItemSortOrder.oldestFirst, isFalse);
    });
  });
}
