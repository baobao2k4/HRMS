import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static late SharedPreferences _prefs;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'YOUR_API_KEY',
        appId: 'YOUR_APP_ID',
        messagingSenderId: 'YOUR_SENDER_ID',
        projectId: 'YOUR_PROJECT_ID',
        storageBucket: 'YOUR_STORAGE_BUCKET',
      ),
    );

    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();
    
    _initialized = true;
  }

  static SharedPreferences get prefs {
    if (!_initialized) {
      throw Exception('AppConfig must be initialized before accessing prefs');
    }
    return _prefs;
  }

  // App Environment
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';

  // API Configuration
  static String get apiBaseUrl {
    switch (environment) {
      case 'production':
        return 'https://api.hrms.com';
      case 'staging':
        return 'https://staging-api.hrms.com';
      default:
        return 'https://dev-api.hrms.com';
    }
  }

  // Feature Flags
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;

  // Cache Configuration
  static const Duration cacheTimeout = Duration(hours: 24);
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB

  // Network Configuration
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
} 