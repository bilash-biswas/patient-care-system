import 'package:dio/dio.dart';
import 'package:patient_management_app/core/network/dio_client.dart';
import 'package:patient_management_app/core/constants/api_constants.dart';
import 'package:patient_management_app/core/exceptions/app_exceptions.dart';
import 'package:patient_management_app/data/models/api_response_model.dart';
import 'package:patient_management_app/data/models/auth_response_model.dart';
import 'package:patient_management_app/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<AuthResponseModel> register(Map<String, dynamic> registerData);
  Future<AuthResponseModel> refreshToken(String token, String refreshToken);
  Future<bool> logout();
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;


  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      print('🔐 Attempting login to: ${ApiConstants.baseUrl}${ApiConstants.login}');
      
      final response = await dioClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      
      print('✅ Login response received');
      
      final apiResponse = ApiResponseModel<AuthResponseModel>.fromJson(
        response.data,
        (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
      );
      
      if (apiResponse.success) {
        return apiResponse.data;
      } else {
        throw ServerException(message: apiResponse.message ?? 'Login failed');
      }
    } on DioException catch (e) {
      print('❌ DioException in login: ${e.type}');
      throw ServerException(message: e.message ?? 'Network error');
    } catch (e) {
      print('❌ Unexpected error in login: $e');
      throw ServerException(message: 'An error occurred');
    }
  }

  @override
  Future<AuthResponseModel> register(Map<String, dynamic> registerData) async {
    try {
      final response = await dioClient.post(
        ApiConstants.register,
        data: registerData,
      );

      final apiResponse = ApiResponseModel<AuthResponseModel>.fromJson(
        response.data,
        (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success) {
        return apiResponse.data;
      } else {
        throw ServerException(
          message: apiResponse.message ?? 'Registration failed',
        );
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(message: 'An error occurred');
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(
    String token,
    String refreshToken,
  ) async {
    try {
      final response = await dioClient.post(
        ApiConstants.refreshToken,
        data: {'token': token, 'refreshToken': refreshToken},
      );

      final apiResponse = ApiResponseModel<AuthResponseModel>.fromJson(
        response.data,
        (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success) {
        return apiResponse.data;
      } else {
        throw ServerException(
          message: apiResponse.message ?? 'Token refresh failed',
        );
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(message: 'An error occurred');
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final response = await dioClient.post(ApiConstants.revokeToken);
      final apiResponse = ApiResponseModel.fromJson(
        response.data,
        (json) => json as bool,
      );
      return apiResponse.success;
    } on DioException catch (_) {
      // Even if network fails, consider logout successful locally
      return true;
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dioClient.get(ApiConstants.getCurrentUser);
      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success) {
        return UserModel.fromJson(apiResponse.data);
      } else {
        throw ServerException(
          message: apiResponse.message ?? 'Failed to get user',
        );
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(message: 'An error occurred');
    }
  }
}
