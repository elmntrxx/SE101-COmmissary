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
  Future<Role?> getRoleById(int id) {
    return (select(roles)..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  /// Get role by cloud ID
  Future<Role?> getRoleByCloudId(String cloudId) {
    return (select(roles)..where((r) => r.cloudId.equals(cloudId)))
        .getSingleOrNull();
  }

  /// Get role by name
  Future<Role?> getRoleByName(String name) {
    return (select(roles)..where((r) => r.name.equals(name))).getSingleOrNull();
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
}
