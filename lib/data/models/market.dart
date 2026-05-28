import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'market.g.dart';

@HiveType(typeId: 2)
@JsonEnum()
enum Market {
  @HiveField(0)
  tw,
  @HiveField(1)
  us,
}
