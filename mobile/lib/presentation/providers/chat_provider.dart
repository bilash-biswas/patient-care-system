import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/core/services/chat_service.dart';
import 'package:patient_management_app/domain/entities/message_entity.dart';
import 'package:patient_management_app/core/network/dio_client.dart';
import 'package:patient_management_app/injection_container.dart';
import 'package:patient_management_app/data/datasources/local/shared_prefs.dart';
import 'package:patient_management_app/domain/repositories/auth_repository.dart';
import 'package:patient_management_app/presentation/providers/auth_provider.dart';
import 'package:patient_management_app/presentation/providers/notification_provider.dart';
import 'dart:async';

class ChatState {
  final List<dynamic> conversations; // Recent conversation contacts
  final Map<String, List<MessageEntity>> messages; // messages mapped by contactId
  final String? activeContactId;
  final List<dynamic> directory; // Staff directory list
  final bool isLoadingDirectory;
  final bool isLoadingConversations;
  final bool isLoadingMessages;
  final String directorySearchQuery;
  final int directoryPage;
  final int directoryTotalPages;

  ChatState({
    this.conversations = const [],
    this.messages = const {},
    this.activeContactId,
    this.directory = const [],
    this.isLoadingDirectory = false,
    this.isLoadingConversations = false,
    this.isLoadingMessages = false,
    this.directorySearchQuery = '',
    this.directoryPage = 1,
    this.directoryTotalPages = 1,
  });

  ChatState copyWith({
    List<dynamic>? conversations,
    Map<String, List<MessageEntity>>? messages,
    String? activeContactId,
    List<dynamic>? directory,
    bool? isLoadingDirectory,
    bool? isLoadingConversations,
    bool? isLoadingMessages,
    String? directorySearchQuery,
    int? directoryPage,
    int? directoryTotalPages,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      activeContactId: activeContactId ?? this.activeContactId,
      directory: directory ?? this.directory,
      isLoadingDirectory: isLoadingDirectory ?? this.isLoadingDirectory,
      isLoadingConversations: isLoadingConversations ?? this.isLoadingConversations,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      directorySearchQuery: directorySearchQuery ?? this.directorySearchQuery,
      directoryPage: directoryPage ?? this.directoryPage,
      directoryTotalPages: directoryTotalPages ?? this.directoryTotalPages,
    );
  }
}

class ChatViewModel extends StateNotifier<ChatState> {
  final SignalRChatService _chatService;
  final DioClient _dioClient;
  final Ref _ref;
  bool _isInitialized = false;

  ChatViewModel(this._chatService, this._dioClient, this._ref) : super(ChatState());

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final token = await sl<SharedPrefs>().getString('token');
      if (token == null) return;

      await _chatService.connect(token, (messageData) {
        final message = MessageEntity.fromJson(messageData);
        _handleIncomingMessage(message, messageData);
      });
      _isInitialized = true;

