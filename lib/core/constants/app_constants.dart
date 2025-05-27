class AppConstants {
  // App Info
  static const String appName = 'HR-MS';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String baseUrl = 'https://your-api-endpoint.com';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Sizes
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultSpacing = 8.0;
  
  // Leave Types
  static const List<String> leaveTypes = [
    'Annual Leave',
    'Sick Leave',
    'Personal Leave',
    'Maternity Leave',
    'Paternity Leave',
    'Unpaid Leave'
  ];
  
  // Employee Status
  static const List<String> employeeStatus = [
    'Active',
    'On Leave',
    'Terminated',
    'Resigned'
  ];
  
  // Role Types
  static const List<String> roleTypes = [
    'Admin',
    'HR Manager',
    'Department Head',
    'Employee'
  ];
  
  // Department Types
  static const List<String> departments = [
    'Human Resources',
    'Information Technology',
    'Finance',
    'Marketing',
    'Operations',
    'Sales',
    'Research & Development'
  ];
} 