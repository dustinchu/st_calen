import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import 'prediction_type.dart';

part 'prediction.freezed.dart';
part 'prediction.g.dart';

@freezed
class Prediction with _$Prediction {
  @HiveType(typeId: 1, adapterName: 'PredictionAdapter')
  const factory Prediction({
    @HiveField(0) required DateTime date,
    @HiveField(1) required PredictionType type,
    @HiveField(2) double? price,
    @HiveField(3) double? percent,
    @HiveField(4) String? note,
    @HiveField(5) @Default(false) bool settled,
    @HiveField(6) double? actualClose,
    @HiveField(7) double? hitPercent,
  }) = _Prediction;

  factory Prediction.fromJson(Map<String, dynamic> json) =>
      _$PredictionFromJson(json);
}
