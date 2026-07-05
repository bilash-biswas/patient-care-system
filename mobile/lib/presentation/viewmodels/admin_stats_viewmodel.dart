import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/domain/entities/admin_stats_entity.dart';
import 'package:patient_management_app/domain/repositories/user_repository.dart';

class AdminStatsState {
  final AdminStatsEntity? stats;
  final bool isLoading;
  final String? error;

  AdminStatsState({
    this.stats,
    this.isLoading = false,
    this.error,
  });

  AdminStatsState copyWith({
    AdminStatsEntity? stats,
    bool? isLoading,
    String? error,
  }) {
    return AdminStatsState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminStatsViewModel extends StateNotifier<AdminStatsState> {
  final UserRepository _userRepository;

  AdminStatsViewModel(this._userRepository) : super(AdminStatsState());

  Future<void> fetchStats({bool force = false}) async {
    if (state.isLoading) return;
    if (state.stats != null && !force) return;

    try {
      state = state.copyWith(isLoading: true, error: null);
      final stats = await _userRepository.getDashboardStats();
      state = state.copyWith(stats: stats, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceAll('Exception: ', ''), isLoading: false);
    }
  }
}
