// lib/database/tables/users.dart
import 'package:drift/drift.dart';

/// Users table - Stores all users with organization and role assignments
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cloudId => text().unique()();

  // User details
  TextColumn get username => text().withLength(min: 1, max: 100)();
  TextColumn get email => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get passwordHash => text()();

  // Foreign keys (stored as local IDs, synced via cloud IDs)
  IntColumn get organizationId => integer()();
  IntColumn get roleId => integer()();

  // Supabase Auth user ID for RLS
  TextColumn get authUserId => text().nullable()();

  // Status
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // Sync timestamps
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(true))();
}
