// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quote.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Quote _$QuoteFromJson(Map<String, dynamic> json) {
  return _Quote.fromJson(json);
}

/// @nodoc
mixin _$Quote {
  @HiveField(0)
  String get symbol => throw _privateConstructorUsedError;
  @HiveField(1)
  DateTime get date => throw _privateConstructorUsedError;
  @HiveField(2)
  double get close => throw _privateConstructorUsedError;
  @HiveField(3)
  double? get open => throw _privateConstructorUsedError;
  @HiveField(4)
  double? get high => throw _privateConstructorUsedError;
  @HiveField(5)
  double? get low => throw _privateConstructorUsedError;
  @HiveField(6)
  double? get changePercent => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuoteCopyWith<Quote> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuoteCopyWith<$Res> {
  factory $QuoteCopyWith(Quote value, $Res Function(Quote) then) =
      _$QuoteCopyWithImpl<$Res, Quote>;
  @useResult
  $Res call(
      {@HiveField(0) String symbol,
      @HiveField(1) DateTime date,
      @HiveField(2) double close,
      @HiveField(3) double? open,
      @HiveField(4) double? high,
      @HiveField(5) double? low,
      @HiveField(6) double? changePercent});
}

/// @nodoc
class _$QuoteCopyWithImpl<$Res, $Val extends Quote>
    implements $QuoteCopyWith<$Res> {
  _$QuoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symbol = null,
    Object? date = null,
    Object? close = null,
    Object? open = freezed,
    Object? high = freezed,
    Object? low = freezed,
    Object? changePercent = freezed,
  }) {
    return _then(_value.copyWith(
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      close: null == close
          ? _value.close
          : close // ignore: cast_nullable_to_non_nullable
              as double,
      open: freezed == open
          ? _value.open
          : open // ignore: cast_nullable_to_non_nullable
              as double?,
      high: freezed == high
          ? _value.high
          : high // ignore: cast_nullable_to_non_nullable
              as double?,
      low: freezed == low
          ? _value.low
          : low // ignore: cast_nullable_to_non_nullable
              as double?,
      changePercent: freezed == changePercent
          ? _value.changePercent
          : changePercent // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuoteImplCopyWith<$Res> implements $QuoteCopyWith<$Res> {
  factory _$$QuoteImplCopyWith(
          _$QuoteImpl value, $Res Function(_$QuoteImpl) then) =
      __$$QuoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String symbol,
      @HiveField(1) DateTime date,
      @HiveField(2) double close,
      @HiveField(3) double? open,
      @HiveField(4) double? high,
      @HiveField(5) double? low,
      @HiveField(6) double? changePercent});
}

/// @nodoc
class __$$QuoteImplCopyWithImpl<$Res>
    extends _$QuoteCopyWithImpl<$Res, _$QuoteImpl>
    implements _$$QuoteImplCopyWith<$Res> {
  __$$QuoteImplCopyWithImpl(
      _$QuoteImpl _value, $Res Function(_$QuoteImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symbol = null,
    Object? date = null,
    Object? close = null,
    Object? open = freezed,
    Object? high = freezed,
    Object? low = freezed,
    Object? changePercent = freezed,
  }) {
    return _then(_$QuoteImpl(
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      close: null == close
          ? _value.close
          : close // ignore: cast_nullable_to_non_nullable
              as double,
      open: freezed == open
          ? _value.open
          : open // ignore: cast_nullable_to_non_nullable
              as double?,
      high: freezed == high
          ? _value.high
          : high // ignore: cast_nullable_to_non_nullable
              as double?,
      low: freezed == low
          ? _value.low
          : low // ignore: cast_nullable_to_non_nullable
              as double?,
      changePercent: freezed == changePercent
          ? _value.changePercent
          : changePercent // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveType(typeId: 5, adapterName: 'QuoteAdapter')
class _$QuoteImpl implements _Quote {
  const _$QuoteImpl(
      {@HiveField(0) required this.symbol,
      @HiveField(1) required this.date,
      @HiveField(2) required this.close,
      @HiveField(3) this.open,
      @HiveField(4) this.high,
      @HiveField(5) this.low,
      @HiveField(6) this.changePercent});

  factory _$QuoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuoteImplFromJson(json);

  @override
  @HiveField(0)
  final String symbol;
  @override
  @HiveField(1)
  final DateTime date;
  @override
  @HiveField(2)
  final double close;
  @override
  @HiveField(3)
  final double? open;
  @override
  @HiveField(4)
  final double? high;
  @override
  @HiveField(5)
  final double? low;
  @override
  @HiveField(6)
  final double? changePercent;

  @override
  String toString() {
    return 'Quote(symbol: $symbol, date: $date, close: $close, open: $open, high: $high, low: $low, changePercent: $changePercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuoteImpl &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.close, close) || other.close == close) &&
            (identical(other.open, open) || other.open == open) &&
            (identical(other.high, high) || other.high == high) &&
            (identical(other.low, low) || other.low == low) &&
            (identical(other.changePercent, changePercent) ||
                other.changePercent == changePercent));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, symbol, date, close, open, high, low, changePercent);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuoteImplCopyWith<_$QuoteImpl> get copyWith =>
      __$$QuoteImplCopyWithImpl<_$QuoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuoteImplToJson(
      this,
    );
  }
}

abstract class _Quote implements Quote {
  const factory _Quote(
      {@HiveField(0) required final String symbol,
      @HiveField(1) required final DateTime date,
      @HiveField(2) required final double close,
      @HiveField(3) final double? open,
      @HiveField(4) final double? high,
      @HiveField(5) final double? low,
      @HiveField(6) final double? changePercent}) = _$QuoteImpl;

  factory _Quote.fromJson(Map<String, dynamic> json) = _$QuoteImpl.fromJson;

  @override
  @HiveField(0)
  String get symbol;
  @override
  @HiveField(1)
  DateTime get date;
  @override
  @HiveField(2)
  double get close;
  @override
  @HiveField(3)
  double? get open;
  @override
  @HiveField(4)
  double? get high;
  @override
  @HiveField(5)
  double? get low;
  @override
  @HiveField(6)
  double? get changePercent;
  @override
  @JsonKey(ignore: true)
  _$$QuoteImplCopyWith<_$QuoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
