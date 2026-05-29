// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_editor_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$predictionEditorViewModelHash() =>
    r'706ad494be4b1a0049e7a536968af03015c639e5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$PredictionEditorViewModel
    extends BuildlessAutoDisposeNotifier<PredictionDraft> {
  late final String symbol;
  late final int year;
  late final int month;
  late final int day;

  PredictionDraft build(
    String symbol,
    int year,
    int month,
    int day,
  );
}

/// 編輯 sheet 的 ViewModel。
///
/// Family key：(symbol, year, month, day)。傳 int 而非 DateTime 以避免
/// 不同 timezone / time 部分造成 hashCode 不一致。
///
/// build() 從 [calendarViewModelProvider] 一次性讀目前 doc，找出該日是否已有
/// prediction → 決定初始 draft。**用 ref.read 不訂閱**，避免使用者編輯到一半
/// stream emit 把 draft 沖掉。
///
/// save() / delete() 採「整顆 doc 替換」策略：repo 沒有 prediction-level API
/// （Step 9 規格），所以 read-modify-put。
///
/// Copied from [PredictionEditorViewModel].
@ProviderFor(PredictionEditorViewModel)
const predictionEditorViewModelProvider = PredictionEditorViewModelFamily();

/// 編輯 sheet 的 ViewModel。
///
/// Family key：(symbol, year, month, day)。傳 int 而非 DateTime 以避免
/// 不同 timezone / time 部分造成 hashCode 不一致。
///
/// build() 從 [calendarViewModelProvider] 一次性讀目前 doc，找出該日是否已有
/// prediction → 決定初始 draft。**用 ref.read 不訂閱**，避免使用者編輯到一半
/// stream emit 把 draft 沖掉。
///
/// save() / delete() 採「整顆 doc 替換」策略：repo 沒有 prediction-level API
/// （Step 9 規格），所以 read-modify-put。
///
/// Copied from [PredictionEditorViewModel].
class PredictionEditorViewModelFamily extends Family<PredictionDraft> {
  /// 編輯 sheet 的 ViewModel。
  ///
  /// Family key：(symbol, year, month, day)。傳 int 而非 DateTime 以避免
  /// 不同 timezone / time 部分造成 hashCode 不一致。
  ///
  /// build() 從 [calendarViewModelProvider] 一次性讀目前 doc，找出該日是否已有
  /// prediction → 決定初始 draft。**用 ref.read 不訂閱**，避免使用者編輯到一半
  /// stream emit 把 draft 沖掉。
  ///
  /// save() / delete() 採「整顆 doc 替換」策略：repo 沒有 prediction-level API
  /// （Step 9 規格），所以 read-modify-put。
  ///
  /// Copied from [PredictionEditorViewModel].
  const PredictionEditorViewModelFamily();

  /// 編輯 sheet 的 ViewModel。
  ///
  /// Family key：(symbol, year, month, day)。傳 int 而非 DateTime 以避免
  /// 不同 timezone / time 部分造成 hashCode 不一致。
  ///
  /// build() 從 [calendarViewModelProvider] 一次性讀目前 doc，找出該日是否已有
  /// prediction → 決定初始 draft。**用 ref.read 不訂閱**，避免使用者編輯到一半
  /// stream emit 把 draft 沖掉。
  ///
  /// save() / delete() 採「整顆 doc 替換」策略：repo 沒有 prediction-level API
  /// （Step 9 規格），所以 read-modify-put。
  ///
  /// Copied from [PredictionEditorViewModel].
  PredictionEditorViewModelProvider call(
    String symbol,
    int year,
    int month,
    int day,
  ) {
    return PredictionEditorViewModelProvider(
      symbol,
      year,
      month,
      day,
    );
  }

