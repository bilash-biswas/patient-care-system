import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:patient_management_app/domain/entities/medical_record_entity.dart';

part 'medical_record_model.freezed.dart';
part 'medical_record_model.g.dart';

@freezed
class MedicalRecordModel with _$MedicalRecordModel {
  const factory MedicalRecordModel({
    required String id,
    required String patientId,
    required String patientName,
    String? doctorId,
    String? doctorName,
    required String diagnosis,
    required String symptoms,
    required String treatment,
    String? prescription,
    String? notes,
    required DateTime visitDate,
    DateTime? nextVisitDate,
    String? recordType,
    required DateTime createdAt,
  }) = _MedicalRecordModel;

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) =>
      _$MedicalRecordModelFromJson(json);

  factory MedicalRecordModel.fromEntity(MedicalRecordEntity entity) {
    return MedicalRecordModel(
      id: entity.id,
      patientId: entity.patientId,
      patientName: entity.patientName,
      doctorId: entity.doctorId,
      doctorName: entity.doctorName,
      diagnosis: entity.diagnosis,
      symptoms: entity.symptoms,
      treatment: entity.treatment,
      prescription: entity.prescription,
      notes: entity.notes,
      visitDate: entity.visitDate,
      nextVisitDate: entity.nextVisitDate,
      recordType: entity.recordType,
      createdAt: entity.createdAt,
    );
  }

  const MedicalRecordModel._();

  MedicalRecordEntity toEntity() {
    return MedicalRecordEntity(
      id: id,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      diagnosis: diagnosis,
      symptoms: symptoms,
      treatment: treatment,
      prescription: prescription,
      notes: notes,
      visitDate: visitDate,
      nextVisitDate: nextVisitDate,
      recordType: recordType,
      createdAt: createdAt,
    );
  }
}
