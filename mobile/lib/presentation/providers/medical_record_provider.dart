import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/domain/repositories/medical_record_repository.dart';
import 'package:patient_management_app/presentation/viewmodels/medical_record_viewmodel.dart';

final medicalRecordRepositoryProvider = Provider<MedicalRecordRepository>((ref) {
  throw UnimplementedError('MedicalRecordRepository should be overridden');
});

final medicalRecordViewModelProvider =
    StateNotifierProvider<MedicalRecordStateNotifier, MedicalRecordState>((ref) {
  final repository = ref.watch(medicalRecordRepositoryProvider);
  return MedicalRecordStateNotifier(repository);
});

final medicalRecordLoadingProvider = Provider<bool>((ref) {
  return ref.watch(medicalRecordViewModelProvider).isLoading;
});

final medicalRecordErrorProvider = Provider<String?>((ref) {
  return ref.watch(medicalRecordViewModelProvider).error;
});
