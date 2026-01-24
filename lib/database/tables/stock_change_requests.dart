// lib/database/tables/stock_change_requests.dart
import 'package:drift/drift.dart';

/// Stock change requests - Track stock changes within a franchisee
class StockChangeRequests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cloudId => text().unique()();

  // Franchisee where the change occurred
  IntColumn get franchiseeId => integer()();

  // Item being changed
  IntColumn get itemId => integer()();

  // Change type: 'sale', 'spoilage', 'adjustment', 'restock'
  TextColumn get changeType => text()();

  // Quantity changed (positive or negative)
  IntColumn get quantityChange => integer()();

  // Previous and new stock levels
  IntColumn get previousStock => integer()();
  IntColumn get newStock => integer()();

  // Reason for change
  TextColumn get reason => text().nullable()();

  // Status: 'draft', 'pending', 'approved', 'rejected'
  TextColumn get status =>
      text().withDefault(const Constant('pending'))();

  // User who made the request
  IntColumn get requestedBy => integer()();

  // User who approved/rejected
  IntColumn get processedBy => integer().nullable()();
  DateTimeColumn get processedAt => dateTime().nullable()();

  // Sync timestamps
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(true))();
}
