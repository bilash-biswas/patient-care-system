import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/domain/entities/medical_record_entity.dart';
import 'package:patient_management_app/domain/repositories/medical_record_repository.dart';

class MedicalRecordState {
  final List<MedicalRecordEntity> medicalRecords;
  final bool isLoading;
  final String? error;

  MedicalRecordState({
    this.medicalRecords = const [],
    this.isLoading = false,
    this.error,
  });

  MedicalRecordState copyWith({
    List<MedicalRecordEntity>? medicalRecords,
    bool? isLoading,
    String? error,
  }) {
    return MedicalRecordState(
      medicalRecords: medicalRecords ?? this.medicalRecords,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MedicalRecordStateNotifier extends StateNotifier<MedicalRecordState> {
  final MedicalRecordRepository _repository;

  MedicalRecordStateNotifier(this._repository) : super(MedicalRecordState());

  Future<void> fetchMedicalRecords({String? patientId}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final records = await _repository.getMedicalRecords(patientId: patientId);
      state = state.copyWith(medicalRecords: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch medical records: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> createMedicalRecord(MedicalRecordEntity record) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.createMedicalRecord(record);
      await fetchMedicalRecords(patientId: record.patientId);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create medical record: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> updateMedicalRecord(String id, MedicalRecordEntity record) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.updateMedicalRecord(id, record);
      await fetchMedicalRecords(patientId: (record.patientId != '') ? record.patientId : null);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update medical record: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> deleteMedicalRecord(String id, {String? patientId}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.deleteMedicalRecord(id);
      await fetchMedicalRecords(patientId: patientId);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete medical record: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
