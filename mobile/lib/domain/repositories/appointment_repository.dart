import 'package:patient_management_app/domain/entities/appointment_entity.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentEntity>> getAppointments({String? patientId});
  Future<AppointmentEntity> getAppointmentById(String id);
  Future<AppointmentEntity> createAppointment(CreateAppointmentEntity appointment);
  Future<AppointmentEntity> updateAppointmentStatus(String id, String status);
  Future<bool> deleteAppointment(String id);
}
