import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/domain/entities/appointment_entity.dart';
import 'package:patient_management_app/domain/repositories/appointment_repository.dart';

class AppointmentState {
  final List<AppointmentEntity> appointments;
  final bool isLoading;
  final String? error;

  AppointmentState({
    this.appointments = const [],
    this.isLoading = false,
    this.error,
  });

  AppointmentState copyWith({
    List<AppointmentEntity>? appointments,
    bool? isLoading,
    String? error,
  }) {
    return AppointmentState(
      appointments: appointments ?? this.appointments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AppointmentViewModel extends StateNotifier<AppointmentState> {
  final AppointmentRepository _appointmentRepository;

  AppointmentViewModel(this._appointmentRepository) : super(AppointmentState());

  Future<void> fetchAppointments() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final appointments = await _appointmentRepository.getAppointments();
      state = state.copyWith(appointments: appointments, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch appointments: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> createAppointment(CreateAppointmentEntity appointment) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _appointmentRepository.createAppointment(appointment);
      await fetchAppointments();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create appointment: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _appointmentRepository.updateAppointmentStatus(id, status);
      await fetchAppointments();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update status: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> deleteAppointment(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _appointmentRepository.deleteAppointment(id);
      // I should fix the repository method name if I made a mistake
      await fetchAppointments();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete appointment: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
