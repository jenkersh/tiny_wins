import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const int dailyNotificationId = 0; // Same ID for daily repeat

  Future<void> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    // Set the correct local timezone
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Initialize notification settings
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOSInit = DarwinInitializationSettings();

    final initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );

    await _plugin.initialize(initSettings);

    // Request notification permission (especially for iOS)
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Schedules a repeating 8 PM daily reminder
  Future<void> scheduleDailyReminder() async {
    final details = NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      20,
      00,
    );

    print(now);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      dailyNotificationId,
      '🎉 Tiny Wins',
      _getMotivationalMessage(),
      scheduled,
      details,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at same time
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // still required even for iOS build!
    );

    print('Scheduled daily reminder at 20:00.');
  }

  /// Cancels the recurring daily reminder
  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(dailyNotificationId);
    print('Canceled daily reminder.');
  }

  /// Optional: cancel today’s if a win is logged today (no repeat affected)
  Future<void> cancelTodayOnly() async {
    await _plugin.cancel(dailyNotificationId);
    print('Canceled today’s 8 PM reminder only.');
    await scheduleDailyReminder(); // reschedule so future days still work
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  String _getMotivationalMessage() {
    final messages = [
      "You’re doing amazing! 🌟 Log your tiny win!",
      "Celebrate your progress today 🎉",
      "One small win a day keeps doubt away 🚀",
      "Share your sparkle ✨ What did you achieve today?",
      "Tiny steps, big dreams 💪 What’s your win today?",
    ];
    messages.shuffle();
    return messages.first;
  }

  // /// Returns a list of all scheduled notifications
  // Future<List<PendingNotificationRequest>> listScheduledNotifications() async {
  //   final pending = await _plugin.pendingNotificationRequests();
  //   for (var n in pending) {
  //     print('ID: ${n.id}, Title: ${n.title}, Body: ${n.body}');
  //   }
  //   return pending;
  // }
  //
  // /// Immediately shows a test notification
  // /// Schedules a test notification 10 seconds from now
  // Future<void> scheduleTestNotification() async {
  //   final now = tz.TZDateTime.now(tz.local);
  //   final scheduled = now.add(const Duration(seconds: 10));
  //
  //   const details = NotificationDetails(
  //     iOS: DarwinNotificationDetails(
  //       presentAlert: true,
  //       presentBadge: true,
  //       presentSound: true,
  //     ),
  //   );
  //
  //   await _plugin.zonedSchedule(
  //     9999, // Test notification ID
  //     '🔔 Scheduled Test',
  //     'This notification was scheduled 10 seconds ago!',
  //     scheduled,
  //     details,
  //     matchDateTimeComponents: null, // No repeat
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // <-- REQUIRED NOW
  //   );
  //
  //   print('Scheduled a test notification 10 seconds from now.');
  // }






}
