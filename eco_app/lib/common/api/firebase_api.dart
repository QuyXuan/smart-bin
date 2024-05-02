import 'dart:developer';

import 'package:eco_app/common/routes/routes.dart';
import 'package:eco_app/common/services/store.dart';
import 'package:eco_app/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    log('FCM Token: $fCMToken');
    initPushNotification();
    if (fCMToken!.isNotEmpty) {
      await Store.setDeviceToken(fCMToken);
    }
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) {
      return;
    }
    navigatorKey.currentState!.pushNamed(Routes.home);
  }

  Future initPushNotification() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
