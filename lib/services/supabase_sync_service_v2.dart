// lib/services/supabase_sync_service_v2.dart
//
// Refactored sync service using SyncEngine pattern
// - Uses authenticated client (no service role key)
// - Tier-based parallel sync with FK resolution caching
// - Declarative table descriptors
// - Conflict detection with status-aware resolution

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../database/app_database.dart';
import '../utils/app_logger.dart';
import 'sync/sync.dart';

/// Sync service for commissary app using SyncEngine pattern
/// 
/// Key features:
/// - Uses authenticated Supabase client (no service role key)
/// - RLS policies control access on the server side
/// - Tier-based parallel sync for efficiency
/// - O(1) FK resolution via UUID caching
/// - Status-aware conflict resolution for request tables
class SupabaseSyncServiceV2 {
  final AppDatabase db;
  final SupabaseClient supabase;
  
  late final SyncEngine _engine;

  Timer? _syncTimer;
  bool _isSyncing = false;
  bool _isOnline = true;
  StreamSubscription? _connectivitySubscription;

  // Configuration
  static const Duration syncInterval = Duration(minutes: 5);

  // Callbacks
  Function(bool isOnline)? onConnectivityChanged;
  Function(String status)? onSyncStatusChanged;
  Function(String error)? onSyncError;
  Function(double progress, String tableName)? onSyncProgress;
  Function()? onSyncComplete;

  SupabaseSyncServiceV2({
    required this.db,
    required this.supabase,
    this.onConnectivityChanged,
    this.onSyncStatusChanged,
    this.onSyncError,
    this.onSyncProgress,
    this.onSyncComplete,
  }) {
    _engine = SyncEngine(
      db: db,
      supabase: supabase,
      onTableError: (table, error) {
        AppLogger.sync('⚠️ $table: $error');
        onSyncError?.call('$table: $error');
      },
      onTableSynced: (table, pushed, pulled) {
        AppLogger.sync('✅ $table: ↑$pushed ↓$pulled');
      },
      onConflictDetected: (table, message) {
        AppLogger.sync('⚠️ Conflict in $table: $message');
      },
    );
  }

  /// Check if sync is allowed (user must be authenticated)
  bool get canSync => supabase.auth.currentUser != null;

  /// Check if currently online
  bool get isOnline => _isOnline;

  /// Check if sync is in progress
  bool get isSyncing => _isSyncing;

  /// Get last successful sync time
  DateTime? get lastSuccessfulSync => _engine.lastSuccessfulSync;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  Future<void> initialize() async {
    AppLogger.sync('🚀 Initializing commissary sync service v2...');

    _isOnline = await _checkConnectivity();
    onConnectivityChanged?.call(_isOnline);

    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((result) => _handleConnectivityChange(result));

    // Initialize UUID caches
    await _engine.initializeCaches([
      'organizations',
      'roles',
      'categories',
      'users',
      'items',
      'ingredients',
      'recipe_ingredients',
      'stock_replenishment_requests',
      'stock_change_requests',
      'branch_item_stock',
    ]);

    if (_isOnline && canSync) {
      await performFullSync();
    }
  }

  /// Set organization context (call after login)
  void setOrganizationContext({
    required String organizationType,
    required int organizationId,
    required String organizationCloudId,
  }) {
    _engine.setOrganizationContext(
      organizationType: organizationType,
      organizationId: organizationId,
      organizationCloudId: organizationCloudId,
    );
  }

