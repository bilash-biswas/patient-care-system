import 'package:patient_management_app/data/datasources/remote/medical_record_remote_data_source.dart';
import 'package:patient_management_app/domain/entities/medical_record_entity.dart';
import 'package:patient_management_app/domain/repositories/medical_record_repository.dart';

class MedicalRecordRepositoryImpl implements MedicalRecordRepository {
  final MedicalRecordRemoteDataSource remoteDataSource;

  MedicalRecordRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MedicalRecordEntity>> getMedicalRecords({
    String? patientId,
  }) async {
    final models = await remoteDataSource.getMedicalRecords(
      patientId: patientId,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<MedicalRecordEntity> getMedicalRecordById(String id) async {
    final model = await remoteDataSource.getMedicalRecordById(id);
    return model.toEntity();
  }

  @override
  Future<MedicalRecordEntity> createMedicalRecord(
    MedicalRecordEntity record,
  ) async {
    // Note: The model to JSON might need adjustment if fields like createdAt are internal to backend
    // But for now, we follow the pattern
    final data = {
      'patientId': record.patientId,
      'doctorId': record.doctorId,
      'diagnosis': record.diagnosis,
      'symptoms': record.symptoms,
      'treatment': record.treatment,
      'prescription': record.prescription,
      'notes': record.notes,
      'visitDate': record.visitDate.toIso8601String(),
      'nextVisitDate': record.nextVisitDate?.toIso8601String(),
      'recordType': record.recordType,
    };
    final result = await remoteDataSource.createMedicalRecord(data);
    return result.toEntity();
  }

  @override
  Future<MedicalRecordEntity> updateMedicalRecord(
    String id,
    MedicalRecordEntity record,
  ) async {
    final data = {
      'patientId': record.patientId,
      'doctorId': record.doctorId,
      'diagnosis': record.diagnosis,
      'symptoms': record.symptoms,
      'treatment': record.treatment,
      'prescription': record.prescription,
      'notes': record.notes,
      'visitDate': record.visitDate.toIso8601String(),
      'nextVisitDate': record.nextVisitDate?.toIso8601String(),
      'recordType': record.recordType,
    };
    final result = await remoteDataSource.updateMedicalRecord(id, data);
    return result.toEntity();
  }

  @override
  Future<bool> deleteMedicalRecord(String id) async {
    return await remoteDataSource.deleteMedicalRecord(id);
  }
}
