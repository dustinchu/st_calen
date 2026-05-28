// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuoteAdapter extends TypeAdapter<_$QuoteImpl> {
  @override
  final int typeId = 5;

  @override
  _$QuoteImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$QuoteImpl(
      symbol: fields[0] as String,
      date: fields[1] as DateTime,
      close: fields[2] as double,
      open: fields[3] as double?,
      high: fields[4] as double?,
      low: fields[5] as double?,
      changePercent: fields[6] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, _$QuoteImpl obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.close)
      ..writeByte(3)
      ..write(obj.open)
      ..writeByte(4)
      ..write(obj.high)
      ..writeByte(5)
      ..write(obj.low)
      ..writeByte(6)
      ..write(obj.changePercent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuoteImpl _$$QuoteImplFromJson(Map<String, dynamic> json) => _$QuoteImpl(
      symbol: json['symbol'] as String,
      date: DateTime.parse(json['date'] as String),
      close: (json['close'] as num).toDouble(),
      open: (json['open'] as num?)?.toDouble(),
      high: (json['high'] as num?)?.toDouble(),
      low: (json['low'] as num?)?.toDouble(),
      changePercent: (json['changePercent'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$QuoteImplToJson(_$QuoteImpl instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'date': instance.date.toIso8601String(),
      'close': instance.close,
      'open': instance.open,
      'high': instance.high,
      'low': instance.low,
      'changePercent': instance.changePercent,
    };
