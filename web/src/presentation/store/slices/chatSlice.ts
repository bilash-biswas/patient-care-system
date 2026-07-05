import { createSlice, PayloadAction, createAsyncThunk } from '@reduxjs/toolkit';
import { Message, User } from '@/domain/entities';
import { ChatRepository } from '@/data/repositories/ChatRepository';

const repository = new ChatRepository();

export interface NotificationItem {
  id: string;
  message: string;
  isRead: boolean;
  sentAt: string;
}

interface ChatState {
  activeConversationId: string | null;
  conversations: User[];
  directory: User[];
  directoryPagination: { page: number; pageSize: number; totalCount: number; totalPages: number } | null;
  messages: Record<string, Message[]>;
  notifications: NotificationItem[];
  isOnline: boolean;
  isLoading: boolean;
}

const initialState: ChatState = {
  activeConversationId: null,
  conversations: [],
  directory: [],
  directoryPagination: null,
  messages: {},
  notifications: [],
  isOnline: false,
  isLoading: false,
};

export const fetchDirectory = createAsyncThunk(
  'chat/fetchDirectory',
  async (params?: { search?: string; page?: number; pageSize?: number }) => {
    return await repository.getDirectory(params?.search, params?.page, params?.pageSize);
  }
);

export const fetchConversations = createAsyncThunk(
  'chat/fetchConversations',
  async () => {
    return await repository.getRecentConversations();
  }
);

export const fetchMessages = createAsyncThunk(
  'chat/fetchMessages',
  async (userId: string) => {
    const messages = await repository.getMessages(userId);
    return { userId, messages };
  }
);

const chatSlice = createSlice({
  name: 'chat',
  initialState,
  reducers: {
    setActiveConversation: (state, action: PayloadAction<string | null>) => {
      state.activeConversationId = action.payload;
      if (action.payload) {
        const contact = state.directory.find(c => c.id === action.payload);
        if (contact && !state.conversations.some(c => c.id === action.payload)) {
          state.conversations = [contact, ...state.conversations];
        }
      }
    },
    addMessage: (state, action: PayloadAction<Message & { senderName?: string }>) => {
      const { senderId, receiverId, content, senderName } = action.payload;
      
      // Determine conversation key (always the ID of the other person)
      let chatId = senderId;
      if (state.activeConversationId) {
        if (senderId === state.activeConversationId) {
          chatId = senderId;
        } else if (receiverId === state.activeConversationId) {
          chatId = receiverId;
        } else {
          chatId = senderId;
        }
      }

      if (!state.messages[chatId]) {
        state.messages[chatId] = [];
      }

      // Avoid duplicates from optimistic updates vs SignalR broadcast
      const isDuplicate = state.messages[chatId].some(
        (m) => m.content === content && 
               Math.abs(new Date(m.sentAt).getTime() - new Date(action.payload.sentAt).getTime()) < 4000
      );

      if (!isDuplicate) {
        state.messages[chatId].push(action.payload);
      }

      // Add to notifications list if message is incoming and user is not actively viewing this conversation
      if (senderId !== state.activeConversationId) {
        let name = senderName || 'Someone';
        
        if (name === 'Someone') {
          const contact = state.conversations.find((c) => c.id === senderId);
          if (contact) {
            name = `${contact.firstName} ${contact.lastName}`.trim();
          } else {
            const dirUser = state.directory.find((u) => u.id === senderId);
            if (dirUser) {
              name = `${dirUser.firstName} ${dirUser.lastName}`.trim();
            }
          }
        }

        state.notifications.push({
          id: Date.now().toString() + Math.random().toString(36).substring(2, 7),
          message: `Chat: New message from ${name}: ${content}`,
          isRead: false,
          sentAt: new Date().toISOString()
        });
      }
    },
    addNotification: (state, action: PayloadAction<string>) => {
      state.notifications.push({
        id: Date.now().toString() + Math.random().toString(36).substring(2, 7),
        message: action.payload,
        isRead: false,
        sentAt: new Date().toISOString()
      });
    },
    markAsRead: (state, action: PayloadAction<string>) => {
      const notification = state.notifications.find(n => n.id === action.payload);
      if (notification) {
        notification.isRead = true;
      }
    },
    markAllAsRead: (state) => {
      state.notifications.forEach(n => {
        n.isRead = true;
      });
    },
    clearNotifications: (state) => {
      state.notifications = [];
    },
    setOnlineStatus: (state, action: PayloadAction<boolean>) => {
      state.isOnline = action.payload;
    }
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchConversations.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(fetchConversations.fulfilled, (state, action) => {
        state.isLoading = false;
        state.conversations = action.payload;
      })
      .addCase(fetchDirectory.fulfilled, (state, action) => {
        state.directory = action.payload.data || [];
        state.directoryPagination = action.payload.pagination || null;
      })
      .addCase(fetchMessages.fulfilled, (state, action) => {
        state.messages[action.payload.userId] = action.payload.messages;
      });
  }
});

export const { setActiveConversation, addMessage, addNotification, markAsRead, markAllAsRead, clearNotifications, setOnlineStatus } = chatSlice.actions;
export default chatSlice.reducer;
