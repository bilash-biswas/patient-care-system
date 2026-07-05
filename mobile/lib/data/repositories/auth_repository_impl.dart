import 'package:dio/dio.dart';
import 'package:patient_management_app/core/exceptions/app_exceptions.dart';
import 'package:patient_management_app/data/datasources/local/shared_prefs.dart';
import 'package:patient_management_app/data/datasources/remote/auth_remote_data_source.dart';
import 'package:patient_management_app/domain/entities/user_entity.dart';
import 'package:patient_management_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPrefs sharedPrefs;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPrefs,
  });

  @override
  Future<AuthResponseEntity> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);

      // Save tokens
      await saveTokens(response.token, response.refreshToken);

      return response.toEntity();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<AuthResponseEntity> register(RegisterEntity registerEntity) async {
    try {
      final response = await remoteDataSource.register(registerEntity.toJson());

      // Save tokens
      await saveTokens(response.token, response.refreshToken);

      return response.toEntity();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<AuthResponseEntity> refreshToken(
    String token,
    String refreshToken,
  ) async {
    try {
      final response = await remoteDataSource.refreshToken(token, refreshToken);

      // Save new tokens
      await saveTokens(response.token, response.refreshToken);

      return response.toEntity();
    } catch (e) {
      await clearTokens();
      throw _handleError(e);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final success = await remoteDataSource.logout();
      await clearTokens();
      return success;
    } catch (e) {
      // Clear tokens even if network fails
      await clearTokens();
      return true;
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      if (!await isAuthenticated()) {
        return null;
      }

      final userModel = await remoteDataSource.getCurrentUser();
      return userModel.toEntity();
    } catch (e) {
      // If we can't get current user, clear tokens
      await clearTokens();
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await sharedPrefs.getString('token');
    final refreshToken = await sharedPrefs.getString('refreshToken');
    return token != null && refreshToken != null;
  }

  @override
  Future<void> saveTokens(String token, String refreshToken) async {
    await sharedPrefs.setString('token', token);
    await sharedPrefs.setString('refreshToken', refreshToken);
  }

  @override
  Future<void> clearTokens() async {
    await sharedPrefs.remove('token');
    await sharedPrefs.remove('refreshToken');
  }

  dynamic _handleError(dynamic error) {
    if (error is ServerException) {
      return error;
    } else if (error is DioException) {
      return NetworkException(message: error.message ?? 'Network error');
    } else {
      return AppException(message: 'An unexpected error occurred');
    }
  }
}
