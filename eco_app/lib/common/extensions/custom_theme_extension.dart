import 'package:eco_app/common/utils/common_colors.dart';
import 'package:flutter/material.dart';

extension ExtendedTheme on BuildContext {
  CustomThemeExtension get theme =>
      Theme.of(this).extension<CustomThemeExtension>()!;
}

class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Color? circleImageColor;
  final Color? backgroundColor;
  final Color? modalBackgroundColor;
  final Color? textColor;
  final Color? greyColor;
  final Color? rubyBlue;
  final Color? urineBlue;
  final Color? ghostWhite;
  final Color? green;
  final Color? darkGreen;
  final Color? textBlue;

  static const lightMode = CustomThemeExtension(
    circleImageColor: Color(0xFF25D366),
    backgroundColor: CommonColors.backgroundLight,
    modalBackgroundColor: CommonColors.modalBackgroundColorLight,
    textColor: Colors.black,
    greyColor: CommonColors.greyLight,
    rubyBlue: CommonColors.rubyBlue,
    urineBlue: CommonColors.urineBlue,
    ghostWhite: CommonColors.ghostWhite,
    green: CommonColors.green,
    darkGreen: CommonColors.darkGreen,
    textBlue: CommonColors.textBlue,
  );

  static const darkMode = CustomThemeExtension(
    circleImageColor: CommonColors.greenDark,
    backgroundColor: CommonColors.backgroundDark,
    modalBackgroundColor: CommonColors.modalBackgroundColorDark,
    textColor: CommonColors.textColorDark,
    greyColor: CommonColors.greyDark,
    rubyBlue: CommonColors.rubyBlue,
    urineBlue: CommonColors.urineBlue,
    ghostWhite: CommonColors.ghostWhite,
    green: CommonColors.darkGreen,
    darkGreen: CommonColors.green,
    textBlue: CommonColors.textBlue,
  );

  const CustomThemeExtension({
    this.backgroundColor,
    this.modalBackgroundColor,
    this.textColor,
    this.circleImageColor,
    this.greyColor,
    this.rubyBlue,
    this.urineBlue,
    this.ghostWhite,
    this.green,
    this.darkGreen,
    this.textBlue,
  });

  @override
  ThemeExtension<CustomThemeExtension> copyWith({
    Color? circleImageColor,
  }) {
    return CustomThemeExtension(
      circleImageColor: circleImageColor ?? this.circleImageColor,
      textColor: textColor,
      backgroundColor: backgroundColor,
      modalBackgroundColor: modalBackgroundColor,
      greyColor: greyColor,
      rubyBlue: rubyBlue,
      urineBlue: urineBlue,
      ghostWhite: ghostWhite,
      green: green,
      darkGreen: darkGreen,
      textBlue: textBlue,
    );
  }

  @override
  ThemeExtension<CustomThemeExtension> lerp(
      covariant ThemeExtension<CustomThemeExtension>? other, double t) {
    if (other is! CustomThemeExtension) {
      return this;
    }
    return CustomThemeExtension(
      circleImageColor: Color.lerp(circleImageColor, other.circleImageColor, t),
      textColor: Color.lerp(textColor, other.textColor, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      modalBackgroundColor:
          Color.lerp(modalBackgroundColor, other.modalBackgroundColor, t),
      greyColor: Color.lerp(greyColor, other.greyColor, t),
      rubyBlue: Color.lerp(rubyBlue, other.rubyBlue, t),
      urineBlue: Color.lerp(urineBlue, other.urineBlue, t),
      ghostWhite: Color.lerp(ghostWhite, other.ghostWhite, t),
      green: Color.lerp(green, other.green, t),
      darkGreen: Color.lerp(darkGreen, other.darkGreen, t),
      textBlue: Color.lerp(textBlue, other.textBlue, t),
    );
  }
}
