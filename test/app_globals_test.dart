import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:commissary_app/database/app_database.dart';
import 'package:commissary_app/services/supabase_sync_service_v2.dart';
import 'package:commissary_app/services/supabase_auth_service.dart';
import 'package:commissary_app/services/realtime_stock_request_service.dart';

// Mock classes
class MockAppDatabase extends Mock implements AppDatabase {}
class MockSupabaseSyncServiceV2 extends Mock implements SupabaseSyncServiceV2 {}
class MockSupabaseAuthService extends Mock implements SupabaseAuthService {}
class MockRealtimeStockRequestService extends Mock implements RealtimeStockRequestService {}

/// Test implementation of AppGlobals to avoid singleton issues
class TestableAppGlobals {
  TestableAppGlobals._();

  static final TestableAppGlobals instance = TestableAppGlobals._();

  AppDatabase? _database;
  SupabaseSyncServiceV2? _syncService;
  SupabaseAuthService? _authService;
  RealtimeStockRequestService? _realtimeStockRequestService;
  bool _isInitialized = false;

  void initialize({
    required AppDatabase database,
    required SupabaseSyncServiceV2 syncService,
    required SupabaseAuthService authService,
    required RealtimeStockRequestService realtimeStockRequestService,
  }) {
    _database = database;
    _syncService = syncService;
    _authService = authService;
    _realtimeStockRequestService = realtimeStockRequestService;
    _isInitialized = true;
  }

  AppDatabase get database {
    if (!_isInitialized) {
      throw StateError('AppGlobals has not been initialized. Call initialize() first.');
    }
    return _database!;
  }

  SupabaseSyncServiceV2 get syncService {
    if (!_isInitialized) {
      throw StateError('AppGlobals has not been initialized. Call initialize() first.');
    }
    return _syncService!;
  }

  RealtimeStockRequestService get realtimeStockRequestService {
    if (!_isInitialized) {
      throw StateError('AppGlobals has not been initialized. Call initialize() first.');
    }
    return _realtimeStockRequestService!;
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
    _realtimeStockRequestService = null;
    _isInitialized = false;
  }
}

void main() {
  late TestableAppGlobals appGlobals;
  late MockAppDatabase mockDatabase;
  late MockSupabaseSyncServiceV2 mockSyncService;
  late MockSupabaseAuthService mockAuthService;
  late MockRealtimeStockRequestService mockRealtimeStockRequestService;

  setUp(() {
    appGlobals = TestableAppGlobals.instance;
    appGlobals.reset();
    mockDatabase = MockAppDatabase();
    mockSyncService = MockSupabaseSyncServiceV2();
    mockAuthService = MockSupabaseAuthService();
    mockRealtimeStockRequestService = MockRealtimeStockRequestService();
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
        realtimeStockRequestService: mockRealtimeStockRequestService,
      );
      
      expect(appGlobals.isInitialized, isTrue);
    });

    test('should return database after initialization', () {
      appGlobals.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
        realtimeStockRequestService: mockRealtimeStockRequestService,
      );
      
      expect(appGlobals.database, equals(mockDatabase));
    });

    test('should return syncService after initialization', () {
      appGlobals.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
        realtimeStockRequestService: mockRealtimeStockRequestService,
      );
      
      expect(appGlobals.syncService, equals(mockSyncService));
    });

    test('should return authService after initialization', () {
      appGlobals.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
        realtimeStockRequestService: mockRealtimeStockRequestService,
      );
      
      expect(appGlobals.authService, equals(mockAuthService));
    });

    test('initialize should accept required parameters', () {
      expect(
        () => appGlobals.initialize(
          database: mockDatabase,
          syncService: mockSyncService,
          authService: mockAuthService,
          realtimeStockRequestService: mockRealtimeStockRequestService,
        ),
        returnsNormally,
      );
    });

    test('should allow re-initialization', () {
      appGlobals.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
        realtimeStockRequestService: mockRealtimeStockRequestService,
      );

      final newMockDatabase = MockAppDatabase();
      appGlobals.initialize(
        database: newMockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
        realtimeStockRequestService: mockRealtimeStockRequestService,
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
        realtimeStockRequestService: mockRealtimeStockRequestService,
      );
      
      appGlobals.reset();
      
      expect(appGlobals.isInitialized, isFalse);
    });

    test('accessing services after reset should throw', () {
      appGlobals.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
        realtimeStockRequestService: mockRealtimeStockRequestService,
      );
      
      appGlobals.reset();
      
      expect(() => appGlobals.database, throwsA(isA<StateError>()));
    });
  });
}
