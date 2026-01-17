// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_size/window_size.dart';

import 'config/supabase_config.dart';
import 'database/app_database.dart';
import 'services/supabase_sync_service.dart';
import 'services/supabase_auth_service.dart';
import 'app_globals.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Desktop window configuration
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Chicken Joo Commissary');
    setWindowMinSize(const Size(100, 720));
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

  // Initialize sync service
  print('🔄 Initializing sync service...');
  final syncService = SupabaseSyncService(
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

  // Initialize AppGlobals
  AppGlobals.instance.initialize(
    database: db,
    syncService: syncService,
    authService: authService,
  );
  print('✅ AppGlobals initialized');

  // Start sync service if Supabase is available
  if (supabaseInitialized) {
    syncService.initialize().then((_) {
      syncService.startPeriodicSync();
    });
  }

  runApp(const CommissaryApp());
}
