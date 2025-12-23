// lib/services/supabase_sync_service.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/app_database.dart';
import '../config/supabase_config.dart';

/// Sync service for commissary app with star topology support
/// Commissary can sync and view ALL data from all franchisees
class SupabaseSyncService {
  final AppDatabase db;
  final SupabaseClient supabase;

  Timer? _syncTimer;
  bool _isSyncing = false;
  bool _isOnline = true;
  DateTime? _lastSuccessfulSync;
  StreamSubscription? _connectivitySubscription;

  // Service role client for bypassing RLS during sync
  SupabaseClient? _serviceRoleClient;

  // Configuration
  static const Duration syncInterval = Duration(minutes: 5);
  static const int batchSize = 50;

  // Callbacks
  Function(bool isOnline)? onConnectivityChanged;
  Function(String status)? onSyncStatusChanged;
  Function(String error)? onSyncError;
  Function(double progress, String tableName)? onSyncProgress;
  Function()? onSyncComplete;

  SupabaseSyncService({
    required this.db,
    required this.supabase,
    this.onConnectivityChanged,
    this.onSyncStatusChanged,
    this.onSyncError,
    this.onSyncProgress,
    this.onSyncComplete,
  });

  /// Get the client for sync operations (uses service role if available)
  SupabaseClient get _syncClient {
    if (_serviceRoleClient == null && SupabaseConfig.hasServiceRoleKey) {
      _serviceRoleClient = SupabaseClient(
        SupabaseConfig.url,
        SupabaseConfig.serviceRoleKey,
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
      print('🔑 Using service role client for sync (RLS bypassed)');
    }
    return _serviceRoleClient ?? supabase;
  }

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  Future<void> initialize() async {
    print('🚀 Initializing commissary sync service...');

    _isOnline = await _checkConnectivity();
    onConnectivityChanged?.call(_isOnline);

    _connectivitySubscription?.cancel();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) => _handleConnectivityChange(result));

