import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patient_management_app/presentation/providers/auth_provider.dart';
import 'package:patient_management_app/presentation/views/auth/login_screen.dart';
import 'package:patient_management_app/presentation/views/auth/register_screen.dart';
import 'package:patient_management_app/domain/entities/user_entity.dart';
import 'package:patient_management_app/presentation/views/home/admin_home_screen.dart';
import 'package:patient_management_app/presentation/views/home/patient_home_screen.dart';
import 'package:patient_management_app/presentation/views/home/doctor_home_screen.dart';
import 'package:patient_management_app/presentation/views/home/nurse_home_screen.dart';
import 'package:patient_management_app/presentation/views/patient/patient_list_screen.dart';
import 'package:patient_management_app/presentation/views/patient/patient_detail_screen.dart';
import 'package:patient_management_app/presentation/views/patient/add_patient_screen.dart';
import 'package:patient_management_app/presentation/views/user/user_list_screen.dart';
import 'package:patient_management_app/presentation/views/appointment/appointment_screen.dart';
import 'package:patient_management_app/presentation/views/medical/medical_records_screen.dart';
import 'package:patient_management_app/domain/entities/patient_entity.dart';
import 'package:patient_management_app/presentation/views/splash/splash_screen.dart';
import 'package:patient_management_app/presentation/views/onboarding/onboarding_screen.dart';
import 'package:patient_management_app/presentation/views/main_navigation_screen.dart';
import 'package:patient_management_app/presentation/views/profile/profile_screen.dart';
import 'package:patient_management_app/presentation/views/chat/chat_list_screen.dart';
import 'package:patient_management_app/presentation/views/nurse/nurse_list_screen.dart';
import 'package:patient_management_app/presentation/views/notification/notification_list_screen.dart';
import 'package:patient_management_app/presentation/views/doctor/doctor_list_screen.dart';
import 'package:patient_management_app/presentation/views/staff/staff_detail_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorDoctorsKey = GlobalKey<NavigatorState>(debugLabel: 'doctors');
final _shellNavigatorPatientsKey = GlobalKey<NavigatorState>(debugLabel: 'patients');
final _shellNavigatorAppointmentsKey = GlobalKey<NavigatorState>(debugLabel: 'appointments');
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');
final _shellNavigatorChatKey = GlobalKey<NavigatorState>(debugLabel: 'chat');

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isGoingToAuth =
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register');
      final isSplash = state.matchedLocation == '/splash';
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (isSplash || isOnboarding) return null;

      if (!isAuthenticated && !isGoingToAuth) {
        return '/login';
      }

      if (isAuthenticated && isGoingToAuth) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => _getHomeRouteBasedOnRole(ref.read(currentUserProvider)),
      ),
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      
      // Auth routes
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationListScreen(),
      ),
      GoRoute(
        path: '/staff/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final staffId = state.pathParameters['id']!;
          final staffData = state.extra as Map<String, dynamic>?;
          return StaffDetailScreen(staffId: staffId, staffData: staffData);
        },
      ),

      // Main Shell Route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationScreen(navigationShell: navigationShell);
        },
        branches: [
          // Home Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/admin',
                builder: (context, state) => const AdminHomeScreen(),
                routes: [
                  GoRoute(
                    path: 'users',
                    builder: (context, state) => const UserListScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: '/doctor',
                builder: (context, state) => const DoctorHomeScreen(),
              ),
              GoRoute(
                path: '/nurse',
                builder: (context, state) => const NurseHomeScreen(),
              ),
              GoRoute(
                path: '/patient',
                builder: (context, state) => const PatientHomeScreen(),
              ),
              GoRoute(
                path: '/nurses',
                builder: (context, state) => const NurseListScreen(),
              ),
            ],
          ),
          // Doctors Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDoctorsKey,
            routes: [
              GoRoute(
                path: '/doctors',
                builder: (context, state) => const DoctorListScreen(),
              ),
            ],
          ),
          // Patients/Records Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorPatientsKey,
            routes: [
              GoRoute(
                path: '/patients',
                builder: (context, state) => const PatientListScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddPatientScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      final patient = state.extra as PatientEntity?;
                      return PatientDetailScreen(patientId: id, patient: patient);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: '/medical-records',
                builder: (context, state) {
                  final user = ref.read(currentUserProvider);
                  final patientId = state.uri.queryParameters['patientId'] ?? (user?.role == 'Patient' ? user?.id : null);
                  return MedicalRecordsScreen(patientId: patientId);
                },
              ),
            ],
          ),
          // Appointments Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorAppointmentsKey,
            routes: [
              GoRoute(
                path: '/appointments',
                builder: (context, state) => const AppointmentScreen(),
              ),
            ],
          ),
          // Chat Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorChatKey,
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatListScreen(),
              ),
            ],
          ),
          // Profile Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

String _getHomeRouteBasedOnRole(UserEntity? user) {
  if (user == null) return '/login';

  switch (user.role) {
    case 'Admin':
      return '/admin';
    case 'Doctor':
      return '/doctor';
    case 'Nurse':
      return '/nurse';
    case 'Patient':
      return '/patient';
    default:
      return '/login';
  }
}
