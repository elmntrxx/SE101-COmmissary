// lib/services/connectivity_service.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity status
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  bool _isOnline = true;

  ConnectivityService() {
    _init();
  }

  void _init() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) => _updateStatus(result));
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
  }

  void _updateStatus(ConnectivityResult result) {
    // Consider online if connectivity is available (not none)
    final isOnline = result != ConnectivityResult.none;
    
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      _connectionController.add(isOnline);
    }
  }

  /// Stream of connectivity status changes
  Stream<bool> get connectionStream => _connectionController.stream;

  /// Current connectivity status
  bool get isOnline => _isOnline;

  /// Check current connectivity
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
    return _isOnline;
  }

  void dispose() {
    _subscription?.cancel();
    _connectionController.close();
  }
}
