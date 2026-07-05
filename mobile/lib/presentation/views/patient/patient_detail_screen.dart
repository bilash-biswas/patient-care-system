import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:patient_management_app/domain/entities/patient_entity.dart';
import 'package:patient_management_app/presentation/providers/patient_provider.dart';
import 'package:patient_management_app/presentation/theme/app_colors.dart';
import 'package:patient_management_app/presentation/theme/app_text_styles.dart';
import 'package:patient_management_app/presentation/views/chat/chat_room_screen.dart';
import 'package:patient_management_app/presentation/providers/chat_provider.dart';

class PatientDetailScreen extends ConsumerStatefulWidget {
  final String patientId;
  final PatientEntity? patient;

  const PatientDetailScreen({
    super.key,
    required this.patientId,
    this.patient,
  });

  @override
  ConsumerState<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends ConsumerState<PatientDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PatientEntity? patient = widget.patient;

    if (patient == null) {
      final state = ref.watch(patientViewModelProvider);
      try {
        patient = state.patients.firstWhere((p) => p.id == widget.patientId);
      } catch (e) {
        return const Scaffold(
          body: Center(child: Text('Patient not found')),
        );
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Patient Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context, patient),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Personal Information',
              children: [
                _buildInfoRow(context, 'Full Name', patient.fullName),
                _buildInfoRow(context, 'Gender', patient.gender),
                _buildInfoRow(context, 'Date of Birth', DateFormat('MMM dd, yyyy').format(patient.dateOfBirth)),
                _buildInfoRow(context, 'Age', '${patient.age} years'),
                _buildInfoRow(context, 'Blood Group', patient.bloodGroup ?? 'N/A'),
                _buildInfoRow(context, 'Address', patient.address ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Emergency Contact',
              children: [
                _buildInfoRow(context, 'Name', patient.emergencyContactName ?? 'N/A'),
                _buildInfoRow(context, 'Phone', patient.emergencyContactPhone ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Insurance Details',
              children: [
                _buildInfoRow(context, 'Provider', patient.insuranceProvider ?? 'N/A'),
                _buildInfoRow(context, 'Policy Number', patient.insurancePolicyNumber ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(chatViewModelProvider.notifier).setActiveContact(patient!.userId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatRoomScreen(
                        contactId: patient!.userId,
                        fullName: patient.fullName,
                        role: 'Patient',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.message_outlined, color: Colors.white, size: 20),
                label: const Text('Send Message', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push('/appointments');
                    },
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text('Appointments', style: TextStyle(fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push('/medical-records?patientId=${patient!.id}');
                    },
                    icon: const Icon(Icons.medical_services, size: 18),
                    label: const Text('Records', style: TextStyle(fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, PatientEntity patient) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                (patient.firstName.isNotEmpty ? patient.firstName[0] : '') +
                    (patient.lastName.isNotEmpty ? patient.lastName[0] : ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.fullName,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  patient.id.length > 8 ? 'ID: ${patient.id.substring(0, 8)}...' : 'ID: ${patient.id}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            color: isDark ? AppColors.borderDark : AppColors.border,
            thickness: 1,
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
