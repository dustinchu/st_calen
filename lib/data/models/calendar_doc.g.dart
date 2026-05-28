// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_doc.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalendarDocAdapter extends TypeAdapter<_$CalendarDocImpl> {
  @override
  final int typeId = 4;

  @override
  _$CalendarDocImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$CalendarDocImpl(
      id: fields[0] as String,
      userId: fields[1] as String,
      symbol: fields[2] as String,
      year: fields[3] as int,
      month: fields[4] as int,
      title: fields[5] as String,
      themeId: fields[6] as String,
      predictions: (fields[7] as List).cast<Prediction>(),
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, _$CalendarDocImpl obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.symbol)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.month)
      ..writeByte(5)
      ..write(obj.title)
      ..writeByte(6)
      ..write(obj.themeId)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.predictions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarDocAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalendarDocImpl _$$CalendarDocImplFromJson(Map<String, dynamic> json) =>
    _$CalendarDocImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      symbol: json['symbol'] as String,
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      title: json['title'] as String,
      themeId: json['themeId'] as String,
      predictions: (json['predictions'] as List<dynamic>?)
              ?.map((e) => Prediction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Prediction>[],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CalendarDocImplToJson(_$CalendarDocImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'symbol': instance.symbol,
      'year': instance.year,
      'month': instance.month,
      'title': instance.title,
      'themeId': instance.themeId,
      'predictions': instance.predictions.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
