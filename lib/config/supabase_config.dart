// lib/config/supabase_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase configuration
/// 
/// This app uses authenticated user sessions with RLS policies.
/// NO SERVICE ROLE KEY - all access is controlled by Row Level Security.
class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Validate that credentials are loaded
  static bool get isValid => url.isNotEmpty && anonKey.isNotEmpty;
  
  // ============================================================================
  // SECURITY NOTE
  // ============================================================================
  // 
  // This app previously used a service role key to bypass RLS during sync.
  // This was a security vulnerability as the key could be extracted from
  // the app binary.
  //
  // The app now uses:
  // 1. Authenticated user sessions (anon key + user auth)
  // 2. RLS policies that check auth.uid() and organization membership
  // 3. Server-side access control via Supabase RLS
  //
  // See: supabase/migrations/003_commissary_rls_policies.sql
  // ============================================================================
}
