import 'package:flutter/material.dart';

/// 單頁 onboarding 版型：頂部圖示色塊 + 標題 + 副標。
/// Step 12 用 Material Icon 佔位，真正素材留 Step 26。
class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final Color background;
  final String title;
  final String subtitle;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.background,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Icon(icon, size: 120, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
