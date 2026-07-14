// lib/services/notification_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:convert';
import 'storage_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final _onNotificationStream = BehaviorSubject<RemoteMessage?>.seeded(null);
  Stream<RemoteMessage> get onNotificationStream =>
      _onNotificationStream.stream.where((event) => event != null).cast();

  final _onOrderNotification = BehaviorSubject<Map<String, dynamic>>.seeded({});
  Stream<Map<String, dynamic>> get onOrderNotification =>
      _onOrderNotification.stream.where((event) => event.isNotEmpty).cast();

  Future<void> initialize() async {
    try {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);

      if (!kIsWeb) {
        await _initializeLocalNotifications();
      }

      await _requestPermissions();

      await _getAndStoreToken();

      _setupListeners();

      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      }

      debugPrint('✅ Notification Service initialized successfully');
    } catch (e) {
      debugPrint('❌ Notification Service initialization error: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
    );
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('📱 Notification tapped: ${response.payload}');
    if (response.payload != null) {
      _handleNotificationTap(response.payload!);
    }
  }

  void _onBackgroundNotificationResponse(NotificationResponse response) {
    debugPrint('📱 Background notification tapped: ${response.payload}');
    if (response.payload != null) {
      _handleNotificationTap(response.payload!);
    }
  }

  Future<void> _handleNotificationTap(String payload) async {
    try {
      final data = Map<String, dynamic>.from(jsonDecode(payload));
      _onOrderNotification.add(data);
    } catch (e) {
      debugPrint('❌ Error handling notification tap: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
        provisional: false,
      );
      debugPrint('📱 Notification permission: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
    }
  }

  Future<void> _getAndStoreToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('📱 FCM Token: $token');
        await StorageService().saveFCMToken(token);
        await _sendTokenToServer(token);
      }
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      debugPrint('📤 Sending token to server: $token');
    } catch (e) {
      debugPrint('❌ Error sending token to server: $e');
    }
  }

  void _setupListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📨 Received notification: ${message.notification?.title}');
      if (!kIsWeb) {
        _showLocalNotification(message);
      }
      _onNotificationStream.add(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📨 Notification opened: ${message.data}');
      _handleNotificationPayload(message.data);
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 FCM Token refreshed: $newToken');
      _sendTokenToServer(newToken);
    });
  }

  static Future<void> sendPushNotification({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
   
      debugPrint('📤 Would send notification to $token: $title - $body');
      
   
    } catch (e) {
      debugPrint('❌ Error sending push notification: $e');
    }
  }

  static Future<void> sendLowRatingNotification(
    String token,
    String driverName,
    double rating,
    String comment,
    int orderId,
  ) async {
    await sendPushNotification(
      token: token,
      title: '⚠️ Low Rating Alert',
      body: '$driverName, you received a ${rating.toStringAsFixed(1)}⭐ rating: "$comment"',
      data: {
        'type': 'low_rating',
        'order_id': orderId.toString(),
        'rating': rating.toString(),
      },
    );
  }

  static Future<void> sendExcellentRatingNotification(
    String token,
    String driverName,
    double rating,
    String comment,
    int orderId,
  ) async {
    await sendPushNotification(
      token: token,
      title: '🌟 Excellent Rating!',
      body: '$driverName, you received a ${rating.toStringAsFixed(1)}⭐ rating!',
      data: {
        'type': 'excellent_rating',
        'order_id': orderId.toString(),
        'rating': rating.toString(),
      },
    );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (kIsWeb) return;

    try {
      final title = message.notification?.title ?? 'New Notification';
      final body = message.notification?.body ?? '';
      final payload = jsonEncode(message.data);
      final id = DateTime.now().millisecondsSinceEpoch.toInt();

      const androidDetails = AndroidNotificationDetails(
        'delivery_channel',
        'Delivery Notifications',
        channelDescription: 'Notifications about your deliveries',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('❌ Error showing local notification: $e');
    }
  }

  Future<void> showCustomNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (kIsWeb) {
      debugPrint('🌐 Web notification: $title - $body');
      return;
    }

    final payload = data != null ? jsonEncode(data) : null;
    final id = DateTime.now().millisecondsSinceEpoch.toInt();

    const androidDetails = AndroidNotificationDetails(
      'custom_channel',
      'Custom Notifications',
      channelDescription: 'Custom notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await _localNotifications.cancelAll();
  }

  Future<void> _handleNotificationPayload(Map<String, dynamic> data) async {
    try {
      final type = data['type'] ?? 'general';
      switch (type) {
        case 'order':
          debugPrint('📦 New order notification: ${data['orderId']}');
          _onOrderNotification.add(data);
          break;
        case 'driver_status':
          debugPrint('🚗 Driver status updated: ${data['status']}');
          break;
        default:
          debugPrint('📨 General notification: $data');
      }
    } catch (e) {
      debugPrint('❌ Error handling notification payload: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📨 Background message: ${message.notification?.title}');
  await Firebase.initializeApp();
  final notification = NotificationService();
  await notification.showCustomNotification(
    title: message.notification?.title ?? 'New Notification',
    body: message.notification?.body ?? '',
    data: message.data,
  );
}