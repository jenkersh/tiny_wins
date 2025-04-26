import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'tiny_win_storage.dart'; // <-- Important: import your TinyWinStorage

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleDailyNotification() async {
    // First check if the user already logged a win today
    final hasLoggedToday = await _hasLoggedWinToday();

    if (hasLoggedToday) {
      // Optional: cancel any previously scheduled notification
      await cancelAllNotifications();
      print('User already logged a win today. No notification scheduled.');
      return;
    }

    // Otherwise, schedule reminder
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '🎉 Tiny Wins Reminder',
      _getMotivationalMessage(),
      _nextInstanceOfTime(20, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_win_channel',
          'Daily Win Reminder',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );


    print('Scheduled daily notification for 8 PM.');
  }

  Future<bool> _hasLoggedWinToday() async {
    final wins = await TinyWinStorage.loadWins();
    final today = DateTime.now();

    // Check if any win's date matches today
    for (var win in wins) {
      if (_isSameDay(win.date, today)) {
        return true;
      }
    }
    return false;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
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

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
