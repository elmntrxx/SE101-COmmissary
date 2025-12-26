// lib/utils/sync_status.dart

/// Enum representing the sync status of the application
enum SyncStatus {
  synced,
  syncing,
  pendingSync,
  error,
  offline,
}

extension SyncStatusExtension on SyncStatus {
  String get displayName {
    switch (this) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.pendingSync:
        return 'Pending';
      case SyncStatus.error:
        return 'Error';
      case SyncStatus.offline:
        return 'Offline';
    }
  }

  bool get isHealthy => this == SyncStatus.synced;
}
