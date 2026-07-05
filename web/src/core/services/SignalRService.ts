import * as signalR from '@microsoft/signalr';
import { store } from '@/presentation/store';
import { addMessage, addNotification, setOnlineStatus } from '@/presentation/store/slices/chatSlice';

class SignalRService {
  private notificationConnection: signalR.HubConnection | null = null;
  private chatConnection: signalR.HubConnection | null = null;
  private baseUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5278';

  async startConnections(token: string) {
    this.notificationConnection = new signalR.HubConnectionBuilder()
      .withUrl(`${this.baseUrl}/hubs/notifications`, {
        accessTokenFactory: () => token
      })
      .withAutomaticReconnect()
      .build();

    this.chatConnection = new signalR.HubConnectionBuilder()
      .withUrl(`${this.baseUrl}/hubs/chat`, {
        accessTokenFactory: () => token
      })
      .withAutomaticReconnect()
      .build();

    this.notificationConnection.on('ReceiveNotification', (message: string) => {
      store.dispatch(addNotification(message));
    });

    this.notificationConnection.on('ReceiveBroadcast', (message: string) => {
      store.dispatch(addNotification(message));
    });

    this.chatConnection.on('ReceiveMessage', (message: any) => {
      store.dispatch(addMessage(message));
    });

    try {
      await Promise.all([
        this.notificationConnection.start(),
        this.chatConnection.start()
      ]);
      store.dispatch(setOnlineStatus(true));
      console.log('SignalR Connections Started');
    } catch (err) {
      console.error('SignalR Connection Error: ', err);
      store.dispatch(setOnlineStatus(false));
    }
  }

  async sendMessage(receiverId: string, content: string) {
    if (this.chatConnection?.state === signalR.HubConnectionState.Connected) {
      await this.chatConnection.invoke('SendMessage', receiverId, content);
    } else {
      console.error('Chat connection not active');
    }
  }

  stopConnections() {
    this.notificationConnection?.stop();
    this.chatConnection?.stop();
    store.dispatch(setOnlineStatus(false));
  }
}

export const signalRService = new SignalRService();
