import 'package:flutter/material.dart';

Map<String, dynamic> calendarType(String type) {
  switch (type) {
    case 'def':
      return {
        //外框
        "frame": "#dce1e7",
        //背景
        "calendar_background": "#ebebf0",
        //週六週日
        "weekend": "#1565C0",
        //點擊今天
        "click_today": "#dce1eb",
        //點擊今天字體
        "click_today_text": "#000000",
        //標題
        "title_text": "#1565C0",
        //週抬頭底色
        "weekend_row": "#FFFFFF",
        //標題年月
        "header_text": "#000000",
        //平日字體顏色
        "weekday_text": "#000000",
        //線框顏色
        "border_line": "#73000000"
      };
    case 'black':
      return {
        //外框
        "frame": "#000000",
        //背景
        "calendar_background": "#8A000000",
        //週六週日
        "weekend": "#1565C0",
        //點擊今天
        "click_today": "#1FFFFFFF",
        //點擊今天顏色
        "click_today_text": "#FFFFFF",
        //標題
        "title_text": "#1565C0",
        //週抬頭底色
        "weekend_row": "#8A000000",
        //標題年月
        "header_text": "#FFFFFF",
        //平日字體顏色
        "weekday_text": "#FFFFFF",
        //線框顏色
        "border_line": "#B3FFFFFF"
      };
    default:
      return {};
  }
}
