class ApiConstants {
  static const String baseUrl = 'http://192.168.10.235:5278/api';
  // static const String baseUrl = 'http://10.0.2.2:5278/api';
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String revokeToken = '/auth/revoke-token';
  static const String getCurrentUser = '/auth/me';

  // Patient endpoints
  static const String patients = '/patients';

  // Appointment endpoints
  static const String appointments = '/appointments';

  // Medical Record endpoints
  static const String medicalRecords = '/medicalRecords';

  static const String adminUsers = '/admin/users';
  static const String adminStats = '/admin/stats';
}

