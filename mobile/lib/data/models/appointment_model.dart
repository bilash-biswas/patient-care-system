import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:patient_management_app/domain/entities/appointment_entity.dart';

part 'appointment_model.freezed.dart';
part 'appointment_model.g.dart';

@freezed
class AppointmentModel with _$AppointmentModel {
  const factory AppointmentModel({
    required String id,
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required String reason,
    required DateTime appointmentDate,
    required String startTime,
    required String endTime,
    required String status,
    String? notes,
    required DateTime createdAt,
  }) = _AppointmentModel;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);

  factory AppointmentModel.fromEntity(AppointmentEntity entity) {
    return AppointmentModel(
      id: entity.id,
      patientId: entity.patientId,
      patientName: entity.patientName,
      doctorId: entity.doctorId,
      doctorName: entity.doctorName,
      reason: entity.reason,
      appointmentDate: entity.appointmentDate,
      startTime:
          '${entity.startTime.hour.toString().padLeft(2, '0')}:${entity.startTime.minute.toString().padLeft(2, '0')}:00',
      endTime:
          '${entity.endTime.hour.toString().padLeft(2, '0')}:${entity.endTime.minute.toString().padLeft(2, '0')}:00',
      status: entity.status,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }

  const AppointmentModel._();

  AppointmentEntity toEntity() {
    final startTimeParts = startTime.split(':');
    final endTimeParts = endTime.split(':');

    return AppointmentEntity(
      id: id,
      patientId: patientId,
      doctorId: doctorId,
      patientName: patientName,
      doctorName: doctorName,
      reason: reason,
      appointmentDate: appointmentDate,
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      status: status,
      notes: notes,
      createdAt: createdAt,
    );
  }
}
