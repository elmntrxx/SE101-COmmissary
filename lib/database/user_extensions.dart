// lib/database/user_extensions.dart
import 'app_database.dart';

/// Extension methods for User class
extension UserExtensions on User {
  /// Convert User to Map for sync operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cloudId': cloudId,
      'username': username,
      'email': email,
      'phone': phone,
      'passwordHash': passwordHash,
      'organizationId': organizationId,
      'roleId': roleId,
      'authUserId': authUserId,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastSyncedAt': lastSyncedAt,
      'needsSync': needsSync,
    };
  }
}
