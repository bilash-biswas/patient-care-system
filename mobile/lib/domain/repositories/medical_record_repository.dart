import 'package:patient_management_app/domain/entities/medical_record_entity.dart';

abstract class MedicalRecordRepository {
  Future<List<MedicalRecordEntity>> getMedicalRecords({String? patientId});
  Future<MedicalRecordEntity> getMedicalRecordById(String id);
  Future<MedicalRecordEntity> createMedicalRecord(MedicalRecordEntity record);
  Future<MedicalRecordEntity> updateMedicalRecord(String id, MedicalRecordEntity record);
  Future<bool> deleteMedicalRecord(String id);
}
