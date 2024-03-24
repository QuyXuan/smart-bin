import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'eco_app',
        channelName: "Eco App",
        channelGroupKey: "eco-app-group",
        channelDescription: "Notification channel for basic notifications",
        defaultColor: Colors.transparent,
        locked: true,
        enableVibration: true,
        playSound: true,
      ),
    ], channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: "eco-app-group",
        channelGroupName: "Eco App",
      ),
    ]);
  }

  static Future<void> scheduleNotification(
      {required int hour,
      required int minute,
      int? weekDay,
      int? monthDay}) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        payload: {"": ""},
        channelKey: "goblin_tools",
        title: "You have a task to finish today!",
        body: "",
        category: NotificationCategory.Alarm,
        notificationLayout: NotificationLayout.BigText,
        locked: true,
        wakeUpScreen: true,
        autoDismissible: false,
        fullScreenIntent: true,
        backgroundColor: Colors.transparent,
      ),
      schedule: NotificationCalendar(
        second: 0,
        millisecond: 0,
        minute: minute,
        hour: hour,
        day: monthDay,
        weekday: weekDay,
        repeats: true,
        preciseAlarm: true,
        allowWhileIdle: true,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
      ),
      actionButtons: [
        NotificationActionButton(
          key: "Close",
          label: "Close",
          autoDismissible: true,
        ),
        NotificationActionButton(
          key: "Detail",
          label: "View Detail",
          autoDismissible: true,
        ),
      ],
    );
  }
}
