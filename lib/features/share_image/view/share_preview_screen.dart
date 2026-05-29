import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/calendar_themes.dart';
import '../../calendar/viewmodel/calendar_view_model.dart';
import '../../settings/viewmodel/settings_view_model.dart';
import '../model/share_aspect_ratio.dart';
import '../service/image_export_service.dart';
import 'templates/full_calendar_template.dart';

class SharePreviewScreen extends ConsumerStatefulWidget {
  const SharePreviewScreen({required this.symbol, super.key});

  final String symbol;

  @override
  ConsumerState<SharePreviewScreen> createState() => _SharePreviewScreenState();
}

class _SharePreviewScreenState extends ConsumerState<SharePreviewScreen> {
  final _boundaryKey = GlobalKey();
  final _exporter = const ImageExportService();
  ShareAspectRatio _ratio = ShareAspectRatio.story916;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final docAsync = ref.watch(calendarViewModelProvider);
    final month = ref.watch(focusedMonthProvider);
    final appThemeId =
        ref.watch(settingsViewModelProvider).valueOrNull?.themeId ?? 'default';
    final doc = docAsync.valueOrNull;
    final docThemeId = doc?.themeId ?? 'default';
    final theme = CalendarThemes.byId(
        docThemeId == 'default' ? appThemeId : docThemeId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('分享月曆'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<ShareAspectRatio>(
                segments: [
                  for (final r in ShareAspectRatio.values)
                    ButtonSegment(value: r, label: Text(r.label)),
                ],
                selected: {_ratio},
                onSelectionChanged: (s) => setState(() => _ratio = s.first),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: RepaintBoundary(
                      key: _boundaryKey,
                      child: FullCalendarTemplate(
                        doc: doc,
                        theme: theme,
                        ratio: _ratio,
                        symbol: widget.symbol,
                        year: month.year,
                        month: month.month,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _saveToGallery,
                      icon: const Icon(Icons.save_alt),
                      label: const Text('儲存到相簿'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _share,
                      icon: const Icon(Icons.share),
                      label: const Text('分享'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> _capture() async {
    return _exporter.capture(_boundaryKey);
  }

  Future<void> _saveToGallery() async {
    setState(() => _busy = true);
    try {
      final bytes = await _capture();
      if (bytes == null) {
        _toast('截圖失敗');
        return;
      }
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          _toast('未取得相簿權限');
          return;
        }
      }
      await Gal.putImageBytes(bytes, name: _fileName());
      _toast('已儲存到相簿');
    } catch (e) {
      _toast('儲存失敗：$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      final bytes = await _capture();
      if (bytes == null) {
        _toast('截圖失敗');
        return;
      }
      await SharePlus.instance.share(ShareParams(
        files: [
          XFile.fromData(bytes, mimeType: 'image/png', name: '${_fileName()}.png'),
        ],
      ));
    } catch (e) {
      _toast('分享失敗：$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _fileName() {
    final month = ref.read(focusedMonthProvider);
    final mm = month.month.toString().padLeft(2, '0');
    return '${widget.symbol}_${month.year}-$mm';
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
