import 'package:flutter/material.dart';

class Routes {
  static const String welcome = "welcome";
  static const String login = "login";
  static const String signUp = "sign-up";
  static const String home = "home";

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(),
        );

      // case login:
      //   return MaterialPageRoute(
      //     builder: (context) => const LoginPage(),
      //   );

      // case signUp:
      //   return MaterialPageRoute(
      //     builder: (context) => const SignUpPage(),
      //   );

      // case home:
      //   final Map args = settings.arguments as Map;
      //   return MaterialPageRoute(
      //     builder: (context) => HomePage(
      //       todoItemId: args["todoItemId"],
      //     ),
      //   );

      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('No page route provided'),
            ),
          ),
        );
    }
  }
}
