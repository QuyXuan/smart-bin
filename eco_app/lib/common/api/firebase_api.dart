import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:eco_app/common/helpers/notification_helper.dart';
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
  List<String> compartmentNames = ['recyclable', 'danger', 'organic', 'glass'];
  final player = AudioPlayer();

  Future<void> initFunctions() async {
    await authenticateUser();
    await initNotification();
    listenFullGarbage();
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

  void listenFullGarbage() {
    for (String name in compartmentNames) {
      _firebaseDatabase
          .ref("compartments/$name/is_full")
          .onValue
          .listen((event) async {
        final snapshot = event.snapshot;
        final bool? isFull = snapshot.value as bool?;
        if (isFull!) {
          log(name);
          await player.setSource(AssetSource("audios/$name.mp3"));
          await player.resume();
        }
      });
    }
  }

  Future initPushNotification() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationHelper.pushNotification(
        title: message.notification!.title ?? "Smart Bin",
        body: message.notification!.body ?? "Eco App",
      );
    });
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

  void updateServo(String name, bool value) {
    if (_firebaseAuth.currentUser != null) {
      try {
        _firebaseDatabase
            .ref("compartments")
            .child(name)
            .update({"is_open": value});
      } catch (e) {
        log(e.toString());
      }
    } else {
      log('User is not authenticated!');
    }
  }

  void notifyServo(int type) {
    if (_firebaseAuth.currentUser != null) {
      try {
        _firebaseDatabase.ref("compartments").child("speaker_type").set(type);
      } catch (e) {
        log(e.toString());
      }
    } else {
      log('User is not authenticated!');
    }
  }

  Future<List<Compartment>> getCompartments() async {
    final event = await _firebaseDatabase.ref("compartments").once();
    final snapshot = event.snapshot;
    final servos = <Compartment>[];

    if (snapshot.value != null) {
      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
      data.forEach((key, value) {
        final servo =
            Compartment.fromMap(key, Map<String, dynamic>.from(value));
        servos.add(servo);
      });
    }
    return servos;
  }

  void updateEsp32(String name) {
    if (_firebaseAuth.currentUser != null) {
      try {
        _firebaseDatabase.ref("esp32").update({
          "compartment_name": name,
          "has_garbage": true,
        });
        Future.delayed(const Duration(seconds: 4), () {
          NotificationHelper.pushNotification(
            title: "GARBAGE CLASSIFICATION!!!",
            body: "Predicted class: $name",
          );
        });
      } catch (e) {
        log(e.toString());
      }
    } else {
      log('User is not authenticated!');
    }
  }
}
