// lib/database/daos/users_dao.dart
import 'package:drift/drift.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../app_database.dart';
import '../tables/users.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  // ============================================================================
  // PASSWORD HASHING
  // ============================================================================

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

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
  Future<User?> getUserById(int id) {
    return (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  /// Get user by cloud ID
  Future<User?> getUserByCloudId(String cloudId) {
    return (select(users)..where((u) => u.cloudId.equals(cloudId)))
        .getSingleOrNull();
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) {
    return (select(users)..where((u) => u.email.equals(email)))
        .getSingleOrNull();
  }

  /// Authenticate user with email and password
  Future<User?> authenticate(String email, String password) async {
    final hashedPassword = _hashPassword(password);
    return (select(users)
          ..where((u) => u.email.equals(email))
          ..where((u) => u.passwordHash.equals(hashedPassword))
          ..where((u) => u.isActive.equals(true)))
        .getSingleOrNull();
  }

  // ============================================================================
  // MUTATIONS
  // ============================================================================

  /// Create a new user with hashed password
  Future<int> createUser(UsersCompanion user, String plainPassword) {
    final hashedUser = user.copyWith(
      passwordHash: Value(_hashPassword(plainPassword)),
    );
    return into(users).insert(hashedUser);
  }

  /// Update user (without password)
  Future<bool> updateUser(User user) => update(users).replace(user);

  /// Update user password
  Future<int> updatePassword(int id, String newPassword) {
    return (update(users)..where((u) => u.id.equals(id))).write(
      UsersCompanion(
        passwordHash: Value(_hashPassword(newPassword)),
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
  /// Returns the local ID of the inserted/updated user
  /// Note: organizationId and roleId must be resolved to local IDs before calling
  Future<int> upsertFromCloud(Map<String, dynamic> cloudData, {
    required int organizationId,
    required int roleId,
  }) async {
    final cloudId = cloudData['cloud_id'] as String;
    
    // Check if user already exists by cloud_id
    final existing = await getUserByCloudId(cloudId);
    
    if (existing != null) {
      // Update existing user
      await (update(users)..where((u) => u.id.equals(existing.id))).write(
        UsersCompanion(
          username: Value(cloudData['username'] as String),
          email: Value(cloudData['email'] as String),
          phone: Value(cloudData['phone'] as String?),
          organizationId: Value(organizationId),
          roleId: Value(roleId),
          authUserId: Value(cloudData['auth_user_id'] as String?),
          isActive: Value(cloudData['is_active'] as bool? ?? true),
          updatedAt: Value(DateTime.now()),
          lastSyncedAt: Value(DateTime.now()),
          needsSync: const Value(false),
        ),
      );
      return existing.id;
    } else {
      // Insert new user
      // Use password_hash from cloud, or a placeholder if not provided
      final passwordHash = cloudData['password_hash'] as String? ?? 
                          cloudData['password'] as String? ?? 
                          'synced_from_cloud';
      
      final id = await into(users).insert(
        UsersCompanion.insert(
          cloudId: cloudId,
          username: cloudData['username'] as String,
          email: cloudData['email'] as String,
          phone: Value(cloudData['phone'] as String?),
          passwordHash: passwordHash,
          organizationId: organizationId,
          roleId: roleId,
          authUserId: Value(cloudData['auth_user_id'] as String?),
          isActive: Value(cloudData['is_active'] as bool? ?? true),
          lastSyncedAt: Value(DateTime.now()),
          needsSync: const Value(false),
        ),
      );
      return id;
    }
  }

  /// Upsert multiple users from cloud data
  /// Each item in cloudDataList must have 'resolved_organization_id' and 'resolved_role_id'
  Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> cloudDataList) async {
    for (final cloudData in cloudDataList) {
      final orgId = cloudData['resolved_organization_id'] as int?;
      final roleId = cloudData['resolved_role_id'] as int?;
      
      if (orgId != null && roleId != null) {
        await upsertFromCloud(cloudData, organizationId: orgId, roleId: roleId);
      }
    }
  }
}
