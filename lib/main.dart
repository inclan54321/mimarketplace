import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'services/notification_service.dart';

// 🔥 HANDLER PARA MENSAJES EN SEGUNDO PLANO
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('>>> 📨 MENSAJE EN SEGUNDO PLANO: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔥 Inicializar Firebase
  await Firebase.initializeApp();
  
  // 🔥 Inicializar Google Mobile Ads (con App ID de PRUEBA)
  await MobileAds.instance.initialize();

  // 🔥 REGISTRAR HANDLER DE MENSAJES EN SEGUNDO PLANO
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔥 INICIALIZAR NOTIFICACIONES
  await NotificationService.init();
  
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
  }

  // 🔥 Verificar si hay mensajes no leídos al abrir la app
  Future<void> _verificarMensajesNuevos() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final response = await http.get(
        Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/conversaciones/no-leidos/${user.uid}'),
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

      final response = await http.get(
        Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/alertas/no-leidas/${user.uid}'),
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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('>>> 📨 Notificación en primer plano: ${message.notification?.title}');
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
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
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
      ),
    );
  }
}