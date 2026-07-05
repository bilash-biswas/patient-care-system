import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/presentation/providers/chat_provider.dart';
import 'package:patient_management_app/presentation/theme/app_colors.dart';
import 'package:patient_management_app/presentation/theme/app_text_styles.dart';
import 'package:patient_management_app/core/widgets/loading_widget.dart';
import 'package:patient_management_app/presentation/views/chat/chat_room_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatViewModelProvider.notifier).fetchConversations();
      ref.read(chatViewModelProvider.notifier).fetchDirectory(isRefresh: true);
    });
  }

  void _onScroll() {
    if (_tabController.index == 1 &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(chatViewModelProvider);
      if (state.directoryPage < state.directoryTotalPages) {
        ref.read(chatViewModelProvider.notifier).fetchDirectory(
          isRefresh: false,
          search: _searchController.text,
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: isDark ? Colors.white : AppColors.primary,
              unselectedLabelColor: subTextColor,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: isDark ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: const [
                Tab(text: 'Recent'),
                Tab(text: 'Directory'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecentConversations(chatState),
          _buildStaffDirectory(chatState),
        ],
      ),
    );
  }

  Widget _buildRecentConversations(ChatState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    if (state.isLoadingConversations && state.conversations.isEmpty) {
      return const Center(child: LoadingWidget());
    }

    if (state.conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.surfaceDark : Colors.white),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  size: 40,
                  color: subTextColor.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No conversations yet',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start a secure clinical discussion with any of the registered medical staff.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: subTextColor,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _tabController.animateTo(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  elevation: 0,
                ),
                child: const Text('Find a Contact', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(chatViewModelProvider.notifier).fetchConversations(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: state.conversations.length,
        itemBuilder: (context, index) {
          final contact = state.conversations[index];
          return _buildContactTile(contact);
        },
      ),
    );
  }

  Widget _buildStaffDirectory(ChatState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final borderCol = isDark ? AppColors.borderDark : AppColors.border;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              ref.read(chatViewModelProvider.notifier).fetchDirectory(isRefresh: true, search: val);
            },
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search staff directory...',
              hintStyle: TextStyle(color: subTextColor.withValues(alpha: 0.7)),
              prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(chatViewModelProvider.notifier).fetchDirectory(isRefresh: true, search: '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: cardBg,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderCol),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ),
        Expanded(
          child: state.isLoadingDirectory && state.directory.isEmpty
              ? const Center(child: LoadingWidget())
              : RefreshIndicator(
                  onRefresh: () => ref.read(chatViewModelProvider.notifier).fetchDirectory(isRefresh: true, search: _searchController.text),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 24, top: 4),
                    itemCount: state.directory.length + (state.directoryPage < state.directoryTotalPages ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.directory.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: LoadingWidget()),
                        );
                      }
                      final contact = state.directory[index];
                      return _buildContactTile(contact);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildContactTile(dynamic contact) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final borderCol = isDark ? AppColors.borderDark : AppColors.border;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final String fullName = '${contact['firstName']} ${contact['lastName']}';
    final String role = contact['role'] ?? 'Unknown';
    final String id = contact['id'];
    final bool isActive = contact['isActive'] ?? false;

    Color roleColor = AppColors.textSecondary;
    if (role == 'Doctor') roleColor = AppColors.secondary;
    if (role == 'Nurse') roleColor = AppColors.info;
    if (role == 'Admin') roleColor = AppColors.primaryDark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: roleColor.withValues(alpha: 0.08),
              child: Text(
                contact['firstName'][0],
                style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            if (isActive)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: cardBg, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          fullName,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                role.toUpperCase(),
                style: TextStyle(
                  color: roleColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: subTextColor.withValues(alpha: 0.6)),
        onTap: () {
          ref.read(chatViewModelProvider.notifier).setActiveContact(id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(contactId: id, fullName: fullName, role: role),
            ),
          );
        },
      ),
    );
  }
}
