import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class LocalNotificationService {
  static final _notificationPlugin = FlutterLocalNotificationsPlugin();

  static void initialize() {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    );

    _notificationPlugin.initialize(initializationSettings);
    tz_data.initializeTimeZones();
  }

  static Future<void> displayNotification({
    required String day,
    required String hour,
    required String minute,
    required String pillName,
    required String countMedicine,
    RemoteMessage? message,
  }) async {
    // Request permissions for notifications
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    final dateTime = DateTime.now();
    try {
      for (int i = 0; i < int.parse(day); i++) {
        final scheduleTime = DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day + i,
          int.parse(hour),
          int.parse(minute),
        );

        const notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            "medical",
            "medical_channel",
            importance: Importance.max,
            priority: Priority.high,
          ),
        );

        tz.Location timeZone = tz.getLocation('Asia/Almaty');
        tz.TZDateTime tzDateTime = tz.TZDateTime.from(scheduleTime, timeZone);

        await _notificationPlugin.zonedSchedule(
          i,
          'Reminder',
          'Did you forget to take $countMedicine pill of $pillName?',
          tzDateTime,
          notificationDetails,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    } on Exception catch (e) {
      print('Cannot add notification: $e');
    }
  }
}
