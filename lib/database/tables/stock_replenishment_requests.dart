// lib/database/tables/stock_replenishment_requests.dart
import 'package:drift/drift.dart';

/// Stock replenishment requests - Franchisees request stock from commissary
class StockReplenishmentRequests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cloudId => text().unique()();

  // Requesting franchisee
  IntColumn get franchiseeId => integer()();

  // Target commissary
  IntColumn get commissaryId => integer()();

  // Item being requested
  IntColumn get itemId => integer()();

  // Quantity requested
  IntColumn get quantityRequested => integer()();

  // Quantity approved (may differ from requested)
  IntColumn get quantityApproved => integer().nullable()();

  // Status: 'draft', 'pending', 'approved', 'rejected', 'fulfilled'
  TextColumn get status =>
      text().withDefault(const Constant('draft'))();

  // Notes from requester and approver
  TextColumn get requesterNotes => text().nullable()();
  TextColumn get approverNotes => text().nullable()();

  // User who processed the request
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
