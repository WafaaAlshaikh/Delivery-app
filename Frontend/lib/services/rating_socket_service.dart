// lib/services/rating_socket_service.dart

import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/socket_service.dart';

class RatingSocketService {
  static IO.Socket? _socket;

  static void init() {
    _socket = SocketService.getSocket();
    
    _socket?.on('new_rating', (data) {
      print('⭐ New rating received: $data');
    });

    _socket?.on('rating_updated', (data) {
      print('🔄 Rating updated: $data');
    });

    _socket?.on('rating_deleted', (data) {
      print('🗑️ Rating deleted: $data');
    });
  }

  static void onNewRating(Function(dynamic) callback) {
    _socket?.on('new_rating', callback);
  }

  static void onRatingUpdated(Function(dynamic) callback) {
    _socket?.on('rating_updated', callback);
  }

  static void onRatingDeleted(Function(dynamic) callback) {
    _socket?.on('rating_deleted', callback);
  }

  static void dispose() {
    _socket?.off('new_rating');
    _socket?.off('rating_updated');
    _socket?.off('rating_deleted');
  }
}