import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'tiny_win_storage.dart'; // <-- Import your TinyWinStorage

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Cancel only today's notification
  Future<void> cancelNotificationForToday() async {
    final today = DateTime.now();
    final notificationId = _getNotificationIdForDate(today); // Generate unique ID based on the date

    await flutterLocalNotificationsPlugin.cancel(notificationId);
    print('Canceled notification for today.');
  }

  // Helper method to generate a unique ID based on the date
  int _getNotificationIdForDate(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day; // A unique ID based on the date
  }

  // Initialize notification service
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

  // Schedule the daily reminder notification
  Future<void> scheduleDailyNotification() async {
    // First check if the user has logged a win today
    final hasLoggedToday = await _hasLoggedWinToday();

    if (hasLoggedToday) {
      // Optional: cancel any previously scheduled notification
      await cancelAllNotifications();
      print('User already logged a win today. No notification scheduled.');
      return;
    }

    // Otherwise, schedule the reminder notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '🎉 Tiny Wins Reminder',
      _getMotivationalMessage(),
      _nextInstanceOfTime(20, 0), // Schedule at 8:00 PM
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

  // Check if the user has logged a win today
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

  // Helper function to compare if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Get the next scheduled time (e.g., 8:00 PM today, or tomorrow if it's past 8 PM)
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1)); // Move to tomorrow if time has passed
    }
    return scheduledDate;
  }

  // Get a motivational message for the notification
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

  // Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print('All notifications canceled.');
  }

  // Test notification (for testing purposes)
  Future<void> scheduleTestNotification() async {
    DateTime now = DateTime.now();
    DateTime testTime = now.add(const Duration(seconds: 10));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '🚀 Tiny Wins Test',
      'This is your test notification!',
      tz.TZDateTime.from(testTime, tz.local),
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

    print('Scheduled test notification for 10 seconds from now.');
  }
}
