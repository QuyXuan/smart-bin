import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FunctionItem {
  final String title;
  final FaIcon icon;
  final void Function() onTap;

  FunctionItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}
