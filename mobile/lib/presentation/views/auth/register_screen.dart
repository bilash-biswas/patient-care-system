import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patient_management_app/core/utils/validators.dart';
import 'package:patient_management_app/presentation/providers/auth_provider.dart';
import 'package:patient_management_app/presentation/theme/app_colors.dart';
import 'package:patient_management_app/presentation/theme/app_text_styles.dart';
import 'package:patient_management_app/presentation/widgets/custom_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedRole = 'Patient';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ref.read(authViewModelProvider.notifier).clearError();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
        return;
      }

      await ref
          .read(authViewModelProvider.notifier)
          .register(
            email: _emailController.text.trim(),
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phoneNumber: _phoneController.text.isNotEmpty
                ? _phoneController.text
                : null,
            role: _selectedRole,
          );

      final authState = ref.read(authViewModelProvider);
      if (authState.isAuthenticated && authState.error == null) {
        if (mounted) {
          context.go('/');
        }
      }
    }
  }

  Widget _buildRoleChoiceCard({
    required String role,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
  }) {
    final activeColor = role == 'Patient'
        ? AppColors.primary
        : role == 'Doctor'
        ? AppColors.secondary
        : AppColors.success;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.08)
                : (isDark ? AppColors.surfaceDark : AppColors.surface),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : (isDark ? AppColors.borderDark : AppColors.border),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? activeColor
                    : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary),
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                role,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? activeColor
                      : (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final error = ref.watch(authErrorProvider);

    // Navigate to home if authenticated
    if (authState.isAuthenticated && authState.user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/${authState.user!.role.toLowerCase()}');
      });
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.background;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background soft gradient blobs
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Branding Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.health_and_safety_outlined,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'CareSync',
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Join our clinical network',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Register Form Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: borderColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.25 : 0.03,
                          ),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Account',
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Provide your details to register a new account',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 28),

                          if (error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.error.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      error,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _firstNameController,
                                  label: 'First Name',
                                  hintText: 'First name',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  validator: Validators.required,
                                  onChanged: (_) => ref
                                      .read(authViewModelProvider.notifier)
                                      .clearError(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomTextField(
                                  controller: _lastNameController,
                                  label: 'Last Name',
                                  hintText: 'Last name',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  validator: Validators.required,
                                  onChanged: (_) => ref
                                      .read(authViewModelProvider.notifier)
                                      .clearError(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hintText: 'name@hospital.com',
                            prefixIcon: const Icon(Icons.email_outlined),
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                            onChanged: (_) => ref
                                .read(authViewModelProvider.notifier)
                                .clearError(),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: _usernameController,
                            label: 'Username',
                            hintText: 'Choose a username',
                            prefixIcon: const Icon(Icons.alternate_email),
                            validator: Validators.required,
                            onChanged: (_) => ref
                                .read(authViewModelProvider.notifier)
                                .clearError(),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: _phoneController,
                            label: 'Phone Number (Optional)',
                            hintText: 'Enter phone number',
                            prefixIcon: const Icon(Icons.phone_outlined),
                            keyboardType: TextInputType.phone,
                            onChanged: (_) => ref
                                .read(authViewModelProvider.notifier)
                                .clearError(),
                          ),
                          const SizedBox(height: 24),

                          // Custom Segmented Choice Cards for Roles
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Account Role',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildRoleChoiceCard(
                                    role: 'Patient',
                                    icon: Icons.personal_injury_outlined,
                                    isSelected: _selectedRole == 'Patient',
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildRoleChoiceCard(
                                    role: 'Doctor',
                                    icon: Icons.medical_information_outlined,
                                    isSelected: _selectedRole == 'Doctor',
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildRoleChoiceCard(
                                    role: 'Nurse',
                                    icon: Icons.local_hospital_outlined,
                                    isSelected: _selectedRole == 'Nurse',
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          CustomTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hintText: 'Choose a strong password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: Validators.password,
                            onChanged: (_) => ref
                                .read(authViewModelProvider.notifier)
                                .clearError(),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            hintText: 'Re-enter your password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            validator: Validators.required,
                            onChanged: (_) => ref
                                .read(authViewModelProvider.notifier)
                                .clearError(),
                          ),
                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              onPressed: isLoading ? null : _register,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.person_add_outlined,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Create Account',
                                          style: AppTextStyles.button.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Sign In',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
