import 'package:eco_app/common/extensions/custom_theme_extension.dart';
import 'package:eco_app/common/utils/common_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData lightTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    colorScheme: const ColorScheme.light(
      surface: CommonColors.backgroundLight,
    ),
    scaffoldBackgroundColor: CommonColors.backgroundLight,
    extensions: [
      CustomThemeExtension.lightMode,
    ],
    appBarTheme: const AppBarTheme(
      backgroundColor: CommonColors.greenLight,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
    ),
    tabBarTheme: const TabBarTheme(
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: CommonColors.greenLight,
          width: 2,
        ),
      ),
      unselectedLabelColor: Color(0xFFB3D9D2),
      labelColor: CommonColors.greenLight,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CommonColors.greenLight,
        foregroundColor: CommonColors.backgroundLight,
        splashFactory: NoSplash.splashFactory,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: CommonColors.backgroundLight,
      modalBackgroundColor: CommonColors.backgroundLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
        ),
      ),
    ),
    dialogBackgroundColor: CommonColors.backgroundLight,
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: CommonColors.greenDark,
      foregroundColor: Colors.white,
    ),
  );
}
