import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:patient_management_app/presentation/providers/auth_provider.dart';
import 'package:patient_management_app/presentation/providers/appointment_provider.dart';
import 'package:patient_management_app/presentation/providers/user_provider.dart';
import 'package:patient_management_app/presentation/providers/notification_provider.dart';
import 'package:patient_management_app/presentation/theme/app_colors.dart';
import 'package:patient_management_app/presentation/theme/app_text_styles.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminStatsViewModelProvider.notifier).fetchStats();
      ref.read(appointmentViewModelProvider.notifier).fetchAppointments();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final appointmentState = ref.watch(appointmentViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get upcoming appointments
    final upcomingAppointments = appointmentState.appointments
        .where((a) => a.status == 'Scheduled')
        .toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(adminStatsViewModelProvider.notifier).fetchStats(force: true);
          await ref.read(appointmentViewModelProvider.notifier).fetchAppointments();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context, user),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildStatsRow(context, ref),
                    const SizedBox(height: 32),
                    _buildUpcomingAppointments(context, upcomingAppointments),
                    const SizedBox(height: 32),
                    _buildQuickActions(context),
                    const SizedBox(height: 40),
                    _buildQuoteSection(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      expandedHeight: 230,
      pinned: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryDark,
      actions: [
        _buildNotificationBell(context),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      AppColors.backgroundDark,
                      AppColors.surfaceDark,
                    ]
                  : [
                      AppColors.secondaryDark,
                      AppColors.primary,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  'System Dashboard',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Welcome back, ${user?.fullName ?? 'Administrator'}",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                _buildUserProfileSummary(context, user),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 8.0),
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
            onPressed: () => context.push('/notifications'),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserProfileSummary(BuildContext context, user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            radius: 20,
            child: Text(
              user?.fullName[0] ?? 'A',
              style: const TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.fullName ?? 'Administrator',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user?.role ?? 'Admin',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(adminStatsViewModelProvider);
    final stats = statsState.stats;

    final patientsCount = stats?.totalPatients.toString() ?? '...';
    final doctorsCount = stats?.totalDoctors.toString() ?? '...';
    final nursesCount = stats?.totalNurses.toString() ?? '...';
    final appointmentsCount = stats?.upcomingAppointments.toString() ?? '...';
    final revenue = stats != null
        ? NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 0).format(stats.totalRevenue)
        : '...';
    final systemHealth = statsState.error == null ? '100%' : '90%';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildStatCard(context, 'Total Patients', patientsCount, Icons.people_outline, Colors.teal),
          _buildStatCard(context, "Active Doctors", doctorsCount, Icons.medical_services_outlined, Colors.indigo),
          _buildStatCard(context, "Active Nurses", nursesCount, Icons.volunteer_activism_outlined, Colors.pink),
          _buildStatCard(context, 'Upcoming Appts', appointmentsCount, Icons.calendar_today, Colors.blue),
          _buildStatCard(context, 'Total Revenue', revenue, Icons.attach_money_outlined, Colors.amber),
          _buildStatCard(context, 'System Health', systemHealth, Icons.speed, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 148,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments(BuildContext context, List appointments) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/appointments'),
              child: const Text('All Activity'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (appointments.isEmpty)
          _buildEmptyState(context, 'No recent activity')
        else
          ...appointments.take(3).map((a) => _buildAppointmentCard(context, a)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 44,
            color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, appointment) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.primaryLight.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.notifications_active_outlined, color: isDark ? AppColors.primaryLight : AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Appointment: ${appointment.patientName}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Scheduled with Dr. ${appointment.doctorName}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat('HH:mm').format(DateTime(2024, 1, 1, appointment.startTime.hour, appointment.startTime.minute)),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.primaryLight : AppColors.primary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Management Tools',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildActionIcon(context, Icons.manage_accounts_outlined, 'Manage Users', () => context.go('/admin/users')),
              _buildActionIcon(context, Icons.medical_services_outlined, 'Doctor Roster', () => context.go('/doctors')),
              _buildActionIcon(context, Icons.healing_outlined, 'Nurse Roster', () => context.go('/nurses')),
              _buildActionIcon(context, Icons.settings_outlined, 'Settings', () {}),
              _buildActionIcon(context, Icons.analytics_outlined, 'Logs', () {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcon(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: isDark ? AppColors.primaryLight : AppColors.primary, size: 24),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 76,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryLight.withValues(alpha: 0.06) : AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.primaryLight.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.shield_outlined, color: isDark ? AppColors.primaryLight : AppColors.primary, size: 28),
          const SizedBox(height: 12),
          Text(
            '"The secret of change is to focus all of your energy, not on fighting the old, but on building the new."',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
