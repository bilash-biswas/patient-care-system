import 'package:patient_management_app/data/datasources/remote/admin_remote_data_source.dart';
import 'package:patient_management_app/domain/entities/user_entity.dart';
import 'package:patient_management_app/domain/entities/admin_stats_entity.dart';
import 'package:patient_management_app/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final AdminRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<UserEntity>> getAllUsers({String? role}) async {
    final users = await remoteDataSource.getAllUsers(role: role);
    return users.map((u) => u.toEntity()).toList();
  }

  @override
  Future<bool> toggleUserStatus(String userId, bool isActive) async {
    return await remoteDataSource.toggleUserStatus(userId, isActive);
  }

  @override
  Future<AdminStatsEntity> getDashboardStats() async {
    final stats = await remoteDataSource.getDashboardStats();
    return stats.toEntity();
  }
}

