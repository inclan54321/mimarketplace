import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // 🔥 INICIALIZAR NOTIFICACIONES
  static Future<void> init() async {
    // Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings);

    // 🔥 SOLICITAR PERMISOS
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 🔥 OBTENER TOKEN FCM
    final token = await FirebaseMessaging.instance.getToken();
    print('>>> 📱 FCM TOKEN: $token');

    // 🔥 ESCUCHAR MENSAJES EN PRIMER PLANO
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 🔥 ESCUCHAR CUANDO EL USUARIO TOCA LA NOTIFICACIÓN
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    // 🔥 MANEJAR MENSAJE QUE ABRIÓ LA APP
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpened(initialMessage);
    }
  }

  // 🔥 MANEJAR MENSAJE EN PRIMER PLANO
  static void _handleForegroundMessage(RemoteMessage message) {
    print('>>> 📨 NOTIFICACIÓN EN PRIMER PLANO: ${message.notification?.title}');
    
    _showLocalNotification(
      title: message.notification?.title ?? 'Nuevo mensaje',
      body: message.notification?.body ?? '',
      data: message.data,
    );
  }

  // 🔥 MANEJAR CUANDO EL USUARIO TOCA LA NOTIFICACIÓN
  static void _handleMessageOpened(RemoteMessage message) {
    print('>>> 👆 USUARIO TOCÓ NOTIFICACIÓN: ${message.data}');
    
    final conversacionId = message.data['conversacionId'];
    final otroUsuario = message.data['otroUsuario'] ?? 'Usuario';
    final otroUsuarioId = message.data['otroUsuarioId'] ?? '';
    final nombreProducto = message.data['nombreProducto'] ?? 'Producto';
    final productoImagen = message.data['productoImagen'] ?? '';

    // TODO: Navegar a ChatScreen con los datos
    // Implementar después
  }

  // 🔥 MOSTRAR NOTIFICACIÓN LOCAL
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'chat_channel',
      'Mensajes de Chat',
      channelDescription: 'Notificaciones de mensajes nuevos',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('default'),
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }

  // 🔥 GUARDAR FCM TOKEN EN EL SERVIDOR
  static Future<void> guardarToken(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/usuarios/fcm-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': uid,
          'fcm_token': token,
        }),
      );
      print('>>> ✅ FCM TOKEN GUARDADO: ${response.statusCode}');
    } catch (e) {
      print('>>> ❌ Error guardando FCM token: $e');
    }
  }
}