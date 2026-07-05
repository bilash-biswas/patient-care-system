import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/domain/entities/user_entity.dart';
import 'package:patient_management_app/domain/repositories/auth_repository.dart';
import 'package:patient_management_app/presentation/viewmodels/auth_viewmodel.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('AuthRepository should be overridden');
});

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  return AuthViewModel(ref.watch(authRepositoryProvider));
});

final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authViewModelProvider);
});

final currentUserProvider = Provider<UserEntity?>((ref) {
  final state = ref.watch(authViewModelProvider);
  return state.user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final state = ref.watch(authViewModelProvider);
  return state.isAuthenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(authViewModelProvider);
  return state.isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(authViewModelProvider);
  return state.error;
});
