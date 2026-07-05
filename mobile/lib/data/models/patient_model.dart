import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:patient_management_app/domain/entities/patient_entity.dart';

part 'patient_model.freezed.dart';
part 'patient_model.g.dart';

@freezed
class PatientModel with _$PatientModel {
  const factory PatientModel({
    required String id,
    required String userId,
    required String firstName,
    required String lastName,
    required String gender,
    required DateTime dateOfBirth,
    String? bloodGroup,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _PatientModel;

  factory PatientModel.fromJson(Map<String, dynamic> json) =>
      _$PatientModelFromJson(json);

  factory PatientModel.fromEntity(PatientEntity entity) {
    return PatientModel(
      id: entity.id,
      userId: entity.userId,
      firstName: entity.firstName,
      lastName: entity.lastName,
      gender: entity.gender,
      dateOfBirth: entity.dateOfBirth,
      bloodGroup: entity.bloodGroup,
      address: entity.address,
      emergencyContactName: entity.emergencyContactName,
      emergencyContactPhone: entity.emergencyContactPhone,
      insuranceProvider: entity.insuranceProvider,
      insurancePolicyNumber: entity.insurancePolicyNumber,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  const PatientModel._();

  PatientEntity toEntity() {
    return PatientEntity(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      dateOfBirth: dateOfBirth,
      bloodGroup: bloodGroup,
      address: address,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      insuranceProvider: insuranceProvider,
      insurancePolicyNumber: insurancePolicyNumber,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
