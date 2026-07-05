import 'package:patient_management_app/data/datasources/remote/appointment_remote_data_source.dart';
import 'package:patient_management_app/domain/entities/appointment_entity.dart';
import 'package:patient_management_app/domain/repositories/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AppointmentEntity>> getAppointments({String? patientId}) async {
    final models = await remoteDataSource.getAppointments(patientId: patientId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<AppointmentEntity> getAppointmentById(String id) async {
    final model = await remoteDataSource.getAppointmentById(id);
    return model.toEntity();
  }

  @override
  Future<AppointmentEntity> createAppointment(
    CreateAppointmentEntity appointment,
  ) async {
    final result = await remoteDataSource.createAppointment(
      appointment.toJson(),
    );
    return result.toEntity();
  }

  @override
  Future<AppointmentEntity> updateAppointmentStatus(
    String id,
    String status,
  ) async {
    final result = await remoteDataSource.updateAppointmentStatus(id, status);
    return result.toEntity();
  }

  @override
  Future<bool> deleteAppointment(String id) async {
    return await remoteDataSource.deleteAppointment(id);
  }
}
