import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/domain/repositories/user_repository.dart';
import 'package:patient_management_app/presentation/viewmodels/admin_stats_viewmodel.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  throw UnimplementedError('UserRepository should be overridden in main.dart');
});

final adminStatsViewModelProvider = StateNotifierProvider<AdminStatsViewModel, AdminStatsState>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return AdminStatsViewModel(repository);
});

