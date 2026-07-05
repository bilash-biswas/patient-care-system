import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/domain/repositories/appointment_repository.dart';
import 'package:patient_management_app/presentation/viewmodels/appointment_viewmodel.dart';

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  throw UnimplementedError('AppointmentRepository should be overridden');
});

final appointmentViewModelProvider =
    StateNotifierProvider<AppointmentViewModel, AppointmentState>((ref) {
  final repository = ref.watch(appointmentRepositoryProvider);
  return AppointmentViewModel(repository);
});

final appointmentLoadingProvider = Provider<bool>((ref) {
  return ref.watch(appointmentViewModelProvider).isLoading;
});

final appointmentErrorProvider = Provider<String?>((ref) {
  return ref.watch(appointmentViewModelProvider).error;
});
