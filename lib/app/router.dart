import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/calendar/view/calendar_screen.dart';
import '../features/onboarding/view/onboarding_screen.dart';
import '../features/onboarding/viewmodel/onboarding_view_model.dart';
import '../features/settings/view/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final completed = ref.read(onboardingRepositoryProvider).isCompleted();
      final atOnboarding = state.matchedLocation == '/onboarding';
      if (!completed && !atOnboarding) return '/onboarding';
      if (completed && atOnboarding) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
