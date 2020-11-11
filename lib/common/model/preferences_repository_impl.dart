import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'calendar_model.dart';

class PreferencesRepositoryImpl {
  static const String _typeCodeKey = 'type';
  static const String _typeIndexKey = 'typeIndex';
  @override
  Future<void> saveLocale(CalendarModel calendarModel, int type) async {
    final prefs = await SharedPreferences.getInstance();
    bool result;
    switch (type) {
      case (1):
        result =
            await prefs.setString(_typeCodeKey, jsonEncode(calendarType(1)));
        await prefs.setString(_typeIndexKey, '1');
        break;
      case (2):
        result =
            await prefs.setString(_typeCodeKey, jsonEncode(calendarType(2)));
        await prefs.setString(_typeIndexKey, '2');
        break;
      default:
        result = await prefs.setString(_typeCodeKey, jsonEncode(calendarModel));
    }
    return result;
  }

  @override
  Future<CalendarModel> get getCalendarType async {
    final prefs = await SharedPreferences.getInstance();

    final languageCode = prefs.getString(_typeCodeKey);

    if (languageCode != null) {
      Map<String, dynamic> calendarMap;
      final String calendarStr = prefs.getString(_typeCodeKey);
      if (calendarStr != null) {
        calendarMap = jsonDecode(calendarStr) as Map<String, dynamic>;
      }

      if (calendarMap != null) {
        final CalendarModel calendarModel = CalendarModel.fromJson(calendarMap);
        return calendarModel;
      }
      return null;
    } else {
      // var calendarJson =CalendarModel.fromJson(calendarType('def'));
      return CalendarModel.fromJson(calendarType(1));
    }
  }

  @override
  Future<String> get getTypeIndex async {
    final prefs = await SharedPreferences.getInstance();

    final typeIndex = prefs.getString(_typeIndexKey);

    if (typeIndex != null) {
      return typeIndex;
    } else {
      return '1';
    }
  }

  Map<String, dynamic> calendarType(int type) {
    switch (type) {
      case 1:
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
      case 2:
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
}
