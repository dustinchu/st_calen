import 'package:flutter/material.dart';

//rgba(220,225,231,1)
Color frameColor = '#dce1e7'.toColor();

 extension ColorExtension on String {
  toColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}

// Color hexToColor(String code) {
//   return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
// }

// // RGBA to 0xxxx
// int hexOfRGBA(int r, int g, int b, double opacity) {
//   r = (r < 0) ? -r : r;
//   g = (g < 0) ? -g : g;
//   b = (b < 0) ? -b : b;
//   opacity = (opacity < 0) ? -opacity : opacity;
//   opacity = (opacity > 1) ? 255 : opacity * 255;
//   r = (r > 255) ? 255 : r;
//   g = (g > 255) ? 255 : g;
//   b = (b > 255) ? 255 : b;
//   int a = opacity.toInt();
//   return int.parse(
//       '0x${a.toRadixString(16)}${r.toRadixString(16)}${g.toRadixString(16)}${b.toRadixString(16)}');
// }
