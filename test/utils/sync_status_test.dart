import 'package:flutter_test/flutter_test.dart';
import 'package:commissary_app/utils/sync_status.dart';

void main() {
  group('SyncStatus enum', () {
    // ========================================================================
    // POSITIVE TEST CASES
    // ========================================================================

    test('should have synced status', () {
      expect(SyncStatus.synced, isNotNull);
      expect(SyncStatus.values.contains(SyncStatus.synced), isTrue);
    });

    test('should have syncing status', () {
      expect(SyncStatus.syncing, isNotNull);
      expect(SyncStatus.values.contains(SyncStatus.syncing), isTrue);
    });

    test('should have pendingSync status', () {
      expect(SyncStatus.pendingSync, isNotNull);
      expect(SyncStatus.values.contains(SyncStatus.pendingSync), isTrue);
    });

    test('should have error status', () {
      expect(SyncStatus.error, isNotNull);
      expect(SyncStatus.values.contains(SyncStatus.error), isTrue);
    });

    test('should have offline status', () {
      expect(SyncStatus.offline, isNotNull);
      expect(SyncStatus.values.contains(SyncStatus.offline), isTrue);
    });

    test('should contain exactly 5 status values', () {
      expect(SyncStatus.values.length, equals(5));
    });
  });

  group('SyncStatusExtension displayName', () {
    // ========================================================================
    // POSITIVE TEST CASES
    // ========================================================================

    test('synced displayName should return "Synced"', () {
      expect(SyncStatus.synced.displayName, equals('Synced'));
    });

    test('syncing displayName should return "Syncing..."', () {
      expect(SyncStatus.syncing.displayName, equals('Syncing...'));
    });

    test('pendingSync displayName should return "Pending"', () {
      expect(SyncStatus.pendingSync.displayName, equals('Pending'));
    });

    test('error displayName should return "Error"', () {
      expect(SyncStatus.error.displayName, equals('Error'));
    });

    test('offline displayName should return "Offline"', () {
      expect(SyncStatus.offline.displayName, equals('Offline'));
    });

    test('all statuses should have non-empty displayName', () {
      for (final status in SyncStatus.values) {
        expect(status.displayName.isNotEmpty, isTrue);
      }
    });
  });

  group('SyncStatusExtension isHealthy', () {
    // ========================================================================
    // POSITIVE TEST CASES
    // ========================================================================

    test('synced status should be healthy', () {
      expect(SyncStatus.synced.isHealthy, isTrue);
    });

    // ========================================================================
    // NEGATIVE TEST CASES
    // ========================================================================

    test('syncing status should not be healthy', () {
      expect(SyncStatus.syncing.isHealthy, isFalse);
    });

    test('pendingSync status should not be healthy', () {
      expect(SyncStatus.pendingSync.isHealthy, isFalse);
    });

    test('error status should not be healthy', () {
      expect(SyncStatus.error.isHealthy, isFalse);
    });

    test('offline status should not be healthy', () {
      expect(SyncStatus.offline.isHealthy, isFalse);
    });

    test('only synced status should be healthy among all statuses', () {
      final healthyStatuses = SyncStatus.values.where((s) => s.isHealthy).toList();
      expect(healthyStatuses.length, equals(1));
      expect(healthyStatuses.first, equals(SyncStatus.synced));
    });
  });
}
