import 'package:dio/dio.dart';
import 'package:patient_management_app/core/network/dio_client.dart';
import 'package:patient_management_app/core/constants/api_constants.dart';
import 'package:patient_management_app/data/models/patient_model.dart';
import 'package:patient_management_app/data/models/api_response_model.dart';
import 'package:patient_management_app/core/exceptions/app_exceptions.dart';
import 'package:patient_management_app/data/models/appointment_model.dart';
import 'package:patient_management_app/data/models/medical_record_model.dart';

abstract class PatientRemoteDataSource {
  Future<List<PatientModel>> getPatients({String? search, int page = 1, int pageSize = 20});
  Future<PatientModel> getPatientById(String id);
  Future<PatientModel> createPatient(Map<String, dynamic> patientData);
  Future<PatientModel> updatePatient(String id, Map<String, dynamic> patientData);
  Future<bool> deletePatient(String id);
  Future<List<AppointmentModel>> getPatientAppointments(String id);
  Future<List<MedicalRecordModel>> getPatientMedicalRecords(String id);
  Future<PatientModel> getMyProfile();
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final DioClient dioClient;
  static int lastTotalCount = 0;

  PatientRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<PatientModel> getMyProfile() async {
    try {
      final response = await dioClient.get('${ApiConstants.patients}/me');
      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success) {
        return PatientModel.fromJson(apiResponse.data);
      } else {
        throw ServerException(message: apiResponse.message ?? 'Failed to get profile');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(message: 'An error occurred');
    }
  }

  @override
  Future<List<PatientModel>> getPatients({String? search, int page = 1, int pageSize = 20}) async {
    final response = await dioClient.get(
      ApiConstants.patients,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'pageSize': pageSize,
      },
    );
    if (response.statusCode == 200) {
      if (response.data['pagination'] != null && response.data['pagination']['totalCount'] != null) {
        lastTotalCount = response.data['pagination']['totalCount'] as int;
      }
      final List<dynamic> data = response.data['data'];
      return data.map((json) => PatientModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load patients');
    }
  }

  @override
  Future<PatientModel> getPatientById(String id) async {
    final response = await dioClient.get('${ApiConstants.patients}/$id');
    if (response.statusCode == 200) {
      return PatientModel.fromJson(response.data['data']);
    } else {
      throw Exception('Failed to load patient');
    }
  }

  @override
  Future<PatientModel> createPatient(Map<String, dynamic> patientData) async {
    final response = await dioClient.post(
      ApiConstants.patients,
      data: patientData,
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return PatientModel.fromJson(response.data['data']);
    } else {
      throw Exception('Failed to create patient');
    }
  }

  @override
  Future<PatientModel> updatePatient(String id, Map<String, dynamic> patientData) async {
    final response = await dioClient.put(
      '${ApiConstants.patients}/$id',
      data: patientData,
    );
    if (response.statusCode == 200) {
      return PatientModel.fromJson(response.data['data']);
    } else {
      throw Exception('Failed to update patient');
    }
  }

  @override
  Future<bool> deletePatient(String id) async {
    final response = await dioClient.delete('${ApiConstants.patients}/$id');
    return response.statusCode == 204 || response.statusCode == 200;
  }

  @override
  Future<List<AppointmentModel>> getPatientAppointments(String id) async {
    final response = await dioClient.get('${ApiConstants.patients}/$id/appointments');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => AppointmentModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load patient appointments');
    }
  }

  @override
  Future<List<MedicalRecordModel>> getPatientMedicalRecords(String id) async {
    final response = await dioClient.get('${ApiConstants.patients}/$id/medical-records');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => MedicalRecordModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load patient medical records');
    }
  }
}
