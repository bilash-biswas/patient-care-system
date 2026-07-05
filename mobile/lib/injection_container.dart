import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:patient_management_app/core/network/dio_client.dart';
import 'package:patient_management_app/core/network/network_info.dart';
import 'package:patient_management_app/data/datasources/local/shared_prefs.dart';
import 'package:patient_management_app/data/datasources/remote/auth_remote_data_source.dart';
import 'package:patient_management_app/data/datasources/remote/patient_remote_data_source.dart';
import 'package:patient_management_app/data/repositories/auth_repository_impl.dart';
import 'package:patient_management_app/data/repositories/patient_repository_impl.dart';
import 'package:patient_management_app/domain/repositories/auth_repository.dart';
import 'package:patient_management_app/domain/repositories/patient_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:patient_management_app/data/datasources/remote/appointment_remote_data_source.dart';
import 'package:patient_management_app/data/datasources/remote/medical_record_remote_data_source.dart';
import 'package:patient_management_app/data/repositories/appointment_repository_impl.dart';
import 'package:patient_management_app/data/repositories/medical_record_repository_impl.dart';
import 'package:patient_management_app/domain/repositories/appointment_repository.dart';
import 'package:patient_management_app/domain/repositories/medical_record_repository.dart';
import 'package:patient_management_app/data/datasources/remote/admin_remote_data_source.dart';
import 'package:patient_management_app/data/repositories/user_repository_impl.dart';
import 'package:patient_management_app/domain/repositories/user_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Dio());

  // Core
  sl.registerLazySingleton(() => InternetConnectionChecker());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => DioClient());

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<PatientRemoteDataSource>(
    () => PatientRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<AppointmentRemoteDataSource>(
    () => AppointmentRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<MedicalRecordRemoteDataSource>(
    () => MedicalRecordRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<SharedPrefs>(
    () => SharedPrefsImpl(sharedPreferences: sl(), secureStorage: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), sharedPrefs: sl()),
  );
  sl.registerLazySingleton<PatientRepository>(
    () => PatientRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<MedicalRecordRepository>(
    () => MedicalRecordRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
  );
}
