import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../auth/view/login_sheet.dart';
import '../../auth/viewmodel/auth_view_model.dart';

/// Step 6 最小骨架：只放「登入 / 綁定帳號」入口。
/// 其他設定項目由 Step 25 補完。
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
