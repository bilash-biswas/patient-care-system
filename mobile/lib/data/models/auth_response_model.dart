// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:patient_management_app/data/models/user_model.dart';
import 'package:patient_management_app/domain/entities/user_entity.dart';

part 'auth_response_model.freezed.dart';

@freezed
class AuthResponseModel with _$AuthResponseModel {
  const AuthResponseModel._();

  const factory AuthResponseModel({
    required UserModel user,
    required String token,
    @JsonKey(name: 'tokenExpires') required DateTime tokenExpires,
    @JsonKey(name: 'refreshToken') required String refreshToken,
    @JsonKey(name: 'refreshTokenExpires') required DateTime refreshTokenExpires,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json),
      token: json['token'] as String? ?? '',
      tokenExpires: json['tokenExpires'] != null 
          ? DateTime.parse(json['tokenExpires'] as String) 
          : DateTime.now(),
      refreshToken: json['refreshToken'] as String? ?? '',
      refreshTokenExpires: json['refreshTokenExpires'] != null 
          ? DateTime.parse(json['refreshTokenExpires'] as String) 
          : DateTime.now(),
    );
  }

  AuthResponseEntity toEntity() {
    return AuthResponseEntity(
      user: user.toEntity(),
      token: token,
      tokenExpires: tokenExpires,
      refreshToken: refreshToken,
      refreshTokenExpires: refreshTokenExpires,
    );
  }
}