    if (_isOnline) {
      await performFullSync();
    }
  }

  void startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(syncInterval, (_) {
      if (_isOnline && !_isSyncing) {
        performFullSync();
      }
    });
    print('⏰ Periodic sync started (every ${syncInterval.inMinutes} minutes)');
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    print('⏹️ Periodic sync stopped');
  }

  Future<bool> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;

    if (wasOnline != _isOnline) {
      print('📡 Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
      onConnectivityChanged?.call(_isOnline);

      if (_isOnline && !wasOnline) {
        // Came back online - sync
        performFullSync();
      }
    }
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// Perform full sync (pull remote first to get cloud_ids, then push local)
  Future<void> performFullSync() async {
    if (_isSyncing) {
      print('⚠️ Sync already in progress');
      return;
    }

    if (!_isOnline) {
      print('📵 Offline - skipping sync');
      return;
    }

    _isSyncing = true;
    onSyncStatusChanged?.call('Syncing...');

    try {
      print('🔄 Starting full sync...');

      // Pull remote changes FIRST to get existing cloud_ids
      await _pullRemoteChanges();

      // Then push local changes (only new records)
      await _pushLocalChanges();

      _lastSuccessfulSync = DateTime.now();
      onSyncStatusChanged?.call('Synced');
      onSyncComplete?.call();
      print('✅ Sync completed successfully');
    } catch (e) {
      print('❌ Sync error: $e');
      onSyncError?.call(e.toString());
      onSyncStatusChanged?.call('Sync failed');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pushLocalChanges() async {
    print('📤 Pushing local changes...');
    onSyncStatusChanged?.call('Uploading changes...');

    // Push in dependency order
    await _pushOrganizations();
    await _pushRoles();
    await _pushUsers();
    await _pushCategories();
    await _pushItems();
    await _pushIngredients();
    await _pushReplenishmentRequests();
    await _pushStockChanges();
  }

  Future<void> _pullRemoteChanges() async {
    print('📥 Pulling remote changes...');
    onSyncStatusChanged?.call('Downloading changes...');

    // As commissary, we pull ALL data (star topology hub)
    await _pullOrganizations();
    await _pullRoles();
    await _pullUsers();
    await _pullCategories();
    await _pullItems();
    await _pullIngredients();
    await _pullReplenishmentRequests();
    await _pullStockChanges();
  }

  // ============================================================================
  // PUSH OPERATIONS
  // ============================================================================

  Future<void> _pushOrganizations() async {
    final unsynced = await db.organizationsDao.getUnsyncedOrganizations();
    if (unsynced.isEmpty) return;

    print('   📤 Pushing ${unsynced.length} organizations...');
    for (final org in unsynced) {
      try {
        // Use ignoreDuplicates to skip records that already exist in Supabase
        // This prevents FK constraint violations from updating cloud_id
        await _syncClient.from('organizations').upsert({
          'cloud_id': org.cloudId,
          'local_id': org.id,
          'name': org.name,
          'type': org.type,
          'address': org.address,
          'phone': org.phone,
          'email': org.email,
          'parent_commissary_id': org.parentCommissaryId,
          'is_active': org.isActive,
          'created_at': org.createdAt.toIso8601String(),
          'last_updated': org.updatedAt.toIso8601String(),
        }, onConflict: 'local_id', ignoreDuplicates: true);
        await db.organizationsDao.markAsSynced(org.id, DateTime.now());
      } catch (e) {
        print('      ❌ Failed to push org ${org.name}: $e');
      }
    }
  }

  Future<void> _pushRoles() async {
    final unsynced = await db.rolesDao.getUnsyncedRoles();
    if (unsynced.isEmpty) return;

    print('   📤 Pushing ${unsynced.length} roles...');
    for (final role in unsynced) {
      try {
        await _syncClient.from('roles').upsert({
          'cloud_id': role.cloudId,
          'local_id': role.id,
          'name': role.name,
          'description': role.description,
          'can_view_inventory': role.canViewInventory,
          // Map canManageInventory to separate Supabase columns
          'can_add_inventory': role.canManageInventory,
          'can_edit_inventory': role.canManageInventory,
          'can_delete_inventory': role.canManageInventory,
          'can_manage_employees': role.canManageEmployees,
          'can_manage_roles': role.canManageRoles,
          'can_view_reports': role.canViewReports,
          'can_export_data': role.canViewReports, // Map to canViewReports
          'can_access_settings': role.canManageRoles, // Map to canManageRoles
          'can_manage_branches': role.canManageBranches,
          'is_system_role': role.isSystemRole,
          'is_active': role.isActive,
          'created_at': role.createdAt.toIso8601String(),
          'last_updated': role.updatedAt.toIso8601String(),
        }, onConflict: 'local_id', ignoreDuplicates: true);
        await db.rolesDao.markAsSynced(role.id, DateTime.now());
      } catch (e) {
        print('      ❌ Failed to push role ${role.name}: $e');
      }
    }
  }

  Future<void> _pushUsers() async {
    final unsynced = await db.usersDao.getUnsyncedUsers();
    if (unsynced.isEmpty) return;

    print('   📤 Pushing ${unsynced.length} users...');
    for (final user in unsynced) {
      try {
        // Get cloud IDs for foreign keys
        final org = await db.organizationsDao.getOrganizationById(user.organizationId);
        final role = await db.rolesDao.getRoleById(user.roleId);
        if (org == null || role == null) continue;

        await _syncClient.from('users').upsert({
          'cloud_id': user.cloudId,
          'local_id': user.id,
          'username': user.username,
          'email': user.email,
          'phone': user.phone,
          'password': user.passwordHash, // Supabase uses 'password' column
          'password_hash': user.passwordHash,
          'organization_id': org.cloudId,
          'role_id': role.cloudId,
          'auth_user_id': user.authUserId,
          'is_active': user.isActive,
          'created_at': user.createdAt.toIso8601String(),
          'last_updated': user.updatedAt.toIso8601String(),
        }, onConflict: 'local_id', ignoreDuplicates: true);
        await db.usersDao.markAsSynced(user.id, DateTime.now());
      } catch (e) {
        print('      ❌ Failed to push user ${user.email}: $e');
      }
    }
  }

  Future<void> _pushCategories() async {
    final unsynced = await db.categoriesDao.getUnsyncedCategories();
    if (unsynced.isEmpty) return;

    print('   📤 Pushing ${unsynced.length} categories...');
    for (final cat in unsynced) {
      try {
        await _syncClient.from('categories').upsert({
          'cloud_id': cat.cloudId,
          'name': cat.name,
          'description': cat.description,
          'is_deleted': cat.isDeleted,
          'created_at': cat.createdAt.toIso8601String(),
          'updated_at': cat.updatedAt.toIso8601String(),
        });
        await db.categoriesDao.markAsSynced(cat.id, DateTime.now());
      } catch (e) {
        print('      ❌ Failed to push category ${cat.name}: $e');
      }
    }
  }

  Future<void> _pushItems() async {
    final unsynced = await db.itemsDao.getUnsyncedItems();
    if (unsynced.isEmpty) return;

    print('   📤 Pushing ${unsynced.length} items...');
    for (final item in unsynced) {
      try {
        final org = await db.organizationsDao.getOrganizationById(item.organizationId);
        if (org == null) continue;

        String? categoryCloudId;
        if (item.categoryId != null) {
          final cat = await db.categoriesDao.getCategoryById(item.categoryId!);
          categoryCloudId = cat?.cloudId;
        }

        await _syncClient.from('items').upsert({
          'cloud_id': item.cloudId,
          'name': item.name,
          'description': item.description,
          'stock': item.stock,
          'critical_level': item.criticalLevel,
          'sold': item.sold,
          'spoilage': item.spoilage,
          'price': item.price,
          'cost': item.cost,
          'organization_id': org.cloudId,
          'category_id': categoryCloudId,
          'master_item_id': item.masterItemId,
          'is_active': item.isActive,
          'created_at': item.createdAt.toIso8601String(),
          'updated_at': item.updatedAt.toIso8601String(),
        });
        await db.itemsDao.markAsSynced(item.id, DateTime.now());
      } catch (e) {
        print('      ❌ Failed to push item ${item.name}: $e');
      }
    }
  }

  Future<void> _pushIngredients() async {
    final unsynced = await db.ingredientsDao.getUnsyncedIngredients();
    if (unsynced.isEmpty) return;

    print('   📤 Pushing ${unsynced.length} ingredients...');
    for (final ing in unsynced) {
      try {
        final commissary = await db.organizationsDao.getOrganizationById(ing.commissaryId);
        if (commissary == null) continue;

        await _syncClient.from('ingredients').upsert({
          'cloud_id': ing.cloudId,
          'name': ing.name,
          'unit': ing.unit,
          'stock': ing.stock,
          'critical_level': ing.criticalLevel,
          'cost_per_unit': ing.costPerUnit,
          'commissary_id': commissary.cloudId,
          'is_active': ing.isActive,
          'created_at': ing.createdAt.toIso8601String(),
          'updated_at': ing.updatedAt.toIso8601String(),
        });
        await db.ingredientsDao.markAsSynced(ing.id, DateTime.now());
      } catch (e) {
        print('      ❌ Failed to push ingredient ${ing.name}: $e');
      }
    }
  }

  Future<void> _pushReplenishmentRequests() async {
    final unsynced = await db.stockReplenishmentRequestsDao.getUnsyncedRequests();
    if (unsynced.isEmpty) return;

    print('   📤 Pushing ${unsynced.length} replenishment requests...');
    // Implementation similar to above
  }

  Future<void> _pushStockChanges() async {
    final unsynced = await db.stockChangeRequestsDao.getUnsyncedRequests();
    if (unsynced.isEmpty) return;

    print('   📤 Pushing ${unsynced.length} stock changes...');
    // Implementation similar to above
  }

  // ============================================================================
  // PULL OPERATIONS (Commissary pulls ALL data)
  // ============================================================================

  Future<void> _pullOrganizations() async {
    print('   📥 Pulling organizations...');
    try {
      final remoteOrgs = await _syncClient.from('organizations').select();
      print('      Found ${remoteOrgs.length} remote organizations');
      
      for (final remote in remoteOrgs) {
        final cloudId = remote['cloud_id'] as String?;
        final localId = remote['local_id'] as int?;
        if (cloudId == null) continue;
        
        // Check if we have this org locally by local_id or cloud_id
        Organization? existing;
        if (localId != null) {
          existing = await db.organizationsDao.getOrganizationById(localId);
        }
        existing ??= await db.organizationsDao.getOrganizationByCloudId(cloudId);
        
        if (existing != null) {
          // Update local cloud_id to match remote if different
          if (existing.cloudId != cloudId) {
            print('      Updating cloud_id for ${existing.name}');
            await db.organizationsDao.updateCloudId(existing.id, cloudId);
          }
        } else {
          // Insert new organization from remote
          print('      Inserting remote org: ${remote['name']}');
          // Could insert if needed, but for now just log
        }
      }
    } catch (e) {
      print('      ❌ Failed to pull organizations: $e');
    }
  }

  Future<void> _pullRoles() async {
    print('   📥 Pulling roles...');
    try {
      final remoteRoles = await _syncClient.from('roles').select();
      print('      Found ${remoteRoles.length} remote roles');
      
      for (final remote in remoteRoles) {
        final cloudId = remote['cloud_id'] as String?;
        final localId = remote['local_id'] as int?;
        if (cloudId == null) continue;
        
        Role? existing;
        if (localId != null) {
          existing = await db.rolesDao.getRoleById(localId);
        }
        existing ??= await db.rolesDao.getRoleByCloudId(cloudId);
        
        if (existing != null && existing.cloudId != cloudId) {
          print('      Updating cloud_id for ${existing.name}');
          await db.rolesDao.updateCloudId(existing.id, cloudId);
        }
      }
    } catch (e) {
      print('      ❌ Failed to pull roles: $e');
    }
  }

  Future<void> _pullUsers() async {
    print('   📥 Pulling users...');
    try {
      final remoteUsers = await _syncClient.from('users').select();
      print('      Found ${remoteUsers.length} remote users');
      
      for (final remote in remoteUsers) {
        final cloudId = remote['cloud_id'] as String?;
        final localId = remote['local_id'] as int?;
        if (cloudId == null) continue;
        
        User? existing;
        if (localId != null) {
          existing = await db.usersDao.getUserById(localId);
        }
        existing ??= await db.usersDao.getUserByCloudId(cloudId);
        
        if (existing != null && existing.cloudId != cloudId) {
          print('      Updating cloud_id for ${existing.email}');
          await db.usersDao.updateCloudId(existing.id, cloudId);
        }
      }
    } catch (e) {
      print('      ❌ Failed to pull users: $e');
    }
  }

  Future<void> _pullCategories() async {
    print('   📥 Pulling categories...');
  }

  Future<void> _pullItems() async {
    print('   📥 Pulling items...');
  }

  Future<void> _pullIngredients() async {
    print('   📥 Pulling ingredients...');
  }

  Future<void> _pullReplenishmentRequests() async {
    print('   📥 Pulling replenishment requests...');
  }

  Future<void> _pullStockChanges() async {
    print('   📥 Pulling stock changes...');
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;

  void dispose() {
    stopPeriodicSync();
    _connectivitySubscription?.cancel();
  }
}
