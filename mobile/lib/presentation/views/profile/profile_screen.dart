import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/presentation/providers/auth_provider.dart';
import 'package:patient_management_app/presentation/providers/theme_provider.dart';
import 'package:patient_management_app/presentation/providers/patient_provider.dart';
import 'package:patient_management_app/domain/entities/patient_entity.dart';
import 'package:patient_management_app/presentation/theme/app_colors.dart';
import 'package:patient_management_app/presentation/theme/app_text_styles.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final myProfileAsync = user?.role == 'Patient' ? ref.watch(myPatientProfileProvider) : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, user, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Details for Patients
                  if (user?.role == 'Patient' && myProfileAsync != null)
                    myProfileAsync.when(
                      data: (profile) => _buildPatientInfoCard(context, profile),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, s) => const SizedBox.shrink(),
                    ),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('Settings'),
                  _buildSettingsCard(context, ref, isDark),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('Account'),
                  _buildAccountCard(context, ref),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('Support'),
                  _buildSupportCard(context),
                  
                  const SizedBox(height: 32),
                  _buildLogoutButton(ref),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, user, bool isDark) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                  child: const Icon(Icons.person, size: 50, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user?.fullName ?? 'User Name',
                style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                user?.email ?? 'email@example.com',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPatientInfoCard(BuildContext context, profile) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem('Age', '${profile.age}'),
            _buildInfoDivider(),
            _buildInfoItem('Blood', profile.bloodGroup ?? 'N/A'),
            _buildInfoDivider(),
            _buildInfoItem('Gender', profile.gender),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildInfoDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.border.withValues(alpha: 0.5),
    );
  }

  Widget _buildSettingsCard(BuildContext context, WidgetRef ref, bool isDark) {
    return _buildListCard([
      _buildListTile(
        icon: isDark ? Icons.dark_mode : Icons.light_mode,
        title: 'Dark Mode',
        trailing: Switch.adaptive(
          value: isDark,
          activeColor: AppColors.primary,
          onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
        ),
      ),
      _buildListTile(
        icon: Icons.notifications_none_rounded,
        title: 'Notifications',
        onTap: () => context.push('/notifications'),
      ),
      _buildListTile(
        icon: Icons.language_rounded,
        title: 'Language',
        trailing: const Text('English', style: TextStyle(color: AppColors.textSecondary)),
        onTap: () {},
      ),
    ]);
  }

  Widget _buildAccountCard(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final myProfileAsync = user?.role == 'Patient' ? ref.watch(myPatientProfileProvider) : null;

    return _buildListCard([
      _buildListTile(
        icon: Icons.person_outline_rounded,
        title: 'Edit Profile',
        onTap: () {
          if (user?.role == 'Patient' && myProfileAsync != null) {
            myProfileAsync.when(
              data: (profile) => _showEditProfileBottomSheet(context, ref, profile),
              loading: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Loading profile data...')),
              ),
              error: (e, s) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading profile: $e')),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile editing for staff is managed by system administration.')),
            );
          }
        },
      ),
      _buildListTile(
        icon: Icons.lock_outline_rounded,
        title: 'Change Password',
        onTap: () {},
      ),
      _buildListTile(
        icon: Icons.security_rounded,
        title: 'Privacy & Security',
        onTap: () {},
      ),
    ]);
  }

  void _showEditProfileBottomSheet(BuildContext context, WidgetRef ref, PatientEntity profile) {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController(text: profile.firstName);
    final lastNameController = TextEditingController(text: profile.lastName);
    final addressController = TextEditingController(text: profile.address ?? '');
    final bloodGroupController = TextEditingController(text: profile.bloodGroup ?? '');
    final emergencyNameController = TextEditingController(text: profile.emergencyContactName ?? '');
    final emergencyPhoneController = TextEditingController(text: profile.emergencyContactPhone ?? '');
    final insuranceProviderController = TextEditingController(text: profile.insuranceProvider ?? '');
    final insurancePolicyController = TextEditingController(text: profile.insurancePolicyNumber ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Edit Profile', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: firstNameController,
                          decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: lastNameController,
                          decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: bloodGroupController,
                          decoration: const InputDecoration(labelText: 'Blood Group', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: insuranceProviderController,
                          decoration: const InputDecoration(labelText: 'Insurance Provider', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: insurancePolicyController,
                    decoration: const InputDecoration(labelText: 'Insurance Policy Number', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: emergencyNameController,
                          decoration: const InputDecoration(labelText: 'Emergency Contact Name', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: emergencyPhoneController,
                          decoration: const InputDecoration(labelText: 'Emergency Contact Phone', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          final updated = profile.copyWith(
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            address: addressController.text,
                            bloodGroup: bloodGroupController.text,
                            emergencyContactName: emergencyNameController.text,
                            emergencyContactPhone: emergencyPhoneController.text,
                            insuranceProvider: insuranceProviderController.text,
                            insurancePolicyNumber: insurancePolicyController.text,
                            updatedAt: DateTime.now(),
                          );
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          await ref.read(patientViewModelProvider.notifier).updatePatient(updated);
                          ref.invalidate(myPatientProfileProvider);
                          navigator.pop();
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return _buildListCard([
      _buildListTile(
        icon: Icons.help_outline_rounded,
        title: 'Help Center',
        onTap: () {},
      ),
      _buildListTile(
        icon: Icons.info_outline_rounded,
        title: 'About App',
        onTap: () {},
      ),
    ]);
  }

  Widget _buildListCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.bodyLarge),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => ref.read(authViewModelProvider.notifier).logout(),
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
