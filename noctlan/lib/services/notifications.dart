import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:noctlan/main.dart';

void mostrarNotificacion(String titulo, String cuerpo) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'canal_id',
    'Canal de Notificaciones',
    channelDescription: 'Notificaciones del sistema de monitoreo',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0, // ID de la notificación
    titulo,
    cuerpo,
    notificationDetails,
  );
}
