// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) {
  return _AppSettings.fromJson(json);
}

/// @nodoc
mixin _$AppSettings {
  @HiveField(0)
  String get themeId => throw _privateConstructorUsedError;
  @HiveField(1)
  bool get notificationsEnabled => throw _privateConstructorUsedError;
  @HiveField(2)
  bool get autoSettleEnabled => throw _privateConstructorUsedError;
  @HiveField(3)
  String? get lastSelectedSymbol => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppSettingsCopyWith<AppSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsCopyWith<$Res> {
  factory $AppSettingsCopyWith(
          AppSettings value, $Res Function(AppSettings) then) =
      _$AppSettingsCopyWithImpl<$Res, AppSettings>;
  @useResult
  $Res call(
      {@HiveField(0) String themeId,
      @HiveField(1) bool notificationsEnabled,
      @HiveField(2) bool autoSettleEnabled,
      @HiveField(3) String? lastSelectedSymbol});
}

/// @nodoc
class _$AppSettingsCopyWithImpl<$Res, $Val extends AppSettings>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeId = null,
    Object? notificationsEnabled = null,
    Object? autoSettleEnabled = null,
    Object? lastSelectedSymbol = freezed,
  }) {
    return _then(_value.copyWith(
      themeId: null == themeId
          ? _value.themeId
          : themeId // ignore: cast_nullable_to_non_nullable
              as String,
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      autoSettleEnabled: null == autoSettleEnabled
          ? _value.autoSettleEnabled
          : autoSettleEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSelectedSymbol: freezed == lastSelectedSymbol
          ? _value.lastSelectedSymbol
          : lastSelectedSymbol // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppSettingsImplCopyWith<$Res>
    implements $AppSettingsCopyWith<$Res> {
  factory _$$AppSettingsImplCopyWith(
          _$AppSettingsImpl value, $Res Function(_$AppSettingsImpl) then) =
      __$$AppSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String themeId,
      @HiveField(1) bool notificationsEnabled,
      @HiveField(2) bool autoSettleEnabled,
      @HiveField(3) String? lastSelectedSymbol});
}

/// @nodoc
class __$$AppSettingsImplCopyWithImpl<$Res>
    extends _$AppSettingsCopyWithImpl<$Res, _$AppSettingsImpl>
    implements _$$AppSettingsImplCopyWith<$Res> {
  __$$AppSettingsImplCopyWithImpl(
      _$AppSettingsImpl _value, $Res Function(_$AppSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeId = null,
    Object? notificationsEnabled = null,
    Object? autoSettleEnabled = null,
    Object? lastSelectedSymbol = freezed,
  }) {
    return _then(_$AppSettingsImpl(
      themeId: null == themeId
          ? _value.themeId
          : themeId // ignore: cast_nullable_to_non_nullable
              as String,
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      autoSettleEnabled: null == autoSettleEnabled
          ? _value.autoSettleEnabled
          : autoSettleEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSelectedSymbol: freezed == lastSelectedSymbol
          ? _value.lastSelectedSymbol
          : lastSelectedSymbol // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveType(typeId: 6, adapterName: 'AppSettingsAdapter')
class _$AppSettingsImpl implements _AppSettings {
  const _$AppSettingsImpl(
      {@HiveField(0) this.themeId = 'def',
      @HiveField(1) this.notificationsEnabled = true,
      @HiveField(2) this.autoSettleEnabled = true,
      @HiveField(3) this.lastSelectedSymbol});

  factory _$AppSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingsImplFromJson(json);

  @override
  @JsonKey()
  @HiveField(0)
  final String themeId;
  @override
  @JsonKey()
  @HiveField(1)
  final bool notificationsEnabled;
  @override
  @JsonKey()
  @HiveField(2)
  final bool autoSettleEnabled;
  @override
  @HiveField(3)
  final String? lastSelectedSymbol;

  @override
  String toString() {
    return 'AppSettings(themeId: $themeId, notificationsEnabled: $notificationsEnabled, autoSettleEnabled: $autoSettleEnabled, lastSelectedSymbol: $lastSelectedSymbol)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingsImpl &&
            (identical(other.themeId, themeId) || other.themeId == themeId) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            (identical(other.autoSettleEnabled, autoSettleEnabled) ||
                other.autoSettleEnabled == autoSettleEnabled) &&
            (identical(other.lastSelectedSymbol, lastSelectedSymbol) ||
                other.lastSelectedSymbol == lastSelectedSymbol));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, themeId, notificationsEnabled,
      autoSettleEnabled, lastSelectedSymbol);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      __$$AppSettingsImplCopyWithImpl<_$AppSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSettingsImplToJson(
      this,
    );
  }
}

abstract class _AppSettings implements AppSettings {
  const factory _AppSettings(
      {@HiveField(0) final String themeId,
      @HiveField(1) final bool notificationsEnabled,
      @HiveField(2) final bool autoSettleEnabled,
      @HiveField(3) final String? lastSelectedSymbol}) = _$AppSettingsImpl;

  factory _AppSettings.fromJson(Map<String, dynamic> json) =
      _$AppSettingsImpl.fromJson;

  @override
  @HiveField(0)
  String get themeId;
  @override
  @HiveField(1)
  bool get notificationsEnabled;
  @override
  @HiveField(2)
  bool get autoSettleEnabled;
  @override
  @HiveField(3)
  String? get lastSelectedSymbol;
  @override
  @JsonKey(ignore: true)
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
