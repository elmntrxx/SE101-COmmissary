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
  /// Returns the first match if duplicates exist (handles data issues gracefully)
  Future<Organization?> getOrganizationByCloudId(String cloudId) async {
    final results = await (select(organizations)
          ..where((o) => o.cloudId.equals(cloudId))
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  /// Alias for getOrganizationByCloudId (for SyncEngine compatibility)
  Future<Organization?> getByCloudId(String cloudId) => getOrganizationByCloudId(cloudId);

  /// Get commissary (the parent organization)
  /// Returns the first active commissary if multiple exist (handles duplicate data gracefully)
  Future<Organization?> getCommissary() async {
    final results = await (select(organizations)
          ..where((o) => o.type.equals('commissary'))
          ..where((o) => o.isActive.equals(true))
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
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
  /// SyncEngine provides camelCase keys
  /// Returns the local ID of the inserted/updated organization
  Future<int> upsertFromCloud(Map<String, dynamic> cloudData) async {
    print('🔄 upsertFromCloud: $cloudData');
    final cloudId = (cloudData['cloudId'] ?? cloudData['cloud_id']) as String?;
    if (cloudId == null) throw ArgumentError('cloudId is required');
    print('   - cloudId: $cloudId');
    print('   - parentCommissaryId: ${cloudData['parentCommissaryId']}');
    
    // Check if organization already exists by cloud_id
    final existing = await getOrganizationByCloudId(cloudId);
    
    if (existing != null) {
      print('   - Existing record found (id: ${existing.id}, needsSync: ${existing.needsSync})');
      // Note: Conflict resolution is handled by SyncEngine before calling this method.
      // If we reach here, the cloud data should be applied.
      
      // Update existing organization
      await (update(organizations)..where((o) => o.id.equals(existing.id))).write(
        OrganizationsCompanion(
          name: Value(cloudData['name'] as String? ?? existing.name),
          type: Value(cloudData['type'] as String? ?? existing.type),
          address: Value(cloudData['address'] as String?),
          phone: Value(cloudData['phone'] as String?),
          email: Value(cloudData['email'] as String?),
          parentCommissaryId: Value(cloudData['parentCommissaryId'] as String?),
          isActive: Value(cloudData['isActive'] as bool? ?? true),
          updatedAt: Value(DateTime.now()),
          lastSyncedAt: Value(DateTime.now()),
          needsSync: const Value(false),
        ),
      );
      print('   - ✅ Updated existing organization');
      return existing.id;
    } else {
      print('   - Creating new organization');
      // Insert new organization
      final id = await into(organizations).insert(
        OrganizationsCompanion.insert(
          cloudId: cloudId,
          name: cloudData['name'] as String? ?? 'Unknown',
          type: cloudData['type'] as String? ?? 'franchisee',
          address: Value(cloudData['address'] as String?),
          phone: Value(cloudData['phone'] as String?),
          email: Value(cloudData['email'] as String?),
          parentCommissaryId: Value(cloudData['parentCommissaryId'] as String?),
          isActive: Value(cloudData['isActive'] as bool? ?? true),
          lastSyncedAt: Value(DateTime.now()),
          needsSync: const Value(false),
        ),
      );
      print('   - ✅ Created new organization (id: $id)');
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
