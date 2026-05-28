// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarketAdapter extends TypeAdapter<Market> {
  @override
  final int typeId = 2;

  @override
  Market read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Market.tw;
      case 1:
        return Market.us;
      default:
        return Market.tw;
    }
  }

  @override
  void write(BinaryWriter writer, Market obj) {
    switch (obj) {
      case Market.tw:
        writer.writeByte(0);
        break;
      case Market.us:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
