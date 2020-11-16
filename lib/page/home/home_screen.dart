import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:stock_calendar/common/color/hex_color.dart';
import 'package:stock_calendar/common/model/admob_service.dart';
import 'package:stock_calendar/common/model/calendar.dart';
import 'package:stock_calendar/common/model/preferences_repository_impl.dart';
import 'package:stock_calendar/common/status/home_status.dart';
import 'package:stock_calendar/common/status/image_status.dart';
import 'package:stock_calendar/common/widget/menu.dart';
import 'package:stock_calendar/page/home/title_text_field.dart';
import 'dart:ui' as ui;
import 'mark_app_name.dart';
import 'title_row.dart';
import 'today_click.dart';
import '../../table_calendar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  //   keywords: <String>['game', 'words'],
  // );

  BannerAd _bannerAd;

  // BannerAd createBannerAd() {
  //   return BannerAd(
  //     // adUnitId: BannerAd.testAdUnitId,
  //     adUnitId: getBannerAdUnitId(),
  //     size: AdSize.banner,
  //     targetingInfo: targetingInfo,
  //     listener: (MobileAdEvent event) {
  //       print("BannerAd event $event");
  //     },
  //   );
  // }

  // 給一個初始值
  final Map<DateTime, List> _holidays = {
    DateTime(2020, 10, 27): [''],
    DateTime(2020, 10, 28): [''],
  };
  Map<DateTime, List> _events;

  AnimationController _animationController;
  CalendarController _calendarController;
  TextEditingController _titleClickController;
  TextEditingController _todayClickController;
  bool status1 = true;
  bool markStatus = true;
  bool todayClick = false;
  String title = "請輸入標題";
  DateTime clickDateTime;

  GlobalKey _globalKey = new GlobalKey();
  bool inside = false;
  Uint8List imageInMemory; //widget to image
  final preferencesRepository = PreferencesRepositoryImpl();
  double appWidth = 0;
  double appHeight = 0;
  // AdmobBannerSize bannerSize;
  // AdmobInterstitial interstitialAd;
  // AdmobReward rewardAd;
  @override
  void initState() {
    super.initState();
    //權限
    _requestPermission();
    //廣告
    FirebaseAdMob.instance.initialize(appId: getadMobAppid());

    //讀取選擇的index存到state
    preferencesRepository.getTypeIndex.then((calendarIndex) {
      Provider.of<HomeStatus>(context, listen: false)
          .setCalendarIndex(calendarIndex);
    });
    WidgetsBinding.instance.addObserver(this);
    // bannerSize = AdmobBannerSize.BANNER;
    // Admob.requestTrackingAuthorization();
    // interstitialAd = AdmobInterstitial(
    //   adUnitId: getInterstitialAdUnitId(),
    //   listener: (AdmobAdEvent event, Map<String, dynamic> args) {
    //     if (event == AdmobAdEvent.closed) interstitialAd.load();
    //     // handleEvent(event, args, 'Interstitial');
    //   },
    // );

    // rewardAd = AdmobReward(
    //   adUnitId: getRewardBasedVideoAdUnitId(),
    //   listener: (AdmobAdEvent event, Map<String, dynamic> args) {
    //     if (event == AdmobAdEvent.closed) rewardAd.load();
    //     // handleEvent(event, args, 'Reward');
    //   },
    // );

    // interstitialAd.load();
    // rewardAd.load();

    //鍵盤事件
    KeyboardVisibilityNotification()
        .addNewListener(onChange: _onKeyboardVisibilityNotification);
    //日期
    _events = {};
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _todayClickController = TextEditingController();
    _titleClickController = TextEditingController();
    _animationController.forward();

    _titleClickController.addListener((_onTitleEdit));
    _todayClickController.addListener((_onTodayEdit));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    _titleClickController.dispose();
    _todayClickController.dispose();
    super.dispose();
  }

  //權限監控
  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
  }

  // @override
  // void didChangeMetrics() {
  //   super.didChangeMetrics();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     setState(() {
  //       if (MediaQuery.of(context).viewInsets.bottom == 0) {
  //         //关闭键盘
  //         print("鍵盤關閉");
  //         Provider.of<HomeStatus>(context, listen: false).homeToday(false);
  //         _calendarController.swipeCalendarFormat(isSwipeUp: false);
  //       } else {
  //         //显示键盘
  //       }
  //     });
  //   });
  // }

  // //鍵盤狀態監聽
  void _onKeyboardVisibilityNotification(bool visible) {
    visible
        ? print(visible)
        : setState(() {
            Provider.of<HomeStatus>(context, listen: false).homeToday(false);
            _calendarController.swipeCalendarFormat(isSwipeUp: false);
          });
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    clickDateTime = DateTime(day.year, day.month, day.day);
    todayClick = true;
    Provider.of<HomeStatus>(context, listen: false).homeToday(true);
    setState(() {});
    print('CALLBACK: _onDaySelected${day.year}');
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  //漲
  void _onClickBtn1() {
    setState(() {
      markStatus = true;
      //價格輸入
      _holidays[clickDateTime] = [_todayClickController.text];
      _events[clickDateTime] = [markStatus ? '1' : '2'];
    });

    print('Model: btn1');
  }

  //跌
  void _onClickBtn2() {
    setState(() {
      markStatus = false;
      //價格輸入
      _holidays[clickDateTime] = [_todayClickController.text];
      _events[clickDateTime] = [markStatus ? '1' : '2'];
    });
    print('Model: btn2');
  }

  //價格輸入
  void _onTodayEdit() {
    setState(() {
      _calendarController.swipeCalendarFormat(isSwipeUp: true);
      _holidays[clickDateTime] = [_todayClickController.text];
      _events[clickDateTime] = [markStatus ? '1' : '2'];
    });
    print('Model: edit');
  }

  //標題
  void _onTitleEdit() {
    setState(() {
      title = _titleClickController.text;
      _calendarController.swipeCalendarFormat(isSwipeUp: true);
    });
    print('Model: edit');
  }

  void _reset() {
    setState(() {
      _holidays.clear();
      _events.clear();
      // _todayClickController.clear();
    });
  }

  void _capturePng(context) async {
    try {
      // RenderRepaintBoundary boundary =
      //     _globalKey.currentContext.findRenderObject();
      // ui.Image image = await boundary.toImage();
      // ByteData byteData =
      //     await image.toByteData(format: ui.ImageByteFormat.png);
      // final result =
      //     await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());
      // print(result);
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      // Provider.of<ImageStatus>(context, listen: false).imageUpload(pngBytes);
      Navigator.pushNamed(context, '/image', arguments: pngBytes);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var homeState = Provider.of<HomeStatus>(context);
    appWidth = MediaQuery.of(context).size.height;
    appHeight = MediaQuery.of(context).size.height > 700 ? 90 : 42;
    _bannerAd ??= createBannerAd();
    _bannerAd
      ..load()
      ..show();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: Color.fromRGBO(220, 225, 231, 1.00),
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.bottomCenter,
        fit: StackFit.expand, //未定位widget占满Stack整个空间
        children: [
          SafeArea(
            child: Container(
              color: Colors.black,
              // color: Color.fromRGBO(220, 225, 231, 1.00),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  RepaintBoundary(
                      key: _globalKey,
                      child: Container(
                        decoration: new BoxDecoration(
                            //外框背景
                            // color: Color.fromRGBO(220, 225, 231, 1.00),
                            color: '${homeState.getCalendarModel['frame']}'
                                .toColor()),
                        padding: appWidth > 900
                            ? EdgeInsets.only(
                                left: 100, right: 100, bottom: 50, top: 50)
                            : EdgeInsets.all(10),
                        child: Container(
                          decoration: new BoxDecoration(
                            //行事曆底色
                            // color: Color.fromRGBO(220, 225, 231, 1.00),
                            // color: '${def['calendar_background']}'.toColor(),
                            border: new Border.all(
                                color:
                                    '${homeState.getCalendarModel['border_line']}'
                                        .toColor(),
                                width: 0.5), // 邊框 寬度 顏色
                          ),
                          child: Column(
                            children: [
                              TitleRow(
                                title: title,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width - 40,
                                height: 0.5,
                                color:
                                    '${homeState.getCalendarModel['border_line']}'
                                        .toColor(),
                              ),
                              _buildTableCalendarWithBuilders(homeState),
                              MarkAppName(homeState),
                            ],
                          ),
                        ),
                      )),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: appWidth > 900
                            ? EdgeInsets.only(left: 100, right: 100)
                            : EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          children: [
                            //標題
                            TitleTextField(
                                titleFieldController: _titleClickController),
                            const SizedBox(height: 10.0),
                            //是否顯示 編輯價格資料
                            todayClick
                                ? TodayClick(
                                    todayClickController: _todayClickController,
                                    onClickBtn1: _onClickBtn1,
                                    onClickBtn2: _onClickBtn2,
                                    markStatus: markStatus)
                                : Container(),

                            OutlineButton(
                              onPressed: () {
                                // Provider.of<HomeStatus>(context, listen: false)
                                // .setCalendarModel(2);

                                _capturePng(context);
                              },
                              child: Text(
                                "預覽",
                                style: TextStyle(fontSize: 15),
                              ),
                              textColor: Colors.blue[200],
                              splashColor: Colors.white38,
                              borderSide: new BorderSide(color: Colors.white60),
                            ),
                            // inside
                            //     ? CircularProgressIndicator()
                            //     : imageInMemory != null
                            //         ? Container(
                            //             child: Image.memory(imageInMemory),
                            //             margin: EdgeInsets.all(10))
                            //         : Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 橫幅廣告
                  // BannerAd(
                  //   bannerSize: bannerSize,
                  // ),
                ],
              ),
            ),
          ),
          // Positioned(
          //   bottom: 20,
          //   child: BannerAd(
          //     bannerSize: bannerSize,
          //   ),
          // ),
          Positioned(
            child: Padding(
              padding: EdgeInsets.only(bottom: appHeight, right: 8.0),
              child: Menu(reset: _reset),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCalendarWithBuilders(homeState) {
    return new TableCalendar(
      rowHeight: 50,
      locale: 'zh_CN',
      calendarController: _calendarController,
      holidays: _holidays,
      events: _events,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
        CalendarFormat.week: '',
      },
      //內容背景
      calendarStyle: CalendarStyle(
        contentPadding: EdgeInsets.only(bottom: 0),
        contentDecoration: BoxDecoration(
          //日期背景
          color:
              '${homeState.getCalendarModel['calendar_background']}'.toColor(),
          // color: Color.fromRGBO(235, 236, 241, 0.8),
        ),
        highlightToday: false,
        // markersAlignment:Alignment.topLeft,
        outsideDaysVisible: false,
        weekdayStyle: TextStyle().copyWith(
            color: '${homeState.getCalendarModel['weekday_text']}'.toColor()),
        weekendStyle: TextStyle().copyWith(
            color: '${homeState.getCalendarModel['weekend']}'.toColor()),
        // weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
        holidayStyle: TextStyle().copyWith(
            color: '${homeState.getCalendarModel['weekday_text']}'.toColor()),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        //標題日期樣式
        decoration: BoxDecoration(
            color: '${homeState.getCalendarModel['weekend_row']}'.toColor(),
            borderRadius:
                new BorderRadius.vertical(top: Radius.elliptical(8, 8))),
        //假日顏色
        weekendStyle: TextStyle().copyWith(
            color: '${homeState.getCalendarModel['weekend']}'.toColor()),
      ),
      headerStyle: HeaderStyle(
        titleTextStyle: TextStyle(
            //標題
            color: '${homeState.getCalendarModel['header_text']}'.toColor(),
            fontSize: 17),
        centerHeaderTitle: true,
        formatButtonVisible: false,
        showLeftChevron: false,
        showRightChevron: false,
      ),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              //對齊
              padding: const EdgeInsets.only(top: 12.0),
              //點擊背景
              color: homeState.getHomeButtonStatus
                  ? '${homeState.getCalendarModel['click_today']}'.toColor()
                  : Colors.transparent,
              // color: Colors.deepOrange[300],
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                textAlign: TextAlign.center,
                //點擊顏色
                style: TextStyle().copyWith(
                    color: '${homeState.getCalendarModel['click_today_text']}'
                        .toColor(),
                    fontSize: 16.0),
              ),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          String textColor =
              events.toString().replaceAll(new RegExp(r"\[|\]"), "");
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: appWidth > 900 ? 30 : 1,
                top: 15,
                // bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }
          if (holidays.isNotEmpty) {
            children.add(
              Positioned(
                  child: AutoSizeText(
                '${holidays.toString().replaceAll(new RegExp(r"\[|\]"), "")}',
                style: TextStyle(
                    fontSize: 16,
                    color:
                        textColor == '1' ? Colors.red[800] : Colors.green[800]),
                minFontSize: 10,
                stepGranularity: 2,
                maxLines: 1,
              )),
            );
          }

          return children;
        },
      ),
      onDaySelected: (date, events, holidays) {
        _onDaySelected(date, events, holidays);
        _animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    String martString = events.toString().replaceAll(new RegExp(r"\[|\]"), "");
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: martString == '1' ? Colors.red[800] : Colors.green[800]),
      width: 13.0,
      height: 13.0,
      child: Center(
        child: Text(
          martString == '1' ? '漲' : '跌',
          // '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 10.0,
          ),
        ),
      ),
    );
  }
}
