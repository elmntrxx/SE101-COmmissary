// lib/services/sync/descriptors/recipe_ingredients_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for RecipeIngredients table sync
/// 
/// Tier 3: Depends on Items, Ingredients
/// Push: Commissary manages recipes
/// Pull: Everyone can read recipes
final recipeIngredientsDescriptor = TableSyncDescriptor(
  tableName: 'recipe_ingredients',
  cloudTableName: 'recipe_ingredients',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 3,
  incrementalSync: false, // Full refresh
  pullLimit: 1000,
  
  // Commissary manages recipes
  canPush: (orgType) => orgType == 'commissary',
  
  // No organization filter
  organizationField: null,
  
  foreignKeys: [
    ForeignKeyMapping(
      localField: 'itemId',
      cloudField: 'item_id',
      referenceTable: 'items',
      required: true,
      cloudUsesUuid: true,
    ),
    ForeignKeyMapping(
      localField: 'ingredientId',
      cloudField: 'ingredient_id',
      referenceTable: 'ingredients',
      required: true,
      cloudUsesUuid: true,
    ),
  ],
  
  fieldMappings: [
    FieldMapping.real('quantity', 'quantity'),
    FieldMapping.simple('unit', 'unit'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('updatedAt', 'last_updated'),
  ],
);
