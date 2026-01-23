import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    try {
      final dynamic result = await FlutterTimezone.getLocalTimezone();
      String timeZoneName = result.toString();
      
      // Handle TimezoneInfo object toString format: "TimezoneInfo(America/Chicago, ...)"
      if (timeZoneName.startsWith('TimezoneInfo(')) {
        final parts = timeZoneName.split(',');
        if (parts.isNotEmpty) {
          timeZoneName = parts[0].replaceAll('TimezoneInfo(', '').trim();
        }
      }
      
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Error setting timezone: $e');
      // Fallback to UTC
      tz.setLocalLocation(tz.UTC);
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        debugPrint('Notification tapped with payload: ${response.payload}');
      },
    );

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    bool? grantedAndroid = false;
    bool? grantedIOS = false;

    // Android 13+ requires specific permission
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      grantedAndroid = await androidImplementation.requestNotificationsPermission();
      // Request exact alarm permission for Android 12+
      await androidImplementation.requestExactAlarmsPermission();
    }

    // iOS
    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
            
    if (iosImplementation != null) {
      grantedIOS = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    
    // MacOS
    final MacOSFlutterLocalNotificationsPlugin? macosImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();

    if (macosImplementation != null) {
        await macosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return (grantedAndroid ?? false) || (grantedIOS ?? false);
  }

  Future<void> scheduleDailyOutfitNotification({
    required int hour,
    required int minute,
    required String occasion,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(0); // Cancel previous if any

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0, // ID
        'Capsule Closet',
        'Your $occasion outfit is ready! Tap to see what to wear today.',
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_outfit_channel',
            'Daily Outfit Notifications',
            channelDescription: 'Daily notifications for your outfit recommendations',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_outfit_$occasion',
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelDailyNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }
}
