// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppointmentModelImpl _$$AppointmentModelImplFromJson(
  Map<String, dynamic> json,
) => _$AppointmentModelImpl(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  patientName: json['patientName'] as String,
  doctorId: json['doctorId'] as String,
  doctorName: json['doctorName'] as String,
  reason: json['reason'] as String,
  appointmentDate: DateTime.parse(json['appointmentDate'] as String),
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
  status: json['status'] as String,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$AppointmentModelImplToJson(
  _$AppointmentModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'patientName': instance.patientName,
  'doctorId': instance.doctorId,
  'doctorName': instance.doctorName,
  'reason': instance.reason,
  'appointmentDate': instance.appointmentDate.toIso8601String(),
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'status': instance.status,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
};