  @override
  PredictionEditorViewModelProvider getProviderOverride(
    covariant PredictionEditorViewModelProvider provider,
  ) {
    return call(
      provider.symbol,
      provider.year,
      provider.month,
      provider.day,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'predictionEditorViewModelProvider';
}

/// 編輯 sheet 的 ViewModel。
///
/// Family key：(symbol, year, month, day)。傳 int 而非 DateTime 以避免
/// 不同 timezone / time 部分造成 hashCode 不一致。
///
/// build() 從 [calendarViewModelProvider] 一次性讀目前 doc，找出該日是否已有
/// prediction → 決定初始 draft。**用 ref.read 不訂閱**，避免使用者編輯到一半
/// stream emit 把 draft 沖掉。
///
/// save() / delete() 採「整顆 doc 替換」策略：repo 沒有 prediction-level API
/// （Step 9 規格），所以 read-modify-put。
///
/// Copied from [PredictionEditorViewModel].
class PredictionEditorViewModelProvider extends AutoDisposeNotifierProviderImpl<
    PredictionEditorViewModel, PredictionDraft> {
  /// 編輯 sheet 的 ViewModel。
  ///
  /// Family key：(symbol, year, month, day)。傳 int 而非 DateTime 以避免
  /// 不同 timezone / time 部分造成 hashCode 不一致。
  ///
  /// build() 從 [calendarViewModelProvider] 一次性讀目前 doc，找出該日是否已有
  /// prediction → 決定初始 draft。**用 ref.read 不訂閱**，避免使用者編輯到一半
  /// stream emit 把 draft 沖掉。
  ///
  /// save() / delete() 採「整顆 doc 替換」策略：repo 沒有 prediction-level API
  /// （Step 9 規格），所以 read-modify-put。
  ///
  /// Copied from [PredictionEditorViewModel].
  PredictionEditorViewModelProvider(
    String symbol,
    int year,
    int month,
    int day,
  ) : this._internal(
          () => PredictionEditorViewModel()
            ..symbol = symbol
            ..year = year
            ..month = month
            ..day = day,
          from: predictionEditorViewModelProvider,
          name: r'predictionEditorViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$predictionEditorViewModelHash,
          dependencies: PredictionEditorViewModelFamily._dependencies,
          allTransitiveDependencies:
              PredictionEditorViewModelFamily._allTransitiveDependencies,
          symbol: symbol,
          year: year,
          month: month,
          day: day,
        );

  PredictionEditorViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.symbol,
    required this.year,
    required this.month,
    required this.day,
  }) : super.internal();

  final String symbol;
  final int year;
  final int month;
  final int day;

  @override
  PredictionDraft runNotifierBuild(
    covariant PredictionEditorViewModel notifier,
  ) {
    return notifier.build(
      symbol,
      year,
      month,
      day,
    );
  }

  @override
  Override overrideWith(PredictionEditorViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: PredictionEditorViewModelProvider._internal(
        () => create()
          ..symbol = symbol
          ..year = year
          ..month = month
          ..day = day,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        symbol: symbol,
        year: year,
        month: month,
        day: day,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<PredictionEditorViewModel, PredictionDraft>
      createElement() {
    return _PredictionEditorViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PredictionEditorViewModelProvider &&
        other.symbol == symbol &&
        other.year == year &&
        other.month == month &&
        other.day == day;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, symbol.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);
    hash = _SystemHash.combine(hash, day.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PredictionEditorViewModelRef
    on AutoDisposeNotifierProviderRef<PredictionDraft> {
  /// The parameter `symbol` of this provider.
  String get symbol;

  /// The parameter `year` of this provider.
  int get year;

  /// The parameter `month` of this provider.
  int get month;

  /// The parameter `day` of this provider.
  int get day;
}

class _PredictionEditorViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<PredictionEditorViewModel,
        PredictionDraft> with PredictionEditorViewModelRef {
  _PredictionEditorViewModelProviderElement(super.provider);

  @override
  String get symbol => (origin as PredictionEditorViewModelProvider).symbol;
  @override
  int get year => (origin as PredictionEditorViewModelProvider).year;
  @override
  int get month => (origin as PredictionEditorViewModelProvider).month;
  @override
  int get day => (origin as PredictionEditorViewModelProvider).day;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
