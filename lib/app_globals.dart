// lib/app_globals.dart
import 'database/app_database.dart';
import 'services/supabase_sync_service.dart';
import 'services/supabase_auth_service.dart';

/// Global application state singleton
class AppGlobals {
  AppGlobals._();

  static final AppGlobals instance = AppGlobals._();

  late AppDatabase _database;
  late SupabaseSyncService _syncService;
  late SupabaseAuthService _authService;
  bool _isInitialized = false;

  /// Initialize the global app state
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

  /// Get the database instance
  AppDatabase get database {
    if (!_isInitialized) {
      throw StateError('AppGlobals has not been initialized. Call initialize() first.');
    }
    return _database;
  }

  /// Get the sync service instance
  SupabaseSyncService get syncService {
    if (!_isInitialized) {
      throw StateError('AppGlobals has not been initialized. Call initialize() first.');
    }
    return _syncService;
  }

  /// Get the auth service instance
  SupabaseAuthService get authService {
    if (!_isInitialized) {
      throw StateError('AppGlobals has not been initialized. Call initialize() first.');
    }
    return _authService;
  }

  /// Check if initialized
  bool get isInitialized => _isInitialized;
}

/// Convenience getter for database
AppDatabase get database => AppGlobals.instance.database;

/// Convenience getter for sync service
SupabaseSyncService get syncService => AppGlobals.instance.syncService;

/// Convenience getter for auth service
SupabaseAuthService get authService => AppGlobals.instance.authService;
