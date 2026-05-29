import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/calendar_doc.dart';
import '../../../data/models/prediction.dart';
import '../../../data/models/prediction_type.dart';
import '../../auth/viewmodel/auth_view_model.dart';
import '../../calendar/viewmodel/calendar_view_model.dart';

part 'prediction_editor_view_model.g.dart';

/// 編輯 sheet 的 draft 狀態。
/// price / percent 用 String 保留使用者原始輸入（不立即 parse），
/// 直到 [canSave] / [toPrediction] 才轉成 double。
class PredictionDraft {
  final PredictionType type;
  final String priceText;
  final String percentText;
  final String note;

  /// 是否對應到 doc 內已存在的 prediction（決定 sheet 顯示「刪除」按鈕）。
  final bool isExisting;

  const PredictionDraft({
    required this.type,
    required this.priceText,
    required this.percentText,
    required this.note,
    required this.isExisting,
  });

  factory PredictionDraft.empty() => const PredictionDraft(
        type: PredictionType.bullish,
        priceText: '',
        percentText: '',
        note: '',
        isExisting: false,
      );

  factory PredictionDraft.fromPrediction(Prediction p) => PredictionDraft(
        type: p.type,
        priceText: p.price?.toString() ?? '',
        percentText: p.percent?.toString() ?? '',
        note: p.note ?? '',
        isExisting: true,
      );

  PredictionDraft copyWith({
    PredictionType? type,
    String? priceText,
    String? percentText,
    String? note,
  }) =>
      PredictionDraft(
        type: type ?? this.type,
        priceText: priceText ?? this.priceText,
        percentText: percentText ?? this.percentText,
        note: note ?? this.note,
        isExisting: isExisting,
      );

  bool get canSave {
    switch (type) {
      case PredictionType.customPrice:
        final v = double.tryParse(priceText.trim());
        return v != null && v > 0;
      case PredictionType.customPercent:
        final v = double.tryParse(percentText.trim());
        return v != null && v > -100;
      case PredictionType.upLimit:
      case PredictionType.downLimit:
      case PredictionType.bullish:
      case PredictionType.bearish:
        return true;
    }
  }

  Prediction toPrediction(DateTime date) {
    final trimmedNote = note.trim();
    return Prediction(
      date: date,
      type: type,
      price: type == PredictionType.customPrice
          ? double.tryParse(priceText.trim())
          : null,
      percent: type == PredictionType.customPercent
          ? double.tryParse(percentText.trim())
          : null,
      note: trimmedNote.isEmpty ? null : trimmedNote,
    );
  }
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
@riverpod
class PredictionEditorViewModel extends _$PredictionEditorViewModel {
  static const _uuid = Uuid();

  @override
  PredictionDraft build(String symbol, int year, int month, int day) {
    final doc = ref.read(calendarViewModelProvider).valueOrNull;
    final existing = _findExisting(doc, year, month, day);
    return existing != null
        ? PredictionDraft.fromPrediction(existing)
        : PredictionDraft.empty();
  }

  void setType(PredictionType type) =>
      state = state.copyWith(type: type);
  void setPriceText(String text) => state = state.copyWith(priceText: text);
  void setPercentText(String text) =>
      state = state.copyWith(percentText: text);
  void setNote(String text) => state = state.copyWith(note: text);

  Future<bool> save() async {
    if (!state.canSave) return false;
    final repo = ref.read(calendarRepositoryProvider);
    final date = DateTime.utc(year, month, day);
    final newPred = state.toPrediction(date);

    final doc = ref.read(calendarViewModelProvider).valueOrNull;
    final CalendarDoc updated;
    if (doc == null) {
      final uid = ref.read(authServiceProvider).currentUserId ?? 'local';
      final now = DateTime.now().toUtc();
      updated = CalendarDoc(
        id: _uuid.v4(),
        userId: uid,
        symbol: symbol,
        year: year,
        month: month,
        title: '$symbol $year-$month',
        themeId: 'default',
        predictions: [newPred],
        createdAt: now,
        updatedAt: now,
      );
    } else {
      final kept = doc.predictions
          .where((p) => !_sameDay(p.date, year, month, day))
          .toList(growable: false);
      updated = doc.copyWith(
        predictions: [...kept, newPred],
        updatedAt: DateTime.now().toUtc(),
      );
    }
    final r = await repo.put(updated);
    return r.isSuccess;
  }

  Future<bool> delete() async {
    final repo = ref.read(calendarRepositoryProvider);
    final doc = ref.read(calendarViewModelProvider).valueOrNull;
    if (doc == null) return true;
    final kept = doc.predictions
        .where((p) => !_sameDay(p.date, year, month, day))
        .toList(growable: false);
    final updated = doc.copyWith(
      predictions: kept,
      updatedAt: DateTime.now().toUtc(),
    );
    final r = await repo.put(updated);
    return r.isSuccess;
  }

  static Prediction? _findExisting(
      CalendarDoc? doc, int year, int month, int day) {
    if (doc == null) return null;
    for (final p in doc.predictions) {
      if (_sameDay(p.date, year, month, day)) return p;
    }
    return null;
  }

  static bool _sameDay(DateTime d, int year, int month, int day) {
    final local = d.toLocal();
    return local.year == year && local.month == month && local.day == day;
  }
}
