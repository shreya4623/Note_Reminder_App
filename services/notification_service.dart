import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/note_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  int _notificationId(String noteId) => noteId.hashCode.abs() % 2147483647;

  Future<void> scheduleReminder(Note note) async {
    if (note.reminderDateTime == null || note.isCompleted) {
      await cancelReminder(note.id);
      return;
    }

    final scheduledDate = note.reminderDateTime!;
    if (scheduledDate.isBefore(DateTime.now())) return;

    final androidDetails = AndroidNotificationDetails(
      'note_reminders',
      'Note Reminders',
      channelDescription: 'Notifications for note reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      _notificationId(note.id),
      'Reminder: ${note.title}',
      note.content.isNotEmpty ? note.content : 'You have a reminder!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: _repeatComponent(note.repeatType),
      payload: note.id,
    );
  }

  DateTimeComponents? _repeatComponent(RepeatType repeatType) {
    switch (repeatType) {
      case RepeatType.daily:
        return DateTimeComponents.time;
      case RepeatType.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case RepeatType.none:
        return null;
    }
  }

  Future<void> cancelReminder(String noteId) async {
    await _plugin.cancel(_notificationId(noteId));
  }

  Future<void> rescheduleAll(List<Note> notes) async {
    for (final note in notes) {
      if (note.hasReminder && !note.isCompleted) {
        await scheduleReminder(note);
      } else {
        await cancelReminder(note.id);
      }
    }
  }
}
