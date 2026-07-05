import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/presentation/theme/app_colors.dart';
import 'package:patient_management_app/presentation/theme/app_text_styles.dart';
import 'package:patient_management_app/presentation/views/chat/chat_room_screen.dart';
import 'package:patient_management_app/presentation/providers/chat_provider.dart';
import 'package:patient_management_app/presentation/providers/auth_provider.dart';
import 'package:patient_management_app/presentation/views/appointment/appointment_screen.dart';

class StaffDetailScreen extends ConsumerWidget {
  final String staffId;
  final Map<String, dynamic>? staffData;

  const StaffDetailScreen({
    super.key,
    required this.staffId,
    this.staffData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final staff = staffData ?? {};
    final String firstName = staff['firstName'] ?? '';
    final String lastName = staff['lastName'] ?? '';
    final String fullName = staff['role'] == 'Doctor' 
        ? 'Dr. $firstName $lastName' 
        : '$firstName $lastName';
    final String role = staff['role'] ?? 'Staff';
    final String email = staff['email'] ?? 'No email';
    final String phone = staff['phoneNumber'] ?? 'Not specified';
    final bool isActive = staff['isActive'] ?? false;
    
    final Color roleColor = role == 'Doctor' ? AppColors.secondary : AppColors.primary;
    final Color textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: role == 'Doctor'
                        ? [AppColors.secondaryDark, AppColors.secondary]
                        : [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: Colors.white,
                          child: Text(
                            firstName.isNotEmpty ? firstName[0] : 'S',
                            style: TextStyle(
                              color: roleColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 36,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fullName,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(context, isActive),
                  const SizedBox(height: 28),
                  Text(
                    'Contact Information',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildInfoTile(
                    context,
                    Icons.email_outlined,
                    'Email Address',
                    email,
                    () {
                      Clipboard.setData(ClipboardData(text: email));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email copied to clipboard')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildInfoTile(
                    context,
                    Icons.phone_outlined,
                    'Phone Number',
                    phone,
                    () {
                      if (phone != 'Not specified') {
                        Clipboard.setData(ClipboardData(text: phone));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Phone number copied to clipboard')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 36),
                  if (role == 'Doctor' && currentUser?.role == 'Patient') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: roleColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => CreateAppointmentDialog(doctorId: staffId),
                          );
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: Text(
                          'Book Appointment',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: roleColor, width: 2),
                          foregroundColor: roleColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          ref.read(chatViewModelProvider.notifier).setActiveContact(staffId);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoomScreen(
                                contactId: staffId,
                                fullName: fullName,
                                role: role,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.message_outlined, color: roleColor),
                        label: Text(
                          'Send Instant Message',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: roleColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        onPressed: () {
                          ref.read(chatViewModelProvider.notifier).setActiveContact(staffId);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoomScreen(
                                contactId: staffId,
                                fullName: fullName,
                                role: role,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.message_outlined),
                        label: Text(
                          'Send Instant Message',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, bool isActive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final borderCol = isDark ? AppColors.borderDark : AppColors.border;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isActive ? AppColors.success : AppColors.textDisabled).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? Icons.check_circle_outline : Icons.error_outline,
              color: isActive ? AppColors.success : AppColors.textDisabled,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? 'Active Duty' : 'Currently Inactive',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isActive ? 'Available for clinical consult' : 'Unavailable at this moment',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final borderCol = isDark ? AppColors.borderDark : AppColors.border;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderCol),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.copy_outlined, size: 16, color: subTextColor),
          ],
        ),
      ),
    );
  }
}
