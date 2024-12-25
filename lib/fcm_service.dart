import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String KEY_FCM_TOKEN = 'fcm_token';
const String TOPIC_ALL_USERS = 'all_users';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static late SharedPreferences _prefs;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();
    if (Platform.isIOS) {
    await _firebaseMessaging.getAPNSToken();
  }


    // Initialize local notifications
    await _initializeLocalNotifications();

    // Configure message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received foreground message: ${message.messageId}");
      print("Notification: ${message.notification?.title}");
      print("Data: ${message.data}");
      _showNotification(message);
    });

    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Get the token
    String? newToken = await _firebaseMessaging.getToken();
    if (newToken != null) {
      print('New FCM Token: $newToken');
      await _handleTokenUpdate(newToken);
    }

    // Listen for token refreshes
    _firebaseMessaging.onTokenRefresh.listen(_handleTokenUpdate);
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    // await _localNotifications
    //     .resolvePlatformSpecificImplementation
    //         AndroidFlutterLocalNotificationsPlugin>()
    //     ?.createNotificationChannel(channel);
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    if (message.notification != null) {
      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableLights: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      final DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        platformChannelSpecifics,
        payload: message.data.toString(),
      );
    }
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped with payload: ${response.payload}');
    // Add your navigation logic here
  }

  static Future<void> _handleTokenUpdate(String newToken) async {
    try {
      await _firebaseMessaging.subscribeToTopic(TOPIC_ALL_USERS);
      print('Subscribed to topic: $TOPIC_ALL_USERS with token: $newToken');
      
      await _prefs.setString(KEY_FCM_TOKEN, newToken);
      print('New token saved: $newToken');
    } catch (e) {
      print('Error in handleTokenUpdate: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");
  print("Background notification: ${message.notification?.title}");
  print("Background data: ${message.data}");
}