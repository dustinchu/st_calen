import 'package:flutter/material.dart';

/// 分享圖三種固定像素規格（短邊一律 1080，輸出大小可預期）。
enum ShareAspectRatio {
  story916(1080, 1920, 'IG 限動 9:16'),
  square11(1080, 1080, '正方 1:1'),
  portrait45(1080, 1350, 'IG 貼文 4:5');

  const ShareAspectRatio(this.width, this.height, this.label);

  final double width;
  final double height;
  final String label;

  Size get size => Size(width, height);
}
