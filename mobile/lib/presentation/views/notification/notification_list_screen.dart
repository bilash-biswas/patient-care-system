import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:patient_management_app/domain/entities/notification_entity.dart';
import 'package:patient_management_app/presentation/providers/notification_provider.dart';
import 'package:patient_management_app/presentation/theme/app_colors.dart';
import 'package:patient_management_app/presentation/theme/app_text_styles.dart';

class NotificationListScreen extends ConsumerWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        elevation: 0,
        actions: [
          if (notifications.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.mark_chat_read_outlined),
              tooltip: 'Mark all as read',
              onPressed: () => ref.read(notificationViewModelProvider.notifier).markAllAsRead(),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear all',
              onPressed: () => _confirmClearAll(context, ref),
            ),
          ],
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context, isDark)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return _buildDismissibleItem(context, ref, item, isDark);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.04),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: isDark ? AppColors.primaryLight : AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'All Caught Up!',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no new notifications.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissibleItem(
    BuildContext context,
    WidgetRef ref,
    NotificationEntity item,
    bool isDark,
  ) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(notificationViewModelProvider.notifier).removeNotification(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_outline,
          color: AppColors.error,
          size: 28,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: item.isRead
                ? (isDark ? AppColors.borderDark : AppColors.border)
                : (isDark ? AppColors.primaryLight.withValues(alpha: 0.4) : AppColors.primary.withValues(alpha: 0.2)),
            width: item.isRead ? 1 : 1.5,
          ),
        ),
        color: item.isRead
            ? (isDark ? AppColors.surfaceDark : AppColors.surface)
            : (isDark
                ? AppColors.primaryLight.withValues(alpha: 0.03)
                : AppColors.primary.withValues(alpha: 0.015)),
        child: InkWell(
          onTap: () {
            if (!item.isRead) {
              ref.read(notificationViewModelProvider.notifier).markAsRead(item.id);
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryIcon(item.type, item.isRead, isDark),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                                fontSize: 15,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('HH:mm').format(item.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.message,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: item.isRead ? FontWeight.normal : FontWeight.w500,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String type, bool isRead, bool isDark) {
    IconData iconData = Icons.notifications_none;
    Color iconColor = AppColors.primary;

    if (type == 'chat') {
      iconData = Icons.chat_bubble_outline_rounded;
      iconColor = AppColors.success;
    } else if (type == 'appointment') {
      iconData = Icons.calendar_today_rounded;
      iconColor = AppColors.secondary;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        iconData,
        color: isDark ? AppColors.primaryLight : iconColor,
        size: 22,
      ),
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications?'),
        content: const Text('This action will delete all notifications. You cannot undo this.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () {
              ref.read(notificationViewModelProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
