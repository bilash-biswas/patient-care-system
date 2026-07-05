import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patient_management_app/core/widgets/loading_widget.dart';
import 'package:patient_management_app/core/network/dio_client.dart';
import 'package:patient_management_app/injection_container.dart';
import 'package:patient_management_app/presentation/theme/app_colors.dart';
import 'package:patient_management_app/presentation/theme/app_text_styles.dart';

class NurseListScreen extends ConsumerStatefulWidget {
  const NurseListScreen({super.key});

  @override
  ConsumerState<NurseListScreen> createState() => _NurseListScreenState();
}

class _NurseListScreenState extends ConsumerState<NurseListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  
  List<dynamic> _nurses = [];
  bool _isLoading = false;
  int _page = 1;
  int _totalPages = 1;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNurses(isRefresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (_page < _totalPages && !_isLoading) {
        _fetchNurses(isRefresh: false);
      }
    }
  }

  Future<void> _fetchNurses({bool isRefresh = true}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final nextPage = isRefresh ? 1 : _page + 1;
      final response = await sl<DioClient>().get(
        '/nurses',
        queryParameters: {
          'search': _search,
          'page': nextPage,
          'pageSize': 8,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> newData = response.data['data'] ?? [];
        final pagination = response.data['pagination'] ?? {};
        
        setState(() {
          _nurses = isRefresh ? newData : [..._nurses, ...newData];
          _page = nextPage;
          _totalPages = pagination['totalPages'] ?? 1;
        });
      }
    } catch (e) {
      print('Error fetching nurses in NurseListScreen: $e');
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Nurse Roster'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            onPressed: () => _fetchNurses(isRefresh: true),
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
                _fetchNurses(isRefresh: true);
              },
              decoration: InputDecoration(
                hintText: 'Search nurses by name...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _search = '');
                          _fetchNurses(isRefresh: true);
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
            child: _isLoading && _nurses.isEmpty
                ? const Center(child: LoadingWidget())
                : RefreshIndicator(
                    onRefresh: () => _fetchNurses(isRefresh: true),
                    child: _nurses.isEmpty
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
                                  'No nurses found',
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
                            itemCount: _nurses.length + (_page < _totalPages ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _nurses.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: LoadingWidget()),
                                );
                              }
                              final nurse = _nurses[index];
                              return _buildNurseCard(nurse);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNurseCard(dynamic nurse) {
    final String fullName = '${nurse['firstName']} ${nurse['lastName']}';
    final String email = nurse['email'] ?? 'No email';
    final String? phone = nurse['phoneNumber'];
    final bool isActive = nurse['isActive'] ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
          onTap: () => context.push('/staff/${nurse['id']}', extra: nurse),
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
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      nurse['firstName'][0],
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fullName,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (isActive ? AppColors.success : AppColors.textDisabled).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: isActive ? AppColors.success : AppColors.textDisabled,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.email_outlined, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              email,
                              style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (phone != null && phone.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              phone,
                              style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
