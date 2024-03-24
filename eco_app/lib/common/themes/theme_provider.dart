import 'package:eco_app/common/services/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = ChangeNotifierProvider<ThemeProvider>((ref) {
  return ThemeProvider();
});

class ThemeProvider extends ChangeNotifier {
  bool isDarkMode = false;

  ThemeProvider() {
    Store.getTheme().then((value) {
      isDarkMode = value ?? false;
      notifyListeners();
    });
  }

  Future setDarkMode() async {
    isDarkMode = true;
    await Store.setTheme(isDarkMode);
    notifyListeners();
  }

  Future setLightMode() async {
    isDarkMode = false;
    await Store.setTheme(isDarkMode);
    notifyListeners();
  }
}
