import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'notification_schedule.dart';

/// 本地通知 service（Phase 1）。負責：
/// - plugin 初始化 + Android channel 建立
/// - 通知權限請求（iOS / Android 13+ POST_NOTIFICATIONS）
/// - 每日 14:30 台股提醒（週一~週五，固定 Asia/Taipei）
/// - 結算完成即時通知
///
/// 遠端推播（FCM）留待 Step 22。排程計算抽到 [notification_schedule.dart] 單測。
class NotificationService {
  NotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const _channelId = 'st_calen_reminders';
  static const _channelName = '台股提醒';
  static const _channelDesc = '每日 14:30 台股提醒與結算完成通知';

  // 通知 id：每日提醒週一~週五各一（matchDateTimeComponents 週重複）。
  static const _reminderBaseId = 1000; // + weekday(1..5)
  static const _settlementId = 2001;

  static const _reminderHour = 14;
  static const _reminderMinute = 30;

  /// bootstrap 啟動序列呼叫。需在 tz.initializeTimeZones() 之後。
  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );
    await _plugin.initialize(initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
          ),
        );
  }

  /// 請求通知權限（決策：啟動即請求一次）。
  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// 套用開關狀態：ON → 重排每日提醒；OFF → 全部取消（含結算通知）。
  Future<void> applyEnabled(bool enabled) async {
    await cancelAll();
    if (enabled) await _scheduleDailyReminders();
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  /// 結算完成即時通知（彙總單則，避免每筆洗版）。
  Future<void> showSettlementUpdate() {
    return _plugin.show(
      _settlementId,
      '本月結算更新',
      '已自動填回最新收盤結果，點開查看命中狀況。',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// 排程週一~週五 14:30（Asia/Taipei，每週重複）。
  Future<void> _scheduleDailyReminders() async {
    final now = tz.TZDateTime.now(tz.local);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    for (var weekday = DateTime.monday; weekday <= DateTime.friday; weekday++) {
      final when = nextInstanceOfWeekdayTime(
        now,
        weekday: weekday,
        hour: _reminderHour,
        minute: _reminderMinute,
      );
      await _plugin.zonedSchedule(
        _reminderBaseId + weekday,
        '台股提醒',
        '盤後 14:30，記得回來填寫今天的預測結算。',
        when,
        details,
        // 每日提醒非分秒精準需求 → inexact，免 SCHEDULE_EXACT_ALARM 權限。
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }
}

/// App 全域單例（bootstrap 與 ViewModel 共用同一實例）。
final NotificationService notificationService = NotificationService();
