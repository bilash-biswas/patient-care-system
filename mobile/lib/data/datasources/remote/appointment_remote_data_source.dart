import 'package:patient_management_app/core/network/dio_client.dart';
import 'package:patient_management_app/core/constants/api_constants.dart';
import 'package:patient_management_app/data/models/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<AppointmentModel>> getAppointments({String? patientId});
  Future<AppointmentModel> getAppointmentById(String id);
  Future<AppointmentModel> createAppointment(Map<String, dynamic> appointmentData);
  Future<AppointmentModel> updateAppointmentStatus(String id, String status);
  Future<bool> deleteAppointment(String id);
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final DioClient dioClient;

  AppointmentRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<AppointmentModel>> getAppointments({String? patientId}) async {
    final response = await dioClient.get(
      ApiConstants.appointments,
      queryParameters: {
        if (patientId != null) 'patientId': patientId,
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => AppointmentModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  @override
  Future<AppointmentModel> getAppointmentById(String id) async {
    final response = await dioClient.get('${ApiConstants.appointments}/$id');
    if (response.statusCode == 200) {
      return AppointmentModel.fromJson(response.data['data']);
    } else {
      throw Exception('Failed to load appointment');
    }
  }

  @override
  Future<AppointmentModel> createAppointment(Map<String, dynamic> appointmentData) async {
    final response = await dioClient.post(ApiConstants.appointments, data: appointmentData);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return AppointmentModel.fromJson(response.data['data']);
    } else {
      throw Exception('Failed to create appointment');
    }
  }

  @override
  Future<AppointmentModel> updateAppointmentStatus(String id, String status) async {
    final response = await dioClient.post(
      '${ApiConstants.appointments}/$id/status',
      data: {'status': status},
    );
    if (response.statusCode == 200) {
      return AppointmentModel.fromJson(response.data['data']);
    } else {
      throw Exception('Failed to update appointment status');
    }
  }

  @override
  Future<bool> deleteAppointment(String id) async {
    final response = await dioClient.delete('${ApiConstants.appointments}/$id');
    return response.statusCode == 204 || response.statusCode == 200;
  }
}
