import 'package:patient_management_app/core/network/network_info.dart';
import 'package:patient_management_app/data/datasources/remote/patient_remote_data_source.dart';
import 'package:patient_management_app/domain/entities/patient_entity.dart';
import 'package:patient_management_app/domain/entities/appointment_entity.dart';
import 'package:patient_management_app/domain/entities/medical_record_entity.dart';
import 'package:patient_management_app/domain/repositories/patient_repository.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PatientRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<PatientEntity>> getPatients({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final models = await remoteDataSource.getPatients(
      search: search,
      page: page,
      pageSize: pageSize,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<PatientEntity> getPatientById(String id) async {
    final model = await remoteDataSource.getPatientById(id);
    return model.toEntity();
  }

  @override
  Future<PatientEntity> createPatient(PatientEntity patient) async {
    final patientData = {
      'firstName': patient.firstName,
      'lastName': patient.lastName,
      'gender': patient.gender,
      'dateOfBirth': patient.dateOfBirth.toIso8601String(),
      'bloodGroup': patient.bloodGroup,
      'address': patient.address,
      'emergencyContactName': patient.emergencyContactName,
      'emergencyContactPhone': patient.emergencyContactPhone,
      'insuranceProvider': patient.insuranceProvider,
      'insurancePolicyNumber': patient.insurancePolicyNumber,
    };
    final result = await remoteDataSource.createPatient(patientData);
    return result.toEntity();
  }

  @override
  Future<PatientEntity> updatePatient(PatientEntity patient) async {
    final patientData = {
      'firstName': patient.firstName,
      'lastName': patient.lastName,
      'gender': patient.gender,
      'dateOfBirth': patient.dateOfBirth.toIso8601String(),
      'bloodGroup': patient.bloodGroup,
      'address': patient.address,
      'emergencyContactName': patient.emergencyContactName,
      'emergencyContactPhone': patient.emergencyContactPhone,
      'insuranceProvider': patient.insuranceProvider,
      'insurancePolicyNumber': patient.insurancePolicyNumber,
    };
    final result = await remoteDataSource.updatePatient(
      patient.id,
      patientData,
    );
    return result.toEntity();
  }

  @override
  Future<bool> deletePatient(String id) async {
    return await remoteDataSource.deletePatient(id);
  }

  @override
  Future<List<AppointmentEntity>> getPatientAppointments(String id) async {
    final models = await remoteDataSource.getPatientAppointments(id);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<MedicalRecordEntity>> getPatientMedicalRecords(String id) async {
    final models = await remoteDataSource.getPatientMedicalRecords(id);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<PatientEntity> getMyProfile() async {
    final model = await remoteDataSource.getMyProfile();
    return model.toEntity();
  }
}
