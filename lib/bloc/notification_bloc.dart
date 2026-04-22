import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_base/api/device_api.dart';
import 'package:flutter_app_base/bloc/auth_bloc.dart';
import 'package:flutter_app_base/firebase_options.dart';
import 'package:flutter_app_base/mixins/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _handleBackgroundMessage(RemoteMessage remoteMessage) async {
  // await Firebase.initializeApp(); // Uncomment if you're going to use other Firebase services in the background, such as Firestore.
  final Map message = remoteMessage.data;
  print('_handleBackgroundMessage: $message'); // ignore: avoid_print
}

class NotificationBloc with Logger {
  static NotificationBloc? _instance;

  factory NotificationBloc() {
    return _instance ??= NotificationBloc._();
  }

  static Future<NotificationBloc> reset() async {
    await _instance?._dispose();
    final bloc = NotificationBloc._();
    _instance = bloc;
    await bloc.initialize();
    return bloc;
  }

  final DeviceApi _api = DeviceApi();

  final FirebaseMessaging? _firebaseMessaging =
      DefaultFirebaseOptions.isConfigured ? FirebaseMessaging.instance : null;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  StreamSubscription? _loginResultStreamSubscription;
  StreamSubscription? _onMessageSubscription;
  StreamSubscription? _onMessageOpenedSubscription;

  NotificationBloc._();

  Future<void> _dispose() async {
    _instance = null;
    await _loginResultStreamSubscription?.cancel();
    await _onMessageSubscription?.cancel();
    await _onMessageOpenedSubscription?.cancel();
    _loginResultStreamSubscription = null;
    _onMessageSubscription = null;
    _onMessageOpenedSubscription = null;
  }

  Future<void> initialize() async {
    log.finest('initialize()');
    _loginResultStreamSubscription?.cancel();
    _onMessageSubscription?.cancel();
    _onMessageOpenedSubscription?.cancel();

    if (!DefaultFirebaseOptions.isConfigured) return;

    await _firebaseMessaging?.requestPermission();
    const initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );
    _onMessageSubscription =
        FirebaseMessaging.onMessage.listen(_handleMessage);
    if (!Platform.isIOS) {
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    }
    await initTappedMessages();

    final token = await _firebaseMessaging?.getToken();
    log.info('FCM Token: $token');
    if (token != null && token.isNotEmpty) {
      _loginResultStreamSubscription =
          AuthBloc().currentUserStream.listen((_) async {
        await _registerDeviceWithRetry();
      });
    }
  }

  Future<void> unregisterDevice() async {
    try {
      await _api.unregister(await _firebaseMessaging?.getToken() ?? '');
      log.info('Unregister device: success!');
    } catch (error, stackTrace) {
      log.severe('Unregister device: failure!', error, stackTrace);
      rethrow;
    }
  }

  Future<void> initTappedMessages() async {
    final initialMessage = await _firebaseMessaging?.getInitialMessage();

    if (initialMessage != null) {
      // The app was opened from a terminated state by tapping a notification
      _handleNotificationTap(initialMessage, isLaunching: true);
    }

    _onMessageOpenedSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  void _handleNotificationTap(
    RemoteMessage remoteMessage, {
    bool isLaunching = false,
  }) {
    // Now handles launching and resuming..
    final Map data = remoteMessage.data;
    log.info('_handleNotificationTap: $data');
  }

  void _handleMessage(RemoteMessage remoteMessage) {
    final Map data = remoteMessage.data;
    log.info('_handleMessage: $data');
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'app_alerts',
      'App Alerts',
      channelDescription:
          'Alerts received while the app is running',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_launcher',
    );
    const iosPlatformChannelSpecifics = DarwinNotificationDetails();
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    final notification = remoteMessage.notification;

    if (notification == null) {
      log.info('data only message');
      return;
    }

    _flutterLocalNotificationsPlugin.show(
      id: 0,
      title: notification.title,
      body: notification.body,
      notificationDetails: platformChannelSpecifics,
      payload: json.encode(data),
    );
  }

  Future<void> _onSelectNotification(NotificationResponse response) async {
    log.info('_onSelectNotification: ${response.payload}');
  }

  Future<void> _registerDeviceWithRetry() async {
    const maxAttempts = 3;
    const baseDelay = Duration(seconds: 2);

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final freshToken = await _firebaseMessaging?.getToken();
      if (freshToken == null || freshToken.isEmpty) return;

      try {
        await _api.register(freshToken);
        log.info('Register device: success!');
        return;
      } catch (error, stackTrace) {
        log.severe(
          'Register device: attempt $attempt/$maxAttempts failed',
          error,
          stackTrace,
        );
        if (attempt < maxAttempts) {
          await Future.delayed(baseDelay * attempt);
        }
      }
    }
  }
}
