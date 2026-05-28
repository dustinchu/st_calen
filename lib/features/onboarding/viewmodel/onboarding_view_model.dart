import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/hive_boxes.dart';
import '../data/onboarding_repository.dart';

part 'onboarding_view_model.g.dart';

/// meta box 由 bootstrap 預先 open，這裡直接 `Hive.box` sync 取得。
/// 測試可用 `overrideWithValue` 注入測試專用 box / repository。
@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) =>
    OnboardingRepository(Hive.box<dynamic>(kMetaBox));

/// onboarding flag 是純 bool；meta box 已 open，sync notifier 即可。
/// 不用 AsyncNotifier 避免 await 為性能而 await。
@riverpod
class OnboardingViewModel extends _$OnboardingViewModel {
  @override
  bool build() => ref.watch(onboardingRepositoryProvider).isCompleted();

  Future<void> markCompleted() async {
    await ref.read(onboardingRepositoryProvider).markCompleted();
    ref.invalidateSelf();
  }
}
