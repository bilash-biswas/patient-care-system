import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/injection_container.dart' as di;
import 'package:patient_management_app/presentation/router/app_router.dart';
import 'package:patient_management_app/domain/repositories/appointment_repository.dart';
import 'package:patient_management_app/domain/repositories/medical_record_repository.dart';
import 'package:patient_management_app/presentation/providers/appointment_provider.dart';
import 'package:patient_management_app/presentation/providers/auth_provider.dart';
import 'package:patient_management_app/presentation/providers/medical_record_provider.dart';
import 'package:patient_management_app/presentation/providers/patient_provider.dart';
import 'package:patient_management_app/domain/repositories/auth_repository.dart';
import 'package:patient_management_app/domain/repositories/patient_repository.dart';
import 'package:patient_management_app/domain/repositories/user_repository.dart';
import 'package:patient_management_app/presentation/providers/user_provider.dart';

import 'package:patient_management_app/presentation/theme/app_theme.dart';
import 'package:patient_management_app/presentation/providers/theme_provider.dart';
import 'package:patient_management_app/presentation/providers/notification_provider.dart';
import 'package:patient_management_app/presentation/providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(di.sl<AuthRepository>()),
        patientRepositoryProvider.overrideWithValue(di.sl<PatientRepository>()),
        appointmentRepositoryProvider.overrideWithValue(di.sl<AppointmentRepository>()),
        medicalRecordRepositoryProvider.overrideWithValue(di.sl<MedicalRecordRepository>()),
        userRepositoryProvider.overrideWithValue(di.sl<UserRepository>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    // Initialize notification and chat listeners globally
    ref.watch(notificationViewModelProvider);
    ref.watch(chatViewModelProvider);

    return MaterialApp.router(
      title: 'Patient Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
