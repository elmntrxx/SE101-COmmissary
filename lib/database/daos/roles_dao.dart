// lib/database/daos/roles_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/roles.dart';

part 'roles_dao.g.dart';

@DriftAccessor(tables: [Roles])
class RolesDao extends DatabaseAccessor<AppDatabase> with _$RolesDaoMixin {
  RolesDao(super.db);

  // ============================================================================
  // QUERIES
  // ============================================================================

  /// Get all roles
  Future<List<Role>> getAllRoles() => select(roles).get();

  /// Watch all roles
  Stream<List<Role>> watchAllRoles() => select(roles).watch();

  /// Get all active roles
  Future<List<Role>> getActiveRoles() {
    return (select(roles)..where((r) => r.isActive.equals(true))).get();
  }

  /// Get role by ID
  Future<Role?> getRoleById(int id) async {
    final results = await (select(roles)
          ..where((r) => r.id.equals(id))
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  /// Get role by cloud ID
  Future<Role?> getRoleByCloudId(String cloudId) async {
    final results = await (select(roles)
          ..where((r) => r.cloudId.equals(cloudId))
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  /// Get role by name
  Future<Role?> getRoleByName(String name) async {
    final results = await (select(roles)
          ..where((r) => r.name.equals(name))
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  // ============================================================================
  // MUTATIONS
  // ============================================================================

  /// Create a new role
  Future<int> createRole(RolesCompanion role) => into(roles).insert(role);

  /// Update a role
  Future<bool> updateRole(Role role) => update(roles).replace(role);

  /// Delete a role (only if not system role)
  Future<int> deleteRole(int id) async {
    final role = await getRoleById(id);
    if (role == null || role.isSystemRole) return 0;

    return (delete(roles)..where((r) => r.id.equals(id))).go();
  }

  /// Get unsynced roles
  Future<List<Role>> getUnsyncedRoles() {
    return (select(roles)..where((r) => r.needsSync.equals(true))).get();
  }

  /// Mark as synced
  Future<int> markAsSynced(int id, DateTime syncTime) {
    return (update(roles)..where((r) => r.id.equals(id))).write(
      RolesCompanion(
        lastSyncedAt: Value(syncTime),
        needsSync: const Value(false),
      ),
    );
  }

  /// Update cloud ID (for sync reconciliation)
  Future<int> updateCloudId(int id, String cloudId) {
    return (update(roles)..where((r) => r.id.equals(id))).write(
      RolesCompanion(
        cloudId: Value(cloudId),
        needsSync: const Value(false),
      ),
    );
  }

  // ============================================================================
  // SYNC METHODS (for SyncEngine compatibility)
  // ============================================================================

  /// Upsert a single role from cloud data
  /// SyncEngine provides camelCase keys
  Future<int> upsertFromCloud(Map<String, dynamic> cloudData) async {
    final cloudId = (cloudData['cloudId'] ?? cloudData['cloud_id']) as String?;
    if (cloudId == null) throw ArgumentError('cloudId is required');

    final existing = await getRoleByCloudId(cloudId);

    // Protect local unsynced changes from being overwritten
    if (existing != null && existing.needsSync) {
      return existing.id;
    }

    final companion = RolesCompanion(
      cloudId: Value(cloudId),
      name: Value(cloudData['name'] as String? ?? 'Unknown'),
      description: Value(cloudData['description'] as String?),
      canManageInventory: Value(cloudData['canManageInventory'] as bool? ?? false),
      canManageEmployees: Value(cloudData['canManageUsers'] as bool? ?? false),
      canViewReports: Value(cloudData['canViewReports'] as bool? ?? false),
      canManageBranches: Value(cloudData['canManageBranches'] as bool? ?? false),
      isSystemRole: Value(cloudData['isSystemRole'] as bool? ?? false),
      isActive: Value(cloudData['isActive'] as bool? ?? true),
      createdAt: cloudData['createdAt'] != null
          ? Value(cloudData['createdAt'] is DateTime 
              ? cloudData['createdAt'] as DateTime 
              : DateTime.parse(cloudData['createdAt'] as String))
          : Value(DateTime.now()),
      updatedAt: cloudData['updatedAt'] != null
          ? Value(cloudData['updatedAt'] is DateTime 
              ? cloudData['updatedAt'] as DateTime 
              : DateTime.parse(cloudData['updatedAt'] as String))
          : Value(DateTime.now()),
      lastSyncedAt: Value(DateTime.now()),
      needsSync: const Value(false),
    );

    if (existing != null) {
      await (update(roles)..where((r) => r.id.equals(existing.id))).write(companion);
      return existing.id;
    } else {
      return into(roles).insert(companion);
    }
  }

  /// Upsert batch of roles from cloud data
  Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> cloudDataList) async {
    for (final cloudData in cloudDataList) {
      await upsertFromCloud(cloudData);
    }
  }
}
