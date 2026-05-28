import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'prediction_type.g.dart';

@HiveType(typeId: 0)
@JsonEnum()
enum PredictionType {
  @HiveField(0)
  upLimit,
  @HiveField(1)
  downLimit,
  @HiveField(2)
  customPrice,
  @HiveField(3)
  customPercent,
  @HiveField(4)
  bullish,
  @HiveField(5)
  bearish,
}
