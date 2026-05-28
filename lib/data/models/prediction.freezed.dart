// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prediction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Prediction _$PredictionFromJson(Map<String, dynamic> json) {
  return _Prediction.fromJson(json);
}

/// @nodoc
mixin _$Prediction {
  @HiveField(0)
  DateTime get date => throw _privateConstructorUsedError;
  @HiveField(1)
  PredictionType get type => throw _privateConstructorUsedError;
  @HiveField(2)
  double? get price => throw _privateConstructorUsedError;
  @HiveField(3)
  double? get percent => throw _privateConstructorUsedError;
  @HiveField(4)
  String? get note => throw _privateConstructorUsedError;
  @HiveField(5)
  bool get settled => throw _privateConstructorUsedError;
  @HiveField(6)
  double? get actualClose => throw _privateConstructorUsedError;
  @HiveField(7)
  double? get hitPercent => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PredictionCopyWith<Prediction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PredictionCopyWith<$Res> {
  factory $PredictionCopyWith(
          Prediction value, $Res Function(Prediction) then) =
      _$PredictionCopyWithImpl<$Res, Prediction>;
  @useResult
  $Res call(
      {@HiveField(0) DateTime date,
      @HiveField(1) PredictionType type,
      @HiveField(2) double? price,
      @HiveField(3) double? percent,
      @HiveField(4) String? note,
      @HiveField(5) bool settled,
      @HiveField(6) double? actualClose,
      @HiveField(7) double? hitPercent});
}

/// @nodoc
class _$PredictionCopyWithImpl<$Res, $Val extends Prediction>
    implements $PredictionCopyWith<$Res> {
  _$PredictionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? type = null,
    Object? price = freezed,
    Object? percent = freezed,
    Object? note = freezed,
    Object? settled = null,
    Object? actualClose = freezed,
    Object? hitPercent = freezed,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PredictionType,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      percent: freezed == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as double?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      settled: null == settled
          ? _value.settled
          : settled // ignore: cast_nullable_to_non_nullable
              as bool,
      actualClose: freezed == actualClose
          ? _value.actualClose
          : actualClose // ignore: cast_nullable_to_non_nullable
              as double?,
      hitPercent: freezed == hitPercent
          ? _value.hitPercent
          : hitPercent // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PredictionImplCopyWith<$Res>
    implements $PredictionCopyWith<$Res> {
  factory _$$PredictionImplCopyWith(
          _$PredictionImpl value, $Res Function(_$PredictionImpl) then) =
      __$$PredictionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) DateTime date,
      @HiveField(1) PredictionType type,
      @HiveField(2) double? price,
      @HiveField(3) double? percent,
      @HiveField(4) String? note,
      @HiveField(5) bool settled,
      @HiveField(6) double? actualClose,
      @HiveField(7) double? hitPercent});
}

/// @nodoc
class __$$PredictionImplCopyWithImpl<$Res>
    extends _$PredictionCopyWithImpl<$Res, _$PredictionImpl>
    implements _$$PredictionImplCopyWith<$Res> {
  __$$PredictionImplCopyWithImpl(
      _$PredictionImpl _value, $Res Function(_$PredictionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? type = null,
    Object? price = freezed,
    Object? percent = freezed,
    Object? note = freezed,
    Object? settled = null,
    Object? actualClose = freezed,
    Object? hitPercent = freezed,
  }) {
    return _then(_$PredictionImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PredictionType,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      percent: freezed == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as double?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      settled: null == settled
          ? _value.settled
          : settled // ignore: cast_nullable_to_non_nullable
              as bool,
      actualClose: freezed == actualClose
          ? _value.actualClose
          : actualClose // ignore: cast_nullable_to_non_nullable
              as double?,
      hitPercent: freezed == hitPercent
          ? _value.hitPercent
          : hitPercent // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveType(typeId: 1, adapterName: 'PredictionAdapter')
class _$PredictionImpl implements _Prediction {
  const _$PredictionImpl(
      {@HiveField(0) required this.date,
      @HiveField(1) required this.type,
      @HiveField(2) this.price,
      @HiveField(3) this.percent,
      @HiveField(4) this.note,
      @HiveField(5) this.settled = false,
      @HiveField(6) this.actualClose,
      @HiveField(7) this.hitPercent});

  factory _$PredictionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PredictionImplFromJson(json);

  @override
  @HiveField(0)
  final DateTime date;
  @override
  @HiveField(1)
  final PredictionType type;
  @override
  @HiveField(2)
  final double? price;
  @override
  @HiveField(3)
  final double? percent;
  @override
  @HiveField(4)
  final String? note;
  @override
  @JsonKey()
  @HiveField(5)
  final bool settled;
  @override
  @HiveField(6)
  final double? actualClose;
  @override
  @HiveField(7)
  final double? hitPercent;

  @override
  String toString() {
    return 'Prediction(date: $date, type: $type, price: $price, percent: $percent, note: $note, settled: $settled, actualClose: $actualClose, hitPercent: $hitPercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PredictionImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.percent, percent) || other.percent == percent) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.settled, settled) || other.settled == settled) &&
            (identical(other.actualClose, actualClose) ||
                other.actualClose == actualClose) &&
            (identical(other.hitPercent, hitPercent) ||
                other.hitPercent == hitPercent));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, date, type, price, percent, note,
      settled, actualClose, hitPercent);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PredictionImplCopyWith<_$PredictionImpl> get copyWith =>
      __$$PredictionImplCopyWithImpl<_$PredictionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PredictionImplToJson(
      this,
    );
  }
}

abstract class _Prediction implements Prediction {
  const factory _Prediction(
      {@HiveField(0) required final DateTime date,
      @HiveField(1) required final PredictionType type,
      @HiveField(2) final double? price,
      @HiveField(3) final double? percent,
      @HiveField(4) final String? note,
      @HiveField(5) final bool settled,
      @HiveField(6) final double? actualClose,
      @HiveField(7) final double? hitPercent}) = _$PredictionImpl;

  factory _Prediction.fromJson(Map<String, dynamic> json) =
      _$PredictionImpl.fromJson;

  @override
  @HiveField(0)
  DateTime get date;
  @override
  @HiveField(1)
  PredictionType get type;
  @override
  @HiveField(2)
  double? get price;
  @override
  @HiveField(3)
  double? get percent;
  @override
  @HiveField(4)
  String? get note;
  @override
  @HiveField(5)
  bool get settled;
  @override
  @HiveField(6)
  double? get actualClose;
  @override
  @HiveField(7)
  double? get hitPercent;
  @override
  @JsonKey(ignore: true)
  _$$PredictionImplCopyWith<_$PredictionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
