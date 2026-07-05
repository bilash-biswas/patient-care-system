import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:patient_management_app/presentation/providers/patient_provider.dart';
import 'package:patient_management_app/presentation/theme/app_colors.dart';
import 'package:patient_management_app/presentation/theme/app_text_styles.dart';
import 'package:patient_management_app/domain/entities/patient_entity.dart';

class AddPatientScreen extends ConsumerStatefulWidget {
  const AddPatientScreen({super.key});

  @override
  ConsumerState<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends ConsumerState<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _gender = 'Male';
  DateTime _dob = DateTime.now().subtract(const Duration(days: 365 * 30));
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _insuranceProviderController = TextEditingController();
  final _insurancePolicyController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bloodGroupController.dispose();
    _insuranceProviderController.dispose();
    _insurancePolicyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final patient = PatientEntity(
        id: '', // Backend will generate
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        gender: _gender,
        dateOfBirth: _dob,
        emergencyContactPhone: _phoneController.text,
        address: _addressController.text,
        bloodGroup: _bloodGroupController.text,
        insuranceProvider: _insuranceProviderController.text,
        insurancePolicyNumber: _insurancePolicyController.text,
        createdAt: DateTime.now(),
        userId: '', // Optional or internal
      );

      final success = await ref.read(patientViewModelProvider.notifier).createPatient(patient);
      if (success && mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient registered successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Register Patient'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                context,
                'Basic Information',
                [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(_firstNameController, 'First Name', Icons.person_outline),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(_lastNameController, 'Last Name', Icons.person_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(context, 'Gender', ['Male', 'Female', 'Other'], (val) => setState(() => _gender = val!)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDatePickerField(context),
                      ),
                    ],
                  ),
                ],
              ),
              _buildSectionCard(
                context,
                'Contact & Medical',
                [
                  _buildTextField(_phoneController, 'Phone Number', Icons.phone_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildTextField(_addressController, 'Address', Icons.location_on_outlined),
                  const SizedBox(height: 16),
                  _buildTextField(_bloodGroupController, 'Blood Group', Icons.bloodtype_outlined),
                ],
              ),
              _buildSectionCard(
                context,
                'Insurance Details',
                [
                  _buildTextField(_insuranceProviderController, 'Provider Name', Icons.verified_user_outlined),
                  const SizedBox(height: 16),
                  _buildTextField(_insurancePolicyController, 'Policy Number', Icons.numbers_outlined),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Register Patient', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
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
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildDropdownField(BuildContext context, String label, List<String> items, Function(String?) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _dob,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) setState(() => _dob = picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          filled: true,
          fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        child: Text(
          DateFormat('yyyy-MM-dd').format(_dob),
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
