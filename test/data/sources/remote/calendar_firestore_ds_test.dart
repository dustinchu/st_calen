import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/core/utils/result.dart';
import 'package:stock_calendar/data/models/calendar_doc.dart';
import 'package:stock_calendar/data/models/prediction.dart';
import 'package:stock_calendar/data/models/prediction_type.dart';
import 'package:stock_calendar/data/sources/remote/calendar_firestore_ds.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late CalendarFirestoreDataSource ds;

  const uid = 'user-1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    ds = CalendarFirestoreDataSource(firestore);
  });

  CalendarDoc makeDoc({
    String id = 'cal-1',
    String symbol = '2330.TW',
    int year = 2026,
    int month = 6,
    List<Prediction> predictions = const [],
  }) {
    return CalendarDoc(
      id: id,
      userId: uid,
      symbol: symbol,
      year: year,
      month: month,
      title: '$symbol $month',
      themeId: 'def',
      predictions: predictions,
      createdAt: DateTime.utc(2026, 5, 1, 12, 0, 0),
      updatedAt: DateTime.utc(2026, 5, 2, 13, 30, 0),
    );
  }

  group('put / get', () {
    test('round trip preserves all fields including DateTime as Timestamp',
        () async {
      final pred = Prediction(
        date: DateTime.utc(2026, 6, 5),
        type: PredictionType.upLimit,
        note: 'law',
      );
      final doc = makeDoc(predictions: [pred]);

      final putResult = await ds.put(uid: uid, doc: doc);
      expect(putResult.isSuccess, isTrue);

      // Firestore raw 內 createdAt 應為 Timestamp 而非 String。
      final raw = await firestore
          .collection('users')
          .doc(uid)
          .collection('calendars')
          .doc(doc.id)
          .get();
      expect(raw.data()!['createdAt'], isA<Timestamp>());
      expect((raw.data()!['predictions'] as List).first['date'],
          isA<Timestamp>());

      final getResult = await ds.get(uid: uid, calendarId: doc.id);
      expect(getResult.isSuccess, isTrue);
      final got = (getResult as Success<CalendarDoc, AppError>).value;
      expect(got.id, doc.id);
      expect(got.createdAt, doc.createdAt);
      expect(got.updatedAt, doc.updatedAt);
      expect(got.predictions.first.date, pred.date);
      expect(got.predictions.first.type, PredictionType.upLimit);
      expect(got.predictions.first.note, 'law');
    });

    test('get returns NotFoundError when doc missing', () async {
      final r = await ds.get(uid: uid, calendarId: 'missing');
      expect(r.isFailure, isTrue);
      expect((r as Failure<CalendarDoc, AppError>).error, isA<NotFoundError>());
    });

    test('put overwrites existing doc', () async {
      final v1 = makeDoc();
      await ds.put(uid: uid, doc: v1);
      final v2 = v1.copyWith(title: 'updated');
      await ds.put(uid: uid, doc: v2);
      final got = await ds.get(uid: uid, calendarId: v1.id);
      expect((got as Success<CalendarDoc, AppError>).value.title, 'updated');
    });
  });

  group('delete', () {
    test('delete then get returns NotFoundError', () async {
      final doc = makeDoc();
      await ds.put(uid: uid, doc: doc);
      final del = await ds.delete(uid: uid, calendarId: doc.id);
      expect(del.isSuccess, isTrue);
      final got = await ds.get(uid: uid, calendarId: doc.id);
      expect((got as Failure<CalendarDoc, AppError>).error,
          isA<NotFoundError>());
    });

    test('delete non-existent doc still succeeds', () async {
      final del = await ds.delete(uid: uid, calendarId: 'never-existed');
      expect(del.isSuccess, isTrue);
    });
  });

  group('listByStock', () {
    test('returns only docs matching symbol', () async {
      await ds.put(uid: uid, doc: makeDoc(id: 'a', symbol: '2330.TW'));
      await ds.put(uid: uid, doc: makeDoc(id: 'b', symbol: '2330.TW', month: 7));
      await ds.put(uid: uid, doc: makeDoc(id: 'c', symbol: 'AAPL'));

      final r = await ds.listByStock(uid: uid, symbol: '2330.TW');
      final list = (r as Success<List<CalendarDoc>, AppError>).value;
      expect(list.length, 2);
      expect(list.every((d) => d.symbol == '2330.TW'), isTrue);
    });

    test('returns empty list when no matches', () async {
      final r = await ds.listByStock(uid: uid, symbol: 'NONE');
      expect((r as Success<List<CalendarDoc>, AppError>).value, isEmpty);
    });
  });

  group('watch', () {
    test('skips initial snapshot, emits subsequent updates and null on delete',
        () async {
      final doc = makeDoc();
      await ds.put(uid: uid, doc: doc);

      final events = <CalendarDoc?>[];
      final sub = ds.watch(uid: uid, calendarId: doc.id).listen(events.add);

      // 讓 fake firestore 派出 initial snapshot（會被 skip(1) 跳過）。
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, isEmpty, reason: 'initial emit must be skipped');

      // 更新 → emit 新 doc。
      await ds.put(uid: uid, doc: doc.copyWith(title: 'changed'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, hasLength(1));
      expect(events.first!.title, 'changed');

      // 刪除 → emit null。
      await ds.delete(uid: uid, calendarId: doc.id);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events.last, isNull);

      await sub.cancel();
    });
  });

  group('watchByStock', () {
    test('emits filtered list on changes', () async {
      await ds.put(uid: uid, doc: makeDoc(id: 'a', symbol: '2330.TW'));

      final events = <List<CalendarDoc>>[];
      final sub = ds
          .watchByStock(uid: uid, symbol: '2330.TW')
          .listen(events.add);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, isEmpty);

      // 新增另一個同 symbol 的 doc。
      await ds.put(uid: uid, doc: makeDoc(id: 'b', symbol: '2330.TW', month: 7));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, isNotEmpty);
      expect(events.last.length, 2);

      // 加一個別的 symbol，不應觸發。
      final lenBefore = events.length;
      await ds.put(uid: uid, doc: makeDoc(id: 'c', symbol: 'AAPL'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      // 不同 symbol 不會進入 query → events 長度不增。
      expect(events.length, lenBefore);

      await sub.cancel();
    });
  });
}
