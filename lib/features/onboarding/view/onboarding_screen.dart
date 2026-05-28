import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../viewmodel/onboarding_view_model.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = <_PageData>[
    _PageData(
      icon: Icons.calendar_today,
      background: Color(0xFF4C8BF5),
      title: '股市行事曆',
      subtitle: '把你對每檔股票的看法，化作一張可回顧的月曆。',
    ),
    _PageData(
      icon: Icons.insights,
      background: Color(0xFF34A853),
      title: '記錄你的預測',
      subtitle: '漲跌、目標價、區間 — 多種預測類型，隨手填入當日 cell。',
    ),
    _PageData(
      icon: Icons.fact_check,
      background: Color(0xFFFBBC04),
      title: '檢視你的準確度',
      subtitle: '月底自動結算，幫你看清自己對哪些股票真的有 sense。',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _pages.length - 1;

  Future<void> _finish() async {
    await ref.read(onboardingViewModelProvider.notifier).markCompleted();
    if (!mounted) return;
    context.go('/');
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('跳過'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return OnboardingPage(
                    icon: p.icon,
                    background: p.background,
                    title: p.title,
                    subtitle: p.subtitle,
                  );
                },
              ),
            ),
            _Dots(count: _pages.length, index: _index),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(_isLast ? '開始使用' : '下一步'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageData {
  final IconData icon;
  final Color background;
  final String title;
  final String subtitle;
  const _PageData({
    required this.icon,
    required this.background,
    required this.title,
    required this.subtitle,
  });
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;
  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? scheme.primary : scheme.outlineVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
