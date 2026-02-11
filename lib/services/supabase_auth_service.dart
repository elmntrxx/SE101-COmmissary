// lib/services/supabase_auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase show User;
import '../database/app_database.dart';

/// Auth lifecycle states for clear startup flow
enum AuthLifecycleState {
  /// Initial state - auth bootstrap not yet started
  bootstrapping,
  /// Auth bootstrap complete - user is authenticated
  authenticated,
  /// Auth bootstrap complete - user is not authenticated
  unauthenticated,
}

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
/// - Maintains session state with clear lifecycle states
/// - Admin functions for managing branch users
/// - Enforces commissary-only access
/// - Refresh-token aware session recovery
class SupabaseAuthService {
  final SupabaseClient _supabase;
  final AppDatabase _db;

  // Current session state
  UserData? _currentUser;
  StreamController<UserData?>? _authStateController;
  
  // Auth lifecycle state
  AuthLifecycleState _lifecycleState = AuthLifecycleState.bootstrapping;
  final StreamController<AuthLifecycleState> _lifecycleController = 
      StreamController<AuthLifecycleState>.broadcast();
  final Completer<void> _bootstrapCompleter = Completer<void>();
  bool _bootstrapStarted = false;

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
  
  /// Current auth lifecycle state
  AuthLifecycleState get lifecycleState => _lifecycleState;
  
  /// Stream of auth lifecycle state changes
  Stream<AuthLifecycleState> get lifecycleStateChanges => _lifecycleController.stream;
  
  /// Future that completes when auth bootstrap is done
  Future<void> get bootstrapComplete => _bootstrapCompleter.future;

  /// Initialize auth state listener
  void _initAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      _logAuth('Auth state changed: $event');

