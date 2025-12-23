// lib/database/tables/recipe_ingredients.dart
import 'package:drift/drift.dart';

/// Recipe ingredients table - Links items to their ingredients
class RecipeIngredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cloudId => text().unique()();

  // Foreign keys
  IntColumn get itemId => integer()();
  IntColumn get ingredientId => integer()();

  // Quantity of ingredient needed
  RealColumn get quantity => real()();

  // Sync timestamps
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(true))();
}
