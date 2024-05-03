import 'package:eco_app/common/api/firebase_api.dart';
import 'package:eco_app/common/features/home/home.dart';
import 'package:eco_app/common/models/predict_item.dart';
import 'package:eco_app/common/routes/routes.dart';
import 'package:eco_app/common/services/api_service.dart';
import 'package:eco_app/common/services/store.dart';
import 'package:eco_app/common/themes/dark_theme.dart';
import 'package:eco_app/common/themes/light_theme.dart';
import 'package:eco_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotification();
  await Hive.initFlutter();
  Hive.registerAdapter(PredictItemAdapter());
  await Hive.openBox<PredictItem>("predictList");
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
    super.initState();
    Store.getDeviceToken().then((token) {
      if (token == null) {
        return;
      }
      ref
          .read(apiServiceProvider)
          .dioRegisterDeviceToken(token)
          .then((value) => null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
