import 'package:patient_management_app/domain/entities/patient_entity.dart';
import 'package:patient_management_app/domain/entities/appointment_entity.dart';
import 'package:patient_management_app/domain/entities/medical_record_entity.dart';

abstract class PatientRepository {
  Future<List<PatientEntity>> getPatients({String? search, int page = 1, int pageSize = 20});
  Future<PatientEntity> getPatientById(String id);
  Future<PatientEntity> createPatient(PatientEntity patient);
  Future<PatientEntity> updatePatient(PatientEntity patient);
  Future<bool> deletePatient(String id);
  Future<List<AppointmentEntity>> getPatientAppointments(String id);
  Future<List<MedicalRecordEntity>> getPatientMedicalRecords(String id);
  Future<PatientEntity> getMyProfile();
}
