import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stock_calendar/core/storage/hive_boxes.dart';
import 'package:stock_calendar/features/onboarding/data/onboarding_repository.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('onboarding_repo_test');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  late Box<dynamic> box;
  late OnboardingRepository repo;

  setUp(() async {
    box = await Hive.openBox<dynamic>(
        'meta_test_${DateTime.now().microsecondsSinceEpoch}');
    repo = OnboardingRepository(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  test('isCompleted defaults to false when key missing', () {
    expect(repo.isCompleted(), isFalse);
  });

  test('markCompleted persists true', () async {
    await repo.markCompleted();
    expect(repo.isCompleted(), isTrue);
    expect(box.get(kOnboardingCompletedKey), isTrue);
  });

  test('a new repository instance reads the same persisted flag', () async {
    await repo.markCompleted();
    final repo2 = OnboardingRepository(box);
    expect(repo2.isCompleted(), isTrue);
  });
}
