import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patient_management_app/core/widgets/loading_widget.dart';
import 'package:patient_management_app/domain/entities/patient_entity.dart';
import 'package:patient_management_app/presentation/providers/patient_provider.dart';
import 'package:patient_management_app/presentation/providers/auth_provider.dart';
import 'package:patient_management_app/presentation/viewmodels/patient_viewmodel.dart';
import 'package:patient_management_app/presentation/theme/app_colors.dart';
import 'package:patient_management_app/presentation/theme/app_text_styles.dart';
import 'package:patient_management_app/presentation/views/appointment/appointment_screen.dart';

class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({super.key});

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(patientViewModelProvider.notifier).fetchPatients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(patientViewModelProvider.notifier).fetchPatients(isRefresh: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientState = ref.watch(patientViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Patient Explorer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            onPressed: () => ref.read(patientViewModelProvider.notifier).fetchPatients(),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 26),
            onPressed: () {
              final user = ref.read(currentUserProvider);
              if (user?.role != 'Patient') {
                context.push('/patients/add');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Patients cannot register new patients')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: Colors.transparent,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search patients...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(patientViewModelProvider.notifier).onSearchChanged('');
                        },
                      )
                    : null,
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
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                ref.read(patientViewModelProvider.notifier).onSearchChanged(value);
              },
            ),
          ),
          Expanded(
            child: _buildContent(patientState),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(PatientState state) {
    if (state.isLoading && state.patients.isEmpty) {
      return const Center(child: LoadingWidget());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.error != null && state.patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(patientViewModelProvider.notifier).fetchPatients();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 64,
              color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              state.searchQuery.isEmpty ? 'No patients found' : 'No results for "${state.searchQuery}"',
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

    return RefreshIndicator(
      onRefresh: () => ref.read(patientViewModelProvider.notifier).fetchPatients(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24, top: 8),
        itemCount: state.patients.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.patients.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: LoadingWidget()),
            );
          }
          final patient = state.patients[index];
          return _PatientCard(patient: patient);
        },
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final PatientEntity patient;

  const _PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/patients/${patient.id}', extra: patient),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
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
                      patient.firstName[0],
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
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${patient.gender} • ${patient.age} years',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (patient.bloodGroup != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            patient.bloodGroup!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => CreateAppointmentDialog(patientId: patient.id),
                        );
                      },
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
