// lib/database/tables/ingredients.dart
import 'package:drift/drift.dart';

/// Ingredients table - Raw ingredients managed by commissary
class Ingredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cloudId => text().unique()();

  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get unit => text().withLength(min: 1, max: 20)();

  // Stock tracking
  RealColumn get stock => real().withDefault(const Constant(0))();
  RealColumn get criticalLevel => real().withDefault(const Constant(10))();

  // Cost per unit
  RealColumn get costPerUnit => real().withDefault(const Constant(0))();

  // Commissary that owns this ingredient
  IntColumn get commissaryId => integer()();

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
