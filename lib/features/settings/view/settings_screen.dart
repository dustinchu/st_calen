import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/calendar_themes.dart';
import '../../auth/view/login_sheet.dart';
import '../../auth/viewmodel/auth_view_model.dart';
import '../viewmodel/settings_view_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authViewModelProvider).valueOrNull;
    final subtitle = switch (auth) {
      AuthSignedIn(isAnonymous: true) => '目前為匿名帳號',
      AuthSignedIn(hasGoogle: true) => '已綁定 Google',
      AuthSignedIn(hasApple: true) => '已綁定 Apple',
      AuthSignedIn() => '已登入',
      _ => '尚未登入',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('登入 / 綁定帳號'),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openLoginSheet(context),
          ),
          const Divider(),
          _AutoSettleTile(),
          const Divider(),
          _AppThemeTile(),
        ],
      ),
    );
  }

  void _openLoginSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (_) => const LoginSheet(),
    );
  }
}

class _AutoSettleTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsViewModelProvider).valueOrNull;
    final enabled = settings?.autoSettleEnabled ?? true;
    return SwitchListTile(
      secondary: const Icon(Icons.auto_mode),
      title: const Text('自動結算'),
      subtitle: const Text('每月開啟時，自動拉收盤價填回預測結果'),
      value: enabled,
      onChanged: (v) =>
          ref.read(settingsControllerProvider.notifier).setAutoSettleEnabled(v),
    );
  }
}

class _AppThemeTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsViewModelProvider).valueOrNull;
    final current = CalendarThemes.byId(settings?.themeId ?? 'default');
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('App 主題'),
      subtitle: Text(current.displayName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _pick(context, ref, current.id),
    );
  }

  Future<void> _pick(
      BuildContext context, WidgetRef ref, String currentId) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => _ThemePickerSheet(currentId: currentId),
    );
    if (picked != null) {
      await ref
          .read(settingsControllerProvider.notifier)
          .setThemeId(picked);
    }
  }
}

class _ThemePickerSheet extends StatelessWidget {
  const _ThemePickerSheet({required this.currentId});

  final String currentId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('選擇主題', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          for (final t in CalendarThemes.all)
            ListTile(
              leading: CircleAvatar(backgroundColor: t.seed, radius: 12),
              title: Text(t.displayName),
              trailing: t.id == currentId
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () => Navigator.of(context).pop(t.id),
            ),
        ],
      ),
    );
  }
}
