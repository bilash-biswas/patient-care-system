import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/domain/entities/user_entity.dart';
import 'package:patient_management_app/presentation/providers/user_provider.dart';

final doctorsProvider = FutureProvider<List<UserEntity>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getAllUsers(role: 'Doctor');
});

final nursesProvider = FutureProvider<List<UserEntity>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getAllUsers(role: 'Nurse');
});
