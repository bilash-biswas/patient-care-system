import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/presentation/providers/chat_provider.dart';
import 'package:patient_management_app/presentation/theme/app_colors.dart';
import 'package:patient_management_app/presentation/theme/app_text_styles.dart';
import 'package:patient_management_app/core/widgets/loading_widget.dart';
import 'package:intl/intl.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String contactId;
  final String fullName;
  final String role;

  const ChatRoomScreen({
    super.key,
    required this.contactId,
    required this.fullName,
    required this.role,
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatViewModelProvider.notifier).fetchMessages(widget.contactId);
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);
    final messages = chatState.messages[widget.contactId] ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    // Trigger auto-scroll on new messages
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    Color roleColor = AppColors.textSecondary;
    if (widget.role == 'Doctor') roleColor = AppColors.secondary;
    if (widget.role == 'Nurse') roleColor = AppColors.info;
    if (widget.role == 'Admin') roleColor = AppColors.primaryDark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: roleColor.withValues(alpha: 0.08),
              child: Text(
                widget.fullName[0],
                style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.fullName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      color: roleColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.isLoadingMessages && messages.isEmpty
                ? const Center(child: LoadingWidget())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId != widget.contactId;
                      return _buildMessageBubble(message, isMe);
                    },
                  ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic message, bool isMe) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = DateFormat('hh:mm a').format(message.timestamp);
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final borderCol = isDark ? AppColors.borderDark : AppColors.border;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : cardBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          border: isMe ? null : Border.all(color: borderCol),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              timeStr,
              style: TextStyle(
                color: isMe ? Colors.white.withValues(alpha: 0.7) : subTextColor.withValues(alpha: 0.8),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final borderCol = isDark ? AppColors.borderDark : AppColors.border;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: borderCol)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Type secure message...',
                hintStyle: TextStyle(color: subTextColor.withValues(alpha: 0.7)),
                filled: true,
                fillColor: cardBg,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: borderCol),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                onPressed: _handleSend,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend() {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;

    ref.read(chatViewModelProvider.notifier).sendMessage(widget.contactId, text);
    _messageController.clear();
    _scrollToBottom();
  }
}
