import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:campus_event_mgmt_system/models/event.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> scheduleEventReminder(Event event, {int minutesBefore = 30}) async {
    final eventTime = event.dateTime;
    final reminderTime = eventTime.subtract(Duration(minutes: minutesBefore));
    
    // Don't schedule if the reminder time has already passed
    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    final id = event.id.hashCode;
    
    await _notifications.zonedSchedule(
      id,
      'Event Reminder: ${event.title}',
      'Your event starts in $minutesBefore minutes at ${event.venue}',
      tz.TZDateTime.from(reminderTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminders',
          'Event Reminders',
          channelDescription: 'Notifications for event reminders',
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFF2196F3),
          enableLights: true,
          enableVibration: true,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleEventStartNotification(Event event) async {
    final eventTime = event.dateTime;
    
    // Don't schedule if the event time has already passed
    if (eventTime.isBefore(DateTime.now())) {
      return;
    }

    final id = (event.id.hashCode + 1000); // Different ID for start notification
    
    await _notifications.zonedSchedule(
      id,
      'Event Starting: ${event.title}',
      'Your event is starting now at ${event.venue}',
      tz.TZDateTime.from(eventTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'event_start',
          'Event Start',
          channelDescription: 'Notifications when events start',
          importance: Importance.max,
          priority: Priority.max,
          color: const Color(0xFF4CAF50),
          enableLights: true,
          enableVibration: true,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('notification_sound'),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'notification_sound.aiff',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleDailyReminder(Event event) async {
    final eventTime = event.dateTime;
    final today = DateTime.now();
    final eventDate = DateTime(eventTime.year, eventTime.month, eventTime.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    
    // Only schedule if event is today
    if (eventDate.isAtSameMomentAs(todayDate)) {
      await scheduleEventReminder(event, minutesBefore: 60); // 1 hour before
      await scheduleEventReminder(event, minutesBefore: 15); // 15 minutes before
    }
  }

  Future<void> scheduleWeeklyReminder(Event event) async {
    final eventTime = event.dateTime;
    final now = DateTime.now();
    final daysUntilEvent = eventTime.difference(now).inDays;
    
    // Schedule weekly reminders if event is more than 7 days away
    if (daysUntilEvent > 7) {
      final weeklyReminderTime = eventTime.subtract(Duration(days: 7));
      
      if (weeklyReminderTime.isAfter(now)) {
        final id = (event.id.hashCode + 2000); // Different ID for weekly reminder
        
        await _notifications.zonedSchedule(
          id,
          'Upcoming Event: ${event.title}',
          'Your event is in 1 week. Don\'t forget to prepare!',
          tz.TZDateTime.from(weeklyReminderTime, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'weekly_reminders',
              'Weekly Reminders',
              channelDescription: 'Weekly event reminders',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              color: const Color(0xFFFF9800),
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  Future<void> scheduleDayBeforeReminder(Event event) async {
    final eventTime = event.dateTime;
    final dayBefore = eventTime.subtract(const Duration(days: 1));
    
    if (dayBefore.isAfter(DateTime.now())) {
      final id = (event.id.hashCode + 3000); // Different ID for day before reminder
      
      await _notifications.zonedSchedule(
        id,
        'Tomorrow: ${event.title}',
        'Your event is tomorrow at ${event.venue}. Get ready!',
        tz.TZDateTime.from(dayBefore, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'day_before_reminders',
            'Day Before Reminders',
            channelDescription: 'Reminders for events happening tomorrow',
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFF9C27B0),
            enableLights: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelEventNotifications(String eventId) async {
    final baseId = eventId.hashCode;
    await _notifications.cancel(baseId); // 30 min reminder
    await _notifications.cancel(baseId + 1000); // Start notification
    await _notifications.cancel(baseId + 2000); // Weekly reminder
    await _notifications.cancel(baseId + 3000); // Day before reminder
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Smart notification scheduling based on event timing
  Future<void> scheduleSmartReminders(Event event) async {
    final now = DateTime.now();
    final eventTime = event.dateTime;
    final timeUntilEvent = eventTime.difference(now);
    final daysUntilEvent = timeUntilEvent.inDays;

    if (daysUntilEvent > 7) {
      // Event is more than a week away - schedule weekly reminder
      await scheduleWeeklyReminder(event);
    } else if (daysUntilEvent > 1) {
      // Event is 2-7 days away - schedule day before reminder
      await scheduleDayBeforeReminder(event);
    } else if (daysUntilEvent == 1) {
      // Event is tomorrow - schedule day before reminder
      await scheduleDayBeforeReminder(event);
    } else if (daysUntilEvent == 0) {
      // Event is today - schedule hourly and 15-min reminders
      await scheduleDailyReminder(event);
    }

    // Always schedule start notification
    await scheduleEventStartNotification(event);
  }

  // Show immediate notification (for testing or immediate alerts)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'immediate_notifications',
          'Immediate Notifications',
          channelDescription: 'Immediate notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }
}
