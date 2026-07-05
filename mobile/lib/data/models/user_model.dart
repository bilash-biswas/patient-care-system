// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:patient_management_app/domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';


@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String email,
    required String username,
    @JsonKey(name: 'firstName') required String firstName,
    @JsonKey(name: 'lastName') required String lastName,
    String? phoneNumber,
    required String role,
    @JsonKey(name: 'isActive') required bool isActive,
    @JsonKey(name: 'createdAt') required DateTime createdAt,
    @JsonKey(name: 'updatedAt') DateTime? updatedAt,
    @JsonKey(name: 'lastLogin') DateTime? lastLogin,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      username: username,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      role: role,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLogin: lastLogin,
    );
  }
}
