import api from '@/core/api';

export class ChatRepository {
  async getMessages(userId: string, page: number = 1, pageSize: number = 50) {
    const response = await api.get(`/chat/messages/${userId}?page=${page}&pageSize=${pageSize}`);
    return response.data.data;
  }

  async getRecentConversations() {
    const response = await api.get('/chat/conversations');
    return response.data.data;
  }

  async getDirectory(search?: string, page: number = 1, pageSize: number = 10) {
    const searchQuery = search ? `&search=${encodeURIComponent(search)}` : '';
    const response = await api.get(`/chat/directory?page=${page}&pageSize=${pageSize}${searchQuery}`);
    return response.data;
  }
}
