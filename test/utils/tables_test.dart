import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:commissary_app/utils/tables.dart';

void main() {
  group('EmptyButtonType enum', () {
    // ========================================================================
    // POSITIVE TEST CASES
    // ========================================================================

    test('should have none type', () {
      expect(EmptyButtonType.none, isNotNull);
      expect(EmptyButtonType.values.contains(EmptyButtonType.none), isTrue);
    });

    test('should have icon type', () {
      expect(EmptyButtonType.icon, isNotNull);
      expect(EmptyButtonType.values.contains(EmptyButtonType.icon), isTrue);
    });

    test('should have elevated type', () {
      expect(EmptyButtonType.elevated, isNotNull);
      expect(EmptyButtonType.values.contains(EmptyButtonType.elevated), isTrue);
    });

    test('should contain exactly 3 button types', () {
      expect(EmptyButtonType.values.length, equals(3));
    });

    test('none should have index 0', () {
      expect(EmptyButtonType.none.index, equals(0));
    });

    test('icon should have index 1', () {
      expect(EmptyButtonType.icon.index, equals(1));
    });

    test('elevated should have index 2', () {
      expect(EmptyButtonType.elevated.index, equals(2));
    });

    // ========================================================================
    // NEGATIVE TEST CASES
    // ========================================================================

    test('none should not equal icon', () {
      expect(EmptyButtonType.none == EmptyButtonType.icon, isFalse);
    });

    test('icon should not equal elevated', () {
      expect(EmptyButtonType.icon == EmptyButtonType.elevated, isFalse);
    });

    test('none should not equal elevated', () {
      expect(EmptyButtonType.none == EmptyButtonType.elevated, isFalse);
    });
  });

  group('emptyTables widget', () {
    // ========================================================================
    // POSITIVE TEST CASES
    // ========================================================================

    testWidgets('should display message text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyTables(message: 'No items found'),
          ),
        ),
      );

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('should center the content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyTables(message: 'Test message'),
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('should not show button when buttonType is none', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyTables(
              message: 'No items',
              buttonType: EmptyButtonType.none,
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('should show icon button when buttonType is icon and onAddPressed provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyTables(
              message: 'No items',
              buttonType: EmptyButtonType.icon,
              onAddPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('should show elevated button when buttonType is elevated and onAddPressed provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyTables(
              message: 'No items',
              buttonType: EmptyButtonType.elevated,
              onAddPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('elevated button should show custom text when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyTables(
              message: 'No items',
              buttonType: EmptyButtonType.elevated,
              onAddPressed: () {},
              buttonText: 'Add New',
            ),
          ),
        ),
      );

      expect(find.text('Add New'), findsOneWidget);
    });

    testWidgets('elevated button should show "Confirm" when no buttonText provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyTables(
              message: 'No items',
              buttonType: EmptyButtonType.elevated,
              onAddPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Confirm'), findsOneWidget);
    });

    // ========================================================================
    // NEGATIVE TEST CASES
    // ========================================================================

    testWidgets('should not show button when onAddPressed is null even with buttonType', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyTables(
              message: 'No items',
              buttonType: EmptyButtonType.icon,
              onAddPressed: null,
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsNothing);
    });
  });

  group('buildUniversalTable widget', () {
    testWidgets('should render DataTable', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildUniversalTable(
              headers: ['Name', 'Value'],
              rows: [
                ['Item 1', '100'],
                ['Item 2', '200'],
              ],
              smallHeaderWidth: 80,
              largeHeaderWidth: 150,
            ),
          ),
        ),
      );

      expect(find.byType(DataTable), findsOneWidget);
    });

    testWidgets('should display header text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildUniversalTable(
              headers: ['Name', 'Value'],
              rows: [],
              smallHeaderWidth: 80,
              largeHeaderWidth: 150,
            ),
          ),
        ),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Value'), findsOneWidget);
    });
  });
}
