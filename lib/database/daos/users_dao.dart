// lib/database/daos/users_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/users.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  // ============================================================================
  // QUERIES
  // ============================================================================

  /// Get all users
  Future<List<User>> getAllUsers() => select(users).get();

  /// Watch all users
  Stream<List<User>> watchAllUsers() => select(users).watch();

  /// Get users by organization
  Future<List<User>> getUsersByOrganization(int organizationId) {
    return (select(users)
          ..where((u) => u.organizationId.equals(organizationId))
          ..where((u) => u.isActive.equals(true)))
        .get();
  }

  /// Watch users by organization
  Stream<List<User>> watchUsersByOrganization(int organizationId) {
    return (select(users)
          ..where((u) => u.organizationId.equals(organizationId))
          ..where((u) => u.isActive.equals(true)))
        .watch();
  }

  /// Get user by ID
  Future<User?> getUserById(int id) async {
    final results = await (select(users)
          ..where((u) => u.id.equals(id))
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  /// Get user by cloud ID
  Future<User?> getUserByCloudId(String cloudId) async {
    final results = await (select(users)
          ..where((u) => u.cloudId.equals(cloudId))
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    final results = await (select(users)
          ..where((u) => u.email.equals(email))
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  /// Authenticate user with email and password using PBKDF2 verification
  Future<User?> authenticate(String email, String password) async {
    // First, find user by email
    final user = await getUserByEmail(email);
    if (user == null || !user.isActive) {
      return null;
    }
    
    // Verify password using PBKDF2
    if (AppDatabase.verifyPassword(password, user.passwordHash)) {
      return user;
    }
    return null;
  }

  // ============================================================================
  // MUTATIONS
  // ============================================================================

  /// Create a new user with hashed password using PBKDF2
  Future<int> createUser(UsersCompanion user, String plainPassword) {
    final hashedUser = user.copyWith(
      passwordHash: Value(AppDatabase.hashPassword(plainPassword)),
    );
    return into(users).insert(hashedUser);
  }

  /// Update user (without password)
  Future<bool> updateUser(User user) => update(users).replace(user);

  /// Update user password using PBKDF2
  Future<int> updatePassword(int id, String newPassword) {
    return (update(users)..where((u) => u.id.equals(id))).write(
      UsersCompanion(
        passwordHash: Value(AppDatabase.hashPassword(newPassword)),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Deactivate user (soft delete)
  Future<int> deactivateUser(int id) {
    return (update(users)..where((u) => u.id.equals(id))).write(
      UsersCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Get unsynced users
  Future<List<User>> getUnsyncedUsers() {
    return (select(users)..where((u) => u.needsSync.equals(true))).get();
  }

  /// Get unsynced users (including newly created ones)
  Future<List<User>> getUnsyncedUsersForPush() {
    return (select(users)
          ..where((u) => u.needsSync.equals(true)))
        .get();
  }

  /// Mark as synced
  Future<int> markAsSynced(int id, DateTime syncTime) {
    return (update(users)..where((u) => u.id.equals(id))).write(
      UsersCompanion(
        lastSyncedAt: Value(syncTime),
        needsSync: const Value(false),
      ),
    );
  }

  /// Update cloud ID (for sync reconciliation)
  Future<int> updateCloudId(int id, String cloudId) {
    return (update(users)..where((u) => u.id.equals(id))).write(
      UsersCompanion(
        cloudId: Value(cloudId),
        needsSync: const Value(false),
      ),
    );
  }

  // ============================================================================
  // CLOUD SYNC - Insert or update from cloud data
  // ============================================================================

  /// Upsert a single user from cloud data
  /// SyncEngine provides camelCase keys with resolved local IDs
  /// Returns the local ID of the inserted/updated user
  /// Note: organizationId and roleId must be resolved to local IDs before calling
  Future<int> upsertFromCloud(Map<String, dynamic> cloudData, {
    required int organizationId,
    required int roleId,
  }) async {
    final cloudId = (cloudData['cloudId'] ?? cloudData['cloud_id']) as String?;
    if (cloudId == null) throw ArgumentError('cloudId is required');
    
    // Check if user already exists by cloud_id
    final existing = await getUserByCloudId(cloudId);
    
    // Protect local unsynced changes from being overwritten
    if (existing != null && existing.needsSync) {
      return existing.id;
    }
    
    if (existing != null) {
      // Update existing user
      await (update(users)..where((u) => u.id.equals(existing.id))).write(
        UsersCompanion(
          username: Value(cloudData['username'] as String? ?? cloudData['name'] as String? ?? existing.username),
          email: Value(cloudData['email'] as String? ?? existing.email),
          phone: Value(cloudData['phone'] as String?),
          organizationId: Value(organizationId),
          roleId: Value(roleId),
          authUserId: Value(cloudData['authUserId'] as String?),
          isActive: Value(cloudData['isActive'] as bool? ?? true),
          updatedAt: Value(DateTime.now()),
          lastSyncedAt: Value(DateTime.now()),
          needsSync: const Value(false),
        ),
      );
      return existing.id;
    } else {
      // Insert new user
      // Use passwordHash from cloud, or a placeholder if not provided
      final passwordHash = cloudData['passwordHash'] as String? ?? 
                          cloudData['password'] as String? ?? 
                          'synced_from_cloud';
      
      final id = await into(users).insert(
        UsersCompanion.insert(
          cloudId: cloudId,
          username: cloudData['username'] as String? ?? cloudData['name'] as String? ?? 'Unknown',
          email: cloudData['email'] as String? ?? '',
          phone: Value(cloudData['phone'] as String?),
          passwordHash: passwordHash,
          organizationId: organizationId,
          roleId: roleId,
          authUserId: Value(cloudData['authUserId'] as String?),
          isActive: Value(cloudData['isActive'] as bool? ?? true),
          lastSyncedAt: Value(DateTime.now()),
          needsSync: const Value(false),
        ),
      );
      return id;
    }
  }

  /// Upsert multiple users from cloud data
  /// SyncEngine provides camelCase keys with resolved local IDs
  /// Each item in cloudDataList must have 'organizationId' and 'roleId' (resolved by SyncEngine)
  Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> cloudDataList) async {
    for (final cloudData in cloudDataList) {
      final orgId = cloudData['organizationId'] as int?;
      final roleId = cloudData['roleId'] as int?;
      
      if (orgId != null && roleId != null) {
        await upsertFromCloud(cloudData, organizationId: orgId, roleId: roleId);
      }
    }
  }
}
