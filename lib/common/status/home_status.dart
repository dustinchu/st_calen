import 'package:flutter/material.dart';
import 'package:stock_calendar/common/model/calendar_model.dart';
import 'package:stock_calendar/common/model/preferences_repository_impl.dart';

class HomeStatus extends ChangeNotifier {
  HomeStatus(this.calendarModel);
  //按鈕狀態
  bool homeButtonStatus = false;
  CalendarModel calendarModel;
  String type;

  String get getCalendarIndexType => type;
  bool get getHomeButtonStatus => homeButtonStatus;
  Map<String, dynamic> get getCalendarModel => calendarModel.toJson();

  void homeClick() {
    homeButtonStatus = !homeButtonStatus;
    notifyListeners();
  }

  void homeToday(bool status) {
    homeButtonStatus = status;
    notifyListeners();
  }

  void setCalendarIndex(String _type) {
    type = _type;
    notifyListeners();
  }

  void setCalendarModel(int _type) {
    final preferencesRepository = PreferencesRepositoryImpl();
    //得到行事曆類型
    final CalendarModel _calendarModel =
        CalendarModel.fromJson(preferencesRepository.calendarType(_type));
    //儲存
    preferencesRepository.saveLocale(_calendarModel, _type);
    //改變狀態
    calendarModel = _calendarModel;
    notifyListeners();
  }
}
