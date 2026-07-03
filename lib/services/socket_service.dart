import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class SocketService {
  // Singleton pattern
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final Box _messageQueue = Hive.box('offlineMessages');
  
  // Replace with your actual backend URL
  final String _socketUrl = 'https://humsafar.piyushassudani.in';

  void connect(String userId) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      _socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setQuery({'userId': userId}) // Map userId on the backend
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('Connected to Socket.io server');
      _syncOfflineMessages();
    });

    _socket!.onDisconnect((_) {
      debugPrint('Disconnected from Socket.io server');
    });

    _socket!.onConnectError((err) {
      debugPrint('Socket connect error: $err');
    });
    
    _socket!.onError((err) {
      debugPrint('Socket error: $err');
    });
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }

  Future<void> sendMessage(String senderId, String receiverId, String text) async {
    final payload = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(), // Temp local ID
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'isSent': false,
    };

    // 1. Save to local Hive box immediately
    await _messageQueue.put(payload['id'], payload);

    // 2. Try emitting if connected
    if (_socket != null && _socket!.connected) {
      _emitMessage(payload);
    }
  }

  void _emitMessage(Map<dynamic, dynamic> payload) {
    // We emit 'sendMessage'
    _socket!.emit('sendMessage', payload);
    // Since we don't have emitWithAck set up on backend standardly in the previous script,
    // we'll rely on the existing 'messageSent' event to confirm sent status!
  }

  void _syncOfflineMessages() {
    final pendingMessages = _messageQueue.values.where((msg) => msg['isSent'] == false).toList();
    for (var msg in pendingMessages) {
      _emitMessage(msg);
    }
  }

  // Allow the UI to register a callback for incoming messages
  void onReceiveMessage(Function(dynamic data) callback) {
    if (_socket == null) return;
    
    // Remove previous listeners to avoid duplicates if re-registering
    _socket!.off('receiveMessage');
    _socket!.on('receiveMessage', (data) {
      callback(data);
    });
  }
  
  // Handle message sending errors
  void onMessageError(Function(dynamic data) callback) {
    if (_socket == null) return;
    
    _socket!.off('messageError');
    _socket!.on('messageError', (data) {
      callback(data);
    });
  }
  
  // Acknowledge when a message is successfully stored in the backend
  void onMessageSent(Function(dynamic data) callback) {
    if (_socket == null) return;
    
    _socket!.off('messageSent');
    _socket!.on('messageSent', (data) {
      // Find the message in Hive by matching text (or if we passed temp id to backend)
      // Since backend doesn't know local ID, we match by text for MVP or just assume all sent
      // For a bulletproof fix, we could pass localId in payload and return it.
      // For now, let's just mark the most recent pending message as sent if text matches.
      
      final pendingMessages = _messageQueue.values.where((msg) => msg['isSent'] == false).toList();
      for (var msg in pendingMessages) {
        if (msg['text'] == data['text']) {
          msg['isSent'] = true;
          _messageQueue.put(msg['id'], msg);
          break; // Found and updated
        }
      }
      
      callback(data);
    });
  }
}
