import 'package:flutter_test/flutter_test.dart';
import 'package:commissary_app/database/daos/ingredients_dao.dart';

void main() {
  group('IngredientSortOrder enum', () {
    // ========================================================================
    // POSITIVE TEST CASES
    // ========================================================================

    test('should have nameAsc sort order', () {
      expect(IngredientSortOrder.nameAsc, isNotNull);
      expect(IngredientSortOrder.values.contains(IngredientSortOrder.nameAsc), isTrue);
    });

    test('should have nameDesc sort order', () {
      expect(IngredientSortOrder.nameDesc, isNotNull);
      expect(IngredientSortOrder.values.contains(IngredientSortOrder.nameDesc), isTrue);
    });

    test('should have stockAsc sort order', () {
      expect(IngredientSortOrder.stockAsc, isNotNull);
      expect(IngredientSortOrder.values.contains(IngredientSortOrder.stockAsc), isTrue);
    });

    test('should have stockDesc sort order', () {
      expect(IngredientSortOrder.stockDesc, isNotNull);
      expect(IngredientSortOrder.values.contains(IngredientSortOrder.stockDesc), isTrue);
    });

    test('should have costAsc sort order', () {
      expect(IngredientSortOrder.costAsc, isNotNull);
      expect(IngredientSortOrder.values.contains(IngredientSortOrder.costAsc), isTrue);
    });

    test('should have costDesc sort order', () {
      expect(IngredientSortOrder.costDesc, isNotNull);
      expect(IngredientSortOrder.values.contains(IngredientSortOrder.costDesc), isTrue);
    });

    test('should have newestFirst sort order', () {
      expect(IngredientSortOrder.newestFirst, isNotNull);
      expect(IngredientSortOrder.values.contains(IngredientSortOrder.newestFirst), isTrue);
    });

    test('should have oldestFirst sort order', () {
      expect(IngredientSortOrder.oldestFirst, isNotNull);
      expect(IngredientSortOrder.values.contains(IngredientSortOrder.oldestFirst), isTrue);
    });

    test('should contain exactly 8 sort order values', () {
      expect(IngredientSortOrder.values.length, equals(8));
    });

    test('all sort orders should have unique index', () {
      final indices = IngredientSortOrder.values.map((e) => e.index).toSet();
      expect(indices.length, equals(IngredientSortOrder.values.length));
    });

    test('nameAsc should have index 0', () {
      expect(IngredientSortOrder.nameAsc.index, equals(0));
    });

    test('nameDesc should have index 1', () {
      expect(IngredientSortOrder.nameDesc.index, equals(1));
    });

    // ========================================================================
    // NEGATIVE TEST CASES
    // ========================================================================

    test('nameAsc should not equal nameDesc', () {
      expect(IngredientSortOrder.nameAsc == IngredientSortOrder.nameDesc, isFalse);
    });

    test('stockAsc should not equal stockDesc', () {
      expect(IngredientSortOrder.stockAsc == IngredientSortOrder.stockDesc, isFalse);
    });

    test('costAsc should not equal costDesc', () {
      expect(IngredientSortOrder.costAsc == IngredientSortOrder.costDesc, isFalse);
    });

    test('newestFirst should not equal oldestFirst', () {
      expect(IngredientSortOrder.newestFirst == IngredientSortOrder.oldestFirst, isFalse);
    });

    test('stockAsc should not equal costAsc', () {
      expect(IngredientSortOrder.stockAsc == IngredientSortOrder.costAsc, isFalse);
    });
  });
}
