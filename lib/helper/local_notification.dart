import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotification {
  static Future<void> showNotification(RemoteMessage payload) async {
    AudioCache cache = new AudioCache();
    await cache.play("sounds/notification.mp3");
    var android = AndroidInitializationSettings('logo_rs');
    var initiallizationSettingsIOS = IOSInitializationSettings();
    var initialSetting = new InitializationSettings(android: android, iOS: initiallizationSettingsIOS);
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initialSetting);

    // Daftar jenis notifikasi dari aplikasi.

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'default_notification_channel_id',
        'Notification',
        'All Notification is Here',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        icon: "logo_rs",
        playSound: true,
        sound: RawResourceAndroidNotificationSound("notification")
    );
    const iOSDetails = IOSNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidDetails, iOS: iOSDetails);
    // Menampilkan Notifikasi
    await flutterLocalNotificationsPlugin.show(0, payload.notification!.title, payload.notification!.body, platformChannelSpecifics);
  }
}