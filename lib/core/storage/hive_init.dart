import 'package:hive_flutter/hive_flutter.dart';

/// Hive 初始化集中點。
///
/// Step 4 完成 freezed + HiveAdapter 後，在此處 `Hive.registerAdapter(...)`。
class HiveInit {
  const HiveInit._();

  static Future<void> init() async {
    await Hive.initFlutter();
    // adapters registered in Step 4
  }
}
