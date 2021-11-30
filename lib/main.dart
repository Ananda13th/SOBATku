// @dart=2.9
import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobatku/helper/constant.dart';
import 'package:sobatku/page/halaman_intro.dart';
import 'package:sobatku/page/halaman_utama.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'helper/local_notification.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  messageHandler();
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );// To turn off landscape mode
  HttpOverrides.global = new MyHttpOverrides();
  runApp(App());
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

class App extends StatelessWidget  {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'SobatKu',
      theme: ThemeData(
          primaryColor: Constant.color,
          accentColor: Constant.color,
          buttonColor: Constant.color,
      ),
      home: Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<Splash> with AfterLayoutMixin<Splash> {

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new MyApp()));
    } else {
      await prefs.setBool('seen', true);
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new IntroScreen()));
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: CircularProgressIndicator()
      ),
    );
  }
}

/*------------ Bottom Navigation & Main Screen ------------*/



Future<void> messageHandler() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    LocalNotification.showNotification(event);
  });

}

Future<void> _messageHandler(RemoteMessage message) async {
  AudioCache cache = new AudioCache();
  await cache.play("sounds/notification.mp3");
  await Firebase.initializeApp();
}



















