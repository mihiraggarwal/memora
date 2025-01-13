import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:memora/main.dart';

// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   print("Title ${message.notification?.title}");
//   print("Body ${message.notification?.body}");
//   print("Payload ${message.data}");
// }

class Messaging {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Channel',
    description: "This channel is used for important notifications",
    importance: Importance.high
  );

  final _localNotification = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    navigatorKey.currentState?.pushNamed(
      MyApp.id,
      arguments: message
    );
  }

  Future initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');

    const settings = InitializationSettings(android: android, iOS: iOS);

    await _localNotification.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        final message = RemoteMessage.fromMap(jsonDecode(notificationResponse.payload as String));
        handleMessage(message);
      }
    );

    if (Platform.isAndroid) {
      final platform = _localNotification.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await platform?.createNotificationChannel(_androidChannel);
    }

    else if (Platform.isIOS) {
      final platform = _localNotification.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      await platform?.requestPermissions(
        alert: true,
        badge: true,
        sound: true
      );
    }
  }

  Future initPushNotifications() async {
    // for iOS
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true
    );

    // for when the app is opened from a terminated state via the notification
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    // for when the app is opened from a background state via the notification
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    // FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // for when the app is in the foreground and a notification is received
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotification.show(
        notification.hashCode,
        notification.title,
        notification.body,

        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
          )
        ),
        payload: jsonEncode(message.toMap())
      );
    });
  }

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print("token: " + fCMToken!);

    initPushNotifications();
    initLocalNotifications();
  }
}