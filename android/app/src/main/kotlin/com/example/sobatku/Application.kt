//package com.example.sobatku
//
//import io.flutter.app.FlutterApplication
//import io.flutter.plugin.common.PluginRegistry
//import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
//import io.flutter.view.FlutterMain
//import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService
//import io.flutter.plugins.pathprovider.PathProviderPlugin
//import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin
//import io.flutter.plugins.GeneratedPluginRegistrant
//
//class Application : FlutterApplication(), PluginRegistrantCallback {
//    override fun onCreate() {
//        super.onCreate()
//        FlutterFirebaseMessagingBackgroundService.setPluginRegistrant(this);
//    }
//    override fun registerWith(registry: PluginRegistry) {
//        PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
//        FlutterLocalNotificationsPlugin.registerWith(registry!!.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"));
//    }
//}