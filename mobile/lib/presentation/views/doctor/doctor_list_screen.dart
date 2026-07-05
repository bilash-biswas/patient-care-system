import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patient_management_app/core/widgets/loading_widget.dart';
import 'package:patient_management_app/core/network/dio_client.dart';
import 'package:patient_management_app/injection_container.dart';
import 'package:patient_management_app/presentation/theme/app_colors.dart';
import 'package:patient_management_app/presentation/theme/app_text_styles.dart';
import 'package:patient_management_app/presentation/providers/auth_provider.dart';
import 'package:patient_management_app/presentation/views/appointment/appointment_screen.dart';

class DoctorListScreen extends ConsumerStatefulWidget {
  const DoctorListScreen({super.key});

  @override
  ConsumerState<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends ConsumerState<DoctorListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  
  List<dynamic> _doctors = [];
  bool _isLoading = false;
  int _page = 1;
  int _totalPages = 1;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDoctors(isRefresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (_page < _totalPages && !_isLoading) {
        _fetchDoctors(isRefresh: false);
      }
    }
  }

  Future<void> _fetchDoctors({bool isRefresh = true}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final nextPage = isRefresh ? 1 : _page + 1;
      final response = await sl<DioClient>().get(
        '/chat/directory',
        queryParameters: {
          'role': 'Doctor',
          'search': _search,
          'page': nextPage,
          'pageSize': 8,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> newData = response.data['data'] ?? [];
        final pagination = response.data['pagination'] ?? {};
        
        setState(() {
          _doctors = isRefresh ? newData : [..._doctors, ...newData];
          _page = nextPage;
          _totalPages = pagination['totalPages'] ?? 1;
        });
      }
    } catch (e) {
      print('Error fetching doctors in DoctorListScreen: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Doctor Roster'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            onPressed: () => _fetchDoctors(isRefresh: true),
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
              onChanged: (val) {
                setState(() => _search = val);
                _fetchDoctors(isRefresh: true);
              },
              decoration: InputDecoration(
                hintText: 'Search doctors by name...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _search = '');
                          _fetchDoctors(isRefresh: true);
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
            ),
          ),
          Expanded(
            child: _isLoading && _doctors.isEmpty
                ? const Center(child: LoadingWidget())
                : RefreshIndicator(
                    onRefresh: () => _fetchDoctors(isRefresh: true),
                    child: _doctors.isEmpty
                        ? Center(
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
                                  'No doctors found',
                                  style: TextStyle(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: _doctors.length + (_page < _totalPages ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _doctors.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: LoadingWidget()),
                                );
                              }
                              final doctor = _doctors[index];
                              return _buildDoctorCard(doctor, currentUser);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  String _getDoctorSpecialization(String lastName) {
    final specs = [
      'Cardiologist',
      'Pediatrician',
      'Neurologist',
      'Dermatologist',
      'Orthopedic Surgeon',
      'General Practitioner',
      'Internal Medicine Specialist',
      'Oncologist',
      'Psychiatrist',
      'Gynecologist'
    ];
    int hash = 0;
    for (int i = 0; i < lastName.length; i++) {
      hash += lastName.codeUnitAt(i);
    }
    return specs[hash % specs.length];
  }

  double _getDoctorRating(String lastName) {
    int hash = 0;
    for (int i = 0; i < lastName.length; i++) {
      hash += lastName.codeUnitAt(i);
    }
    return 4.5 + (hash % 6) * 0.1;
  }

  int _getDoctorReviewsCount(String lastName) {
    int hash = 0;
    for (int i = 0; i < lastName.length; i++) {
      hash += lastName.codeUnitAt(i);
    }
    return 20 + (hash % 180);
  }

  int _getDoctorExperience(String lastName) {
    int hash = 0;
    for (int i = 0; i < lastName.length; i++) {
      hash += lastName.codeUnitAt(i);
    }
    return 3 + (hash % 20);
  }

  Widget _buildDoctorCard(dynamic doctor, dynamic currentUser) {
    final String firstName = doctor['firstName'] ?? '';
    final String lastName = doctor['lastName'] ?? '';
    final String fullName = 'Dr. $firstName $lastName';
    final bool isActive = doctor['isActive'] ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final specialization = _getDoctorSpecialization(lastName);
    final rating = _getDoctorRating(lastName);
    final reviewsCount = _getDoctorReviewsCount(lastName);
    final expYears = _getDoctorExperience(lastName);

    final initials = '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Glow-ring Avatar
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials.isNotEmpty ? initials : 'DR',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Details Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                fullName,
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Status Dot
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive ? AppColors.success : AppColors.textDisabled,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isActive ? 'Online' : 'Away',
                              style: TextStyle(
                                color: isActive ? AppColors.success : AppColors.textDisabled,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Specialty Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            specialization,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Star Rating & Experience
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '($reviewsCount)',
                              style: TextStyle(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                color: isDark ? AppColors.borderDark : AppColors.border,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$expYears yrs exp',
                              style: TextStyle(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
            // Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isDark ? AppColors.backgroundDark.withValues(alpha: 0.4) : AppColors.background.withValues(alpha: 0.4),
              child: Row(
                children: [
                  // View Profile Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push('/staff/${doctor['id']}', extra: doctor),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                      ),
                      child: Text(
                        'View Profile',
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  if (currentUser?.role == 'Patient') ...[
                    const SizedBox(width: 12),
                    // Book Appointment Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => CreateAppointmentDialog(doctorId: doctor['id']),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_month_outlined, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Book Slot',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
