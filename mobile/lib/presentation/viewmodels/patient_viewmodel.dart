import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/domain/entities/patient_entity.dart';
import 'package:patient_management_app/domain/repositories/patient_repository.dart';

class PatientState {
  final List<PatientEntity> patients;
  final bool isLoading;
  final bool isSearching;
  final bool isLoadingMore;
  final String? error;
  final String searchQuery;
  final int currentPage;
  final bool hasMore;

  PatientState({
    this.patients = const [],
    this.isLoading = false,
    this.isSearching = false,
    this.isLoadingMore = false,
    this.error,
    this.searchQuery = '',
    this.currentPage = 1,
    this.hasMore = true,
  });

  PatientState copyWith({
    List<PatientEntity>? patients,
    bool? isLoading,
    bool? isSearching,
    bool? isLoadingMore,
    String? error,
    String? searchQuery,
    int? currentPage,
    bool? hasMore,
  }) {
    return PatientState(
      patients: patients ?? this.patients,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class PatientViewModel extends StateNotifier<PatientState> {
  final PatientRepository _patientRepository;

  PatientViewModel(this._patientRepository) : super(PatientState());

  Future<void> fetchPatients({bool isRefresh = true}) async {
    try {
      if (isRefresh) {
        state = state.copyWith(isLoading: true, error: null, currentPage: 1, hasMore: true);
      } else {
        if (!state.hasMore || state.isLoadingMore) return;
        state = state.copyWith(isLoadingMore: true);
      }

      final page = isRefresh ? 1 : state.currentPage + 1;
      final patients = await _patientRepository.getPatients(
        search: state.searchQuery,
        page: page,
      );

      if (isRefresh) {
        state = state.copyWith(
          patients: patients,
          isLoading: false,
          currentPage: page,
          hasMore: patients.length >= 20,
        );
      } else {
        state = state.copyWith(
          patients: [...state.patients, ...patients],
          isLoadingMore: false,
          currentPage: page,
          hasMore: patients.length >= 20,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch patients: ${e.toString()}',
        isLoading: false,
        isLoadingMore: false,
      );
    }
  }

  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query);
    // Debounce search could be added here or in the UI
    fetchPatients(isRefresh: true);
  }

  Future<bool> createPatient(PatientEntity patient) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _patientRepository.createPatient(patient);
      await fetchPatients(); // Refresh list
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to add patient: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  Future<void> updatePatient(PatientEntity patient) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _patientRepository.updatePatient(patient);
      await fetchPatients(); // Refresh list
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update patient: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> deletePatient(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _patientRepository.deletePatient(id);
      await fetchPatients(); // Refresh list
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete patient: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
