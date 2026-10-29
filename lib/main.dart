import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // 🔥 BackdropFilter + ImageFilter para efecto cristal
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/sell_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/register_screen.dart';
import 'screens/alertas_screen.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:uuid/uuid.dart';
import 'screens/pantalla_verificacion_encuentro.dart';
import 'screens/pantalla_verificar_identidad_otro.dart';

// 🔥 HANDLER PARA MENSAJES EN SEGUNDO PLANO
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('>>> 📨 MENSAJE EN SEGUNDO PLANO: ${message.notification?.title}');

  // 🔥 Si es una llamada de verificación, mostrar CallKit aunque la app esté cerrada
  if (message.data['tipo'] == 'llamada_verificacion') {
    await _mostrarLlamadaCallkit(message.data);
  }
}

// 🔥 Mostrar pantalla de llamada entrante (CallKit)
Future<void> _mostrarLlamadaCallkit(Map<String, dynamic> data) async {
  final encuentroId = data['encuentro_id']?.toString() ?? '0';
  final params = CallKitParams(
    id: const Uuid().v4(),
    nameCaller: data['caller_name']?.toString() ?? 'Verificación de identidad',
    appName: 'MiMarketplace',
    type: 0,
    duration: 30000,
    extra: {
      'encuentro_id': encuentroId,
      'caller_name': data['caller_name']?.toString() ?? '',
    },
    android: const AndroidParams(
      isCustomNotification: true,
      isShowLogo: true,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#0A5BE0',
      actionColor: '#22C55E',
      textAccept: 'Aceptar',
      textDecline: 'Rechazar',
    ),
  );
  await FlutterCallkitIncoming.showCallkitIncoming(params);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 🔥 BLOQUEAR ROTACIÓN HORIZONTAL
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // 🔥 Inicializar Firebase
  await Firebase.initializeApp();
  
  // 🔥 Inicializar Google Mobile Ads (con App ID de PRUEBA)
  await MobileAds.instance.initialize();

  // 🔥 REGISTRAR HANDLER DE MENSAJES EN SEGUNDO PLANO
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔥 INICIALIZAR NOTIFICACIONES
  await NotificationService.init();

  // 🔥 Pedir permiso de full-screen intent (Android 14+)
  await FlutterCallkitIncoming.requestFullIntentPermission();

  // 🔥 Escuchar cuando el usuario acepta la llamada
  FlutterCallkitIncoming.onEvent.listen((event) async {
    if (event == null) return;

    // 🔥 LIBERAR AUDIO AL COLGAR O RECHAZAR
    if (event is CallEventActionCallEnded || event is CallEventActionCallDecline) {
      // Forzar la liberación del audio focus de Android
      try {
        await FlutterCallkitIncoming.endAllCalls();
      } catch (e) {
        debugPrint('Error liberando audio CallKit: $e');
      }
      return;
    }

    if (event is CallEventActionCallAccept) {
      final extra = event.callKitParams.extra;
      final encuentroId =
          int.tryParse(extra?['encuentro_id']?.toString() ?? '0') ?? 0;
      if (encuentroId > 0) {
        final callerName = extra?['caller_name']?.toString() ?? '';
        if (callerName.contains('Verificar identidad del otro')) {
          NotificationService.navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => PantallaVerificarIdentidadOtro(encuentroId: encuentroId),
            ),
          );
        } else {
          NotificationService.navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => PantallaVerificacionEncuentro(encuentroId: encuentroId),
            ),
          );
        }
      }
    }
  });

  runApp(
    Phoenix(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationService.navigatorKey,
      title: 'Mi Marketplace',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth': (context) => const AuthGate(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// ============ CONTROL DE AUTENTICACIÓN ============
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const MainScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

// ============ PANTALLA DE LOGIN ============
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // 🔥 GUARDAR FCM TOKEN DESPUÉS DE INICIAR SESIÓN
      if (userCredential.user != null) {
        await NotificationService.guardarToken(userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      // 🔥 GUARDAR FCM TOKEN DESPUÉS DE INICIAR SESIÓN CON GOOGLE
      if (userCredential.user != null) {
        await NotificationService.guardarToken(userCredential.user!.uid);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Image.asset(
              'assets/icon/icon.png',
              width: 180,
              height: 180,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              ),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              ),
              obscureText: true,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 60),
                          textStyle: const TextStyle(fontSize: 20),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Iniciar Sesión'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _loginWithGoogle,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 55),
                          side: const BorderSide(color: Colors.grey),
                          textStyle: const TextStyle(fontSize: 18),
                          foregroundColor: Colors.black87,
                        ),
                       icon: const Icon(
  Icons.g_mobiledata,
  size: 28,
  color: Colors.blue,
),
                        label: const Text('Continuar con Google'),
                      ),
                    ],
                  ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ MENÚ PRINCIPAL ============
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _hayAlertasNuevas = false; // 🔥 NUEVO
  bool _hayMensajesNuevos = false; // 🔥 NUEVO

  @override
  void initState() {
    super.initState();
    _verificarAlertasNuevas();
    _verificarMensajesNuevos();
    _escucharNotificaciones();

    // 🔥 GUARDAR FCM TOKEN CADA VEZ QUE SE ABRE LA APP
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      NotificationService.guardarToken(user.uid);
    }
  }

  // 🔥 Verificar si hay mensajes no leídos al abrir la app
  Future<void> _verificarMensajesNuevos() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.get(
        Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/conversaciones/no-leidos/${user.uid}'),
        headers: {
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hayNuevos = data['hay_nuevos'] == true;
        if (mounted) {
          setState(() => _hayMensajesNuevos = hayNuevos);
        }
      }
    } catch (e) {
      print('Error al verificar mensajes: $e');
    }
  }

  // 🔥 Verificar si hay alertas no leídas al abrir la app
  Future<void> _verificarAlertasNuevas() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.get(
        Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/alertas/no-leidas/${user.uid}'),
        headers: {
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hayNuevas = data['hay_nuevas'] == true;
        if (mounted) {
          setState(() => _hayAlertasNuevas = hayNuevas);
        }
      }
    } catch (e) {
      print('Error al verificar alertas: $e');
    }
  }

  // 🔥 Escuchar notificaciones en primer plano
  void _escucharNotificaciones() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('>>> 📨 Notificación en primer plano: ${message.notification?.title}');

      // 🔥 Si es una llamada de verificación, mostrar CallKit
      if (message.data['tipo'] == 'llamada_verificacion') {
        await _mostrarLlamadaCallkit(message.data);
        return;
      }

      if (mounted) {
        // 🔥 Detectar si es un mensaje de chat
        final tipo = message.data['tipo']?.toString() ?? '';
        if (tipo == 'texto' || tipo == 'imagen' || message.data['conversacionId'] != null) {
          setState(() => _hayMensajesNuevos = true);
        }
        setState(() => _hayAlertasNuevas = true);
      }
    });
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const AlertasScreen(),
    const SellScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        _hayAlertasNuevas = false;
      }
      // 🔥 Si entra a Mensajes, quitar el punto
      if (index == 3) {
        _hayMensajesNuevos = false;
      }
    });
  }

  // 🎨 Colores según la pestaña activa
  Color _getBackgroundColor() {
    switch (_selectedIndex) {
      case 1: // Avisos → transparente (el blur lo pone el Stack)
        return Colors.transparent;
      case 2: // Vender
        return const Color(0xFF1A0B2E); // Morado oscuro
      case 3: // Mensajes
        return const Color(0xFF0A1628); // Azul oscuro
      case 4: // Perfil
        return const Color(0xFF0A1929); // Azul oscuro
      default:
        return Colors.white;
    }
  }

  // 🔥 ¿Estamos en la pestaña de Avisos? (para aplicar cristal)
  bool get _esTabAvisos => _selectedIndex == 1;

  Color _getSelectedColor() {
    switch (_selectedIndex) {
      case 2: // Vender - morado neón
        return const Color(0xFFBF00FF);
      case 3: // Mensajes - cyan neón
        return const Color(0xFF00E5FF);
      case 4: // Perfil - verde neón
        return const Color(0xFF39FF14);
      default:
        return Colors.blue;
    }
  }

  Color _getUnselectedColor() {
    switch (_selectedIndex) {
      case 2: // Vender
        return Colors.white.withValues(alpha: 0.5);
      case 3: // Mensajes
        return Colors.white.withValues(alpha: 0.5);
      case 4: // Perfil
        return Colors.white.withValues(alpha: 0.5);
      default:
        return Colors.black87;
    }
  }

  Color _getVenderIconColor() {
    switch (_selectedIndex) {
      case 2: // Vender
        return const Color(0xFFBF00FF);
      case 4: // Perfil
        return const Color(0xFF39FF14);
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 BottomNavigationBar base (reutilizado abajo)
    final barra = BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: _getBackgroundColor(),
      elevation: _selectedIndex == 4 ? 10 : 0,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: _getSelectedColor(),
      unselectedItemColor: _getUnselectedColor(),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Inicio'),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications),
              if (_hayAlertasNuevas)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          label: 'Avisos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle, size: 50, color: _getVenderIconColor()),
          label: 'Vender',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble_outline),
              if (_hayMensajesNuevos)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          label: 'Mensajes',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person_outline,
            shadows: _selectedIndex == 4
                ? [
                    Shadow(
                      color: const Color(0xFF39FF14).withValues(alpha: 0.8),
                      blurRadius: 15,
                    ),
                  ]
                : null,
          ),
          label: 'Perfil',
        ),
      ],
    );

    // 🔥 En Avisos, envolvemos con blur + tinte de cristal
    if (!_esTabAvisos) {
      return Scaffold(
        body: _widgetOptions[_selectedIndex],
        bottomNavigationBar: barra,
      );
    }

    // 🔥 EFECTO CRISTAL (glassmorphism)
    return Scaffold(
      extendBody: true, // 🔥 deja que el contenido pase por debajo
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              // 🔥 tinte blanco translúcido encima del blur
              color: Colors.white.withValues(alpha: 0.15),
              // 🔥 línea superior tipo "borde de vidrio"
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              // 🔥 sombra suave hacia arriba
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: barra,
          ),
        ),
      ),
    );
  }
}