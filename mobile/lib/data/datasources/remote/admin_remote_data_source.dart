import 'package:dio/dio.dart';
import 'package:patient_management_app/core/network/dio_client.dart';
import 'package:patient_management_app/data/models/api_response_model.dart';
import 'package:patient_management_app/data/models/user_model.dart';
import 'package:patient_management_app/data/models/admin_stats_model.dart';
import 'package:patient_management_app/core/exceptions/app_exceptions.dart';
import 'package:patient_management_app/core/constants/api_constants.dart';

abstract class AdminRemoteDataSource {
  Future<List<UserModel>> getAllUsers({String? role});
  Future<bool> toggleUserStatus(String userId, bool isActive);
  Future<AdminStatsModel> getDashboardStats();
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final DioClient dioClient;

  AdminRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<UserModel>> getAllUsers({String? role}) async {
    try {
      final response = await dioClient.get(
        ApiConstants.adminUsers,
        queryParameters: role != null ? {'role': role} : null,
      );
      final apiResponse = ApiResponseModel<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success) {
        return apiResponse.data.map((u) => UserModel.fromJson(u as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(message: apiResponse.message ?? 'Failed to fetch users');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(message: 'An error occurred');
    }
  }

  @override
  Future<bool> toggleUserStatus(String userId, bool isActive) async {
     try {
      final response = await dioClient.post('${ApiConstants.adminUsers}/$userId/toggle', data: {'isActive': isActive});
      final apiResponse = ApiResponseModel.fromJson(
        response.data,
        (json) => json as bool,
      );
      return apiResponse.success;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AdminStatsModel> getDashboardStats() async {
    try {
      final response = await dioClient.get(ApiConstants.adminStats);
      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success) {
        return AdminStatsModel.fromJson(apiResponse.data);
      } else {
        throw ServerException(message: apiResponse.message ?? 'Failed to fetch stats');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(message: 'An error occurred');
    }
  }
}

