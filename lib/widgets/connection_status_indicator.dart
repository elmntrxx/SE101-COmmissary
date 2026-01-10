// lib/widgets/connection_status_indicator.dart
import 'package:flutter/material.dart';
import '../utils/sync_status.dart';

/// Widget that displays the current connection and sync status
class ConnectionStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final SyncStatus syncStatus;

  const ConnectionStatusIndicator({
    super.key,
    required this.isOnline,
    required this.syncStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBackgroundColor()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIcon(),
          const SizedBox(width: 4),
          Text(
            _getStatusText(),
            style: TextStyle(
              color: _getBackgroundColor(),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (!isOnline) {
      return const Icon(Icons.cloud_off, size: 16, color: Colors.grey);
    }

    switch (syncStatus) {
      case SyncStatus.syncing:
        return const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.synced:
        return const Icon(Icons.cloud_done, size: 16, color: Colors.green);
      case SyncStatus.pendingSync:
        return const Icon(Icons.cloud_upload, size: 16, color: Colors.orange);
      case SyncStatus.error:
        return const Icon(Icons.cloud_off, size: 16, color: Colors.red);
      case SyncStatus.offline:
        return const Icon(Icons.cloud_off, size: 16, color: Colors.grey);
    }
  }

  String _getStatusText() {
    if (!isOnline) return 'Offline';
    return syncStatus.displayName;
  }

  Color _getBackgroundColor() {
    if (!isOnline) return Colors.grey;

    switch (syncStatus) {
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.pendingSync:
        return Colors.orange;
      case SyncStatus.error:
        return Colors.red;
      case SyncStatus.offline:
        return Colors.grey;
    }
  }
}
