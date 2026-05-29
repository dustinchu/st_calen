import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 把 RepaintBoundary 截成 PNG bytes。
///
/// `pixelRatio` 預設 1.0：template 已使用實際輸出像素（如 1080×1920）作為
/// logical size，無需再放大。
class ImageExportService {
  const ImageExportService();

  Future<Uint8List?> capture(GlobalKey boundaryKey,
      {double pixelRatio = 1.0}) async {
    final ctx = boundaryKey.currentContext;
    if (ctx == null) return null;
    final boundary = ctx.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return byteData?.buffer.asUint8List();
  }
}
