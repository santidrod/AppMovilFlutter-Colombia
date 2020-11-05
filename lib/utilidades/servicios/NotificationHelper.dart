import 'package:ciudadaniadigital/models/PushNotification.dart';
import 'package:ciudadaniadigital/utilidades/servicios/MessageBus.dart';
import 'package:ciudadaniadigital/utilidades/servicios/ServiceLocator.dart';
import 'package:ciudadaniadigital/utilidades/utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

final BehaviorSubject<PushNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<PushNotification>();

Future<void> initNotifications(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  var initializationSettingsAndroid = AndroidInitializationSettings('ic_stat_name');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String title, String body, dynamic payload) async {
        didReceiveLocalNotificationSubject.add(PushNotification(
          id: id.toString(), titulo: title, mensaje: body, payload: payload
        ));
      });
  var initializationSettings = InitializationSettings(
    android:  initializationSettingsAndroid,
    iOS: initializationSettingsIOS
  );

  PushTouchedMessageBus _pushMessageBus = locator<PushTouchedMessageBus>();

  await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null && payload.isNotEmpty) {
          Utilidades.imprimir('notification payload: ' + payload);
          // se emite broadcast para mostrar bandeja notificaciones
          _pushMessageBus.broadcastPushTouched(payload);
        }
      }
  );
}

Future<void> showNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    PushNotification pushNotification) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '0', 'Notification', 'Descripción canal',
      importance: Importance.max, priority: Priority.high, ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics
  );
  await flutterLocalNotificationsPlugin.show(
      0, pushNotification.titulo, pushNotification.mensaje, platformChannelSpecifics,
      payload: pushNotification.id);
}

Future<void> turnOffNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

Future<void> turnOffNotificationById(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    num id) async {
  await flutterLocalNotificationsPlugin.cancel(id);
}

void requestIOSPermissions(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}
