import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:patient_management_app/core/widgets/loading_widget.dart';
import 'package:patient_management_app/domain/entities/medical_record_entity.dart';
import 'package:patient_management_app/presentation/providers/medical_record_provider.dart';
import 'package:patient_management_app/presentation/providers/auth_provider.dart';
import 'package:patient_management_app/presentation/providers/patient_provider.dart';
import 'package:patient_management_app/presentation/theme/app_colors.dart';
import 'package:patient_management_app/presentation/theme/app_text_styles.dart';

class MedicalRecordsScreen extends ConsumerStatefulWidget {
  final String? patientId;

  const MedicalRecordsScreen({super.key, this.patientId});

  @override
  ConsumerState<MedicalRecordsScreen> createState() =>
      _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends ConsumerState<MedicalRecordsScreen> {
  final List<String> _recordTypeFilters = [
    'All',
    'Consultation',
    'Lab',
    'Radiology',
    'Prescription',
  ];
  String _selectedFilter = 'All';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = ref.read(currentUserProvider);
      String? targetPatientId = widget.patientId;

      if (user?.role == 'Patient' && targetPatientId == null) {
        try {
          final patientProfile = await ref.read(patientRepositoryProvider).getMyProfile();
          targetPatientId = patientProfile.id;
        } catch (e) {
          debugPrint('Error fetching patient profile: $e');
        }
      }

      if (targetPatientId != null) {
        ref
            .read(medicalRecordViewModelProvider.notifier)
            .fetchMedicalRecords(patientId: targetPatientId);
      } else if (user?.role != 'Patient') {
        ref.read(medicalRecordViewModelProvider.notifier).fetchMedicalRecords();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final medicalRecordState = ref.watch(medicalRecordViewModelProvider);
    final isLoading = ref.watch(medicalRecordLoadingProvider);
    final error = ref.watch(medicalRecordErrorProvider);

    List<MedicalRecordEntity> filteredRecords = medicalRecordState
        .medicalRecords
        .where((record) {
          final matchesType =
              _selectedFilter == 'All' || record.recordType == _selectedFilter;
          final matchesDate =
              (_startDate == null || record.visitDate.isAfter(_startDate!)) &&
              (_endDate == null || record.visitDate.isBefore(_endDate!));
          return matchesType && matchesDate;
        })
        .toList()
        .reversed
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Medical Records'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (ref.watch(currentUserProvider)?.role != 'Patient')
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 26, color: AppColors.primary),
              onPressed: () => _showCreateMedicalRecordDialog(context),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(context),
          Expanded(
            child: _buildContent(
              isLoading: isLoading,
              error: error,
              records: filteredRecords,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _recordTypeFilters.length,
                    itemBuilder: (context, index) {
                      final type = _recordTypeFilters[index];
                      final isSelected = _selectedFilter == type;
                      final isAll = type == 'All';
                      final typeColor = isAll ? AppColors.primary : _getRecordTypeColor(type);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          showCheckmark: false,
                          label: Text(
                            type,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: isSelected ? typeColor : Colors.transparent,
                          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : (isDark ? AppColors.borderDark : AppColors.border),
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFilter = type;
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectStartDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _startDate != null
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : (isDark ? AppColors.surfaceDark : AppColors.surface),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _startDate != null
                            ? AppColors.primary
                            : (isDark ? AppColors.borderDark : AppColors.border),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _startDate != null
                              ? DateFormat('dd/MM/yyyy').format(_startDate!)
                              : 'From Date',
                          style: TextStyle(
                            color: _startDate != null
                                ? AppColors.primary
                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: _startDate != null ? AppColors.primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _selectEndDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _endDate != null
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : (isDark ? AppColors.surfaceDark : AppColors.surface),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _endDate != null
                            ? AppColors.primary
                            : (isDark ? AppColors.borderDark : AppColors.border),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _endDate != null
                              ? DateFormat('dd/MM/yyyy').format(_endDate!)
                              : 'To Date',
                          style: TextStyle(
                            color: _endDate != null
                                ? AppColors.primary
                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: _endDate != null ? AppColors.primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_startDate != null || _endDate != null) ...[
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.clear_all,
                      color: AppColors.error,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getRecordTypeColor(String? type) {
    switch (type) {
      case 'Consultation':
        return AppColors.primary;
      case 'Lab':
        return AppColors.secondary;
      case 'Radiology':
        return AppColors.warning;
      case 'Prescription':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildContent({
    required bool isLoading,
    required String? error,
    required List<MedicalRecordEntity> records,
  }) {
    if (isLoading) {
      return const Center(child: LoadingWidget());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(medicalRecordViewModelProvider.notifier)
                    .fetchMedicalRecords();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 64,
              color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No medical records found',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24, top: 8),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _MedicalRecordCard(record: record);
      },
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _showCreateMedicalRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateMedicalRecordDialog(patientId: widget.patientId),
    );
  }
}

class _MedicalRecordCard extends StatelessWidget {
  final MedicalRecordEntity record;

  const _MedicalRecordCard({required this.record});

  Color _getRecordTypeColor(String? type) {
    switch (type) {
      case 'Consultation':
        return AppColors.primary;
      case 'Lab':
        return AppColors.secondary;
      case 'Radiology':
        return AppColors.warning;
      case 'Prescription':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = _getRecordTypeColor(record.recordType);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.medical_services_outlined, color: typeColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.diagnosis,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (record.recordType != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            record.recordType!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: typeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: isDark ? AppColors.borderDark : AppColors.border, thickness: 1),
            const SizedBox(height: 12),
            _buildInfoRow(
              context: context,
              icon: Icons.calendar_today_outlined,
              label: 'Visit Date',
              value: record.formattedVisitDate,
            ),
            if (record.formattedNextVisitDate != null)
              _buildInfoRow(
                context: context,
                icon: Icons.event_repeat_outlined,
                label: 'Next Visit',
                value: record.formattedNextVisitDate!,
              ),
            if (record.doctorName != null)
              _buildInfoRow(
                context: context,
                icon: Icons.person_outline,
                label: 'Doctor',
                value: record.doctorName!,
              ),
            const SizedBox(height: 16),
            _buildSection(context, 'Symptoms', record.symptoms),
            const SizedBox(height: 12),
            _buildSection(context, 'Treatment', record.treatment),
            if (record.prescription != null && record.prescription!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSection(context, 'Prescription', record.prescription!),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(record.createdAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class CreateMedicalRecordDialog extends ConsumerStatefulWidget {
  final String? patientId;
  const CreateMedicalRecordDialog({super.key, this.patientId});

  @override
  ConsumerState<CreateMedicalRecordDialog> createState() =>
      _CreateMedicalRecordDialogState();
}

class _CreateMedicalRecordDialogState
    extends ConsumerState<CreateMedicalRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _prescriptionController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _visitDate;
  DateTime? _nextVisitDate;
  String? _selectedRecordType;
  late String? _selectedPatientId;
  late String? _selectedDoctorId;

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.patientId ?? "00000000-0000-0000-0000-000000000000";
    final currentUser = ref.read(currentUserProvider);
    _selectedDoctorId = currentUser?.id ?? "00000000-0000-0000-0000-000000000000";
  }

  final List<String> _recordTypes = [
    'Consultation',
    'Lab',
    'Radiology',
    'Prescription',
    'Other',
  ];

  @override
  void dispose() {
    _diagnosisController.dispose();
    _symptomsController.dispose();
    _treatmentController.dispose();
    _prescriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _createMedicalRecord() async {
    if (_formKey.currentState!.validate() &&
        _visitDate != null &&
        _selectedRecordType != null) {
      final record = MedicalRecordEntity(
        id: "", // Backend generates ID
        patientId: _selectedPatientId!,
        patientName: "", // Backend fetches name
        doctorId: _selectedDoctorId,
        diagnosis: _diagnosisController.text,
        symptoms: _symptomsController.text,
        treatment: _treatmentController.text,
        prescription: _prescriptionController.text,
        notes: _notesController.text,
        visitDate: _visitDate!,
        nextVisitDate: _nextVisitDate,
        recordType: _selectedRecordType,
        createdAt: DateTime.now(),
      );

      await ref
          .read(medicalRecordViewModelProvider.notifier)
          .createMedicalRecord(record);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Medical Record',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _selectedRecordType,
                  decoration: InputDecoration(
                    labelText: 'Record Type',
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
                  items: _recordTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRecordType = value;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _diagnosisController,
                  decoration: InputDecoration(
                    labelText: 'Diagnosis',
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
                  maxLines: 2,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _symptomsController,
                  decoration: InputDecoration(
                    labelText: 'Symptoms',
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
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _treatmentController,
                  decoration: InputDecoration(
                    labelText: 'Treatment',
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
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _prescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Prescription (Optional)',
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
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Visit Date',
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
                    suffixIcon: const Icon(Icons.calendar_today, size: 18),
                  ),
                  controller: TextEditingController(
                    text: _visitDate != null
                        ? DateFormat('yyyy-MM-dd').format(_visitDate!)
                        : '',
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _visitDate = picked;
                      });
                    }
                  },
                  validator: (value) => _visitDate == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Next Visit Date (Optional)',
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
                    suffixIcon: const Icon(Icons.calendar_today, size: 18),
                  ),
                  controller: TextEditingController(
                    text: _nextVisitDate != null
                        ? DateFormat('yyyy-MM-dd').format(_nextVisitDate!)
                        : '',
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _nextVisitDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Additional Notes (Optional)',
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
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _createMedicalRecord();
                      final error = ref.read(medicalRecordErrorProvider);
                      if (error != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        ref.read(medicalRecordViewModelProvider.notifier).clearError();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Record', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
