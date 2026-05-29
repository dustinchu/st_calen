import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/calendar_themes.dart';
import '../../../core/constants/app_constants.dart';
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
          _NotificationsTile(),
          const Divider(),
          _AutoSettleTile(),
          const Divider(),
          _AppThemeTile(),
          const Divider(),
          const _AboutTile(),
          const _LegalTile(
            icon: Icons.privacy_tip_outlined,
            title: '隱私權政策',
            url: kPrivacyPolicyUrl,
          ),
          const _LegalTile(
            icon: Icons.description_outlined,
            title: '服務條款',
            url: kTermsOfServiceUrl,
          ),
          const Divider(),
          const _ResetTile(),
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

class _NotificationsTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsViewModelProvider).valueOrNull;
    final enabled = settings?.notificationsEnabled ?? true;
    return SwitchListTile(
      secondary: const Icon(Icons.notifications_outlined),
      title: const Text('通知'),
      subtitle: const Text('每日 14:30 台股提醒與結算完成通知'),
      value: enabled,
      onChanged: (v) => ref
          .read(settingsControllerProvider.notifier)
          .setNotificationsEnabled(v),
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
              // 預覽：實際 monthBackground 底 + seed 環，5 套可辨（深淺/主色不同）。
              leading: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: t.monthBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: t.seed, width: 3),
                ),
              ),
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

/// 關於 / 版本：FutureBuilder 取 package_info，onTap 開原生 about dialog。
class _AboutTile extends StatelessWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final version =
            info == null ? '—' : '${info.version} (${info.buildNumber})';
        return ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('關於'),
          subtitle: Text('版本 $version'),
          onTap: info == null
              ? null
              : () => showAboutDialog(
                    context: context,
                    applicationName: info.appName,
                    applicationVersion: version,
                  ),
        );
      },
    );
  }
}

/// 法律連結（隱私權政策 / 服務條款）：url_launcher 外部開啟。
class _LegalTile extends StatelessWidget {
  const _LegalTile({
    required this.icon,
    required this.title,
    required this.url,
  });

  final IconData icon;
  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () async {
        final messenger = ScaffoldMessenger.of(context);
        final ok = await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
        if (!ok) {
          messenger.showSnackBar(
            const SnackBar(content: Text('無法開啟連結')),
          );
        }
      },
    );
  }
}

/// 重設本地資料：二次確認後清 calendars / stocks / settings + meta 待同步佇列。
class _ResetTile extends ConsumerWidget {
  const _ResetTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(Icons.delete_outline, color: scheme.error),
      title: Text('重設本地資料', style: TextStyle(color: scheme.error)),
      subtitle: const Text('清除本機行事曆、股票與設定（保留帳號登入狀態）'),
      onTap: () => _confirm(context, ref),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重設本地資料'),
        content: const Text(
          '將清除本機所有行事曆、股票清單與設定，且無法復原。'
          '帳號登入狀態與已上傳雲端的資料不受影響。確定要重設嗎？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('確定重設'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(settingsControllerProvider.notifier).resetAllLocalData();
    messenger.showSnackBar(
      const SnackBar(content: Text('已重設本地資料')),
    );
  }
}
