// lib/database/tables/roles.dart
import 'package:drift/drift.dart';

/// Roles table - Defines user roles with permission flags
class Roles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cloudId => text().unique()();

  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get description => text().nullable()();

  // Permission flags
  BoolColumn get canViewInventory =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get canManageInventory =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get canManageEmployees =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get canManageRoles =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get canViewReports =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get canManageBranches =>
      boolean().withDefault(const Constant(false))();

  // System role flag (cannot be deleted)
  BoolColumn get isSystemRole =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // Sync timestamps
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(true))();
}
