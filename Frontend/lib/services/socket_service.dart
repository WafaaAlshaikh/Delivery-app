// lib/services/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../core/constants/api_constants.dart';
import 'storage_service.dart';

class SocketService {
  static IO.Socket? _socket;
  static bool _isConnected = false;

  static IO.Socket getSocket() {
    if (_socket == null) {
      _initializeSocket();
    }
    return _socket!;
  }

  static void _initializeSocket() async {
    final token = await StorageService().getToken();
    
    _socket = IO.io(ApiConstants.baseUrl, {
      'transports': ['websocket', 'polling'],
      'path': '/socket.io',
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
      'auth': {
        'token': token,
      },
    });

    _socket?.onConnect((_) {
      _isConnected = true;
      print('🔌 Socket connected');
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
      print('🔌 Socket disconnected');
    });

    _socket?.onConnectError((error) {
      print('❌ Socket connection error: $error');
    });

    _socket?.onError((error) {
      print('❌ Socket error: $error');
    });
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
  }

  static bool isConnected() => _isConnected;

  static void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  static void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  static void off(String event) {
    _socket?.off(event);
  }
}