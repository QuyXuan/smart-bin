import 'package:flutter/widgets.dart';

class BinItem {
  final String id;
  final String name;
  final String servoName;
  bool state;
  final String imageDir;
  final Color color;

  BinItem({
    required this.id,
    required this.name,
    required this.servoName,
    required this.state,
    required this.imageDir,
    required this.color,
  });

  factory BinItem.fromJson(Map<String, dynamic> json) {
    return BinItem(
      id: json['id'],
      name: json['name'],
      servoName: json['servoName'],
      state: json['state'],
      imageDir: json['imageDir'],
      color: json['color'],
    );
  }
}
