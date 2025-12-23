// lib/services/supabase_auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase show User;
import '../database/app_database.dart';

/// Result type for authentication operations
class AuthResult {
  final bool success;
  final String? message;
  final supabase.User? user;
  final UserData? localUser;

  const AuthResult({
    required this.success,
    this.message,
    this.user,
    this.localUser,
  });

  factory AuthResult.success({supabase.User? user, UserData? localUser, String? message}) {
    return AuthResult(
      success: true,
      user: user,
      localUser: localUser,
      message: message,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult(success: false, message: message);
  }
}

/// Local user data with role and organization info
class UserData {
  final int id;
  final String username;
  final String email;
  final String? phone;
  final int organizationId;
  final String? organizationCloudId;
  final String organizationType;
  final String organizationName;
  final int roleId;
  final String roleName;
  final RolePermissions permissions;
  final String? cloudId;
  final String? authUserId;

  const UserData({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    required this.organizationId,
    this.organizationCloudId,
    required this.organizationType,
    required this.organizationName,
    required this.roleId,
    required this.roleName,
    required this.permissions,
    this.cloudId,
    this.authUserId,
  });

  bool get isCommissary => organizationType == 'commissary';
  bool get isFranchisee => organizationType == 'franchisee';
}

/// Role permissions for easy access
class RolePermissions {
  final bool canViewInventory;
  final bool canManageInventory;
  final bool canViewReports;
  final bool canManageEmployees;
  final bool canManageRoles;
  final bool canManageBranches;

  const RolePermissions({
    this.canViewInventory = false,
    this.canManageInventory = false,
    this.canViewReports = false,
    this.canManageEmployees = false,
    this.canManageRoles = false,
    this.canManageBranches = false,
  });

  factory RolePermissions.fromRole(Role role) {
    return RolePermissions(
      canViewInventory: role.canViewInventory,
      canManageInventory: role.canManageInventory,
      canViewReports: role.canViewReports,
      canManageEmployees: role.canManageEmployees,
      canManageRoles: role.canManageRoles,
      canManageBranches: role.canManageBranches,
    );
  }
}

/// Supabase Auth Service for Commissary (Hub) App
///
/// Features:
/// - Email/Password authentication via Supabase Auth
/// - Links Supabase Auth users to local users table
/// - Maintains session state
/// - Admin functions for managing branch users
/// - Enforces commissary-only access
class SupabaseAuthService {
  final SupabaseClient _supabase;
  final AppDatabase _db;

  // Current session state
  UserData? _currentUser;
  StreamController<UserData?>? _authStateController;

  SupabaseAuthService({
    required SupabaseClient supabase,
    required AppDatabase db,
  })  : _supabase = supabase,
        _db = db {
    _authStateController = StreamController<UserData?>.broadcast();
    _initAuthListener();
  }

  // Getters
  UserData? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isCommissary => _currentUser?.isCommissary ?? false;
  Stream<UserData?> get authStateChanges => _authStateController!.stream;
  supabase.User? get supabaseUser => _supabase.auth.currentUser;

  /// Initialize auth state listener
  void _initAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (kDebugMode) {
        print('🔐 Auth state changed: $event');
      }

