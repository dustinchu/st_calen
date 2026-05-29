import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stock_calendar/core/firebase/auth_service.dart';
import 'package:stock_calendar/core/utils/result.dart';
import 'package:stock_calendar/data/models/calendar_doc.dart';
import 'package:stock_calendar/data/models/prediction.dart';
import 'package:stock_calendar/data/models/prediction_type.dart';
import 'package:stock_calendar/data/repositories/calendar_repository.dart';
import 'package:stock_calendar/features/auth/viewmodel/auth_view_model.dart';
import 'package:stock_calendar/features/calendar/viewmodel/calendar_view_model.dart';
import 'package:stock_calendar/features/prediction/viewmodel/prediction_editor_view_model.dart';

class _MockRepo extends Mock implements CalendarRepository {}

class _FakeAuth implements AuthService {
  @override
  String? get currentUserId => 'u1';
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  @override
  User? get currentUser => null;
  @override
  Stream<User?> userChanges() => const Stream.empty();
}

CalendarDoc _doc({
  String symbol = '2330.TW',
  int year = 2026,
  int month = 6,
  List<Prediction> predictions = const [],
}) {
  final t = DateTime.utc(2026, 5, 1);
  return CalendarDoc(
    id: 'c-$symbol-$year-$month',
    userId: 'u1',
    symbol: symbol,
    year: year,
    month: month,
    title: '$symbol $year-$month',
    themeId: 'def',
    predictions: predictions,
    createdAt: t,
    updatedAt: t,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_doc());
  });

  late _MockRepo repo;

  ProviderContainer makeContainer({CalendarDoc? initialDoc}) {
    final container = ProviderContainer(overrides: [
      calendarRepositoryProvider.overrideWithValue(repo),
      authServiceProvider.overrideWithValue(_FakeAuth()),
    ]);
    when(() => repo.watch(
          symbol: any(named: 'symbol'),
          year: any(named: 'year'),
          month: any(named: 'month'),
        )).thenAnswer((_) => Stream.value(initialDoc));
    when(() => repo.put(any()))
        .thenAnswer((_) async => const Result.success(null));
    container.read(currentSymbolProvider.notifier).set('2330.TW');
    container
        .read(focusedMonthProvider.notifier)
        .set(DateTime.utc(2026, 6, 1));
    return container;
  }

  setUp(() => repo = _MockRepo());

  group('PredictionDraft', () {
    test('empty draft defaults to bullish + cannot delete', () {
      final d = PredictionDraft.empty();
      expect(d.type, PredictionType.bullish);
      expect(d.isExisting, isFalse);
      expect(d.canSave, isTrue);
    });

    test('customPrice canSave only when price > 0', () {
      final base = PredictionDraft.empty().copyWith(
        type: PredictionType.customPrice,
      );
      expect(base.canSave, isFalse);
      expect(base.copyWith(priceText: '0').canSave, isFalse);
      expect(base.copyWith(priceText: '-1').canSave, isFalse);
      expect(base.copyWith(priceText: 'abc').canSave, isFalse);
      expect(base.copyWith(priceText: '123.5').canSave, isTrue);
    });

    test('customPercent canSave only when percent > -100', () {
      final base = PredictionDraft.empty().copyWith(
        type: PredictionType.customPercent,
      );
      expect(base.canSave, isFalse);
      expect(base.copyWith(percentText: '-100').canSave, isFalse);
      expect(base.copyWith(percentText: '-99').canSave, isTrue);
      expect(base.copyWith(percentText: '5.5').canSave, isTrue);
    });

    test('fromPrediction prefills fields and marks isExisting', () {
      final p = Prediction(
        date: DateTime.utc(2026, 6, 10),
        type: PredictionType.customPrice,
        price: 600,
        note: 'hi',
      );
      final d = PredictionDraft.fromPrediction(p);
      expect(d.type, PredictionType.customPrice);
      expect(d.priceText, '600.0');
      expect(d.note, 'hi');
      expect(d.isExisting, isTrue);
    });
  });

  group('PredictionEditorViewModel', () {
    test('build with no existing prediction → empty draft', () async {
      final container = makeContainer(initialDoc: _doc());
      await container.read(calendarViewModelProvider.future);
      final draft = container.read(
          predictionEditorViewModelProvider('2330.TW', 2026, 6, 10));
      expect(draft.isExisting, isFalse);
      expect(draft.type, PredictionType.bullish);
      container.dispose();
    });

    test('build with existing prediction → prefilled + isExisting',
        () async {
      final existing = Prediction(
        date: DateTime.utc(2026, 6, 10),
        type: PredictionType.bearish,
        note: 'fed week',
      );
      final container = makeContainer(
          initialDoc: _doc(predictions: [existing]));
      await container.read(calendarViewModelProvider.future);
      final draft = container.read(
          predictionEditorViewModelProvider('2330.TW', 2026, 6, 10));
      expect(draft.isExisting, isTrue);
      expect(draft.type, PredictionType.bearish);
      expect(draft.note, 'fed week');
      container.dispose();
    });

    test('save with empty doc → creates new CalendarDoc with prediction',
        () async {
      final container = makeContainer(initialDoc: null);
      await container.read(calendarViewModelProvider.future);
      final vm = container
          .read(predictionEditorViewModelProvider('2330.TW', 2026, 6, 10)
              .notifier);
      vm.setType(PredictionType.bullish);
      final ok = await vm.save();
      expect(ok, isTrue);
      final captured = verify(() => repo.put(captureAny())).captured;
      final doc = captured.single as CalendarDoc;
      expect(doc.symbol, '2330.TW');
      expect(doc.predictions, hasLength(1));
      expect(doc.predictions.first.type, PredictionType.bullish);
      expect(doc.predictions.first.date, DateTime.utc(2026, 6, 10));
      container.dispose();
    });

    test('save replaces existing prediction on same day', () async {
      final old = Prediction(
        date: DateTime.utc(2026, 6, 10),
        type: PredictionType.bullish,
      );
      final other = Prediction(
        date: DateTime.utc(2026, 6, 15),
        type: PredictionType.bearish,
      );
      final container = makeContainer(
          initialDoc: _doc(predictions: [old, other]));
      await container.read(calendarViewModelProvider.future);
      final vm = container
          .read(predictionEditorViewModelProvider('2330.TW', 2026, 6, 10)
              .notifier);
      vm.setType(PredictionType.customPrice);
      vm.setPriceText('700');

      final ok = await vm.save();
      expect(ok, isTrue);
      final doc = verify(() => repo.put(captureAny())).captured.single
          as CalendarDoc;
      expect(doc.predictions, hasLength(2));
      final updated =
          doc.predictions.firstWhere((p) => p.date.day == 10);
      expect(updated.type, PredictionType.customPrice);
      expect(updated.price, 700);
      // 另一天的 prediction 保留
      expect(doc.predictions.any((p) => p.date.day == 15), isTrue);
      container.dispose();
    });

    test('save returns false when canSave is false (no repo write)',
        () async {
      final container = makeContainer(initialDoc: _doc());
      await container.read(calendarViewModelProvider.future);
      final vm = container
          .read(predictionEditorViewModelProvider('2330.TW', 2026, 6, 10)
              .notifier);
      vm.setType(PredictionType.customPrice); // 沒填 price
      final ok = await vm.save();
      expect(ok, isFalse);
      verifyNever(() => repo.put(any()));
      container.dispose();
    });

    test('delete removes prediction on that day, keeps others', () async {
      final p10 = Prediction(
        date: DateTime.utc(2026, 6, 10),
        type: PredictionType.bullish,
      );
      final p15 = Prediction(
        date: DateTime.utc(2026, 6, 15),
        type: PredictionType.bearish,
      );
      final container = makeContainer(
          initialDoc: _doc(predictions: [p10, p15]));
      await container.read(calendarViewModelProvider.future);
      final vm = container
          .read(predictionEditorViewModelProvider('2330.TW', 2026, 6, 10)
              .notifier);
      final ok = await vm.delete();
      expect(ok, isTrue);
      final doc = verify(() => repo.put(captureAny())).captured.single
          as CalendarDoc;
      expect(doc.predictions, hasLength(1));
      expect(doc.predictions.single.date.day, 15);
      container.dispose();
    });

    test('delete with no doc → no repo write, returns true', () async {
      final container = makeContainer(initialDoc: null);
      await container.read(calendarViewModelProvider.future);
      final vm = container
          .read(predictionEditorViewModelProvider('2330.TW', 2026, 6, 10)
              .notifier);
      final ok = await vm.delete();
      expect(ok, isTrue);
      verifyNever(() => repo.put(any()));
      container.dispose();
    });
  });
}
