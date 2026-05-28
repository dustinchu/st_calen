import 'package:hive/hive.dart';

import '../../../core/storage/hive_boxes.dart';

/// 薄層 wrapper：onboarding 完成 flag 只是一個 bool，不走 DS / Model 三層。
/// meta box 由 bootstrap 預先 open，所以這裡讀寫都是 sync（write put 仍 async）。
class OnboardingRepository {
  final Box<dynamic> _metaBox;
  OnboardingRepository(this._metaBox);

  bool isCompleted() =>
      _metaBox.get(kOnboardingCompletedKey, defaultValue: false) as bool;

  Future<void> markCompleted() =>
      _metaBox.put(kOnboardingCompletedKey, true);
}
