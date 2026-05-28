import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stock_calendar/features/onboarding/data/onboarding_repository.dart';
import 'package:stock_calendar/features/onboarding/viewmodel/onboarding_view_model.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('onboarding_vm_test');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  late Box<dynamic> box;
  late ProviderContainer container;

  setUp(() async {
    box = await Hive.openBox<dynamic>(
        'meta_test_${DateTime.now().microsecondsSinceEpoch}');
    container = ProviderContainer(overrides: [
      onboardingRepositoryProvider.overrideWithValue(OnboardingRepository(box)),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await box.deleteFromDisk();
  });

  test('initial state is false when meta box is empty', () {
    expect(container.read(onboardingViewModelProvider), isFalse);
  });

  test('markCompleted flips state to true', () async {
    await container
        .read(onboardingViewModelProvider.notifier)
        .markCompleted();
    expect(container.read(onboardingViewModelProvider), isTrue);
  });

  test('flag persists across container restarts', () async {
    await container
        .read(onboardingViewModelProvider.notifier)
        .markCompleted();
    container.dispose();

    final container2 = ProviderContainer(overrides: [
      onboardingRepositoryProvider
          .overrideWithValue(OnboardingRepository(box)),
    ]);
    addTearDown(container2.dispose);
    expect(container2.read(onboardingViewModelProvider), isTrue);
  });
}
