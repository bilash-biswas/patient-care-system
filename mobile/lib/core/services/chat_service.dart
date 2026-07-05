import 'package:signalr_core/signalr_core.dart';
import 'package:patient_management_app/core/constants/api_constants.dart';

class SignalRChatService {
  HubConnection? _chatConnection;
  bool _isConnecting = false;

  HubConnectionState get state => _chatConnection?.state ?? HubConnectionState.disconnected;

  Future<void> connect(String token, Function(Map<String, dynamic>) onMessageReceived) async {
    if (_chatConnection != null && _chatConnection!.state == HubConnectionState.connected) {
      return;
    }
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      final cleanBaseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
      final hubUrl = '$cleanBaseUrl/hubs/chat';

      _chatConnection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            HttpConnectionOptions(
              accessTokenFactory: () async => token,
            ),
          )
          .withAutomaticReconnect()
          .build();

      _chatConnection!.on('ReceiveMessage', (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          final messageData = arguments[0] as Map<String, dynamic>;
          onMessageReceived(messageData);
        }
      });

      _chatConnection!.onclose((error) {
        print('SignalR Chat Connection Closed: $error');
      });

      await _chatConnection!.start();
      print('SignalR Chat Connection Started Successfully');
    } catch (e) {
      print('SignalR Chat Connection Error: $e');
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> sendMessage(String receiverId, String content) async {
    if (_chatConnection?.state == HubConnectionState.connected) {
      await _chatConnection!.invoke('SendMessage', args: [receiverId, content]);
    } else {
      throw Exception('SignalR Connection is not active');
    }
  }

  Future<void> disconnect() async {
    if (_chatConnection != null) {
      await _chatConnection!.stop();
      _chatConnection = null;
    }
  }
}
