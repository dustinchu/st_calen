// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockAdapter extends TypeAdapter<_$StockImpl> {
  @override
  final int typeId = 3;

  @override
  _$StockImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$StockImpl(
      symbol: fields[0] as String,
      market: fields[1] as Market,
      name: fields[2] as String,
      sector: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, _$StockImpl obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.market)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.sector);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StockImpl _$$StockImplFromJson(Map<String, dynamic> json) => _$StockImpl(
      symbol: json['symbol'] as String,
      market: $enumDecode(_$MarketEnumMap, json['market']),
      name: json['name'] as String,
      sector: json['sector'] as String?,
    );

Map<String, dynamic> _$$StockImplToJson(_$StockImpl instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'market': _$MarketEnumMap[instance.market]!,
      'name': instance.name,
      'sector': instance.sector,
    };

const _$MarketEnumMap = {
  Market.tw: 'tw',
  Market.us: 'us',
};
