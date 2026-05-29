// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsLocalDataSourceHash() =>
    r'26e329d9dd9d271f3e9daad4762b910673107570';

/// See also [settingsLocalDataSource].
@ProviderFor(settingsLocalDataSource)
final settingsLocalDataSourceProvider =
    Provider<SettingsLocalDataSource>.internal(
  settingsLocalDataSource,
  name: r'settingsLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SettingsLocalDataSourceRef = ProviderRef<SettingsLocalDataSource>;
String _$settingsRepositoryHash() =>
    r'6bff58321daa8bf2bbb318b7ac0feb233f2abd3d';

/// See also [settingsRepository].
@ProviderFor(settingsRepository)
final settingsRepositoryProvider = Provider<SettingsRepository>.internal(
  settingsRepository,
  name: r'settingsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SettingsRepositoryRef = ProviderRef<SettingsRepository>;
String _$settingsViewModelHash() => r'f90b85286ec70f8e21e7b691031c92248487e39a';

/// Hot stream：訂閱 AppSettings 變動。第一次 emit 來自 repo.get（預設值 fallback）。
///
/// Copied from [settingsViewModel].
@ProviderFor(settingsViewModel)
final settingsViewModelProvider =
    AutoDisposeStreamProvider<AppSettings>.internal(
  settingsViewModel,
  name: r'settingsViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SettingsViewModelRef = AutoDisposeStreamProviderRef<AppSettings>;
String _$settingsControllerHash() =>
    r'99e9e6c32db8d61223bbb429b3d1d2d44c3fc9fc';

/// 更新單一欄位（read-modify-put）。
///
/// Copied from [SettingsController].
@ProviderFor(SettingsController)
final settingsControllerProvider =
    AutoDisposeNotifierProvider<SettingsController, void>.internal(
  SettingsController.new,
  name: r'settingsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SettingsController = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
