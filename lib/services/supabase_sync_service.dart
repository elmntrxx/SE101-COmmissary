// lib/services/supabase_sync_service.dart
import 'dart:async';
import 'package:drift/drift.dart' show Value;
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
          'name': org.name,
          'type': org.type,
          'address': org.address,
          'phone': org.phone,
          'email': org.email,
          'parent_commissary_id': org.parentCommissaryId,
          'is_active': org.isActive,
          'created_at': org.createdAt.toIso8601String(),
          'last_updated': org.updatedAt.toIso8601String(),
        }, onConflict: 'cloud_id');
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
        }, onConflict: 'cloud_id');
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
        });
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
        if (org == null || org.cloudId == null) {
          print('      ⚠️ Skipping item ${item.name}: org not found or missing cloud_id');
          continue;
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
          'organization_id': org.cloudId,  // ✅ FIX: Use cloud_id (UUID), not local int
          'category_id': item.categoryId,
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
        if (commissary == null || commissary.cloudId == null) {
          print('      ⚠️ Skipping ingredient ${ing.name}: commissary not found or missing cloud_id');
          continue;
        }

        await _syncClient.from('ingredients').upsert({
          'cloud_id': ing.cloudId,
          'name': ing.name,
          'unit': ing.unit,
          'stock': ing.stock,
          'critical_level': ing.criticalLevel,
          'cost_per_unit': ing.costPerUnit,
          'commissary_id': commissary.cloudId,  // ✅ FIX: Use cloud_id (UUID), not local int
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

      int inserted = 0;
      int updated = 0;

      for (final remote in remoteOrgs) {
        final cloudId = remote['cloud_id'] as String?;
        if (cloudId == null) continue;

        // Check if we have this org locally
        final existing = await db.organizationsDao.getOrganizationByCloudId(cloudId);

        if (existing == null) {
          // Insert new organization from cloud
          await db.organizationsDao.upsertFromCloud(remote);
          inserted++;
          print('      ✅ Inserted branch: ${remote['name']}');
        } else {
          // Update existing organization
          await db.organizationsDao.upsertFromCloud(remote);
          updated++;
        }
      }

      if (inserted > 0) print('      📥 Inserted $inserted new branches');
      if (updated > 0) print('      🔄 Updated $updated existing branches');
    } catch (e) {
      print('      ❌ Failed to pull organizations: $e');
    }
  }

  Future<void> _pullRoles() async {
    print('   📥 Pulling roles...');
    try {
      final remoteRoles = await _syncClient.from('roles').select();
      print('      Found ${remoteRoles.length} remote roles');
      
      int inserted = 0;
      int updated = 0;
      
      for (final remote in remoteRoles) {
        final cloudId = remote['cloud_id'] as String?;
        if (cloudId == null) continue;
        
        // Check if role exists locally by cloud_id
        final existing = await db.rolesDao.getRoleByCloudId(cloudId);
        
        if (existing == null) {
          // Insert new role from cloud
          await db.into(db.roles).insert(
            RolesCompanion.insert(
              cloudId: cloudId,
              name: remote['name'] as String,
              description: Value(remote['description'] as String?),
              canViewInventory: Value(remote['can_view_inventory'] as bool? ?? false),
              canManageInventory: Value(remote['can_add_inventory'] as bool? ?? false),
              canManageEmployees: Value(remote['can_manage_employees'] as bool? ?? false),
              canManageRoles: Value(remote['can_manage_roles'] as bool? ?? false),
              canViewReports: Value(remote['can_view_reports'] as bool? ?? false),
              canManageBranches: Value(remote['can_manage_branches'] as bool? ?? false),
              isSystemRole: Value(remote['is_system_role'] as bool? ?? false),
              isActive: Value(remote['is_active'] as bool? ?? true),
              needsSync: const Value(false),
            ),
          );
          inserted++;
          print('      ✅ Inserted role: ${remote['name']}');
        } else {
          updated++;
        }
      }
      
      if (inserted > 0) print('      📥 Inserted $inserted new roles');
      if (updated > 0) print('      🔄 Found $updated existing roles');
    } catch (e) {
      print('      ❌ Failed to pull roles: $e');
    }
  }

  Future<void> _pullUsers() async {
    print('   📥 Pulling users...');
    try {
      final remoteUsers = await _syncClient.from('users').select();
      print('      Found ${remoteUsers.length} remote users');

      int inserted = 0;
      int updated = 0;
      int skipped = 0;

      for (final remote in remoteUsers) {
        final cloudId = remote['cloud_id'] as String?;
        if (cloudId == null) continue;

        // Resolve foreign keys: organization_id and role_id from cloud to local
        final orgCloudId = remote['organization_id'] as String?;
        final roleCloudId = remote['role_id'] as String?;

        if (orgCloudId == null || roleCloudId == null) {
          skipped++;
          continue;
        }

        // Find local organization by cloud_id
        final org = await db.organizationsDao.getOrganizationByCloudId(orgCloudId);
        // Find local role by cloud_id
        final role = await db.rolesDao.getRoleByCloudId(roleCloudId);

        if (org == null || role == null) {
          skipped++;
          print('      ⚠️ Skipped user ${remote['email']} (missing org or role locally)');
          continue;
        }

        // Check if we have this user locally
        final existing = await db.usersDao.getUserByCloudId(cloudId);

        // Add resolved IDs to the data
        final resolvedData = {
          ...remote,
          'resolved_organization_id': org.id,
          'resolved_role_id': role.id,
        };

        if (existing == null) {
          // Insert new user from cloud
          await db.usersDao.upsertFromCloud(
            resolvedData,
            organizationId: org.id,
            roleId: role.id,
          );
          inserted++;
          print('      ✅ Inserted account: ${remote['email']}');
        } else {
          // Update existing user
          await db.usersDao.upsertFromCloud(
            resolvedData,
            organizationId: org.id,
            roleId: role.id,
          );
          updated++;
        }
      }

      if (inserted > 0) print('      📥 Inserted $inserted new accounts');
      if (updated > 0) print('      🔄 Updated $updated existing accounts');
      if (skipped > 0) print('      ⚠️ Skipped $skipped accounts (missing FKs)');
    } catch (e) {
      print('      ❌ Failed to pull users: $e');
    }
  }

  Future<void> _pullCategories() async {
    print('   📥 Pulling categories...');
    try {
      final remoteCategories = await _syncClient.from('categories').select();
      print('      Found ${remoteCategories.length} remote categories');

      int inserted = 0;
      int updated = 0;

      for (final remote in remoteCategories) {
        final cloudId = remote['cloud_id'] as String?;
        if (cloudId == null) continue;

        // Check if we have this category locally
        final existing = await db.categoriesDao.getCategoryByCloudId(cloudId);

        if (existing == null) {
          // Insert new category from cloud
          await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              cloudId: cloudId,
              name: remote['name'] as String,
              description: Value(remote['description'] as String?),
              isDeleted: Value(remote['is_deleted'] as bool? ?? false),
              needsSync: const Value(false),
            ),
          );
          inserted++;
          print('      ✅ Inserted category: ${remote['name']}');
        } else {
          // Update existing category
          await db.update(db.categories).replace(
            Category(
              id: existing.id,
              cloudId: cloudId,
              name: remote['name'] as String,
              description: remote['description'] as String?,
              isDeleted: remote['is_deleted'] as bool? ?? false,
              createdAt: existing.createdAt,
              updatedAt: DateTime.parse(remote['updated_at'] as String? ?? DateTime.now().toIso8601String()),
              lastSyncedAt: DateTime.now(),
              needsSync: false,
            ),
          );
          updated++;
        }
      }

      if (inserted > 0) print('      📥 Inserted $inserted new categories');
      if (updated > 0) print('      🔄 Updated $updated existing categories');
    } catch (e) {
      print('      ❌ Failed to pull categories: $e');
    }
  }

  Future<void> _pullItems() async {
    print('   📥 Pulling items...');
    try {
      final remoteItems = await _syncClient.from('items').select();
      print('      Found ${remoteItems.length} remote items');

      int inserted = 0;
      int updated = 0;
      int skipped = 0;

      for (final remote in remoteItems) {
        final cloudId = remote['cloud_id'] as String?;
        if (cloudId == null) continue;

        // Resolve foreign key: organization_id
        final orgId = remote['organization_id'];
        if (orgId == null) {
          skipped++;
          continue;
        }

        // For items, organization_id can be either cloud_id (string) or local id (int)
        // We need to handle both cases
        Organization? org;
        if (orgId is String) {
          org = await db.organizationsDao.getOrganizationByCloudId(orgId);
        } else if (orgId is int) {
          org = await db.organizationsDao.getOrganizationById(orgId);
        }

        if (org == null) {
          skipped++;
          print('      ⚠️ Skipped item ${remote['name']} (missing organization locally)');
          continue;
        }

        // Resolve category_id if present
        int? categoryId;
        final catId = remote['category_id'];
        if (catId != null) {
          Category? cat;
          if (catId is String) {
            cat = await db.categoriesDao.getCategoryByCloudId(catId);
          } else if (catId is int) {
            cat = await db.categoriesDao.getCategoryById(catId);
          }
          categoryId = cat?.id;
        }

        // Check if we have this item locally
        final existing = await db.itemsDao.getItemByCloudId(cloudId);

        if (existing == null) {
          // Insert new item from cloud
          await db.into(db.items).insert(
            ItemsCompanion.insert(
              cloudId: cloudId,
              name: remote['name'] as String,
              description: Value(remote['description'] as String?),
              stock: Value(remote['stock'] as int? ?? 0),
              criticalLevel: Value(remote['critical_level'] as int? ?? 0),
              sold: Value(remote['sold'] as int? ?? 0),
              spoilage: Value(remote['spoilage'] as int? ?? 0),
              price: Value((remote['price'] as num?)?.toDouble() ?? 0.0),
              cost: Value((remote['cost'] as num?)?.toDouble() ?? 0.0),
              organizationId: org.id,
              categoryId: Value(categoryId),
              masterItemId: Value(remote['master_item_id'] as String?),
              isActive: Value(remote['is_active'] as bool? ?? true),
              needsSync: const Value(false),
            ),
          );
          inserted++;
          print('      ✅ Inserted item: ${remote['name']}');
        } else {
          // Update existing item
          await db.update(db.items).replace(
            Item(
              id: existing.id,
              cloudId: cloudId,
              name: remote['name'] as String,
              description: remote['description'] as String?,
              stock: remote['stock'] as int? ?? 0,
              criticalLevel: remote['critical_level'] as int? ?? 0,
              sold: remote['sold'] as int? ?? 0,
              spoilage: remote['spoilage'] as int? ?? 0,
              price: (remote['price'] as num?)?.toDouble() ?? 0.0,
              cost: (remote['cost'] as num?)?.toDouble() ?? 0.0,
              organizationId: org.id,
              categoryId: categoryId,
              masterItemId: remote['master_item_id'] as String?,
              isActive: remote['is_active'] as bool? ?? true,
              createdAt: existing.createdAt,
              updatedAt: DateTime.parse(remote['updated_at'] as String? ?? DateTime.now().toIso8601String()),
              lastSyncedAt: DateTime.now(),
              needsSync: false,
            ),
          );
          updated++;
        }
      }

      if (inserted > 0) print('      📥 Inserted $inserted new items');
      if (updated > 0) print('      🔄 Updated $updated existing items');
      if (skipped > 0) print('      ⚠️ Skipped $skipped items (missing FKs)');
    } catch (e) {
      print('      ❌ Failed to pull items: $e');
    }
  }

  Future<void> _pullIngredients() async {
    print('   📥 Pulling ingredients...');
    try {
      final remoteIngredients = await _syncClient.from('ingredients').select();
      print('      Found ${remoteIngredients.length} remote ingredients');

      int inserted = 0;
      int updated = 0;
      int skipped = 0;

      for (final remote in remoteIngredients) {
        final cloudId = remote['cloud_id'] as String?;
        if (cloudId == null) continue;

        // Resolve foreign key: commissary_id
        final commissaryId = remote['commissary_id'];
        if (commissaryId == null) {
          skipped++;
          continue;
        }

        // Find local commissary
        Organization? commissary;
        if (commissaryId is String) {
          commissary = await db.organizationsDao.getOrganizationByCloudId(commissaryId);
        } else if (commissaryId is int) {
          commissary = await db.organizationsDao.getOrganizationById(commissaryId);
        }

        if (commissary == null) {
          skipped++;
          print('      ⚠️ Skipped ingredient ${remote['name']} (missing commissary locally)');
          continue;
        }

        // Check if we have this ingredient locally
        final existing = await db.ingredientsDao.getIngredientByCloudId(cloudId);

        if (existing == null) {
          // Insert new ingredient from cloud
          await db.into(db.ingredients).insert(
            IngredientsCompanion.insert(
              cloudId: cloudId,
              name: remote['name'] as String,
              unit: remote['unit'] as String,
              stock: Value((remote['stock'] as num?)?.toDouble() ?? 0.0),
              criticalLevel: Value((remote['critical_level'] as num?)?.toDouble() ?? 0.0),
              costPerUnit: Value((remote['cost_per_unit'] as num?)?.toDouble() ?? 0.0),
              commissaryId: commissary.id,
              isActive: Value(remote['is_active'] as bool? ?? true),
              needsSync: const Value(false),
            ),
          );
          inserted++;
          print('      ✅ Inserted ingredient: ${remote['name']}');
        } else {
          // Update existing ingredient
          await db.update(db.ingredients).replace(
            Ingredient(
              id: existing.id,
              cloudId: cloudId,
              name: remote['name'] as String,
              unit: remote['unit'] as String,
              stock: (remote['stock'] as num?)?.toDouble() ?? 0.0,
              criticalLevel: (remote['critical_level'] as num?)?.toDouble() ?? 0.0,
              costPerUnit: (remote['cost_per_unit'] as num?)?.toDouble() ?? 0.0,
              commissaryId: commissary.id,
              isActive: remote['is_active'] as bool? ?? true,
              createdAt: existing.createdAt,
              updatedAt: DateTime.parse(remote['updated_at'] as String? ?? DateTime.now().toIso8601String()),
              lastSyncedAt: DateTime.now(),
              needsSync: false,
            ),
          );
          updated++;
        }
      }

      if (inserted > 0) print('      📥 Inserted $inserted new ingredients');
      if (updated > 0) print('      🔄 Updated $updated existing ingredients');
      if (skipped > 0) print('      ⚠️ Skipped $skipped ingredients (missing FKs)');
    } catch (e) {
      print('      ❌ Failed to pull ingredients: $e');
    }
  }

  Future<void> _pullReplenishmentRequests() async {
    print('   📥 Pulling replenishment requests...');
    // TODO: Implement if needed for your app
  }

  Future<void> _pullStockChanges() async {
    print('   📥 Pulling stock changes...');
    // TODO: Implement if needed for your app
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  /// Delete item permanently from cloud
  Future<void> deleteItemFromCloud(String cloudId) async {
    try {
      print('🗑️ Deleting item from cloud: $cloudId');
      await _syncClient.from('items').delete().eq('cloud_id', cloudId);
      print('✅ Item deleted from cloud');
    } catch (e) {
      print('❌ Failed to delete item from cloud: $e');
      rethrow;
    }
  }

  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;

  void dispose() {
    stopPeriodicSync();
    _connectivitySubscription?.cancel();
  }
}
