import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
        builder: (context, state) => const _HomePlaceholder(),
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

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('股市行事曆 v2'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: const Center(child: Text('Bootstrap OK')),
    );
  }
}
