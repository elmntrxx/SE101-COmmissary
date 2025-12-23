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
}
