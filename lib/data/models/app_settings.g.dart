// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<_$AppSettingsImpl> {
  @override
  final int typeId = 6;

  @override
  _$AppSettingsImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$AppSettingsImpl(
      themeId: fields[0] as String,
      notificationsEnabled: fields[1] as bool,
      autoSettleEnabled: fields[2] as bool,
      lastSelectedSymbol: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, _$AppSettingsImpl obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.themeId)
      ..writeByte(1)
      ..write(obj.notificationsEnabled)
      ..writeByte(2)
      ..write(obj.autoSettleEnabled)
      ..writeByte(3)
      ..write(obj.lastSelectedSymbol);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsImpl _$$AppSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AppSettingsImpl(
      themeId: json['themeId'] as String? ?? 'def',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      autoSettleEnabled: json['autoSettleEnabled'] as bool? ?? true,
      lastSelectedSymbol: json['lastSelectedSymbol'] as String?,
    );

Map<String, dynamic> _$$AppSettingsImplToJson(_$AppSettingsImpl instance) =>
    <String, dynamic>{
      'themeId': instance.themeId,
      'notificationsEnabled': instance.notificationsEnabled,
      'autoSettleEnabled': instance.autoSettleEnabled,
      'lastSelectedSymbol': instance.lastSelectedSymbol,
    };
