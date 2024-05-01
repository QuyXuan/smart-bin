import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
part 'predict_item.g.dart';

// Run migration command: flutter packages pub run build_runner build --delete-conflicting-outputs

@HiveType(typeId: 1)
class PredictItem {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double accuracy;

  @HiveField(3)
  Uint8List imageUint8List;

  PredictItem({
    required this.id,
    required this.name,
    required this.accuracy,
    required this.imageUint8List,
  });
}
