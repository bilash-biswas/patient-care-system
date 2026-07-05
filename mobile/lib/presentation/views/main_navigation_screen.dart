import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patient_management_app/presentation/providers/auth_provider.dart';
import 'package:patient_management_app/presentation/theme/app_colors.dart';

class MainNavigationScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isPatient = user?.role == 'Patient';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navTheme = Theme.of(context).bottomNavigationBarTheme;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTap(context, ref, index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: navTheme.backgroundColor,
          selectedItemColor: navTheme.selectedItemColor,
          unselectedItemColor: navTheme.unselectedItemColor,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: -0.2),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11, letterSpacing: -0.2),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.dashboard_outlined, size: 22),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.dashboard, size: 22),
              ),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.medical_services_outlined, size: 22),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.medical_services, size: 22),
              ),
              label: 'Doctors',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(isPatient ? Icons.history_outlined : Icons.people_outline, size: 22),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(isPatient ? Icons.history : Icons.people, size: 22),
              ),
              label: isPatient ? 'Records' : 'Patients',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.calendar_today_outlined, size: 22),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.calendar_today, size: 22),
              ),
              label: 'Appointments',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.chat_outlined, size: 22),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.chat, size: 22),
              ),
              label: 'Chat',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_outline, size: 22),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person, size: 22),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref, int index) {
    if (index == 2) {
      final user = ref.read(currentUserProvider);
      if (user?.role == 'Patient') {
        context.go('/medical-records');
        return;
      } else {
        context.go('/patients');
        return;
      }
    }
    
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
