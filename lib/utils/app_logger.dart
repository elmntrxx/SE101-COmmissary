// lib/utils/app_logger.dart
import 'package:flutter/foundation.dart';

/// Simple logger utility for the Commissary app
class AppLogger {
  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ $message');
    }
  }

  static void error(String message) {
    if (kDebugMode) {
      print('❌ $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ $message');
    }
  }

  static void sync(String message) {
    if (kDebugMode) {
      print('🔄 $message');
    }
  }

  static void database(String message) {
    if (kDebugMode) {
      print('🗄️ $message');
    }
  }

  static void connectivity(String message) {
    if (kDebugMode) {
      print('📡 $message');
    }
  }
}
