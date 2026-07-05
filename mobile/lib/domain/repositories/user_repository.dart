import 'package:patient_management_app/domain/entities/user_entity.dart';
import 'package:patient_management_app/domain/entities/admin_stats_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getAllUsers({String? role});
  Future<bool> toggleUserStatus(String userId, bool isActive);
  Future<AdminStatsEntity> getDashboardStats();
}

