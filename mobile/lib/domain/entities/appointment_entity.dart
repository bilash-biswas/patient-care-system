import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class AppointmentEntity extends Equatable {
  final String id;
  final String patientId;
  final String doctorId;
  final String patientName;
  final String doctorName;
  final String reason;
  final DateTime appointmentDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AppointmentEntity({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    required this.reason,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  String get formattedDate {
    return '${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}';
  }

  String get formattedTime {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  bool get isUpcoming => status == 'Scheduled';
  bool get isCompleted => status == 'Completed';
  bool get isCancelled => status == 'Cancelled';

  @override
  List<Object?> get props => [
    id,
    patientId,
    doctorId,
    patientName,
    doctorName,
    reason,
    appointmentDate,
    startTime,
    endTime,
    status,
    notes,
    createdAt,
    updatedAt,
  ];

  AppointmentEntity copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? patientName,
    String? doctorName,
    String? reason,
    DateTime? appointmentDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentEntity(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      reason: reason ?? this.reason,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CreateAppointmentEntity {
  final String patientId;
  final String doctorId;
  final String reason;
  final DateTime appointmentDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? notes;

  CreateAppointmentEntity({
    required this.patientId,
    required this.doctorId,
    required this.reason,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'patientId': patientId,
    'doctorId': doctorId,
    'reason': reason,
    'appointmentDate': appointmentDate.toIso8601String(),
    'startTime':
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00',
    'endTime':
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00',
    if (notes != null) 'notes': notes,
  };
}
