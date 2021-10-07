import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotification {
  static Future<void> showNotification(RemoteMessage payload) async {
    var android = AndroidInitializationSettings('app_icon');
    var initiallizationSettingsIOS = IOSInitializationSettings();
    var initialSetting = new InitializationSettings(android: android, iOS: initiallizationSettingsIOS);
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initialSetting);

    // Parsing ID Notifikasi
    final int idNotification = 1;


    // Daftar jenis notifikasi dari aplikasi.

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'BBD', 'Notification', 'All Notification is Here',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        icon: "app_icon");
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    // Menampilkan Notifikasi
    await flutterLocalNotificationsPlugin.show(
        idNotification, payload.notification!.title, payload.notification!.body, platformChannelSpecifics);
  }

  // Future<void> notificationHandler(GlobalKey<NavigatorState> navigatorKey) async {
  //   // Pengaturan Notifikasi
  //
  //   // AndroidInitializationSettings default value is 'app_icon'
  //   const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('logo_bbd_sm');
  //   final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  //
  //   // Handling notifikasi yang di tap oleh pengguna
  //   flutterLocalNotificationsPlugin.initialize(initializationSettings,
  //       onSelectNotification: (String payload) async {
  //         if (payload != null) {
  //           NavigatorNavigate().go(navigatorKey, payload);
  //         }
  //       });
  // }
}