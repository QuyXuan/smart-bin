import 'package:eco_app/common/models/predict_item.dart';
import 'package:hive/hive.dart';

class PredictService {
  final String _boxName = 'predictList';

  Future<Box<PredictItem>> get _box async =>
      await Hive.openBox<PredictItem>(_boxName);

  Future<void> addPredictItem(PredictItem predictItem) async {
    var box = await _box;
    await box.add(predictItem);
  }

  Future<List<PredictItem>> getPredictItems() async {
    var box = await _box;
    return box.values.toList();
  }

  Future<void> deletePredictItem(String id) async {
    var box = await _box;
    final keyToDelete = box.keys.firstWhere((k) {
      var item = box.get(k);
      return item != null && item.id == id;
    }, orElse: () => null);
    if (keyToDelete != null) {
      await box.delete(keyToDelete);
    }
    return;
  }

  Future<void> deleteAllPredictItems() async {
    var box = await _box;
    await box.clear();
  }
}
