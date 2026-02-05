// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_size/window_size.dart';

import 'config/supabase_config.dart';
import 'database/app_database.dart';
import 'services/supabase_sync_service_v2.dart';
import 'services/supabase_auth_service.dart';
import 'services/realtime_stock_request_service.dart';
import 'app_globals.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Desktop window configuration
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Chicken Joo Commissary');
    setWindowMinSize(const Size(1280, 720));
    setWindowMaxSize(const Size(1920, 1080));
  }

  // Initialize database
  print('🗄️ Initializing database...');
  final dbFolder = await getApplicationDocumentsDirectory();
  print('📁 Database path: ${dbFolder.path}/chickenjoo_commissary.sqlite');
  final db = AppDatabase();

  // Initialize Supabase
  print('☁️ Initializing Supabase...');
  bool supabaseInitialized = false;

  try {
    if (SupabaseConfig.isValid) {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      print('✅ Supabase initialized');
      supabaseInitialized = true;
    } else {
      print('⚠️ Supabase credentials not configured');
    }
  } catch (e) {
    print('⚠️ Supabase initialization failed: $e');
    print('📱 App will work in offline-only mode');
  }

  // Initialize sync service (V2 - uses authenticated client with RLS)
  print('🔄 Initializing sync service V2...');
  final syncService = SupabaseSyncServiceV2(
    db: db,
    supabase: supabaseInitialized
        ? Supabase.instance.client
        : SupabaseClient('', ''), // Dummy client for offline mode
    onConnectivityChanged: (isOnline) {
      print('📡 Connectivity: ${isOnline ? "Online ✅" : "Offline 📵"}');
    },
    onSyncStatusChanged: (status) {
      print('🔄 Sync status: $status');
    },
    onSyncError: (error) {
      print('❌ Sync error: $error');
    },
  );

  // Initialize auth service
  print('🔐 Initializing auth service...');
  final authService = SupabaseAuthService(
    supabase: supabaseInitialized
        ? Supabase.instance.client
        : SupabaseClient('', ''),
    db: db,
  );

  // Initialize realtime stock request service
  print('📡 Initializing realtime stock request service...');
  final realtimeStockRequestService = RealtimeStockRequestService(
    supabase: supabaseInitialized
        ? Supabase.instance.client
        : SupabaseClient('', ''),
    db: db,
  );

  // Wire up sync callback for realtime service
  realtimeStockRequestService.syncCallback = () async {
    await syncService.performFullSync();
  };

  // Initialize AppGlobals
  AppGlobals.instance.initialize(
    database: db,
    syncService: syncService,
    authService: authService,
    realtimeStockRequestService: realtimeStockRequestService,
  );
  print('✅ AppGlobals initialized');

  // Start sync service if Supabase is available
  if (supabaseInitialized) {
    syncService.initialize().then((_) {
      syncService.startPeriodicSync();
    });
    
    // Wire up auth state to sync service organization context
    authService.authStateChanges.listen((user) {
      if (user != null) {
        // User logged in - set organization context for sync
        syncService.setOrganizationContext(
          organizationType: user.organizationType,
          organizationId: user.organizationId,
          organizationCloudId: user.organizationCloudId ?? '',
        );
        print('🔄 Sync context set: ${user.organizationType} (org ${user.organizationId})');
        // Trigger a sync now that we have context
        syncService.performFullSync();
      }
    });
    
    // If user is already logged in, set context immediately
    if (authService.currentUser != null) {
      final user = authService.currentUser!;
      syncService.setOrganizationContext(
        organizationType: user.organizationType,
        organizationId: user.organizationId,
        organizationCloudId: user.organizationCloudId ?? '',
      );
      print('🔄 Sync context set (existing session): ${user.organizationType} (org ${user.organizationId})');
    }
  }

  runApp(const CommissaryApp());
}