  void startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(syncInterval, (_) {
      if (_isOnline && !_isSyncing && canSync) {
        performFullSync();
      }
    });
    AppLogger.sync('⏰ Periodic sync started (every ${syncInterval.inMinutes} minutes)');
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    AppLogger.sync('⏹️ Periodic sync stopped');
  }

  Future<bool> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;

    if (wasOnline != _isOnline) {
      AppLogger.sync('📡 Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
      onConnectivityChanged?.call(_isOnline);

      if (_isOnline && !wasOnline && canSync) {
        performFullSync();
      }
    }
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// Perform full sync using tier-based parallel execution
  Future<void> performFullSync() async {
    if (_isSyncing) {
      AppLogger.sync('⚠️ Sync already in progress');
      return;
    }

    if (!_isOnline) {
      AppLogger.sync('📵 Offline - skipping sync');
      return;
    }

    if (!canSync) {
      AppLogger.sync('🔒 Not authenticated - sync skipped');
      onSyncStatusChanged?.call('Not authenticated');
      return;
    }

    _isSyncing = true;
    onSyncStatusChanged?.call('Syncing...');

    try {
      AppLogger.sync('🔄 Starting full sync (commissary mode)...');

      // Build tier map with push and pull operations
      final tierMap = _buildTierMap();
      
      // Execute sync
      final result = await _engine.syncAllTiers(tierMap);

      if (result.success) {
        onSyncStatusChanged?.call('Synced');
        onSyncComplete?.call();
        AppLogger.sync('✅ Sync completed: ${result.toString()}');
      } else {
        onSyncStatusChanged?.call('Sync completed with errors');
        AppLogger.sync('⚠️ Sync completed with errors: ${result.toString()}');
      }
    } catch (e) {
      AppLogger.sync('❌ Sync error: $e');
      onSyncError?.call(e.toString());
      onSyncStatusChanged?.call('Sync failed');
    } finally {
      _isSyncing = false;
    }
  }

  /// Build tier map for parallel sync execution
  Map<int, List<Future<TableSyncResult> Function()>> _buildTierMap() {
    return {
      // Tier 1: No dependencies - sync in parallel
      1: [
        () => _syncOrganizations(),
        () => _syncRoles(),
        () => _syncCategories(),
      ],
      // Tier 2: Depends on Tier 1
      2: [
        () => _syncUsers(),
        () => _syncItems(),
        () => _syncIngredients(),
      ],
      // Tier 3: Depends on Tier 2
      3: [
        () => _syncRecipeIngredients(),
        () => _syncBranchItemStock(),
      ],
      // Tier 4: Depends on Tier 2/3
      4: [
        () => _syncReplenishmentRequests(),
        () => _syncChangeRequests(),
      ],
    };
  }

  // ============================================================================
  // TABLE SYNC IMPLEMENTATIONS
  // ============================================================================

  Future<TableSyncResult> _syncOrganizations() async {
    // Push first
    final pushResult = await _engine.pushTable(
      descriptor: organizationsDescriptor,
      getUnsyncedRecords: ({int limit = 50, int offset = 0}) async {
        final all = await db.organizationsDao.getUnsyncedOrganizations();
        return all.skip(offset).take(limit).toList();
      },
      markAsSynced: (ids, {Map<int, String>? cloudIds}) async {
        for (final id in ids) {
          await db.organizationsDao.markAsSynced(id, DateTime.now());
          if (cloudIds != null && cloudIds.containsKey(id)) {
            await db.organizationsDao.updateCloudId(id, cloudIds[id]!);
          }
        }
      },
      toMap: (org) => {
        'name': org.name,
        'type': org.type,
        'address': org.address,
        'phone': org.phone,
        'email': org.email,
        'parentCommissaryId': null, // Self-reference handled separately
        'isActive': org.isActive,
        'createdAt': org.createdAt,
        'updatedAt': org.updatedAt,
      },
      getId: (org) => org.id,
      getCloudId: (org) => org.cloudId,
      shouldSkip: (org) => !org.isActive,
    );

    // Then pull
    final pullResult = await _engine.pullTable(
      descriptor: organizationsDescriptor,
      upsertBatchFromCloud: (records) => db.organizationsDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) => db.organizationsDao.getOrganizationByCloudId(cloudId),
      getLastUpdated: (org) => org.updatedAt,
      getOrganizationId: (org) => org.id,
    );

    return TableSyncResult(
      tableName: 'organizations',
      pushedCount: pushResult.pushedCount,
      pulledCount: pullResult.pulledCount,
      conflictCount: pullResult.conflictCount,
      success: pushResult.success && pullResult.success,
    );
  }

  Future<TableSyncResult> _syncRoles() async {
    final pushResult = await _engine.pushTable(
      descriptor: rolesDescriptor,
      getUnsyncedRecords: ({int limit = 50, int offset = 0}) async {
        final all = await db.rolesDao.getUnsyncedRoles();
        return all.skip(offset).take(limit).toList();
      },
      markAsSynced: (ids, {Map<int, String>? cloudIds}) async {
        for (final id in ids) {
          await db.rolesDao.markAsSynced(id, DateTime.now());
        }
      },
      toMap: (role) => {
        'name': role.name,
        'description': role.description,
        'canManageInventory': role.canManageInventory,
        'canManageUsers': role.canManageEmployees,
        'canViewReports': role.canViewReports,
        'canManageBranches': role.canManageBranches,
        'isSystemRole': role.isSystemRole,
        'isActive': role.isActive,
        'createdAt': role.createdAt,
        'updatedAt': role.updatedAt,
      },
      getId: (role) => role.id,
      getCloudId: (role) => role.cloudId,
      shouldSkip: (role) => !role.isActive,
    );

    final pullResult = await _engine.pullTable(
      descriptor: rolesDescriptor,
      upsertBatchFromCloud: (records) => db.rolesDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) => db.rolesDao.getRoleByCloudId(cloudId),
      getLastUpdated: (role) => role.updatedAt,
      getOrganizationId: (role) => null,
    );

    return TableSyncResult(
      tableName: 'roles',
      pushedCount: pushResult.pushedCount,
      pulledCount: pullResult.pulledCount,
      conflictCount: pullResult.conflictCount,
      success: pushResult.success && pullResult.success,
    );
  }

  Future<TableSyncResult> _syncCategories() async {
    final pushResult = await _engine.pushTable(
      descriptor: categoriesDescriptor,
      getUnsyncedRecords: ({int limit = 50, int offset = 0}) async {
        final all = await db.categoriesDao.getUnsyncedCategories();
        return all.skip(offset).take(limit).toList();
      },
      markAsSynced: (ids, {Map<int, String>? cloudIds}) async {
        for (final id in ids) {
          await db.categoriesDao.markAsSynced(id, DateTime.now());
        }
      },
      toMap: (cat) => {
        'name': cat.name,
        'description': cat.description,
        'isDeleted': cat.isDeleted,
        'createdAt': cat.createdAt,
        'updatedAt': cat.updatedAt,
      },
      getId: (cat) => cat.id,
      getCloudId: (cat) => cat.cloudId,
      shouldSkip: (cat) => cat.isDeleted,
    );

    final pullResult = await _engine.pullTable(
      descriptor: categoriesDescriptor,
      upsertBatchFromCloud: (records) => db.categoriesDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) => db.categoriesDao.getCategoryByCloudId(cloudId),
      getLastUpdated: (cat) => cat.updatedAt,
      getOrganizationId: (cat) => null,
    );

    return TableSyncResult(
      tableName: 'categories',
      pushedCount: pushResult.pushedCount,
      pulledCount: pullResult.pulledCount,
      conflictCount: pullResult.conflictCount,
      success: pushResult.success && pullResult.success,
    );
  }

  Future<TableSyncResult> _syncUsers() async {
    final pushResult = await _engine.pushTable(
      descriptor: usersDescriptor,
      getUnsyncedRecords: ({int limit = 50, int offset = 0}) async {
        final all = await db.usersDao.getUnsyncedUsers();
        return all.skip(offset).take(limit).toList();
      },
      markAsSynced: (ids, {Map<int, String>? cloudIds}) async {
        for (final id in ids) {
          await db.usersDao.markAsSynced(id, DateTime.now());
        }
      },
      toMap: (user) => {
        'email': user.email,
        'name': user.username,
        'authUserId': user.authUserId,
        'passwordHash': user.passwordHash,
        'organizationId': user.organizationId,
        'roleId': user.roleId,
        'isActive': user.isActive,
        'createdAt': user.createdAt,
        'updatedAt': user.updatedAt,
      },
      getId: (user) => user.id,
      getCloudId: (user) => user.cloudId,
      shouldSkip: (user) => !user.isActive,
    );

    final pullResult = await _engine.pullTable(
      descriptor: usersDescriptor,
      upsertBatchFromCloud: (records) => db.usersDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) => db.usersDao.getUserByCloudId(cloudId),
      getLastUpdated: (user) => user.updatedAt,
      getOrganizationId: (user) => user.organizationId,
    );

    return TableSyncResult(
      tableName: 'users',
      pushedCount: pushResult.pushedCount,
      pulledCount: pullResult.pulledCount,
      conflictCount: pullResult.conflictCount,
      success: pushResult.success && pullResult.success,
    );
  }

  Future<TableSyncResult> _syncItems() async {
    final pushResult = await _engine.pushTable(
      descriptor: itemsDescriptor,
      getUnsyncedRecords: ({int limit = 50, int offset = 0}) async {
        final all = await db.itemsDao.getUnsyncedItems();
        return all.skip(offset).take(limit).toList();
      },
      markAsSynced: (ids, {Map<int, String>? cloudIds}) async {
        for (final id in ids) {
          await db.itemsDao.markAsSynced(id, DateTime.now());
        }
      },
      toMap: (item) => {
        'name': item.name,
        'description': item.description,
        'stock': item.stock,
        'criticalLevel': item.criticalLevel,
        'sold': item.sold,
        'spoilage': item.spoilage,
        'price': item.price,
        'cost': item.cost,
        'organizationId': item.organizationId,
        'categoryId': item.categoryId,
        'masterItemId': item.masterItemId,
        'isActive': item.isActive,
        'isDeleted': false,
        'createdAt': item.createdAt,
        'updatedAt': item.updatedAt,
      },
      getId: (item) => item.id,
      getCloudId: (item) => item.cloudId,
      shouldSkip: (item) => !item.isActive,
    );

    final pullResult = await _engine.pullTable(
      descriptor: itemsDescriptor,
      upsertBatchFromCloud: (records) => db.itemsDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) => db.itemsDao.getItemByCloudId(cloudId),
      getLastUpdated: (item) => item.updatedAt,
      getOrganizationId: (item) => item.organizationId,
    );

    return TableSyncResult(
      tableName: 'items',
      pushedCount: pushResult.pushedCount,
      pulledCount: pullResult.pulledCount,
      conflictCount: pullResult.conflictCount,
      success: pushResult.success && pullResult.success,
    );
  }

  Future<TableSyncResult> _syncIngredients() async {
    final pushResult = await _engine.pushTable(
      descriptor: ingredientsDescriptor,
      getUnsyncedRecords: ({int limit = 50, int offset = 0}) async {
        final all = await db.ingredientsDao.getUnsyncedIngredients();
        return all.skip(offset).take(limit).toList();
      },
      markAsSynced: (ids, {Map<int, String>? cloudIds}) async {
        for (final id in ids) {
          await db.ingredientsDao.markAsSynced(id, DateTime.now());
        }
      },
      toMap: (ing) => {
        'name': ing.name,
        'unit': ing.unit,
        'stock': ing.stock,
        'criticalLevel': ing.criticalLevel,
        'costPerUnit': ing.costPerUnit,
        'commissaryId': ing.commissaryId,
        'isActive': ing.isActive,
        'createdAt': ing.createdAt,
        'updatedAt': ing.updatedAt,
      },
      getId: (ing) => ing.id,
      getCloudId: (ing) => ing.cloudId,
      shouldSkip: (ing) => !ing.isActive,
    );

    final pullResult = await _engine.pullTable(
      descriptor: ingredientsDescriptor,
      upsertBatchFromCloud: (records) => db.ingredientsDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) => db.ingredientsDao.getIngredientByCloudId(cloudId),
      getLastUpdated: (ing) => ing.updatedAt,
      getOrganizationId: (ing) => ing.commissaryId,
    );

    return TableSyncResult(
      tableName: 'ingredients',
      pushedCount: pushResult.pushedCount,
      pulledCount: pullResult.pulledCount,
      conflictCount: pullResult.conflictCount,
      success: pushResult.success && pullResult.success,
    );
  }

  Future<TableSyncResult> _syncRecipeIngredients() async {
    final pushResult = await _engine.pushTable(
      descriptor: recipeIngredientsDescriptor,
      getUnsyncedRecords: ({int limit = 50, int offset = 0}) async {
        final all = await db.recipeIngredientsDao.getUnsyncedRecipeIngredients();
        return all.skip(offset).take(limit).toList();
      },
      markAsSynced: (ids, {Map<int, String>? cloudIds}) async {
        for (final id in ids) {
          await db.recipeIngredientsDao.markAsSynced(id, DateTime.now());
        }
      },
      toMap: (ri) => {
        'quantity': ri.quantity,
        'unit': ri.unit,
        'itemId': ri.itemId,
        'ingredientId': ri.ingredientId,
        'createdAt': ri.createdAt,
        'updatedAt': ri.updatedAt,
      },
      getId: (ri) => ri.id,
      getCloudId: (ri) => ri.cloudId,
      shouldSkip: (ri) => false,
    );

    final pullResult = await _engine.pullTable(
      descriptor: recipeIngredientsDescriptor,
      upsertBatchFromCloud: (records) => db.recipeIngredientsDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) => db.recipeIngredientsDao.getByCloudId(cloudId),
      getLastUpdated: (ri) => ri.updatedAt,
      getOrganizationId: (ri) => null,
    );

    return TableSyncResult(
      tableName: 'recipe_ingredients',
      pushedCount: pushResult.pushedCount,
      pulledCount: pullResult.pulledCount,
      conflictCount: pullResult.conflictCount,
      success: pushResult.success && pullResult.success,
    );
  }

  Future<TableSyncResult> _syncBranchItemStock() async {
    final pushResult = await _engine.pushTable(
      descriptor: branchItemStockDescriptor,
      getUnsyncedRecords: ({int limit = 50, int offset = 0}) async {
        final all = await db.branchItemStockDao.getUnsyncedStock();
        return all.skip(offset).take(limit).toList();
      },
      markAsSynced: (ids, {Map<int, String>? cloudIds}) async {
        await db.branchItemStockDao.markAsSynced(ids, cloudIds: cloudIds);
      },
      toMap: (stock) => {
        'stock': stock.stock,
        'sold': stock.sold,
        'spoilage': stock.spoilage,
        'price': stock.price,
        'costPrice': stock.costPrice,
        'minimumStock': stock.minimumStock,
        'organizationId': stock.organizationId,
        'itemId': stock.itemId,
        'lastReceivedAt': stock.lastReceivedAt,
        'lastReceivedQuantity': stock.lastReceivedQuantity,
        'lastUpdated': stock.lastUpdated,
        'isDeleted': stock.isDeleted,
      },
      getId: (stock) => stock.id,
      getCloudId: (stock) => stock.cloudId,
      shouldSkip: (stock) => stock.isDeleted,
    );

    final pullResult = await _engine.pullTable(
      descriptor: branchItemStockDescriptor,
      upsertBatchFromCloud: (records) => db.branchItemStockDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) => db.branchItemStockDao.getByCloudId(cloudId),
      getLastUpdated: (stock) => stock.lastUpdated,
      getOrganizationId: (stock) => stock.organizationId,
    );

    return TableSyncResult(
      tableName: 'branch_item_stock',
      pushedCount: pushResult.pushedCount,
      pulledCount: pullResult.pulledCount,
      conflictCount: pullResult.conflictCount,
      success: pushResult.success && pullResult.success,
    );
  }

  Future<TableSyncResult> _syncReplenishmentRequests() async {
    final pushResult = await _engine.pushTable(
      descriptor: replenishmentRequestsDescriptor,
      getUnsyncedRecords: ({int limit = 50, int offset = 0}) async {
        final all = await db.stockReplenishmentRequestsDao.getUnsyncedRequests();
        return all.skip(offset).take(limit).toList();
      },
      markAsSynced: (ids, {Map<int, String>? cloudIds}) async {
        for (final id in ids) {
          final cloudId = cloudIds?[id];
          await db.stockReplenishmentRequestsDao.markAsSynced(id, cloudId);
        }
      },
      toMap: (req) => {
        'quantityRequested': req.quantityRequested,
        'status': req.status,
        'requestedAt': req.requestedAt,
        'reviewedAt': req.reviewedAt,
        'deliveryDate': req.deliveryDate,
        'franchiseeNotes': req.franchiseeNotes,
        'commissaryNotes': req.commissaryNotes,
        'franchiseeId': req.franchiseeId,
        'commissaryId': req.commissaryId,
        'itemId': req.itemId,
        'requestedBy': req.requestedBy,
        'reviewedBy': req.reviewedBy,
        'isDeleted': req.isDeleted,
        'createdAt': req.createdAt,
        'lastUpdated': req.lastUpdated,
      },
      getId: (req) => req.id,
      getCloudId: (req) => req.cloudId,
      shouldSkip: (req) => req.isDeleted,
    );

    final pullResult = await _engine.pullTable(
      descriptor: replenishmentRequestsDescriptor,
      upsertBatchFromCloud: (records) => db.stockReplenishmentRequestsDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) => db.stockReplenishmentRequestsDao.getRequestByCloudId(cloudId),
      getLastUpdated: (req) => req.lastUpdated,
      getOrganizationId: (req) => req.commissaryId,
    );

    return TableSyncResult(
      tableName: 'stock_replenishment_requests',
      pushedCount: pushResult.pushedCount,
      pulledCount: pullResult.pulledCount,
      conflictCount: pullResult.conflictCount,
      success: pushResult.success && pullResult.success,
    );
  }

  Future<TableSyncResult> _syncChangeRequests() async {
    final pushResult = await _engine.pushTable(
      descriptor: changeRequestsDescriptor,
      getUnsyncedRecords: ({int limit = 50, int offset = 0}) async {
        final all = await db.stockChangeRequestsDao.getUnsyncedRequests();
        return all.skip(offset).take(limit).toList();
      },
      markAsSynced: (ids, {Map<int, String>? cloudIds}) async {
        for (final id in ids) {
          await db.stockChangeRequestsDao.markAsSynced(id, DateTime.now());
        }
      },
      toMap: (req) => {
        'changeType': req.changeType,
        'previousQuantity': req.previousQuantity,
        'newQuantity': req.newQuantity,
        'reason': req.reason,
        'status': req.status,
        'notes': req.notes,
        'franchiseeId': req.franchiseeId,
        'itemId': req.itemId,
        'requestedBy': req.requestedBy,
        'reviewedBy': req.reviewedBy,
        'requestedAt': req.requestedAt,
        'reviewedAt': req.reviewedAt,
        'isDeleted': req.isDeleted,
        'createdAt': req.createdAt,
        'lastUpdated': req.lastUpdated,
      },
      getId: (req) => req.id,
      getCloudId: (req) => req.cloudId,
      shouldSkip: (req) => req.isDeleted,
    );

    final pullResult = await _engine.pullTable(
      descriptor: changeRequestsDescriptor,
      upsertBatchFromCloud: (records) => db.stockChangeRequestsDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) => db.stockChangeRequestsDao.getRequestByCloudId(cloudId),
      getLastUpdated: (req) => req.lastUpdated,
      getOrganizationId: (req) => req.franchiseeId,
    );

    return TableSyncResult(
      tableName: 'stock_change_requests',
      pushedCount: pushResult.pushedCount,
      pulledCount: pullResult.pulledCount,
      conflictCount: pullResult.conflictCount,
      success: pushResult.success && pullResult.success,
    );
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  /// Delete item permanently from cloud
  Future<void> deleteItemFromCloud(String cloudId) async {
    try {
      AppLogger.sync('🗑️ Deleting item from cloud: $cloudId');
      await supabase.from('items').delete().eq('cloud_id', cloudId);
      AppLogger.sync('✅ Item deleted from cloud');
    } catch (e) {
      AppLogger.sync('❌ Failed to delete item from cloud: $e');
      rethrow;
    }
  }

  // ============================================================================
  // CLEANUP
  // ============================================================================

  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
  }

  /// Force a full sync (reset incremental sync timestamp)
  Future<void> forceFullSync() async {
    _engine.resetLastSuccessfulSync();
    await performFullSync();
  }

  /// Get sync statistics
  Map<String, int> getCacheStats() => _engine.getCacheStats();
}
