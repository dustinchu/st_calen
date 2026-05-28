// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PredictionTypeAdapter extends TypeAdapter<PredictionType> {
  @override
  final int typeId = 0;

  @override
  PredictionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PredictionType.upLimit;
      case 1:
        return PredictionType.downLimit;
      case 2:
        return PredictionType.customPrice;
      case 3:
        return PredictionType.customPercent;
      case 4:
        return PredictionType.bullish;
      case 5:
        return PredictionType.bearish;
      default:
        return PredictionType.upLimit;
    }
  }

  @override
  void write(BinaryWriter writer, PredictionType obj) {
    switch (obj) {
      case PredictionType.upLimit:
        writer.writeByte(0);
        break;
      case PredictionType.downLimit:
        writer.writeByte(1);
        break;
      case PredictionType.customPrice:
        writer.writeByte(2);
        break;
      case PredictionType.customPercent:
        writer.writeByte(3);
        break;
      case PredictionType.bullish:
        writer.writeByte(4);
        break;
      case PredictionType.bearish:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
