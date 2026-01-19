import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // Icone padrão do app
      [
        NotificationChannel(
          channelKey: 'med_reminders',
          channelName: 'Lembretes de Remédios',
          channelDescription: 'Notificações para hora dos remédios',
          defaultColor: const Color(0xFF009688),
          ledColor: const Color(0xFF009688),
          importance: NotificationImportance.High,
        ),
      ],
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'med_reminders',
        title: title,
        body: body,
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
    );
  }

  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }
}
