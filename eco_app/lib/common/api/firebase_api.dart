import 'dart:developer';

import 'package:eco_app/common/models/servo.dart';
import 'package:eco_app/common/routes/routes.dart';
import 'package:eco_app/common/services/store.dart';
import 'package:eco_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _firebaseDatabase = FirebaseDatabase.instance;

  Future<void> initFunctions() async {
    await authenticateUser();
    await initNotification();
  }

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    log('FCM Token: $fCMToken');
    initPushNotification();
    if (fCMToken!.isNotEmpty) {
      await Store.setDeviceToken(fCMToken);
    }
  }

  Future<void> authenticateUser() async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: "quyxuan@gmail.com",
      password: "Quy1@123",
    );
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

  void updateServo(String servoName, int state) {
    if (_firebaseAuth.currentUser != null) {
      try {
        _firebaseDatabase.ref("servos").child(servoName).set(state);
      } catch (e) {
        log(e.toString());
      }
    } else {
      log('User is not authenticated!');
    }
  }

  Future<List<Servo>> getServos() async {
    final event = await _firebaseDatabase.ref("servos").once();
    final snapshot = event.snapshot;
    final servos = <Servo>[];

    if (snapshot.value != null) {
      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
      data.forEach((key, value) {
        final servo = Servo.fromMap(key, value as int);
        servos.add(servo);
      });
    }
    return servos;
  }
}
