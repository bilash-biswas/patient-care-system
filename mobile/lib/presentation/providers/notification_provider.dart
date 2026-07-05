import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/core/services/notification_service.dart';
import 'package:patient_management_app/domain/entities/notification_entity.dart';
import 'package:patient_management_app/presentation/providers/auth_provider.dart';
import 'package:patient_management_app/presentation/router/app_router.dart';
import 'package:patient_management_app/presentation/theme/app_colors.dart';
import 'package:patient_management_app/injection_container.dart';
import 'package:patient_management_app/data/datasources/local/shared_prefs.dart';

final notificationServiceProvider = Provider<SignalRNotificationService>((ref) {
  return SignalRNotificationService();
});

class NotificationViewModel extends StateNotifier<List<NotificationEntity>> {
  final SignalRNotificationService _notificationService;
  static const _storageKey = 'cached_notifications';

  NotificationViewModel(this._notificationService) : super([]) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final jsonStr = await sl<SharedPrefs>().getString(_storageKey);
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        state = decoded.map((item) => NotificationEntity.fromJson(item)).toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading notifications from storage: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final jsonStr = jsonEncode(state.map((item) => item.toJson()).toList());
      await sl<SharedPrefs>().setString(_storageKey, jsonStr);
    } catch (e) {
      // ignore: avoid_print
      print('Error saving notifications to storage: $e');
    }
  }

  Future<void> init() async {
    try {
      final token = await sl<SharedPrefs>().getString('token');
      if (token == null) return;

      await _notificationService.connect(
        token,
        onNotificationReceived: (message) {
          _addNotification(message, isBroadcast: false);
        },
        onBroadcastReceived: (message) {
          _addNotification(message, isBroadcast: true);
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('Failed to initialize SignalR in NotificationViewModel: $e');
    }
  }

  void _addNotification(String message, {required bool isBroadcast}) {
    String title = isBroadcast ? 'Broadcast Alert' : 'System Notification';
    String body = message;
    String type = 'info';

    if (message.contains(': ')) {
      final parts = message.split(': ');
      if (parts.length >= 2) {
        final prefix = parts[0].trim();
        if (prefix.toLowerCase() == 'chat' || prefix.toLowerCase() == 'message') {
          title = 'New Message';
          type = 'chat';
          body = parts.sublist(1).join(': ');
        } else if (prefix.toLowerCase() == 'appointment') {
          title = 'Appointment Update';
          type = 'appointment';
          body = parts.sublist(1).join(': ');
        } else {
          title = prefix;
          body = parts.sublist(1).join(': ');
        }
      }
    } else {
      final lower = message.toLowerCase();
      if (lower.contains('appointment') || lower.contains('schedule')) {
        title = 'Appointment Alert';
        type = 'appointment';
      } else if (lower.contains('message') || lower.contains('chat')) {
        title = 'Chat Alert';
        type = 'chat';
      }
    }

    final newNotification = NotificationEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      message: body,
      timestamp: DateTime.now(),
      isRead: false,
      type: type,
    );

    state = [newNotification, ...state];
    _saveToStorage();
    _showInAppBanner(title, body, type);
  }

  void markAsRead(String id) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();
    _saveToStorage();
  }

  void markAllAsRead() {
    state = state.map((item) => item.copyWith(isRead: true)).toList();
    _saveToStorage();
  }

  void removeNotification(String id) {
    state = state.where((item) => item.id != id).toList();
    _saveToStorage();
  }

  void clearAll() {
    state = [];
    _saveToStorage();
  }

  void addManualNotification({
    required String title,
    required String body,
    required String type,
  }) {
    final newNotification = NotificationEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      message: body,
      timestamp: DateTime.now(),
      isRead: false,
      type: type,
    );

    state = [newNotification, ...state];
    _saveToStorage();
    _showInAppBanner(title, body, type);
  }

  void cleanup() {
    _notificationService.disconnect();
    clearAll();
  }

  void _showInAppBanner(String title, String message, String type) {
    final context = rootNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    IconData iconData = Icons.notifications_active;
    Color themeColor = AppColors.primary;
    if (type == 'appointment') {
      iconData = Icons.calendar_today;
      themeColor = AppColors.secondary;
    } else if (type == 'chat') {
      iconData = Icons.chat;
      themeColor = AppColors.success;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: isDark ? AppColors.primaryLight : themeColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.close, size: 18, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                  onPressed: () {
                    if (entry.mounted) entry.remove();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}

final notificationViewModelProvider = StateNotifierProvider<NotificationViewModel, List<NotificationEntity>>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final service = ref.watch(notificationServiceProvider);
  final viewModel = NotificationViewModel(service);

  if (isAuthenticated) {
    viewModel.init();
  } else {
    viewModel.cleanup();
  }

  return viewModel;
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationViewModelProvider);
  return list.where((item) => !item.isRead).length;
});
