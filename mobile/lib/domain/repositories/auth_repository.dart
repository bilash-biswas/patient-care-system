import 'package:patient_management_app/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthResponseEntity> login(String email, String password);
  Future<AuthResponseEntity> register(RegisterEntity registerEntity);
  Future<AuthResponseEntity> refreshToken(String token, String refreshToken);
  Future<bool> logout();
  Future<UserEntity?> getCurrentUser();
  Future<bool> isAuthenticated();
  Future<void> saveTokens(String token, String refreshToken);
  Future<void> clearTokens();
}
