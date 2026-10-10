import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mimarketplace/screens/pantalla_verificacion_encuentro.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // 🔥 KEY GLOBAL PARA NAVEGAR DESDE NOTIFICACIONES
  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

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

    final tipo = message.data['tipo'];

    // 🔥 Recordatorio de encuentro → abrir pantalla de verificación
    if (tipo == 'recordatorio_1h' || tipo == 'recordatorio_10m') {
      final encuentroIdStr = message.data['encuentro_id'];
      final encuentroId = int.tryParse(encuentroIdStr ?? '');
      if (encuentroId != null) {
        _navegarAPantallaVerificacion(encuentroId);
      }
      return;
    }

    // Mensaje normal → abrir chat
    final conversacionId = message.data['conversacionId'];
    final otroUsuario = message.data['otroUsuario'] ?? 'Usuario';
    final otroUsuarioId = message.data['otroUsuarioId'] ?? '';
    final nombreProducto = message.data['nombreProducto'] ?? 'Producto';
    final productoImagen = message.data['productoImagen'] ?? '';

    // TODO: Navegar a ChatScreen con los datos
    // Implementar después
  }

  // 🔥 NAVEGAR A PANTALLA DE VERIFICACIÓN DE ENCUENTRO
  static void _navegarAPantallaVerificacion(int encuentroId) {
    final navigatorKey = GlobalKey<NavigatorState>();
    // Necesitamos un Navigator global. Ver Parte 2C.

    final context = _navigatorKey.currentContext;
    if (context == null) {
      print('>>> ⚠️ No hay contexto para navegar');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PantallaVerificacionEncuentro(encuentroId: encuentroId),
      ),
    );
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