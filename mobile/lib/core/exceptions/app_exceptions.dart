class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException({required this.message, this.prefix});

  @override
  String toString() => '${prefix ?? ''}$message';
}

class ServerException extends AppException {
  ServerException({required super.message}) : super(prefix: 'Server Error: ');
}

class NetworkException extends AppException {
  NetworkException({required super.message}) : super(prefix: 'Network Error: ');
}

class CacheException extends AppException {
  CacheException({required super.message}) : super(prefix: 'Cache Error: ');
}

class ValidationException extends AppException {
  ValidationException({required super.message}) : super(prefix: 'Validation Error: ');
}

class AuthenticationException extends AppException {
  AuthenticationException({required super.message}) : super(prefix: 'Auth Error: ');
}
