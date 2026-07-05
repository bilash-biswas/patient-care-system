import 'package:equatable/equatable.dart';

class PatientEntity extends Equatable {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String gender;
  final DateTime dateOfBirth;
  final String? bloodGroup;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? insuranceProvider;
  final String? insurancePolicyNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PatientEntity({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    this.bloodGroup,
    this.address,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.insuranceProvider,
    this.insurancePolicyNumber,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    firstName,
    lastName,
    gender,
    dateOfBirth,
    bloodGroup,
    address,
    emergencyContactName,
    emergencyContactPhone,
    insuranceProvider,
    insurancePolicyNumber,
    createdAt,
    updatedAt,
  ];

  PatientEntity copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? gender,
    DateTime? dateOfBirth,
    String? bloodGroup,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      address: address ?? this.address,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insurancePolicyNumber:
          insurancePolicyNumber ?? this.insurancePolicyNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
