import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/domain/entities/user_entity.dart';
import 'package:patient_management_app/domain/repositories/user_repository.dart';
import 'package:patient_management_app/presentation/providers/user_provider.dart';

class UserState {
  final List<UserEntity> users;
  final bool isLoading;
  final String? error;

  UserState({
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    List<UserEntity>? users,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserViewModel extends StateNotifier<UserState> {
  final UserRepository _userRepository;

  UserViewModel(this._userRepository) : super(UserState());

  Future<void> fetchUsers() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final users = await _userRepository.getAllUsers();
      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      final success = await _userRepository.toggleUserStatus(userId, isActive);
      if (success) {
        await fetchUsers();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final userViewModelProvider = StateNotifierProvider<UserViewModel, UserState>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserViewModel(repository);
});
