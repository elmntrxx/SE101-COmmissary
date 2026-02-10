import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:commissary_app/utils/design_constants.dart';

void main() {
  group('Design Constants', () {
    // ========================================================================
    // POSITIVE TEST CASES
    // ========================================================================

    test('fontAll should be Montserrat', () {
      expect(fontAll, equals('Montserrat'));
    });

    test('imageAll should be correct asset path', () {
      expect(imageAll, equals('assets/chicken_joo_logo.png'));
    });

    test('colorAll should be red', () {
      expect(colorAll, equals(Colors.red));
    });

    test('fontAll should be non-empty string', () {
      expect(fontAll.isNotEmpty, isTrue);
    });

    test('imageAll should contain assets folder prefix', () {
      expect(imageAll.startsWith('assets/'), isTrue);
    });

    test('imageAll should have png extension', () {
      expect(imageAll.endsWith('.png'), isTrue);
    });

    test('colorAll should be a valid Color', () {
      expect(colorAll, isA<Color>());
    });

    // ========================================================================
    // NEGATIVE TEST CASES
    // ========================================================================

    test('fontAll should not be empty', () {
      expect(fontAll, isNot(equals('')));
    });

    test('imageAll should not be empty', () {
      expect(imageAll, isNot(equals('')));
    });

    test('colorAll should not be transparent', () {
      expect(colorAll.alpha, isNot(equals(0)));
    });

    test('fontAll should not contain special characters', () {
      final hasSpecialChars = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(fontAll);
      expect(hasSpecialChars, isFalse);
    });

    test('imageAll should not contain spaces', () {
      expect(imageAll.contains(' '), isFalse);
    });
  });

  group('AppLayout', () {
    // ========================================================================
    // POSITIVE TEST CASES - Using testWidgets for BuildContext
    // ========================================================================

    testWidgets('isDesktop should return true for width > 800', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1000, 800)),
          child: Builder(
            builder: (context) {
              expect(AppLayout.isDesktop(context), isTrue);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('isDesktop should return false for width <= 800', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: Builder(
            builder: (context) {
              expect(AppLayout.isDesktop(context), isFalse);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('fieldPadding should return 400 for width >= 1200', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: Builder(
            builder: (context) {
              expect(AppLayout.fieldPadding(context), equals(400.0));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('fieldPadding should return 200 for width >= 800 and < 1200', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(900, 600)),
          child: Builder(
            builder: (context) {
              expect(AppLayout.fieldPadding(context), equals(200.0));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('fieldPadding should return 24 for width < 800', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(600, 400)),
          child: Builder(
            builder: (context) {
              expect(AppLayout.fieldPadding(context), equals(24.0));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('loginButtonWidth should return 320 for width >= 1200', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: Builder(
            builder: (context) {
              expect(AppLayout.loginButtonWidth(context), equals(320.0));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('loginButtonWidth should return 280 for width >= 800 and < 1200', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(900, 600)),
          child: Builder(
            builder: (context) {
              expect(AppLayout.loginButtonWidth(context), equals(280.0));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('loginButtonWidth should return double.infinity for width < 800', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(600, 400)),
          child: Builder(
            builder: (context) {
              expect(AppLayout.loginButtonWidth(context), equals(double.infinity));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    // ========================================================================
    // NEGATIVE TEST CASES
    // ========================================================================

    testWidgets('isDesktop should return false for very small width', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(320, 480)),
          child: Builder(
            builder: (context) {
              expect(AppLayout.isDesktop(context), isFalse);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('fieldPadding should not return negative value', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(100, 100)),
          child: Builder(
            builder: (context) {
              expect(AppLayout.fieldPadding(context), greaterThan(0));
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
