// lib/config/supabase_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Service role key for admin operations (bypasses RLS)
  /// ⚠️ NEVER expose this key in client-side code in production!
  /// This should only be used for sync operations.
  static String get serviceRoleKey =>
      dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';

  // Validate that credentials are loaded
  static bool get isValid => url.isNotEmpty && anonKey.isNotEmpty;

  // Check if service role key is available for sync
  static bool get hasServiceRoleKey => serviceRoleKey.isNotEmpty;
}
