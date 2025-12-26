// lib/database/daos/organizations_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/organizations.dart';

part 'organizations_dao.g.dart';

@DriftAccessor(tables: [Organizations])
class OrganizationsDao extends DatabaseAccessor<AppDatabase>
    with _$OrganizationsDaoMixin {
  OrganizationsDao(super.db);

  // ============================================================================
  // QUERIES
  // ============================================================================

  /// Get all organizations
  Future<List<Organization>> getAllOrganizations() => select(organizations).get();

  /// Watch all organizations
  Stream<List<Organization>> watchAllOrganizations() =>
      select(organizations).watch();

  /// Get all active franchisees under this commissary
  Future<List<Organization>> getFranchisees(String commissaryCloudId) {
    return (select(organizations)
          ..where((o) => o.parentCommissaryId.equals(commissaryCloudId))
          ..where((o) => o.isActive.equals(true)))
        .get();
  }

  /// Watch all franchisees
  Stream<List<Organization>> watchFranchisees(String commissaryCloudId) {
    return (select(organizations)
          ..where((o) => o.parentCommissaryId.equals(commissaryCloudId))
          ..where((o) => o.isActive.equals(true)))
        .watch();
  }

  /// Get organization by ID
  Future<Organization?> getOrganizationById(int id) {
    return (select(organizations)..where((o) => o.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get organization by cloud ID
  Future<Organization?> getOrganizationByCloudId(String cloudId) {
    return (select(organizations)..where((o) => o.cloudId.equals(cloudId)))
        .getSingleOrNull();
  }

  /// Get commissary (the parent organization)
  Future<Organization?> getCommissary() {
    return (select(organizations)
          ..where((o) => o.type.equals('commissary'))
          ..where((o) => o.isActive.equals(true)))
        .getSingleOrNull();
  }

  // ============================================================================
  // MUTATIONS
  // ============================================================================

  /// Create a new organization
  Future<int> createOrganization(OrganizationsCompanion org) =>
      into(organizations).insert(org);

  /// Update an organization
  Future<bool> updateOrganization(Organization org) =>
      update(organizations).replace(org);

  /// Soft delete (deactivate) an organization
  Future<int> deactivateOrganization(int id) {
    return (update(organizations)..where((o) => o.id.equals(id))).write(
      OrganizationsCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Get unsynced organizations
  Future<List<Organization>> getUnsyncedOrganizations() {
    return (select(organizations)..where((o) => o.needsSync.equals(true))).get();
  }

  /// Mark as synced
  Future<int> markAsSynced(int id, DateTime syncTime) {
    return (update(organizations)..where((o) => o.id.equals(id))).write(
      OrganizationsCompanion(
        lastSyncedAt: Value(syncTime),
        needsSync: const Value(false),
      ),
    );
  }

  /// Update cloud ID (for sync reconciliation)
  Future<int> updateCloudId(int id, String cloudId) {
    return (update(organizations)..where((o) => o.id.equals(id))).write(
      OrganizationsCompanion(
        cloudId: Value(cloudId),
        needsSync: const Value(false),
      ),
    );
  }

  // ============================================================================
  // CLOUD SYNC - Insert or update from cloud data
  // ============================================================================

  /// Upsert a single organization from cloud data
  /// Returns the local ID of the inserted/updated organization
  Future<int> upsertFromCloud(Map<String, dynamic> cloudData) async {
    final cloudId = cloudData['cloud_id'] as String;
    
    // Check if organization already exists by cloud_id
    final existing = await getOrganizationByCloudId(cloudId);
    
    if (existing != null) {
      // Update existing organization
      await (update(organizations)..where((o) => o.id.equals(existing.id))).write(
        OrganizationsCompanion(
          name: Value(cloudData['name'] as String),
          type: Value(cloudData['type'] as String),
          address: Value(cloudData['address'] as String?),
          phone: Value(cloudData['phone'] as String?),
          email: Value(cloudData['email'] as String?),
          parentCommissaryId: Value(cloudData['parent_commissary_id'] as String?),
          isActive: Value(cloudData['is_active'] as bool? ?? true),
          updatedAt: Value(DateTime.now()),
          lastSyncedAt: Value(DateTime.now()),
          needsSync: const Value(false),
        ),
      );
      return existing.id;
    } else {
      // Insert new organization
      final id = await into(organizations).insert(
        OrganizationsCompanion.insert(
          cloudId: cloudId,
          name: cloudData['name'] as String,
          type: cloudData['type'] as String,
          address: Value(cloudData['address'] as String?),
          phone: Value(cloudData['phone'] as String?),
          email: Value(cloudData['email'] as String?),
          parentCommissaryId: Value(cloudData['parent_commissary_id'] as String?),
          isActive: Value(cloudData['is_active'] as bool? ?? true),
          lastSyncedAt: Value(DateTime.now()),
          needsSync: const Value(false),
        ),
      );
      return id;
    }
  }

  /// Upsert multiple organizations from cloud data
  Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> cloudDataList) async {
    for (final cloudData in cloudDataList) {
      await upsertFromCloud(cloudData);
    }
  }
}