      if (event == AuthChangeEvent.signedIn && session != null) {
        await _loadCurrentUser(session.user);
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _authStateController?.add(null);
      } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
        if (_currentUser == null) {
          await _loadCurrentUser(session.user);
        }
      }
    });
  }

  /// Load current user data from local database
  Future<void> _loadCurrentUser(supabase.User authUser) async {
    try {
      final localUser = await _findLocalUser(authUser);
      
      if (localUser != null) {
        // Verify this is a commissary user
        if (!localUser.isCommissary) {
          if (kDebugMode) {
            print('⚠️ User is not a commissary user: ${localUser.organizationType}');
          }
          _currentUser = null;
          _authStateController?.add(null);
          return;
        }
        
        _currentUser = localUser;
        _authStateController?.add(localUser);
        
        if (kDebugMode) {
          print('✅ User loaded: ${localUser.username} (${localUser.organizationType})');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ No local user found for auth user: ${authUser.email}');
        }
        _currentUser = null;
        _authStateController?.add(null);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading user: $e');
      }
      _currentUser = null;
      _authStateController?.add(null);
    }
  }

  /// Find local user by Supabase auth user
  Future<UserData?> _findLocalUser(supabase.User authUser) async {
    try {
      final users = await _db.usersDao.getAllUsers();
      
      for (final user in users) {
        if (!user.isActive) continue;
        
        if (user.email.toLowerCase() == authUser.email?.toLowerCase()) {
          final org = await _db.organizationsDao.getOrganizationById(user.organizationId);
          final role = await _db.rolesDao.getRoleById(user.roleId);
          
          if (org == null || role == null) continue;
          
          return UserData(
            id: user.id,
            username: user.username,
            email: user.email,
            phone: user.phone,
            organizationId: user.organizationId,
            organizationCloudId: org.cloudId,
            organizationType: org.type,
            organizationName: org.name,
            roleId: user.roleId,
            roleName: role.name,
            permissions: RolePermissions.fromRole(role),
            cloudId: user.cloudId,
            authUserId: authUser.id,
          );
        }
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error finding local user: $e');
      }
      return null;
    }
  }

  /// Sign in with email and password
  /// Uses Supabase Auth to establish a session with auth.uid() for RLS
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔑 [AUTH] Attempting Supabase Auth signIn for: $email');
      // 1. Authenticate with Supabase Auth
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('🔑 [AUTH] Supabase response: user=${authResponse.user?.email}');

      if (authResponse.user == null) {
        print('🔑 [AUTH] No user returned from Supabase');
        return AuthResult.failure('Invalid credentials');
      }

      // 2. Load local user data
      print('🔑 [AUTH] Loading local user data...');
      await _loadCurrentUser(authResponse.user!);

      if (_currentUser == null) {
        print('🔑 [AUTH] No local user found or not commissary');
        // Sign out since user doesn't have local record or isn't commissary
        await _supabase.auth.signOut();
        return AuthResult.failure('Access denied. Commissary users only.');
      }

      print('🔑 [AUTH] Login successful via Supabase Auth');
      return AuthResult.success(
        user: authResponse.user,
        localUser: _currentUser,
        message: 'Signed in successfully',
      );
    } on AuthException catch (e) {
      print('🔑 [AUTH] AuthException: ${e.message}');
      // If network fails, try offline login
      if (e.message.contains('network') || e.message.contains('connection')) {
        print('🔑 [AUTH] Network error, trying offline login...');
        return _offlineSignIn(email, password);
      }
      print('🔑 [AUTH] Trying offline login due to auth error...');
      return _offlineSignIn(email, password);
    } catch (e) {
      print('🔑 [AUTH] General exception: $e, trying offline login...');
      // Try offline login on any error
      return _offlineSignIn(email, password);
    }
  }

  /// Offline sign in using local database
  Future<AuthResult> _offlineSignIn(String email, String password) async {
    print('🔑 [OFFLINE] Attempting offline login for: $email');
    try {
      final user = await _db.usersDao.getUserByEmail(email);
      
      print('🔑 [OFFLINE] User found: ${user != null}, isActive: ${user?.isActive}');
      
      if (user == null || !user.isActive) {
        print('🔑 [OFFLINE] User not found or inactive');
        return AuthResult.failure('Invalid credentials');
      }

      print('🔑 [OFFLINE] Stored hash: ${user.passwordHash}');
      print('🔑 [OFFLINE] Hash length: ${user.passwordHash.length}');
      
      // Verify password hash
      if (!_verifyPassword(password, user.passwordHash)) {
        print('🔑 [OFFLINE] Password verification failed');
        return AuthResult.failure('Invalid credentials');
      }

      print('🔑 [OFFLINE] Password verified successfully');

      // Load organization and role
      final org = await _db.organizationsDao.getOrganizationById(user.organizationId);
      final role = await _db.rolesDao.getRoleById(user.roleId);

      if (org == null || role == null) {
        return AuthResult.failure('User configuration error');
      }

      // Verify commissary access
      if (org.type != 'commissary') {
        return AuthResult.failure('Access denied. Commissary users only.');
      }

      _currentUser = UserData(
        id: user.id,
        username: user.username,
        email: user.email,
        phone: user.phone,
        organizationId: user.organizationId,
        organizationCloudId: org.cloudId,
        organizationType: org.type,
        organizationName: org.name,
        roleId: user.roleId,
        roleName: role.name,
        permissions: RolePermissions.fromRole(role),
        cloudId: user.cloudId,
      );

      _authStateController?.add(_currentUser);

      return AuthResult.success(
        localUser: _currentUser,
        message: 'Signed in offline',
      );
    } catch (e) {
      return AuthResult.failure('Offline sign in failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error signing out from Supabase: $e');
      }
    }
    
    _currentUser = null;
    _authStateController?.add(null);
  }

  /// Restore session on app start
  Future<AuthResult> restoreSession() async {
    try {
      final session = _supabase.auth.currentSession;
      
      if (session != null && await isSessionValid()) {
        await _loadCurrentUser(session.user);
        
        if (_currentUser != null) {
          return AuthResult.success(
            user: session.user,
            localUser: _currentUser,
          );
        }
      }
      
      return AuthResult.failure('No active session');
    } catch (e) {
      return AuthResult.failure('Session restore failed: $e');
    }
  }

  /// Check if current session is valid
  Future<bool> isSessionValid() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return false;
    
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;
    
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    return DateTime.now().isBefore(expiryDate);
  }

  /// Get access token for API calls
  String? get accessToken => _supabase.auth.currentSession?.accessToken;

  // ============================================================
  // ADMIN FUNCTIONS FOR MANAGING BRANCH USERS
  // ============================================================

  /// Create a Supabase Auth user for a branch admin
  /// This allows them to authenticate with RLS working correctly
  Future<String?> createBranchAdminAuthUser({
    required String email,
    required String password,
    required String organizationCloudId,
  }) async {
    try {
      final response = await _supabase.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true,
          userMetadata: {
            'organization_id': organizationCloudId,
            'role': 'branch_admin',
          },
        ),
      );

      if (response.user != null) {
        if (kDebugMode) {
          print('✅ Created Supabase Auth user: ${response.user!.id}');
        }
        return response.user!.id;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to create auth user: $e');
      }
      return null;
    }
  }

  /// Delete a Supabase Auth user
  Future<bool> deleteAuthUser(String authUserId) async {
    try {
      await _supabase.auth.admin.deleteUser(authUserId);
      if (kDebugMode) {
        print('✅ Deleted auth user: $authUserId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to delete auth user: $e');
      }
      return false;
    }
  }

  /// Update user password in Supabase Auth
  Future<bool> updateUserPassword(String authUserId, String newPassword) async {
    try {
      await _supabase.auth.admin.updateUserById(
        authUserId,
        attributes: AdminUserAttributes(password: newPassword),
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to update password: $e');
      }
      return false;
    }
  }

  // ============================================================
  // PASSWORD HASHING (for offline login support)
  // ============================================================

  /// Generate a cryptographically secure random salt
  String _generateSalt([int length = 16]) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Hash password using PBKDF2 with per-user random salt
  String hashPassword(String password) {
    final salt = _generateSalt();
    return _hashPasswordWithSalt(password, salt);
  }

  /// Hash password with a specific salt
  String _hashPasswordWithSalt(String password, String salt) {
    const int iterations = 100000;
    const int keyLength = 32;

    final hmac = Hmac(sha256, utf8.encode(password));
    final saltBytes = utf8.encode(salt);

    List<int> int32ToBytes(int i) {
      return <int>[
        (i >> 24) & 0xff,
        (i >> 16) & 0xff,
        (i >> 8) & 0xff,
        i & 0xff,
      ];
    }

    final blockIndexBytes = int32ToBytes(1);
    var u = hmac.convert([...saltBytes, ...blockIndexBytes]).bytes;
    final List<int> derivedBlock = List<int>.from(u);

    for (int i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (int j = 0; j < derivedBlock.length; j++) {
        derivedBlock[j] ^= u[j];
      }
    }

    final dk = derivedBlock.sublist(0, keyLength);
    final hashHex = dk.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    return '$salt\$$hashHex';
  }

  /// Verify a password against a stored hash
  bool _verifyPassword(String password, String storedHash) {
    print('🔐 [VERIFY] Verifying password...');
    print('🔐 [VERIFY] Stored hash: $storedHash');
    
    final parts = storedHash.split('\$');
    print('🔐 [VERIFY] Hash parts count: ${parts.length}');
    
    if (parts.length != 2) {
      if (kDebugMode) {
        print('⚠️ Invalid hash format (expected salt\$hash), got ${parts.length} parts');
      }
      return false;
    }

    final salt = parts[0];
    print('🔐 [VERIFY] Salt: $salt (length: ${salt.length})');
    
    final expectedFullHash = _hashPasswordWithSalt(password, salt);
    print('🔐 [VERIFY] Expected hash: $expectedFullHash');
    print('🔐 [VERIFY] Stored hash:   $storedHash');

    if (storedHash.length != expectedFullHash.length) {
      print('🔐 [VERIFY] Length mismatch: stored=${storedHash.length}, expected=${expectedFullHash.length}');
      return false;
    }
    
    int result = 0;
    for (int i = 0; i < storedHash.length; i++) {
      result |= storedHash.codeUnitAt(i) ^ expectedFullHash.codeUnitAt(i);
    }
    print('🔐 [VERIFY] Comparison result: $result (0 = match)');
    return result == 0;
  }

  /// Dispose resources
  void dispose() {
    _authStateController?.close();
  }
}
