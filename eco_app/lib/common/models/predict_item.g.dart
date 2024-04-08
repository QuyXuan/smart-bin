// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'predict_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PredictItemAdapter extends TypeAdapter<PredictItem> {
  @override
  final int typeId = 1;

  @override
  PredictItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PredictItem(
      id: fields[0] as String,
      name: fields[1] as String,
      accuracy: fields[2] as double,
      imageUint8List: fields[3] as Uint8List,
    );
  }

  @override
  void write(BinaryWriter writer, PredictItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.accuracy)
      ..writeByte(3)
      ..write(obj.imageUint8List);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
