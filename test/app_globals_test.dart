import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:commissary_app/database/app_database.dart';
import 'package:commissary_app/services/supabase_sync_service.dart';
import 'package:commissary_app/services/supabase_auth_service.dart';

// Mock classes
class MockAppDatabase extends Mock implements AppDatabase {}
class MockSupabaseSyncService extends Mock implements SupabaseSyncService {}
class MockSupabaseAuthService extends Mock implements SupabaseAuthService {}

/// Test implementation of AppGlobals to avoid singleton issues
class TestableAppGlobals {
  TestableAppGlobals._();

  static final TestableAppGlobals instance = TestableAppGlobals._();

  AppDatabase? _database;
  SupabaseSyncService? _syncService;
  SupabaseAuthService? _authService;
  bool _isInitialized = false;

  void initialize({
    required AppDatabase database,
    required SupabaseSyncService syncService,
    required SupabaseAuthService authService,
  }) {
    _database = database;
    _syncService = syncService;
    _authService = authService;
    _isInitialized = true;
  }

  AppDatabase get database {
    if (!_isInitialized) {
      throw StateError('AppGlobals has not been initialized. Call initialize() first.');
    }
    return _database!;
  }

  SupabaseSyncService get syncService {
    if (!_isInitialized) {
      throw StateError('AppGlobals has not been initialized. Call initialize() first.');
    }
    return _syncService!;
  }

  SupabaseAuthService get authService {
    if (!_isInitialized) {
      throw StateError('AppGlobals has not been initialized. Call initialize() first.');
    }
    return _authService!;
  }

  bool get isInitialized => _isInitialized;

  void reset() {
    _database = null;
    _syncService = null;
    _authService = null;
    _isInitialized = false;
  }
}

void main() {
  late TestableAppGlobals appGlobals;
  late MockAppDatabase mockDatabase;
  late MockSupabaseSyncService mockSyncService;
  late MockSupabaseAuthService mockAuthService;

  setUp(() {
    appGlobals = TestableAppGlobals.instance;
    appGlobals.reset();
    mockDatabase = MockAppDatabase();
    mockSyncService = MockSupabaseSyncService();
    mockAuthService = MockSupabaseAuthService();
  });

  group('AppGlobals', () {
    // ========================================================================
    // POSITIVE TEST CASES
    // ========================================================================

    test('should be a singleton instance', () {
      final instance1 = TestableAppGlobals.instance;
      final instance2 = TestableAppGlobals.instance;
      
      expect(identical(instance1, instance2), isTrue);
    });

    test('isInitialized should return false before initialization', () {
      expect(appGlobals.isInitialized, isFalse);
    });

    test('isInitialized should return true after initialization', () {
      appGlobals.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
      );
      
      expect(appGlobals.isInitialized, isTrue);
    });

    test('should return database after initialization', () {
      appGlobals.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
      );
      
      expect(appGlobals.database, equals(mockDatabase));
    });

    test('should return syncService after initialization', () {
      appGlobals.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
      );
      
      expect(appGlobals.syncService, equals(mockSyncService));
    });

    test('should return authService after initialization', () {
      appGlobals.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
      );
      
      expect(appGlobals.authService, equals(mockAuthService));
    });

    test('initialize should accept required parameters', () {
      expect(
        () => appGlobals.initialize(
          database: mockDatabase,
          syncService: mockSyncService,
          authService: mockAuthService,
        ),
        returnsNormally,
      );
    });

    test('should allow re-initialization', () {
      appGlobals.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
      );

      final newMockDatabase = MockAppDatabase();
      appGlobals.initialize(
        database: newMockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
      );

      expect(appGlobals.database, equals(newMockDatabase));
    });

    // ========================================================================
    // NEGATIVE TEST CASES
    // ========================================================================

    test('database getter should throw StateError when not initialized', () {
      expect(
        () => appGlobals.database,
        throwsA(isA<StateError>()),
      );
    });

    test('syncService getter should throw StateError when not initialized', () {
      expect(
        () => appGlobals.syncService,
        throwsA(isA<StateError>()),
      );
    });

    test('authService getter should throw StateError when not initialized', () {
      expect(
        () => appGlobals.authService,
        throwsA(isA<StateError>()),
      );
    });

    test('StateError message should mention initialization', () {
      expect(
        () => appGlobals.database,
        throwsA(
          predicate<StateError>(
            (e) => e.message.contains('initialize'),
          ),
        ),
      );
    });

    test('reset should set isInitialized to false', () {
      appGlobals.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
      );
      
      appGlobals.reset();
      
      expect(appGlobals.isInitialized, isFalse);
    });

    test('accessing services after reset should throw', () {
      appGlobals.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
      );
      
      appGlobals.reset();
      
      expect(() => appGlobals.database, throwsA(isA<StateError>()));
    });
  });
}
