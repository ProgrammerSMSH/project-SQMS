// Note: Ensure `socket_io_client` is in pubspec.yaml
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService extends ChangeNotifier {
  IO.Socket? socket;
  final String serverUrl = 'https://project-sqms.vercel.app'; // Live Vercel Socket

  void initSocket() {
    socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    socket!.onConnect((_) {
      print('Socket Connected');
    });

    socket!.onDisconnect((_) => print('Socket Disconnected'));
  }

  void joinQueue(String queueId, String userId) {
    if (socket != null && socket!.connected) {
      socket!.emit('join_queue', {
        'queueId': queueId,
        'userId': userId,
      });

      socket!.on('queue_updated', (data) {
        print("Live Queue Update: $data");
        // Update local state or dispatch to provider
        notifyListeners();
      });
    }
  }

  void disposeSocket() {
    socket?.disconnect();
    socket?.dispose();
  }
}
