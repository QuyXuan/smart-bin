import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final _notification = FlutterLocalNotificationsPlugin();

  static init() {
    _notification.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  static pushNotification({
    required String title,
    required String body,
    bool isToggleServo = false,
  }) async {
    var androidDetails = const AndroidNotificationDetails(
      'eco_app_channel',
      "Eco App",
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );
    var iOSDetails = const DarwinNotificationDetails();
    var notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);
    await _notification.show(
        isToggleServo ? 2804 : 2003, title, body, notificationDetails);
  }
}
