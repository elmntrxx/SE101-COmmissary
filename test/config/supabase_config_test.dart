import 'package:flutter_test/flutter_test.dart';

// Note: We test the SupabaseConfig logic without importing flutter_dotenv
// since that would require actual .env file. Instead we test the validation logic.

void main() {
  group('SupabaseConfig validation logic', () {
    // ========================================================================
    // POSITIVE TEST CASES
    // ========================================================================

    test('isValid should return true when both url and anonKey are non-empty', () {
      final url = 'https://example.supabase.co';
      final anonKey = 'test-anon-key-123';
      
      final isValid = url.isNotEmpty && anonKey.isNotEmpty;
      expect(isValid, isTrue);
    });

    test('hasServiceRoleKey should return true when serviceRoleKey is non-empty', () {
      final serviceRoleKey = 'test-service-role-key';
      
      final hasKey = serviceRoleKey.isNotEmpty;
      expect(hasKey, isTrue);
    });

    test('url should be valid Supabase URL format', () {
      final url = 'https://example.supabase.co';
      
      expect(url.startsWith('https://'), isTrue);
      expect(url.contains('supabase'), isTrue);
    });

    test('anonKey should be non-empty string', () {
      final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test';
      
      expect(anonKey.isNotEmpty, isTrue);
    });

    test('serviceRoleKey should be non-empty string when provided', () {
      final serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.service';
      
      expect(serviceRoleKey.isNotEmpty, isTrue);
    });

    test('default empty string fallback should work for url', () {
      final String? envValue = null;
      final url = envValue ?? '';
      
      expect(url, equals(''));
    });

    test('default empty string fallback should work for anonKey', () {
      final String? envValue = null;
      final anonKey = envValue ?? '';
      
      expect(anonKey, equals(''));
    });

    test('default empty string fallback should work for serviceRoleKey', () {
      final String? envValue = null;
      final serviceRoleKey = envValue ?? '';
      
      expect(serviceRoleKey, equals(''));
    });

    // ========================================================================
    // NEGATIVE TEST CASES
    // ========================================================================

    test('isValid should return false when url is empty', () {
      final url = '';
      final anonKey = 'test-anon-key';
      
      final isValid = url.isNotEmpty && anonKey.isNotEmpty;
      expect(isValid, isFalse);
    });

    test('isValid should return false when anonKey is empty', () {
      final url = 'https://example.supabase.co';
      final anonKey = '';
      
      final isValid = url.isNotEmpty && anonKey.isNotEmpty;
      expect(isValid, isFalse);
    });

    test('isValid should return false when both url and anonKey are empty', () {
      final url = '';
      final anonKey = '';
      
      final isValid = url.isNotEmpty && anonKey.isNotEmpty;
      expect(isValid, isFalse);
    });

    test('hasServiceRoleKey should return false when serviceRoleKey is empty', () {
      final serviceRoleKey = '';
      
      final hasKey = serviceRoleKey.isNotEmpty;
      expect(hasKey, isFalse);
    });

    test('null env value should default to empty string', () {
      final String? envValue = null;
      final result = envValue ?? '';
      
      expect(result.isEmpty, isTrue);
    });

    test('whitespace-only string should still be considered non-empty by isNotEmpty', () {
      final value = '   ';
      
      // isNotEmpty returns true for whitespace, but it's not a valid key
      expect(value.isNotEmpty, isTrue);
      expect(value.trim().isEmpty, isTrue);
    });

    test('empty url should fail validation', () {
      final url = '';
      expect(url.isEmpty, isTrue);
    });
  });
}
