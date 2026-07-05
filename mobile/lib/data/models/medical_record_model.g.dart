// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MedicalRecordModelImpl _$$MedicalRecordModelImplFromJson(
  Map<String, dynamic> json,
) => _$MedicalRecordModelImpl(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  patientName: json['patientName'] as String,
  doctorId: json['doctorId'] as String?,
  doctorName: json['doctorName'] as String?,
  diagnosis: json['diagnosis'] as String,
  symptoms: json['symptoms'] as String,
  treatment: json['treatment'] as String,
  prescription: json['prescription'] as String?,
  notes: json['notes'] as String?,
  visitDate: DateTime.parse(json['visitDate'] as String),
  nextVisitDate: json['nextVisitDate'] == null
      ? null
      : DateTime.parse(json['nextVisitDate'] as String),
  recordType: json['recordType'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$MedicalRecordModelImplToJson(
  _$MedicalRecordModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'patientName': instance.patientName,
  'doctorId': instance.doctorId,
  'doctorName': instance.doctorName,
  'diagnosis': instance.diagnosis,
  'symptoms': instance.symptoms,
  'treatment': instance.treatment,
  'prescription': instance.prescription,
  'notes': instance.notes,
  'visitDate': instance.visitDate.toIso8601String(),
  'nextVisitDate': instance.nextVisitDate?.toIso8601String(),
  'recordType': instance.recordType,
  'createdAt': instance.createdAt.toIso8601String(),
};
