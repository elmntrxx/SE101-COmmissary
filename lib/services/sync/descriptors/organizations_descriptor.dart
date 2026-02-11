// lib/services/sync/descriptors/organizations_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for Organizations table sync (Commissary version)
/// 
/// Tier 1: No FK dependencies
/// Push: Commissary can push organizations (creates franchisees)
/// Pull: Commissary sees ALL organizations in network (no filter)
final organizationsDescriptor = TableSyncDescriptor(
  tableName: 'organizations',
  cloudTableName: 'organizations',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 1,
  incrementalSync: false, // Always full refresh to ensure all orgs are available for FK resolution
  pullLimit: 500,
  
  // Commissary can create organizations (franchisees)
  canPush: (orgType) => orgType == 'commissary',
  
  // No organization filter - commissary sees all (RLS handles this)
  organizationField: null,
  
  // No FK mappings - parentCommissaryId stores cloud UUID directly (TEXT column)
  foreignKeys: [],
  
  fieldMappings: [
    // Parent commissary ID is a simple text field storing cloud UUID
    // Not a FK because local column is TEXT (stores UUID), not an integer reference
    FieldMapping.simple('parentCommissaryId', 'parent_commissary_id'),
    FieldMapping.simple('name', 'name'),
    FieldMapping.simple('type', 'type'),
    FieldMapping.simple('address', 'address'),
    FieldMapping.simple('phone', 'phone'),
    FieldMapping.simple('email', 'email'),
    FieldMapping.boolean('isActive', 'is_active'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('updatedAt', 'last_updated'),
  ],
);
