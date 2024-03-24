import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eco_app/common/extensions/notification_controller.dart';
import 'package:eco_app/common/features/home/home.dart';
import 'package:eco_app/common/routes/routes.dart';
import 'package:eco_app/common/services/notification_service.dart';
import 'package:eco_app/common/themes/dark_theme.dart';
import 'package:eco_app/common/themes/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isAllowedToSendNotifications =
      await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedToSendNotifications) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
  await NotificationService.initializeNotification();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationController.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Eco App',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: ThemeMode.light,
      onGenerateRoute: Routes.onGenerateRoute,
      home: const HomePage(),
    );
  }
}
