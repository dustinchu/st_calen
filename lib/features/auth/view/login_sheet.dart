import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/utils/result.dart';
import '../viewmodel/auth_view_model.dart';

/// 登入 / 綁定帳號 sheet。
/// 從設定頁觸發：`showModalBottomSheet(context: ..., builder: (_) => const LoginSheet())`。
class LoginSheet extends ConsumerStatefulWidget {
  const LoginSheet({super.key});

  @override
  ConsumerState<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends ConsumerState<LoginSheet> {
  bool _busy = false;
  String? _message;

  Future<void> _run(Future<AuthError?> Function() action,
      {required String okLabel}) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    final error = await action();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = switch (error) {
        null => okLabel,
        AuthCancelledError() => '已取消',
        AuthAccountExistsError(:final email) =>
          '此帳號${email == null ? '' : '（$email）'}已綁定其他裝置資料，請改用該帳號登入',
        AuthNetworkError() => '網路無法連線，請稍後再試',
        AuthOperationNotAllowedError() => '此登入方式尚未啟用',
        _ => '失敗：${error.message}',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authViewModelProvider).valueOrNull;
    final signedIn = auth is AuthSignedIn ? auth : null;
    final hasGoogle = signedIn?.hasGoogle ?? false;
    final hasApple = signedIn?.hasApple ?? false;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              '登入 / 綁定帳號',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '綁定後可在多裝置同步資料',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _ProviderButton(
              label: hasGoogle ? '已綁定 Google' : '使用 Google 綁定',
              icon: Icons.account_circle,
              enabled: !_busy && !hasGoogle,
              onPressed: () => _run(
                () => ref.read(authViewModelProvider.notifier).linkWithGoogle(),
                okLabel: '已綁定 Google',
              ),
            ),
            if (Platform.isIOS) ...[
              const SizedBox(height: 12),
              _ProviderButton(
                label: hasApple ? '已綁定 Apple' : '使用 Apple 綁定',
                icon: Icons.apple,
                enabled: !_busy && !hasApple,
                onPressed: () => _run(
                  () =>
                      ref.read(authViewModelProvider.notifier).linkWithApple(),
                  okLabel: '已綁定 Apple',
                ),
              ),
            ],
            if (hasGoogle || hasApple) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: _busy
                    ? null
                    : () async {
                        final provider = hasGoogle ? 'google.com' : 'apple.com';
                        await _run(
                          () async {
                            final err = await ref
                                .read(authViewModelProvider.notifier)
                                .unlinkProvider(provider);
                            return err;
                          },
                          okLabel: '已解除綁定',
                        );
                      },
                child: Text(hasGoogle ? '解除 Google 綁定' : '解除 Apple 綁定'),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 20,
              child: _busy
                  ? const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Text(
                      _message ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  const _ProviderButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
      ),
    );
  }
}
