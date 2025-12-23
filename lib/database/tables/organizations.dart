// lib/database/tables/organizations.dart
import 'package:drift/drift.dart';

/// Organizations table - Stores commissary and franchisee organizations
/// In a star topology:
/// - Commissary (hub): type = 'commissary', parentCommissaryId = null
/// - Franchisee (spoke): type = 'franchisee', parentCommissaryId = commissary's cloud_id
class Organizations extends Table {
  // Local auto-increment ID
  IntColumn get id => integer().autoIncrement()();

  // UUID for cloud sync
  TextColumn get cloudId => text().unique()();

  // Organization name
  TextColumn get name => text().withLength(min: 1, max: 100)();

  // Type: 'commissary' or 'franchisee'
  TextColumn get type => text().withLength(min: 1, max: 20)();

  // Address information
  TextColumn get address => text().nullable()();

  // Contact information
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();

  // Parent commissary for franchisees (null for commissary)
  TextColumn get parentCommissaryId => text().nullable()();

  // Active status for soft delete
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // Sync timestamps
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(true))();
}
