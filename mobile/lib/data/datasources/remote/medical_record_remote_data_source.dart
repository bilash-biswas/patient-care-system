import 'package:patient_management_app/core/network/dio_client.dart';
import 'package:patient_management_app/core/constants/api_constants.dart';
import 'package:patient_management_app/data/models/medical_record_model.dart';

abstract class MedicalRecordRemoteDataSource {
  Future<List<MedicalRecordModel>> getMedicalRecords({String? patientId});
  Future<MedicalRecordModel> getMedicalRecordById(String id);
  Future<MedicalRecordModel> createMedicalRecord(Map<String, dynamic> recordData);
  Future<MedicalRecordModel> updateMedicalRecord(String id, Map<String, dynamic> recordData);
  Future<bool> deleteMedicalRecord(String id);
}

class MedicalRecordRemoteDataSourceImpl implements MedicalRecordRemoteDataSource {
  final DioClient dioClient;

  MedicalRecordRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<MedicalRecordModel>> getMedicalRecords({String? patientId}) async {
    final Map<String, dynamic> queryParameters = {};
    if (patientId != null) {
      queryParameters['patientId'] = patientId;
    }

    final response = await dioClient.get(
      ApiConstants.medicalRecords,
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => MedicalRecordModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load medical records');
    }
  }

  @override
  Future<MedicalRecordModel> getMedicalRecordById(String id) async {
    final response = await dioClient.get('${ApiConstants.medicalRecords}/$id');
    if (response.statusCode == 200) {
      return MedicalRecordModel.fromJson(response.data['data']);
    } else {
      throw Exception('Failed to load medical record');
    }
  }

  @override
  Future<MedicalRecordModel> createMedicalRecord(Map<String, dynamic> recordData) async {
    final response = await dioClient.post(ApiConstants.medicalRecords, data: recordData);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return MedicalRecordModel.fromJson(response.data['data']);
    } else {
      throw Exception('Failed to create medical record');
    }
  }

  @override
  Future<MedicalRecordModel> updateMedicalRecord(String id, Map<String, dynamic> recordData) async {
    final response = await dioClient.put('${ApiConstants.medicalRecords}/$id', data: recordData);
    if (response.statusCode == 200) {
      return MedicalRecordModel.fromJson(response.data['data']);
    } else {
      throw Exception('Failed to update medical record');
    }
  }

  @override
  Future<bool> deleteMedicalRecord(String id) async {
    final response = await dioClient.delete('${ApiConstants.medicalRecords}/$id');
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete medical record');
    }
  }
}
