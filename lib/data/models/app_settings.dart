import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

@freezed
class AppSettings with _$AppSettings {
  @HiveType(typeId: 6, adapterName: 'AppSettingsAdapter')
  const factory AppSettings({
    @HiveField(0) @Default('def') String themeId,
    @HiveField(1) @Default(true) bool notificationsEnabled,
    @HiveField(2) @Default(true) bool autoSettleEnabled,
    @HiveField(3) String? lastSelectedSymbol,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
