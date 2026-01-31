// lib/database/tables/stock_replenishment_requests.dart
import 'package:drift/drift.dart';
import 'items.dart';
import 'organizations.dart';
import 'users.dart';

/// StockReplenishmentRequests table - Franchisee requests items from Commissary
///
/// Schema matches Supabase table:
/// - pending: Request created by franchisee
/// - approved: Commissary approved, stock transferred
/// - rejected: Commissary rejected
/// - delivered: Items physically delivered
class StockReplenishmentRequests extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Requesting franchisee organization
  @ReferenceName('franchiseeReplenishmentRequests')
  IntColumn get franchiseeId => integer().references(Organizations, #id)();

  /// Target commissary organization
  @ReferenceName('commissaryReplenishmentRequests')
  IntColumn get commissaryId => integer().references(Organizations, #id)();

  /// Item being requested
  IntColumn get itemId => integer().references(Items, #id)();

  /// Quantity requested by franchisee
  IntColumn get quantityRequested => integer()();

  /// Status: 'pending', 'approved', 'rejected', 'delivered'
  TextColumn get status => text()
      .withLength(min: 3, max: 50)
      .withDefault(const Constant('pending'))();

  /// User who created the request
  @ReferenceName('replenishmentRequester')
  IntColumn get requestedBy => integer().references(Users, #id)();

  DateTimeColumn get requestedAt =>
      dateTime().clientDefault(() => DateTime.now())();

  /// User who reviewed/processed the request (commissary user)
  @ReferenceName('replenishmentReviewer')
  IntColumn get reviewedBy => integer().nullable().references(Users, #id)();

  DateTimeColumn get reviewedAt => dateTime().nullable()();

  /// Expected delivery date (optional)
  DateTimeColumn get deliveryDate => dateTime().nullable()();

  /// Notes from the franchisee (reason for request)
  TextColumn get franchiseeNotes => text().nullable().withLength(max: 1000)();

  /// Notes from the commissary (approval/rejection reason)
  TextColumn get commissaryNotes => text().nullable().withLength(max: 1000)();

  /// Timestamps
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get lastUpdated =>
      dateTime().clientDefault(() => DateTime.now())();

  /// Soft delete
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Sync fields
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get cloudId => text().nullable()();
}
