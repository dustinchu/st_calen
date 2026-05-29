import 'package:flutter/material.dart';

/// 分享圖共用浮水印「股市行事曆」（靠右對齊）。
/// 視覺與 Step 18 full_calendar_template 內私有版型一致；本元件供新版型重用。
class ShareWatermark extends StatelessWidget {
  const ShareWatermark({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(Icons.calendar_month, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          '股市行事曆',
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
