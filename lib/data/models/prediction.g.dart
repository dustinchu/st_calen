// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PredictionAdapter extends TypeAdapter<_$PredictionImpl> {
  @override
  final int typeId = 1;

  @override
  _$PredictionImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$PredictionImpl(
      date: fields[0] as DateTime,
      type: fields[1] as PredictionType,
      price: fields[2] as double?,
      percent: fields[3] as double?,
      note: fields[4] as String?,
      settled: fields[5] as bool,
      actualClose: fields[6] as double?,
      hitPercent: fields[7] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, _$PredictionImpl obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.percent)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.settled)
      ..writeByte(6)
      ..write(obj.actualClose)
      ..writeByte(7)
      ..write(obj.hitPercent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PredictionImpl _$$PredictionImplFromJson(Map<String, dynamic> json) =>
    _$PredictionImpl(
      date: DateTime.parse(json['date'] as String),
      type: $enumDecode(_$PredictionTypeEnumMap, json['type']),
      price: (json['price'] as num?)?.toDouble(),
      percent: (json['percent'] as num?)?.toDouble(),
      note: json['note'] as String?,
      settled: json['settled'] as bool? ?? false,
      actualClose: (json['actualClose'] as num?)?.toDouble(),
      hitPercent: (json['hitPercent'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$PredictionImplToJson(_$PredictionImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'type': _$PredictionTypeEnumMap[instance.type]!,
      'price': instance.price,
      'percent': instance.percent,
      'note': instance.note,
      'settled': instance.settled,
      'actualClose': instance.actualClose,
      'hitPercent': instance.hitPercent,
    };

const _$PredictionTypeEnumMap = {
  PredictionType.upLimit: 'upLimit',
  PredictionType.downLimit: 'downLimit',
  PredictionType.customPrice: 'customPrice',
  PredictionType.customPercent: 'customPercent',
  PredictionType.bullish: 'bullish',
  PredictionType.bearish: 'bearish',
};
