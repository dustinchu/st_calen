import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'quote.freezed.dart';
part 'quote.g.dart';

@freezed
class Quote with _$Quote {
  @HiveType(typeId: 5, adapterName: 'QuoteAdapter')
  const factory Quote({
    @HiveField(0) required String symbol,
    @HiveField(1) required DateTime date,
    @HiveField(2) required double close,
    @HiveField(3) double? open,
    @HiveField(4) double? high,
    @HiveField(5) double? low,
    @HiveField(6) double? changePercent,
  }) = _Quote;

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
}
