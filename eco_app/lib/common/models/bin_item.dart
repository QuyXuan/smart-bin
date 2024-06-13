import 'package:flutter/widgets.dart';

class BinItem {
  final String id;
  final String name;
  bool isOpen;
  final String imageDir;
  final Color color;

  BinItem({
    required this.id,
    required this.name,
    required this.isOpen,
    required this.imageDir,
    required this.color,
  });

  factory BinItem.fromJson(Map<String, dynamic> json) {
    return BinItem(
      id: json['id'],
      name: json['name'],
      isOpen: json['isOpen'],
      imageDir: json['imageDir'],
      color: json['color'],
    );
  }
}
