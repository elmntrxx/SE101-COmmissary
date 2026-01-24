// lib/database/tables/items.dart
import 'package:drift/drift.dart';

/// Items table - Inventory items with organization scope
/// Supports master items (commissary creates) and branch-specific copies
class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cloudId => text().unique()();

  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();

  // Stock tracking
  IntColumn get stock => integer().withDefault(const Constant(0))();
  IntColumn get criticalLevel => integer().withDefault(const Constant(10))();
  IntColumn get sold => integer().withDefault(const Constant(0))();
  IntColumn get spoilage => integer().withDefault(const Constant(0))();

  // Pricing
  RealColumn get price => real().withDefault(const Constant(0.0))();
  RealColumn get cost => real().withDefault(const Constant(0.0))();

  // Foreign keys
  IntColumn get organizationId => integer()();
  IntColumn get categoryId => integer().nullable()();

  // Master item reference (for franchisee copies)
  TextColumn get masterItemId => text().nullable()();

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
