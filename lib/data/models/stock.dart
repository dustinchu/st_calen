import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import 'market.dart';

part 'stock.freezed.dart';
part 'stock.g.dart';

@freezed
class Stock with _$Stock {
  @HiveType(typeId: 3, adapterName: 'StockAdapter')
  const factory Stock({
    @HiveField(0) required String symbol,
    @HiveField(1) required Market market,
    @HiveField(2) required String name,
    @HiveField(3) String? sector,
  }) = _Stock;

  factory Stock.fromJson(Map<String, dynamic> json) => _$StockFromJson(json);
}
