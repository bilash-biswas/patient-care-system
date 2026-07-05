import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;

  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.lastLogin,
  });

  String get fullName => '$firstName $lastName';

  bool get isAdmin => role == 'Admin';
  bool get isDoctor => role == 'Doctor';
  bool get isNurse => role == 'Nurse';
  bool get isPatient => role == 'Patient';

  @override
  List<Object?> get props => [
    id,
    email,
    username,
    firstName,
    lastName,
    phoneNumber,
    role,
    isActive,
    createdAt,
    updatedAt,
    lastLogin,
  ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

class AuthResponseEntity {
  final UserEntity user;
  final String token;
  final DateTime tokenExpires;
  final String refreshToken;
  final DateTime refreshTokenExpires;

  AuthResponseEntity({
    required this.user,
    required this.token,
    required this.tokenExpires,
    required this.refreshToken,
    required this.refreshTokenExpires,
  });
}

class LoginEntity {
  final String email;
  final String password;

  LoginEntity({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterEntity {
  final String email;
  final String username;
  final String password;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String role;

  RegisterEntity({
    required this.email,
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.role = 'Patient',
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'username': username,
    'password': password,
    'firstName': firstName,
    'lastName': lastName,
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
    'role': role,
  };
}
