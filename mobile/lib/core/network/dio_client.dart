import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:patient_management_app/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioClient {
  static DioClient? _instance;
  late final Dio _dio;
  
  DioClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      responseType: ResponseType.json,
    ));
    
    _setupInterceptors();
  }
  
  factory DioClient() {
    _instance ??= DioClient._internal();
    return _instance!;
  }
  
  void _setupInterceptors() {
    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print('📤 REQUEST: ${options.method} ${options.baseUrl}${options.path}');
          print('📤 DATA: ${options.data}');
          
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('📥 RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          print('📥 DATA: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          print('❌ ERROR: ${error.message}');
          print('❌ TYPE: ${error.type}');
          print('❌ RESPONSE: ${error.response?.data}');
          
          if (error.response?.statusCode == 401) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('token');
            await prefs.remove('refreshToken');
          }
          return handler.next(error);
        },
      ),
    );
    
    // Add logger in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: false,
          maxWidth: 120,
        ),
      );
    }
  }
  
  Dio get dio => _dio;
  
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      print('🌐 POST to: ${_dio.options.baseUrl}$path');
      print('📦 Data: $data');
      
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      print('✅ Response: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('❌ DioException: ${e.type} - ${e.message}');
      if (e.response != null) {
        print('❌ Response data: ${e.response?.data}');
      }
      throw _handleError(e);
    }
  }
  
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  dynamic _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to connect to server. Please check your internet connection and ensure the backend server is running at ${ApiConstants.baseUrl}';
    }
    
    if (error.response != null) {
      final data = error.response?.data;
      final message = data is Map ? data['message'] : data.toString();
      
      switch (error.response?.statusCode) {
        case 400:
          return 'Bad request: $message';
        case 401:
          return 'Invalid email or password';
        case 403:
          return 'Access denied';
        case 404:
          return 'Service not found. Please check if the backend is running.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return message ?? 'An error occurred';
      }
    }
    
    return error.message ?? 'Network error occurred';
  }
}