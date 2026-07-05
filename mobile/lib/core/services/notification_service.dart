import 'package:signalr_core/signalr_core.dart';
import 'package:patient_management_app/core/constants/api_constants.dart';

class SignalRNotificationService {
  HubConnection? _connection;
  bool _isConnecting = false;

  HubConnectionState get state => _connection?.state ?? HubConnectionState.disconnected;

  Future<void> connect(
    String token, {
    required Function(String message) onNotificationReceived,
    required Function(String message) onBroadcastReceived,
  }) async {
    if (_connection != null && _connection!.state == HubConnectionState.connected) {
      return;
    }
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      final cleanBaseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
      final hubUrl = '$cleanBaseUrl/hubs/notifications';

      _connection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            HttpConnectionOptions(
              accessTokenFactory: () async => token,
            ),
          )
          .withAutomaticReconnect()
          .build();

      _connection!.on('ReceiveNotification', (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          final message = arguments[0] as String;
          onNotificationReceived(message);
        }
      });

      _connection!.on('ReceiveBroadcast', (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          final message = arguments[0] as String;
          onBroadcastReceived(message);
        }
      });

      _connection!.onclose((error) {
        // ignore: avoid_print
        print('SignalR Notification Connection Closed: $error');
      });

      await _connection!.start();
      // ignore: avoid_print
      print('SignalR Notification Connection Started Successfully');
    } catch (e) {
      // ignore: avoid_print
      print('SignalR Notification Connection Error: $e');
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> disconnect() async {
    if (_connection != null) {
      await _connection!.stop();
      _connection = null;
    }
  }
}
