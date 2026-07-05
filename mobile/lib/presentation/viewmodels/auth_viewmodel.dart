import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/core/exceptions/app_exceptions.dart';
import 'package:patient_management_app/domain/entities/user_entity.dart';
import 'package:patient_management_app/domain/repositories/auth_repository.dart';

class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(AuthState()) {
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      state = state.copyWith(isLoading: true);
      final isAuthenticated = await _authRepository.isAuthenticated();

      if (isAuthenticated) {
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(
          user: user,
          isAuthenticated: user != null,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to check authentication',
        isLoading: false,
      );
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final authResponse = await _authRepository.login(email, password);

      state = state.copyWith(
        user: authResponse.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'An unexpected error occurred',
        isLoading: false,
      );
    }
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String role = 'Patient',
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final registerEntity = RegisterEntity(
        email: email,
        username: username,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        role: role,
      );

      final authResponse = await _authRepository.register(registerEntity);

      state = state.copyWith(
        user: authResponse.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'An unexpected error occurred',
        isLoading: false,
      );
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true);
      await _authRepository.logout();
      state = AuthState(isLoading: false);
    } catch (e) {
      state = AuthState(error: 'Failed to logout', isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
