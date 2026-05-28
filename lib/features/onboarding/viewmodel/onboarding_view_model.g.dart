// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingRepositoryHash() =>
    r'50d688ed48833702a259e5e32b85bba619c6af91';

/// meta box 由 bootstrap 預先 open，這裡直接 `Hive.box` sync 取得。
/// 測試可用 `overrideWithValue` 注入測試專用 box / repository。
///
/// Copied from [onboardingRepository].
@ProviderFor(onboardingRepository)
final onboardingRepositoryProvider = Provider<OnboardingRepository>.internal(
  onboardingRepository,
  name: r'onboardingRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onboardingRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef OnboardingRepositoryRef = ProviderRef<OnboardingRepository>;
String _$onboardingViewModelHash() =>
    r'd06c9130ecb7a4e4f51b119a5587e3d5e5feb347';

/// onboarding flag 是純 bool；meta box 已 open，sync notifier 即可。
/// 不用 AsyncNotifier 避免 await 為性能而 await。
///
/// Copied from [OnboardingViewModel].
@ProviderFor(OnboardingViewModel)
final onboardingViewModelProvider =
    AutoDisposeNotifierProvider<OnboardingViewModel, bool>.internal(
  OnboardingViewModel.new,
  name: r'onboardingViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onboardingViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OnboardingViewModel = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
