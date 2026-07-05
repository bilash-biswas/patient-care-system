import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/domain/repositories/patient_repository.dart';
import 'package:patient_management_app/presentation/viewmodels/patient_viewmodel.dart';

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  throw UnimplementedError('PatientRepository should be overridden in main.dart');
});

final patientViewModelProvider = StateNotifierProvider<PatientViewModel, PatientState>((ref) {
  final repository = ref.watch(patientRepositoryProvider);
  return PatientViewModel(repository);
});

final patientLoadingProvider = Provider<bool>((ref) {
  return ref.watch(patientViewModelProvider).isLoading;
});

final patientErrorProvider = Provider<String?>((ref) {
  return ref.watch(patientViewModelProvider).error;
});

final myPatientProfileProvider = FutureProvider((ref) async {
  final repository = ref.watch(patientRepositoryProvider);
  return repository.getMyProfile();
});
