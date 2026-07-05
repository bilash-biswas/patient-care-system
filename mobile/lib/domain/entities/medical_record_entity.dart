import 'package:equatable/equatable.dart';

class MedicalRecordEntity extends Equatable {
  final String id;
  final String patientId;
  final String? doctorId;
  final String patientName;
  final String? doctorName;
  final String diagnosis;
  final String symptoms;
  final String treatment;
  final String? prescription;
  final String? notes;
  final DateTime visitDate;
  final DateTime? nextVisitDate;
  final String? recordType;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MedicalRecordEntity({
    required this.id,
    required this.patientId,
    this.doctorId,
    required this.patientName,
    this.doctorName,
    required this.diagnosis,
    required this.symptoms,
    required this.treatment,
    this.prescription,
    this.notes,
    required this.visitDate,
    this.nextVisitDate,
    this.recordType,
    required this.createdAt,
    this.updatedAt,
  });

  String get formattedVisitDate {
    return '${visitDate.day}/${visitDate.month}/${visitDate.year}';
  }

  String? get formattedNextVisitDate {
    return nextVisitDate != null
        ? '${nextVisitDate!.day}/${nextVisitDate!.month}/${nextVisitDate!.year}'
        : null;
  }

  @override
  List<Object?> get props => [
    id,
    patientId,
    doctorId,
    patientName,
    doctorName,
    diagnosis,
    symptoms,
    treatment,
    prescription,
    notes,
    visitDate,
    nextVisitDate,
    recordType,
    createdAt,
    updatedAt,
  ];

  MedicalRecordEntity copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? patientName,
    String? doctorName,
    String? diagnosis,
    String? symptoms,
    String? treatment,
    String? prescription,
    String? notes,
    DateTime? visitDate,
    DateTime? nextVisitDate,
    String? recordType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicalRecordEntity(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      diagnosis: diagnosis ?? this.diagnosis,
      symptoms: symptoms ?? this.symptoms,
      treatment: treatment ?? this.treatment,
      prescription: prescription ?? this.prescription,
      notes: notes ?? this.notes,
      visitDate: visitDate ?? this.visitDate,
      nextVisitDate: nextVisitDate ?? this.nextVisitDate,
      recordType: recordType ?? this.recordType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