      // Prefetch conversations and directory to resolve names
      fetchConversations();
      fetchDirectory(isRefresh: true);
    } catch (e) {
      print('Failed to initialize SignalR in ChatViewModel: $e');
    }
  }

  void _handleIncomingMessage(MessageEntity message, Map<String, dynamic> messageData) {
    final otherUserId = state.activeContactId;
    final contactKey = message.senderId == otherUserId ? message.senderId : message.receiverId;

    final updatedMessages = Map<String, List<MessageEntity>>.from(state.messages);
    final list = updatedMessages[contactKey] ?? [];
    
    // Avoid duplicates
    if (!list.any((m) => m.id == message.id)) {
      updatedMessages[contactKey] = [...list, message];
    }

    // Move contact to the top of recent conversations
    final updatedConversations = List<dynamic>.from(state.conversations);
    final contactIndex = updatedConversations.indexWhere((c) => c['id'] == contactKey);
    
    if (contactIndex != -1) {
      final contact = updatedConversations.removeAt(contactIndex);
      updatedConversations.insert(0, contact);
    } else {
      // Fetch conversations to reload details
      fetchConversations();
    }

    state = state.copyWith(
      messages: updatedMessages,
      conversations: updatedConversations,
    );

    // Trigger local chat notification alert if not in the active chat view with this sender
    final currentUser = _ref.read(currentUserProvider);
    if (currentUser != null && message.senderId != currentUser.id && state.activeContactId != message.senderId) {
      // Get senderName directly from the Hub message payload
      String senderName = messageData['senderName'] ?? 'Someone';
      
      if (senderName == 'Someone') {
        // Find sender name in recent conversations
        final contact = state.conversations.firstWhere(
          (c) => c['id'] == message.senderId,
          orElse: () => null,
        );
        if (contact != null) {
          senderName = contact['fullName'] ?? contact['name'] ?? 'Someone';
        } else {
          // Find sender name in directory
          final dirContact = state.directory.firstWhere(
            (d) => d['id'] == message.senderId,
            orElse: () => null,
          );
          if (dirContact != null) {
            senderName = dirContact['fullName'] ?? dirContact['name'] ?? 'Someone';
          }
        }
      }

      // Add to notification history list and pop up top toast banner
      _ref.read(notificationViewModelProvider.notifier).addManualNotification(
        title: 'New Message from $senderName',
        body: message.content,
        type: 'chat',
      );
    }
  }

  Future<void> fetchConversations() async {
    try {
      state = state.copyWith(isLoadingConversations: true);
      final response = await _dioClient.get('/chat/conversations');
      if (response.data != null && response.data['success'] == true) {
        state = state.copyWith(
          conversations: response.data['data'] ?? [],
          isLoadingConversations: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoadingConversations: false);
    }
  }

  Future<void> fetchDirectory({bool isRefresh = true, String search = ''}) async {
    try {
      final page = isRefresh ? 1 : state.directoryPage + 1;
      state = state.copyWith(
        isLoadingDirectory: true,
        directorySearchQuery: search,
      );

      final response = await _dioClient.get(
        '/chat/directory',
        queryParameters: {
          'page': page,
          'pageSize': 6,
          'search': search,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> newData = response.data['data'] ?? [];
        final pagination = response.data['pagination'] ?? {};
        final totalPages = pagination['totalPages'] ?? 1;

        state = state.copyWith(
          directory: isRefresh ? newData : [...state.directory, ...newData],
          directoryPage: page,
          directoryTotalPages: totalPages,
          isLoadingDirectory: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoadingDirectory: false);
    }
  }

  Future<void> fetchMessages(String contactId) async {
    try {
      state = state.copyWith(isLoadingMessages: true, activeContactId: contactId);
      final response = await _dioClient.get(
        '/chat/messages/$contactId',
      );

      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> rawList = response.data['data'] ?? [];
        final list = rawList.map((m) => MessageEntity.fromJson(m)).toList();

        final updatedMessages = Map<String, List<MessageEntity>>.from(state.messages);
        updatedMessages[contactId] = list;

        state = state.copyWith(
          messages: updatedMessages,
          isLoadingMessages: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoadingMessages: false);
    }
  }

  Future<void> sendMessage(String receiverId, String content) async {
    if (content.trim().isEmpty) return;

    try {
      // Optimistic Update
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final currentUserId = sl<AuthRepository>().getCurrentUser().then((user) => user?.id ?? '');
      final resolvedSenderId = await currentUserId;

      final tempMessage = MessageEntity(
        id: tempId,
        senderId: resolvedSenderId,
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
      );

      final updatedMessages = Map<String, List<MessageEntity>>.from(state.messages);
      updatedMessages[receiverId] = [...(updatedMessages[receiverId] ?? []), tempMessage];

      state = state.copyWith(messages: updatedMessages);

      // Backend send
      await _chatService.sendMessage(receiverId, content);

      // Prepend receiver to recent conversations if not exists
      final isExisting = state.conversations.any((c) => c['id'] == receiverId);
      if (!isExisting) {
        await fetchConversations();
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void setActiveContact(String? contactId) {
    state = state.copyWith(activeContactId: contactId);
  }

  void cleanup() {
    _chatService.disconnect();
    _isInitialized = false;
    state = ChatState();
  }

  @override
  void dispose() {
    cleanup();
    super.dispose();
  }
}

final chatServiceProvider = Provider<SignalRChatService>((ref) {
  return SignalRChatService();
});

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final service = ref.watch(chatServiceProvider);
  final dioClient = sl<DioClient>();
  final viewModel = ChatViewModel(service, dioClient, ref);

  if (isAuthenticated) {
    viewModel.init();
  } else {
    viewModel.cleanup();
  }

  return viewModel;
});
