import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import 'prediction.dart';

part 'calendar_doc.freezed.dart';
part 'calendar_doc.g.dart';

@freezed
class CalendarDoc with _$CalendarDoc {
  @HiveType(typeId: 4, adapterName: 'CalendarDocAdapter')
  const factory CalendarDoc({
    @HiveField(0) required String id,
    @HiveField(1) required String userId,
    @HiveField(2) required String symbol,
    @HiveField(3) required int year,
    @HiveField(4) required int month,
    @HiveField(5) required String title,
    @HiveField(6) required String themeId,
    @HiveField(7) @Default(<Prediction>[]) List<Prediction> predictions,
    @HiveField(8) required DateTime createdAt,
    @HiveField(9) required DateTime updatedAt,
  }) = _CalendarDoc;

  factory CalendarDoc.fromJson(Map<String, dynamic> json) =>
      _$CalendarDocFromJson(json);
}