      // Handle all session-providing events the same way  
      if ((event == AuthChangeEvent.signedIn || 
           event == AuthChangeEvent.tokenRefreshed ||
           event == AuthChangeEvent.initialSession) && session != null) {
        await _loadCurrentUser(session.user);
        _updateLifecycleState(_currentUser != null 
            ? AuthLifecycleState.authenticated 
            : AuthLifecycleState.unauthenticated);
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _authStateController?.add(null);
        _updateLifecycleState(AuthLifecycleState.unauthenticated);
      }
    });
  }
  
  /// Update lifecycle state and notify listeners
  void _updateLifecycleState(AuthLifecycleState newState) {
    if (_lifecycleState != newState) {
      _lifecycleState = newState;
      _lifecycleController.add(newState);
      _logAuth('Lifecycle state: $newState');
    }
    
    // Complete bootstrap if we've reached a final state
    if (!_bootstrapCompleter.isCompleted && 
        newState != AuthLifecycleState.bootstrapping) {
      _bootstrapCompleter.complete();
    }
  }
  
  /// Structured logging for auth events
  void _logAuth(String message) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('🔐 [$timestamp] [AUTH] $message');
    }
  }
  
  /// Bootstrap auth - call once on app startup to restore session
  /// Returns the final auth state after bootstrap completes
  Future<AuthLifecycleState> bootstrap() async {
    if (_bootstrapStarted) {
      await _bootstrapCompleter.future;
      return _lifecycleState;
    }
    _bootstrapStarted = true;
    
    _logAuth('Bootstrap starting...');
    
    try {
      final session = _supabase.auth.currentSession;
      
      if (session == null) {
        _logAuth('Bootstrap: No session found');
        _updateLifecycleState(AuthLifecycleState.unauthenticated);
        return _lifecycleState;
      }
      
      _logAuth('Bootstrap: Session found, checking validity...');
      
      // Check if access token is expired
      final expiresAt = session.expiresAt;
      final isExpired = expiresAt != null && 
          DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000));
      
      if (isExpired) {
        _logAuth('Bootstrap: Access token expired, attempting refresh...');
        
        // Try to refresh the session using refresh token
        if (session.refreshToken != null) {
          try {
            final refreshResponse = await _supabase.auth.refreshSession();
            
            if (refreshResponse.session != null) {
              _logAuth('Bootstrap: Token refresh successful');
              await _loadCurrentUser(refreshResponse.session!.user);
              
              if (_currentUser != null) {
                _updateLifecycleState(AuthLifecycleState.authenticated);
                return _lifecycleState;
              }
            }
          } catch (e) {
            _logAuth('Bootstrap: Token refresh failed: $e');
          }
        }
        
        // Refresh failed - session is unrecoverable
        _logAuth('Bootstrap: Session unrecoverable');
        _updateLifecycleState(AuthLifecycleState.unauthenticated);
        return _lifecycleState;
      }
      
      // Access token is still valid
      _logAuth('Bootstrap: Access token valid, loading user...');
      await _loadCurrentUser(session.user);
      
      if (_currentUser != null) {
        _updateLifecycleState(AuthLifecycleState.authenticated);
      } else {
        _updateLifecycleState(AuthLifecycleState.unauthenticated);
      }
      
      return _lifecycleState;
    } catch (e) {
      _logAuth('Bootstrap: Error during bootstrap: $e');
      _updateLifecycleState(AuthLifecycleState.unauthenticated);
      return _lifecycleState;
    }
  }

  /// Load current user data from local database
  Future<void> _loadCurrentUser(supabase.User authUser) async {
    try {
      _logAuth('Loading local user for: ${authUser.email}');
      final localUser = await _findLocalUser(authUser);
      
      if (localUser != null) {
        // Verify this is a commissary user
        if (!localUser.isCommissary) {
          _logAuth('User is not a commissary user: ${localUser.organizationType}');
          _currentUser = null;
          _authStateController?.add(null);
          return;
        }
        
        _currentUser = localUser;
        _authStateController?.add(localUser);
        
        _logAuth('User loaded: ${localUser.username} (${localUser.organizationType})');
      } else {
        _logAuth('No local user found for auth user: ${authUser.email}');
        _currentUser = null;
        _authStateController?.add(null);
      }
    } catch (e) {
      _logAuth('Error loading user: $e');
      _currentUser = null;
      _authStateController?.add(null);
    }
  }

  /// Find local user by Supabase auth user
  /// Uses auth user ID first, then falls back to email matching
  /// If not found locally, pulls from cloud and stores locally
  Future<UserData?> _findLocalUser(supabase.User authUser) async {
    try {
      // First, try to find user locally
      final users = await _db.usersDao.getAllUsers();
      
      // Priority 1: Match by auth_user_id first (most reliable)
      for (final user in users) {
        if (!user.isActive) continue;
        
        if (user.authUserId != null && user.authUserId == authUser.id) {
          _logAuth('Found user by authUserId: ${user.username}');
          return await _buildUserData(user, authUser);
        }
      }
      
      // Priority 2: Fall back to email match
      for (final user in users) {
        if (!user.isActive) continue;
        
        if (user.email.toLowerCase() == authUser.email?.toLowerCase()) {
          _logAuth('Found user by email: ${user.username}');
          return await _buildUserData(user, authUser);
        }
      }
      
      // Not found locally - try to pull from cloud
      _logAuth('User not found locally, pulling from cloud...');
      
      return await _pullUserFromCloud(authUser);
    } catch (e) {
      _logAuth('Error finding local user: $e');
      return null;
    }
  }
  
  /// Build UserData from a local User record
  Future<UserData?> _buildUserData(User user, supabase.User authUser) async {
    final org = await _db.organizationsDao.getOrganizationById(user.organizationId);
    final role = await _db.rolesDao.getRoleById(user.roleId);
    
    if (org == null || role == null) return null;
    
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

  /// Pull user data from Supabase cloud and store locally
  Future<UserData?> _pullUserFromCloud(supabase.User authUser) async {
    try {
      // Query user from cloud - try by auth_user_id first, then email
      Map<String, dynamic>? userResponse;
      
      // First try by auth_user_id (most reliable)
      userResponse = await _supabase
          .from('users')
          .select()
          .eq('auth_user_id', authUser.id)
          .maybeSingle();
      
      // Fall back to email if not found
      if (userResponse == null && authUser.email != null) {
        userResponse = await _supabase
            .from('users')
            .select()
            .eq('email', authUser.email!)
            .maybeSingle();
      }
      
      if (userResponse == null) {
        _logAuth('User not found in cloud: ${authUser.email}');
        return null;
      }
      
      _logAuth('Found user in cloud: ${userResponse['username']}');
      
      // Get organization from cloud
      final orgCloudId = userResponse['organization_id'] as String?;
      if (orgCloudId == null) {
        _logAuth('User has no organization_id');
        return null;
      }
      
      final orgResponse = await _supabase
          .from('organizations')
          .select()
          .eq('cloud_id', orgCloudId)
          .maybeSingle();
      
      if (orgResponse == null) {
        _logAuth('Organization not found in cloud: $orgCloudId');
        return null;
      }
      
      _logAuth('Found organization: ${orgResponse['name']} (${orgResponse['type']})');
      
      // Get role from cloud
      final roleCloudId = userResponse['role_id'] as String?;
      if (roleCloudId == null) {
        _logAuth('User has no role_id');
        return null;
      }
      
      final roleResponse = await _supabase
          .from('roles')
          .select()
          .eq('cloud_id', roleCloudId)
          .maybeSingle();
      
      if (roleResponse == null) {
        _logAuth('Role not found in cloud: $roleCloudId');
        return null;
      }
      
      _logAuth('Found role: ${roleResponse['name']}');
      
      // Store organization locally
      final localOrgId = await _db.organizationsDao.upsertFromCloud(orgResponse);
      
      // Store role locally
      final localRoleId = await _upsertRoleFromCloud(roleResponse);
      
      // Store user locally
      final localUserId = await _db.usersDao.upsertFromCloud(
        userResponse,
        organizationId: localOrgId,
        roleId: localRoleId,
      );
      
      // Fetch the stored data
      final localUser = await _db.usersDao.getUserById(localUserId);
      final localOrg = await _db.organizationsDao.getOrganizationById(localOrgId);
      final localRole = await _db.rolesDao.getRoleById(localRoleId);
      
      if (localUser == null || localOrg == null || localRole == null) {
        _logAuth('Failed to store user data locally');
        return null;
      }
      
      _logAuth('User data synced to local database');
      
      return UserData(
        id: localUser.id,
        username: localUser.username,
        email: localUser.email,
        phone: localUser.phone,
        organizationId: localUser.organizationId,
        organizationCloudId: localOrg.cloudId,
        organizationType: localOrg.type,
        organizationName: localOrg.name,
        roleId: localUser.roleId,
        roleName: localRole.name,
        permissions: RolePermissions.fromRole(localRole),
        cloudId: localUser.cloudId,
        authUserId: authUser.id,
      );
    } catch (e) {
      _logAuth('Error pulling user from cloud: $e');
      return null;
    }
  }

  /// Upsert role from cloud data
  Future<int> _upsertRoleFromCloud(Map<String, dynamic> cloudData) async {
    final cloudId = cloudData['cloud_id'] as String;
    
    // Check if role exists locally
    final existing = await _db.rolesDao.getRoleByCloudId(cloudId);
    
    if (existing != null) {
      return existing.id;
    }
    
    // Insert new role
    return await _db.into(_db.roles).insert(
      RolesCompanion.insert(
        cloudId: cloudId,
        name: cloudData['name'] as String,
        description: Value(cloudData['description'] as String?),
        canViewInventory: Value(cloudData['can_view_inventory'] as bool? ?? false),
        canManageInventory: Value(cloudData['can_add_inventory'] as bool? ?? false),
        canManageEmployees: Value(cloudData['can_manage_employees'] as bool? ?? false),
        canManageRoles: Value(cloudData['can_manage_roles'] as bool? ?? false),
        canViewReports: Value(cloudData['can_view_reports'] as bool? ?? false),
        canManageBranches: Value(cloudData['can_manage_branches'] as bool? ?? false),
        isSystemRole: Value(cloudData['is_system_role'] as bool? ?? false),
        isActive: Value(cloudData['is_active'] as bool? ?? true),
        needsSync: const Value(false),
      ),
    );
  }

  /// Sign in with email and password
  /// Uses Supabase Auth to establish a session with auth.uid() for RLS
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _logAuth('Attempting Supabase Auth signIn for: $email');
      // 1. Authenticate with Supabase Auth
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      _logAuth('Supabase response: user=${authResponse.user?.email}');

      if (authResponse.user == null) {
        _logAuth('No user returned from Supabase');
        return AuthResult.failure('Invalid credentials');
      }

      // 2. Load local user data
      _logAuth('Loading local user data...');
      await _loadCurrentUser(authResponse.user!);

      if (_currentUser == null) {
        _logAuth('No local user found or not commissary');
        // Sign out since user doesn't have local record or isn't commissary
        await _supabase.auth.signOut();
        return AuthResult.failure('Access denied. Commissary users only.');
      }

      _logAuth('Login successful via Supabase Auth');
      _updateLifecycleState(AuthLifecycleState.authenticated);
      return AuthResult.success(
        user: authResponse.user,
        localUser: _currentUser,
        message: 'Signed in successfully',
      );
    } on AuthException catch (e) {
      _logAuth('AuthException: ${e.message}');
      // If network fails, try offline login
      if (e.message.contains('network') || e.message.contains('connection')) {
        _logAuth('Network error, trying offline login...');
        return _offlineSignIn(email, password);
      }
      _logAuth('Trying offline login due to auth error...');
      return _offlineSignIn(email, password);
    } catch (e) {
      _logAuth('General exception: $e, trying offline login...');
      // Try offline login on any error
      return _offlineSignIn(email, password);
    }
  }

  /// Offline sign in using local database
  Future<AuthResult> _offlineSignIn(String email, String password) async {
    _logAuth('[OFFLINE] Attempting offline login for: $email');
    try {
      final user = await _db.usersDao.getUserByEmail(email);
      
      _logAuth('[OFFLINE] User found: ${user != null}, isActive: ${user?.isActive}');
      
      if (user == null || !user.isActive) {
        _logAuth('[OFFLINE] User not found or inactive');
        return AuthResult.failure('Invalid credentials');
      }
      
      // Verify password hash
      if (!_verifyPassword(password, user.passwordHash)) {
        _logAuth('[OFFLINE] Password verification failed');
        return AuthResult.failure('Invalid credentials');
      }

      _logAuth('[OFFLINE] Password verified successfully');

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
      _updateLifecycleState(AuthLifecycleState.authenticated);

      return AuthResult.success(
        localUser: _currentUser,
        message: 'Signed in offline',
      );
    } catch (e) {
      return AuthResult.failure('Offline sign in failed: $e');
    }
  }

  /// Sign out - this is the ONLY intentional path to clear persisted session
  Future<void> signOut() async {
    _logAuth('Signing out...');
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      _logAuth('Error signing out from Supabase: $e');
    }
    
    _currentUser = null;
    _authStateController?.add(null);
    _updateLifecycleState(AuthLifecycleState.unauthenticated);
    _logAuth('Sign out complete');
  }

  /// Restore session on app start (legacy - prefer using bootstrap() instead)
  /// This method is refresh-token aware and will attempt to refresh expired sessions
  @Deprecated('Use bootstrap() instead for proper lifecycle management')
  Future<AuthResult> restoreSession() async {
    try {
      _logAuth('restoreSession() called - attempting session restore');
      final session = _supabase.auth.currentSession;
      
      if (session == null) {
        _logAuth('restoreSession: No session found');
        return AuthResult.failure('No active session');
      }
      
      // Check if access token is expired
      final expiresAt = session.expiresAt;
      final isExpired = expiresAt != null && 
          DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000));
      
      if (isExpired) {
        _logAuth('restoreSession: Access token expired, attempting refresh...');
        
        // Try to refresh the session using refresh token
        if (session.refreshToken != null) {
          try {
            final refreshResponse = await _supabase.auth.refreshSession();
            
            if (refreshResponse.session != null) {
              _logAuth('restoreSession: Token refresh successful');
              await _loadCurrentUser(refreshResponse.session!.user);
              
              if (_currentUser != null) {
                return AuthResult.success(
                  user: refreshResponse.session!.user,
                  localUser: _currentUser,
                );
              }
            }
          } catch (e) {
            _logAuth('restoreSession: Token refresh failed: $e');
          }
        }
        
        return AuthResult.failure('Session expired and could not be refreshed');
      }
      
      // Access token is still valid
      await _loadCurrentUser(session.user);
      
      if (_currentUser != null) {
        return AuthResult.success(
          user: session.user,
          localUser: _currentUser,
        );
      }
      
      return AuthResult.failure('No active session');
    } catch (e) {
      _logAuth('restoreSession: Error: $e');
      return AuthResult.failure('Session restore failed: $e');
    }
  }

  /// Get access token for API calls
  String? get accessToken => _supabase.auth.currentSession?.accessToken;

  // ============================================================
  // ADMIN FUNCTIONS FOR MANAGING BRANCH USERS
  // ============================================================

  /// Create a Supabase Auth user for a branch admin
  /// Uses signUp() which works with anon key (no admin privileges needed)
  /// Note: Ensure "Confirm email" is disabled in Supabase Auth settings
  /// or the user will need to confirm their email before logging in
  Future<String?> createBranchAdminAuthUser({
    required String email,
    required String password,
    required String organizationCloudId,
  }) async {
    // Store current commissary admin session before creating new user
    final currentSession = _supabase.auth.currentSession;
    final savedUser = _currentUser;
    
    try {
      // Use signUp instead of admin.createUser (works with anon key)
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'organization_id': organizationCloudId,
          'role': 'branch_admin',
        },
      );

      if (response.user != null) {
        final newAuthUserId = response.user!.id;
        
        _logAuth('Created Supabase Auth user: $newAuthUserId');
        
        // Sign out the newly created user
        await _supabase.auth.signOut();
        
        // Restore the commissary admin's session if we had one
        if (currentSession != null) {
          try {
            await _supabase.auth.setSession(currentSession.refreshToken!);
            _currentUser = savedUser;
            _authStateController?.add(savedUser);
            _logAuth('Restored commissary admin session');
          } catch (e) {
            _logAuth('Could not restore session, admin will need to re-login: $e');
          }
        }
        
        return newAuthUserId;
      }
      return null;
    } catch (e) {
      // Restore session on error too
      if (currentSession != null) {
        try {
          await _supabase.auth.setSession(currentSession.refreshToken!);
          _currentUser = savedUser;
          _authStateController?.add(savedUser);
        } catch (_) {}
      }
      
      _logAuth('Failed to create auth user: $e');
      rethrow; // Rethrow to show error message to user
    }
  }

  /// Delete a Supabase Auth user
  Future<bool> deleteAuthUser(String authUserId) async {
    try {
      await _supabase.auth.admin.deleteUser(authUserId);
      _logAuth('Deleted auth user: $authUserId');
      return true;
    } catch (e) {
      _logAuth('Failed to delete auth user: $e');
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
      _logAuth('Failed to update password: $e');
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
    final parts = storedHash.split('\$');
    
    if (parts.length != 2) {
      _logAuth('[VERIFY] Invalid hash format (expected salt\$hash), got ${parts.length} parts');
      return false;
    }

    final salt = parts[0];
    final expectedFullHash = _hashPasswordWithSalt(password, salt);

    if (storedHash.length != expectedFullHash.length) {
      _logAuth('[VERIFY] Length mismatch');
      return false;
    }
    
    int result = 0;
    for (int i = 0; i < storedHash.length; i++) {
      result |= storedHash.codeUnitAt(i) ^ expectedFullHash.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Dispose resources
  void dispose() {
    _authStateController?.close();
    _lifecycleController.close();
  }
}
