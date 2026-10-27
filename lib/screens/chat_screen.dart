import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/boton_grabacion.dart';
import '../services/chat_websocket_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';
import 'package:animated_emoji/animated_emoji.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../models/producto.dart';
import 'detalle_producto_screen.dart';
import 'perfil_vendedor_screen.dart';
import 'portafolio_vendedor_screen.dart'; // 🔥 NUEVO
import '../widgets/conversation_status_indicator.dart';
import 'image_viewer_screen.dart';
import 'pantalla_verificacion_encuentro.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/escudo_seguridad_widget.dart'; // 🔥 NUEVO
import '../widgets/modal_escudo_uber.dart'; // 🔥 NUEVO
import '../services/chat_service.dart';        // 🔥 NUEVO
import '../widgets/calificacion_widget.dart';    
import 'package:shared_preferences/shared_preferences.dart';       // 🔥 NUEVO
// 🔥 NUEVO
import 'package:intl/intl.dart';                                    // 🔥 NUEVO



class ChatScreen extends StatefulWidget {
  final String conversacionId;
  final String otroUsuario;
  final String otroUsuarioId;
  final String nombreProducto;
  final String productoImagen;
    final String productoId; // ← NUEVO
  final String productoPrecio; // ← NUEVO
   final String productoCategoria;
  final String productoDescripcion;
  final String productoDireccion;
   final String productoImagenDestacada;
  final String productoImagenesReales;
  final String fotoPerfil;
  

  const ChatScreen({
    super.key,
    required this.conversacionId,
    required this.otroUsuario,
    required this.otroUsuarioId,
    required this.nombreProducto,
    this.productoImagen = '',
     this.productoId = '', // ← NUEVO
    this.productoPrecio = '0', // ← NUEVO
     this.productoCategoria = '',
  this.productoDescripcion = '',
  this.productoDireccion = '',
  this.productoImagenDestacada = '',
  this.productoImagenesReales = '',
  required this.fotoPerfil, // ← NUEVO
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _comentarioController = TextEditingController(); // 🔥 NUEVO
  final List<Map<String, String>> _mensajes = [];
  bool _isLoading = true;
  bool _enviandoImagen = false;
  final bool _mostrarPanelEmojis = false; // 🔥 NUEVO: panel de emojis
  String _conversacionIdActual = '';
  Timer? _timer;
  String _fotoVendedorReal = '';

  // 🔥 NUEVO: Si el otro usuario está en línea
  bool _otroUsuarioEnLinea = false;
  Timer? _presenciaTimer;
  String? _ultimaConexion;

  // 🔥 NUEVO: LISTA DE PRODUCTOS DEL VENDEDOR (para el header)
  List<Map<String, dynamic>> _productosDelVendedor = [];

  // 🔥 NUEVO: CACHÉ DE FOTOS DE PERFIL EN MEMORIA
  final Map<String, String> _cacheFotosPerfil = {};
  int _calificacionSeleccionada = 0;
  ConversationStatus _conversationStatus = ConversationStatus.neutral;
  final Set<int> _mensajesTachados = {};
  String? _mensajeSeleccionadoId;
  bool _iaActiva = false;
  String? _analisisIA;

  // 🔥 VARIABLES PARA CALIFICACIÓN PENDIENTE
  bool _calificacionPendiente = false;
  bool _calificacionRealizada = false;
  String _vendedorId = '';
  int _productoId = 0;

  // 🔥 NUEVO: Si el panel de análisis del chat está abierto
  bool _panelAnalisisAbierto = false;

    // 🔥 NUEVO: Header de productos expandido/colapsado
  bool _headerExpandido = false;

  // 🔥 CACHÉ DE PROPUESTAS DE ENCUENTRO
  final Map<String, Map<String, dynamic>> _cachePropuestas = {};
  bool _escudoCargado = false; // 🔥 NUEVO
  bool _interfazEncuentroMostrada = false; // 🔥 NUEVO: para no mostrar dos veces
  bool _ultimoQuiereEncuentroProcesado = false; // 🔥 Para no disparar con análisis viejo
  String? _ultimoMensajeEncuentroId; // 🔥 Último mensaje que ya abrió el formulario
  bool _propuestaEncuentroPendiente = false; // 🔥 NUEVO
  bool _chatBloqueado = false; // 🔥 NUEVO
  bool _chatDesbloqueadoPorVerificacion = false; // 🔥 Si ya pasó la verificación cruzada
  bool _mostrarBotonesConfirmar = false; // 🔥 NUEVO
  bool _esperandoRespuestaOtro = false; // 🔥 NUEVO
  bool _usuarioDecidioSeguirConversando = false; // 🔥 NUEVO
  bool _quiereCerrarTrato = false; // 🔥 NUEVO
  bool _mostrarBotonesCerrarTrato = false; // 🔥 NUEVO
  bool _usuarioConfirmoCerrarTrato = false; // 🔥 NUEVO
  bool _otroUsuarioConfirmoCerrarTrato = false; // 🔥 NUEVO
  bool _esperandoConfirmacionCerrarTrato = false; // 🔥 NUEVO
  bool _estadoCargado = false; // 🔥 El input no se muestra hasta conocer el estado de bloqueo
  bool _cerrarTratoForzado = false; // 🔥 Modal de cerrar trato abierto por el escudo o por el otro usuario (la IA no lo apaga)
  bool _yoAbriCerrarTrato = false;  // 🔥 true SOLO si YO pulsé "Cerrar trato" en el menú del escudo

  // 🔥 ESCUDO MUTUO (aceptar/rechazar por el otro usuario)
  String? _escudoActivadoPor;
  bool _escudoYoAcepte = false;
  bool _escudoOtroRechazo = false;
  bool _escudoConfirmado = false;
  bool _mostrarModalEscudo = false; // 🔥 Para no abrir el modal dos veces
  bool _escudoYoViModal = false;    // 🔥 Ya vio el modal, no volver a mostrarlo
  bool _escudoResuelto = false;     // 🔥 Ya no hay que consultar más

   // 🔥 AUDIO
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecording = false;
  String? _audioPath;
  // ============ 🔥 NUEVO: AUDIO REPRODUCCIÓN ============
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _audioPlayingId;
  bool _isAudioPlaying = false;

  // 🔥 NUEVO: REPRODUCTOR PARA SONIDOS DE UI (botón de grabación)
  final AudioPlayer _uiSoundPlayer = AudioPlayer();

  // 🚨 REPRODUCTOR PARA SONIDO DE EMERGENCIA
  final AudioPlayer _emergencySoundPlayer = AudioPlayer();

  // ============ 🔥 NUEVO: GRABACIÓN CON PRESIÓN LARGA ============
  double _micScale = 1.0;              // Para animación del botón
  bool _isSwipedToCancel = false;      // Para detectar deslizamiento
  Timer? _recordingTimer;              // Timer para mostrar tiempo
  String _recordingTime = '00:00';     // Tiempo de grabación
  final Offset _startPosition = Offset.zero;  // 🔥 NUEVO: Posición donde se presionó
  bool _isDraggingOut = false;          // 🔥 NUEVO: Si el dedo está fuera del botón
  bool _mostrarMensajeCancelar = false; // 🔥 NUEVO: Mostrar texto verde de cancelar

  // 🔥 NUEVO: OVERLAY DEL CÍRCULO ROJO
  final GlobalKey _audioButtonKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  // 🔥 NUEVO: ANIMACIÓN DEL CÍRCULO OSCILANTE
  late AnimationController _oscilacionController;
  late Animation<double> _oscilacionAnim;

  // 🔥 ANIMACIÓN DEL BORDE PUNTEADO DE LA PROPUESTA
  late AnimationController _bordeController;

  // 🚨 ANIMACIÓN DE REBOTE DEL BOTÓN DE EMERGENCIA
  late AnimationController _emergencyReboteController;
  late Animation<double> _emergencyReboteAnim;

  // 🔥 WEBSOCKET
  ChatWebSocketService? _wsService;
    

  final List<AnimatedEmoji> _emociones = const [
    AnimatedEmoji(AnimatedEmojis.joy, size: 40, repeat: true),
    AnimatedEmoji(AnimatedEmojis.heartEyes, size: 40, repeat: true),
    AnimatedEmoji(AnimatedEmojis.smile, size: 40, repeat: true),
    AnimatedEmoji(AnimatedEmojis.sad, size: 40, repeat: true),
    AnimatedEmoji(AnimatedEmojis.angry, size: 40, repeat: true),
    AnimatedEmoji(AnimatedEmojis.sleep, size: 40, repeat: true),
  ];
  final int _indiceEmocion = 0;
  late Timer _timerEmociones;

  // 🔥 EL EMOJI DEPENDE DEL ESTADO DE LA IA
  AnimatedEmoji get _emojiActual {
    switch (_conversationStatus) {
      case ConversationStatus.good:
        return _emociones[0]; // 😂 joy
      case ConversationStatus.warning:
        return _emociones[3]; // 😢 sad
      case ConversationStatus.danger:
        return _emociones[4]; // 😡 angry
      case ConversationStatus.neutral:
      default:
        return _emociones[2]; // 🙂 smile
    }
  }
  // 🔥 GUARDAR ESTADO DEL ESCUDO (local + backend)
  Future<void> _guardarEstadoEscudo(bool activo) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || _conversacionIdActual.isEmpty) return;

      // 1. GUARDAR EN LOCAL (rápido)
      final prefs = await SharedPreferences.getInstance();
      final key = 'escudo_activo_${widget.conversacionId}';
      await prefs.setBool(key, activo);
      print('>>> 💾 Escudo local guardado: $activo');

      // 2. GUARDAR EN BACKEND (persistente)
      // 🔥 El escudo solo se activa. Nunca se desactiva.
      if (activo == true) {
        final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
        final response = await http.post(
          Uri.parse(
              'https://mimarketplace-production.up.railway.app/api/escudo/activar'),
          headers: {
            'Content-Type': 'application/json',
            if (idToken != null) 'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'conversacion_id': int.tryParse(_conversacionIdActual) ?? 0,
            'usuario_id': user.uid,
            'activo': true,
          }),
        );

        if (response.statusCode == 200) {
          print('>>> 💾 Escudo backend activado para AMBOS');
        } else {
          print('>>> ⚠️ Error al activar en backend: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error al guardar escudo: $e');
    }
  }

  // 🔥 MODAL DEL ESCUDO ACTIVADO POR EL OTRO USUARIO (ESTILO UBER)
  Future<void> _mostrarModalEscudoActivado() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String nombreQuienActivo = 'El otro usuario';
    try {
      final r = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/usuarios/$_escudoActivadoPor'),
      );
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        nombreQuienActivo = data['nombre'] ?? 'El otro usuario';
      }
    } catch (e) {
      print('Error al obtener nombre de quien activó: $e');
    }

    if (!mounted) return;

    ModalEscudoUber.mostrar(
      context,
      nombreQuienActivo: nombreQuienActivo,
      onAceptar: () => _aceptarEscudo(),
      onRechazar: () => _rechazarEscudo(),
    );
  }

  Future<void> _marcarModalVisto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/escudo/modal-visto'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'conversacion_id': int.tryParse(_conversacionIdActual) ?? 0,
          'usuario_id': user.uid,
        }),
      );
      if (mounted) {
        setState(() {
          _escudoYoViModal = true;
        });
      }
      print('>>> 🛡️ Modal marcado como visto en el backend');
    } catch (e) {
      print('Error al marcar modal visto: $e');
    }
  }

  Future<void> _aceptarEscudo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final r = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/escudo/aceptar'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'conversacion_id': int.tryParse(_conversacionIdActual) ?? 0,
          'usuario_id': user.uid,
        }),
      );
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        final confirmado = data['escudo_confirmado'] == true;
        setState(() {
          _escudoYoAcepte = true;
          _escudoYoViModal = true;
          if (confirmado) _escudoResuelto = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🛡️ Escudo aceptado'),
              backgroundColor: Color(0xFF00E676),
            ),
          );
        }
      }
    } catch (e) {
      print('Error al aceptar escudo: $e');
    }
  }

  Future<void> _rechazarEscudo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final r = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/escudo/rechazar'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'conversacion_id': int.tryParse(_conversacionIdActual) ?? 0,
          'usuario_id': user.uid,
        }),
      );
      if (r.statusCode == 200) {
        setState(() {
          _escudoOtroRechazo = true;
          _chatBloqueado = true;
          _escudoResuelto = true;
          _escudoYoViModal = true;
          _mostrarBotonesConfirmar = false;
          _mostrarBotonesCerrarTrato = false;
          _esperandoConfirmacionCerrarTrato = false;
          _esperandoRespuestaOtro = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🚫 Escudo rechazado. El chat quedó cerrado.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error al rechazar escudo: $e');
    }
  }

  Future<void> _marcarComoLeida() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || _conversacionIdActual.isEmpty) return;

      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      await http.put(
        Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/conversaciones/$_conversacionIdActual/leer'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'usuario_id': user.uid}),
      );
      print('>>> ✅ Conversación marcada como leída');
    } catch (e) {
      print('Error al marcar como leída: $e');
    }
  }

  // 🔥 CARGAR ESTADO DEL ESCUDO (local + backend)
  Future<void> _cargarEstadoEscudo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || _conversacionIdActual.isEmpty) return;

      // 1. LEER DE LOCAL PRIMERO (rápido)
      final prefs = await SharedPreferences.getInstance();
      final key = 'escudo_activo_${widget.conversacionId}';
      final activoLocal = prefs.getBool(key) ?? false;

      if (mounted) {
        setState(() {
          _iaActiva = activoLocal;
        });
      }
      print('>>> 💾 Escudo local: $activoLocal');

      // 2. CONSULTAR AL BACKEND (por si cambió en otro lado)
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.get(
        Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/escudo/estado/$_conversacionIdActual/${user.uid}'),
        headers: {
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final activoBackend = data['escudo_activo'] == true;
        final activadoPor = data['activado_por']?.toString();
        final yoAcepte = data['yo_acepte'] == true;
        final otroRechazo = data['otro_rechazo'] == true;
        final escudoConfirmado = data['escudo_confirmado'] == true;
        final yoViModal = data['yo_vi_modal'] == true;

        if (activoBackend != activoLocal) {
          await prefs.setBool(key, activoBackend);
        }
        if (mounted) {
          setState(() {
            _iaActiva = activoBackend;
            _escudoActivadoPor = activadoPor;
            _escudoYoAcepte = yoAcepte;
            _escudoOtroRechazo = otroRechazo;
            _escudoConfirmado = escudoConfirmado;
            _escudoYoViModal = yoViModal;

            // 🔥 Si el OTRO rechazó el escudo, el chat queda cerrado para AMBOS.
            if (otroRechazo) {
              _chatBloqueado = true;
              _mostrarBotonesConfirmar = false;
              _mostrarBotonesCerrarTrato = false;
              _esperandoConfirmacionCerrarTrato = false;
              _esperandoRespuestaOtro = false;
            }

            // 🔥 Si ya está resuelto (confirmado o rechazado o modal ya visto),
            // 🔥 dejamos de consultar en cada ciclo.
            if (escudoConfirmado || otroRechazo || yoViModal) {
              _escudoResuelto = true;
            }
          });
        }
        print('>>> 🛡️ Escudo backend: activo=$activoBackend, activadoPor=$activadoPor, yoAcepte=$yoAcepte, otroRechazo=$otroRechazo, confirmado=$escudoConfirmado');
      }
    } catch (e) {
      print('Error al cargar escudo: $e');
    }
  }

  // 🔥 GUARDAR ESTADO DE BLOQUEO (para restaurarlo al instante al volver a entrar)
  Future<void> _guardarEstadoBloqueo() async {
    try {
      if (_conversacionIdActual.isEmpty) return;
      final prefs = await SharedPreferences.getInstance();
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final k = 'estado_bloqueo_${uid}_$_conversacionIdActual';
      await prefs.setString(k, jsonEncode({
        'chatBloqueado': _chatBloqueado,
        'mostrarBotonesConfirmar': _mostrarBotonesConfirmar,
        'esperandoConfirmacion': _esperandoConfirmacionCerrarTrato,
        'esperandoRespuestaOtro': _esperandoRespuestaOtro,
        'usuarioConfirmo': _usuarioConfirmoCerrarTrato,
        'otroConfirmo': _otroUsuarioConfirmoCerrarTrato,
        'propuestaPendiente': _propuestaEncuentroPendiente,
        'quiereCerrarTrato': _quiereCerrarTrato,
        'mostrarBotonesCerrarTrato': _mostrarBotonesCerrarTrato,
      }));
    } catch (e) {
      print('Error al guardar estado de bloqueo: $e');
    }
  }

  // 🔥 RESTAURAR ESCUDO Y VERIFICACIÓN DESDE CACHÉ LOCAL (antes del primer frame)
  Future<void> _restaurarEstadoEscudo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activo = prefs.getBool('escudo_activo_${widget.conversacionId}') ?? false;
      final verificado = prefs.getBool('chat_verificado_${widget.conversacionId}') ?? false;
      if (mounted && (activo != _iaActiva || verificado != _chatDesbloqueadoPorVerificacion)) {
        setState(() {
          _iaActiva = activo;
          _chatDesbloqueadoPorVerificacion = verificado;
        });
      }
      print('>>> 💾 Escudo restaurado desde caché: activo=$activo, verificado=$verificado');
    } catch (e) {
      print('Error al restaurar escudo: $e');
    }
  }

  // 🔥 RESTAURAR ESTADO DE BLOQUEO (instantáneo, antes de consultar al servidor)
  Future<void> _restaurarEstadoBloqueo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final raw = prefs.getString('estado_bloqueo_${uid}_${widget.conversacionId}');
      if (raw == null || !mounted) return;
      final m = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        _chatBloqueado = m['chatBloqueado'] == true;
        _mostrarBotonesConfirmar = m['mostrarBotonesConfirmar'] == true;
        // 🔥 NO restaurar "esperandoConfirmacion" ni "esperandoRespuestaOtro" del caché.
        // 🔥 Esos estados los determina la BD en _cargarMensajes.
        _esperandoConfirmacionCerrarTrato = false;
        _esperandoRespuestaOtro = false;
        // 🔥 NO restaurar las confirmaciones del caché.
        // 🔥 Siempre vienen de la BD en _cargarMensajes.
        // 🔥 Así el cartel azul solo aparece para el que confirmó de verdad.
        _usuarioConfirmoCerrarTrato = false;
        _otroUsuarioConfirmoCerrarTrato = false;
        // 🔥 NO restaurar "decidioSeguir" del caché: ese estado se consulta a la BD.
        // Si se restaura, queda pegado para siempre y apaga el modal de cerrar trato.
        _usuarioDecidioSeguirConversando = false;
        _propuestaEncuentroPendiente = m['propuestaPendiente'] == true;
        _quiereCerrarTrato = m['quiereCerrarTrato'] == true;
        // 🔥 NO restaurar el modal de cerrar trato del caché: lo decide el servidor.
        // Si se restaura, aparece unos segundos y luego se apaga.
        _mostrarBotonesCerrarTrato = false;

        // 🔥 Ya tenemos el estado: el input se muestra/oculta al instante
        _estadoCargado = true;
      });
    } catch (e) {
      print('Error al restaurar estado de bloqueo: $e');
    }
  }

  // 🔥 CONECTAR WEBSOCKET
  void _conectarWebSocket() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _conversacionIdActual.isEmpty) return;

    _wsService?.desconectar();
    _wsService = ChatWebSocketService(
      conversacionId: _conversacionIdActual,
      usuarioId: user.uid,
      onNuevoMensaje: (data) {
        print('>>> 📩 WS nuevo mensaje');
        if (mounted) {
          _cargarMensajes(_conversacionIdActual, esMensajeNuevo: true);

          // 🔥 Reintentar el análisis a los 5s (DeepSeek tarda)
          Timer(const Duration(seconds: 5), () {
            if (mounted) {
              final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
              _analizarMensajeConIA('', uid, esMensajeNuevo: true);
            }
          });
        }
      },
      onEstadoCambio: (data) {
        print('>>> 🔄 WS cambio de estado: ${data['estado']}');
        if (!mounted) return;
        if (data['estado'] == 'analisis_listo') {
          // 🔥 El servidor terminó de analizar: consultar al instante
          final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
          _analizarMensajeConIA('', uid, esMensajeNuevo: true);
        } else {
          _cargarMensajes(_conversacionIdActual, forzar: true);
        }
      },
      onConectado: () {
        print('>>> ✅ WS conectado');
      },
      onDesconectado: () {
        print('>>> ❌ WS desconectado');
      },
    );
    _wsService!.conectar();
  }

  // 🔥 FUNCIÓN DE PRUEBA - SOLO PRINTS
  void _prueba() {
  print('>>> 🔥 ====== _prueba() EJECUTADA ======');
  print('>>> 🔥 _vendedorId ANTES: "$_vendedorId"');
  print('>>> 🔥 widget.conversacionId: ${widget.conversacionId}');
  print('>>> 🔥 widget.otroUsuarioId: ${widget.otroUsuarioId}');
  print('>>> 🔥 user.uid: ${FirebaseAuth.instance.currentUser?.uid}');
  print('>>> 🔥 _prueba() TERMINÓ');
}
Future<void> _verificarCalificacion() async {
  print('>>> 🔥 ====== _verificarCalificacion() INICIO ======');
  try {
    final user = FirebaseAuth.instance.currentUser;
    print('>>> 🔥 1. user: ${user?.uid ?? "NULL"}');
    
    if (user == null) {
      print('>>> 🔥 2. user es NULL, retornando');
      return;
    }

    print('>>> 🔥 3. widget.conversacionId: ${widget.conversacionId}');
    
    final chatService = ChatService();
    print('>>> 🔥 4. ChatService creado, llamando a verificarCalificacionPendiente...');
    
    final result = await chatService.verificarCalificacionPendiente(
      widget.conversacionId,
      user.uid,
    );
    
    print('>>> 🔥 5. RESULTADO COMPLETO: $result');
    print('>>> 🔥 6. result["pendiente"]: ${result['pendiente']}');
    print('>>> 🔥 7. result["vendedor_id"]: "${result['vendedor_id']}"');
    print('>>> 🔥 8. result["producto_id"]: ${result['producto_id']}');
    
    print('>>> 🔥 9. ANTES DE SETSTATE - _vendedorId: "$_vendedorId"');
    
    final nuevoPendiente = result['pendiente'] ?? false;
    final nuevoVendedorId = result['vendedor_id'] ?? '';
    final nuevoProductoId = int.tryParse(result['producto_id']?.toString() ?? '0') ?? 0;

    // 🔥 Solo setState si algo cambió de verdad, para no repintar el AppBar
    final huboCambio = _calificacionPendiente != nuevoPendiente ||
        _vendedorId != nuevoVendedorId ||
        _productoId != nuevoProductoId;

    if (huboCambio) {
      setState(() {
        _calificacionPendiente = nuevoPendiente;
        _vendedorId = nuevoVendedorId;
        _productoId = nuevoProductoId;
      });
    } else {
      _calificacionPendiente = nuevoPendiente;
      _vendedorId = nuevoVendedorId;
      _productoId = nuevoProductoId;
    }
    
    print('>>> 🔥 10. DESPUÉS DE SETSTATE - _vendedorId: "$_vendedorId"');
    print('>>> 🔥 11. _vendedorId ES VACÍO? ${_vendedorId.isEmpty}');
    print('>>> 🔥 12. _calificacionPendiente: $_calificacionPendiente');
    print('>>> 🔥 13. _productoId: $_productoId');
    
    // 🔥 ESTO FUERZA LA RECONSTRUCCIÓN DEL LISTVIEW
    print('>>> 🔥 14. Ejecutando addPostFrameCallback...');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('>>> 🔥 15. addPostFrameCallback EJECUTADO - forzando setState');
      setState(() {
        print('>>> 🔥 16. setState dentro de addPostFrameCallback - _vendedorId: "$_vendedorId"');
      });
    });
    
    print('>>> 🔥 17. _verificarCalificacion() TERMINÓ');
    
  } catch (e) {
    print('>>> 🔥 18. ERROR EN _verificarCalificacion: $e');
    print('>>> 🔥 19. Stack trace: ${StackTrace.current}');
  }
}
@override
void initState() {
  super.initState();
  print('>>> 🔥 ====== INITSTATE - CHATSCREEN ======');
  print('>>> 🔥 widget.conversacionId: ${widget.conversacionId}');
    _verificarCalificacion();
 _prueba();
  // 🔥 INICIALIZAR GRABADOR DE AUDIO
  _audioRecorder = FlutterSoundRecorder();
  _audioRecorder!.openRecorder();

  // 🔥 INICIALIZAR ANIMACIÓN DEL CÍRCULO OSCILANTE
  _oscilacionController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200), // velocidad del recorrido
  );

  // 🔥 Curva oscilante: 0 → 1 → 0 (ida y vuelta continua)
  _oscilacionAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _oscilacionController,
      curve: Curves.easeInOut,
    ),
  );

  // 🔥 Ya no gira todo el tiempo: se inicia solo al grabar

  // 🔥 Borde punteado de la tarjeta de propuesta (loop continuo)
  _bordeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  // 🚨 Controller de rebote del botón de emergencia
  _emergencyReboteController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  _emergencyReboteAnim = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.92), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 30),
  ]).animate(CurvedAnimation(
    parent: _emergencyReboteController,
    curve: Curves.easeOut,
  ));
  
  // 🔥 CONFIGURAR REPRODUCTOR DE AUDIO
  _audioPlayer.onPlayerComplete.listen((event) {
    if (mounted) {
      setState(() {
        _isAudioPlaying = false;
        _audioPlayingId = null;
      });
    }
  });
  
  // 🔥 EL EMOJI YA NO CAMBIA SOLO - DEPENDE DEL ESTADO DE LA IA
  // (se eliminó el Timer que cambiaba el emoji cada 3 segundos)
  _conversacionIdActual = widget.conversacionId;

  // 🔥 INICIAR WEBSOCKET
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _conectarWebSocket();
  });
  // 🔥 Precargar la plantilla de la tarjeta de encuentro
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      precacheImage(
        const AssetImage('assets/images/escudo/plantilla_encuentro.png'),
        context,
      );
    }
  });
  _restaurarEstadoEscudo(); // 🔥 escudo y verificación desde caché local
  _restaurarEstadoBloqueo(); // 🔥 estado de bloqueo inmediato desde caché local
  _cargarPropuestasDesdeCache(); // 🔥 propuestas cerradas inmediatas desde caché local
  _obtenerOCrearConversacion();
  _marcarComoLeida(); // 🔥 NUEVO
  _obtenerFotoVendedorReal();
  _cargarProductosDelVendedor(); // 🔥 NUEVO

  // 🔥 NUEVO: Consultar presencia del otro usuario
  _consultarPresencia();
  _presenciaTimer = Timer.periodic(
    const Duration(seconds: 30),
    (_) => _consultarPresencia(),
  );
  print('>>> DESPUÉS de llamar _obtenerFotoVendedorReal()');
  print('>>> _fotoVendedorReal: $_fotoVendedorReal');
    // 🔥 POLLING DESACTIVADO: ahora usa WebSocket
    // _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
    //   if (_conversacionIdActual.isNotEmpty && !_interfazEncuentroMostrada) {
    //     _cargarMensajes(_conversacionIdActual);
    //   }
    // });

  // 🔥 (Eliminado) _verificarCalificacion() ya se llama arriba en initState.
  // Llamarla dos veces solo provocaba setState duplicados y repintados del AppBar.

  // 🔥 (Eliminado el timer aleatorio - ahora el estado lo determina la IA)
}


@override
void dispose() {
  _wsService?.desconectar(); // 🔥 CERRAR WEBSOCKET
  _ocultarCirculoGrabacion(); // 🔥 ELIMINAR OVERLAY
  _oscilacionController.dispose(); // 🔥 LIBERAR ANIMACIÓN
  _bordeController.dispose();
  _emergencyReboteController.dispose();
  // _timerEmociones.cancel(); // 🔥 Ya no se usa
  _timer?.cancel();
  _controller.dispose();
  _audioRecorder?.closeRecorder();
  _audioPlayer.dispose();
  _uiSoundPlayer.dispose();  // 🔥 LIBERAR REPRODUCTOR DE UI
  _emergencySoundPlayer.dispose();  // 🚨 LIBERAR REPRODUCTOR DE EMERGENCIA
  _recordingTimer?.cancel();  // 🔥 NUEVO
  _presenciaTimer?.cancel();  // 🔥 NUEVO
  super.dispose();
}

  Future<void> _obtenerOCrearConversacion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    if (widget.conversacionId.isNotEmpty) {
      setState(() {
        _conversacionIdActual = widget.conversacionId;
      });
      _cargarMensajes(widget.conversacionId);
      return;
    }

    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/conversaciones'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'usuario1_id': user.uid,
          'usuario2_id': widget.otroUsuarioId,
          'producto_nombre': widget.nombreProducto,
          'producto_id': widget.productoId, // ← AGREGA ESTO
  'producto_imagen': widget.productoImagen, // ← Y ESTO
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          _conversacionIdActual = data['id'].toString();
        });
        _cargarMensajes(_conversacionIdActual);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _getFotoPerfil(String usuarioId) async {
    // 🔥 SI YA LA TENEMOS EN MEMORIA, DEVOLVERLA SIN PEDIR AL SERVIDOR
    if (_cacheFotosPerfil.containsKey(usuarioId)) {
      return _cacheFotosPerfil[usuarioId]!;
    }

    try {
      final response = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/perfil/foto/$usuarioId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final foto = data['foto_perfil'] ?? '';
        // 🔥 GUARDAR EN CACHÉ
        _cacheFotosPerfil[usuarioId] = foto;
        return foto;
      }
      return '';
    } catch (e) {
      return '';
    }
  }
  // ============ 🔥 NUEVO: CACHÉ DE MENSAJES ============
  Future<void> _guardarMensajesEnCache(
    String conversacionId,
    List<Map<String, String>> mensajes,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final key = 'chat_cache_${uid}_$conversacionId';
      final jsonString = jsonEncode(mensajes);
      await prefs.setString(key, jsonString);
      print('>>> 💾 Caché guardada: ${mensajes.length} mensajes');
    } catch (e) {
      print('Error al guardar caché: $e');
    }
  }

  Future<List<Map<String, String>>> _cargarMensajesDesdeCache(
    String conversacionId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final key = 'chat_cache_${uid}_$conversacionId';
      final jsonString = prefs.getString(key);
      if (jsonString == null || jsonString.isEmpty) return [];

      final List data = jsonDecode(jsonString);
      return data.map((item) {
        return {
          'id': item['id']?.toString() ?? '',
          'texto': item['texto']?.toString() ?? '',
          'usuario_id': item['usuario_id']?.toString() ?? '',
          'hora': item['hora']?.toString() ?? '',
          'foto_perfil': item['foto_perfil']?.toString() ?? '',
          'imagen': item['imagen']?.toString() ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error al cargar caché: $e');
      return [];
    }
  }

  Future<void> _limpiarCache(String conversacionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await prefs.remove('chat_cache_${uid}_$conversacionId');
    } catch (e) {
      print('Error al limpiar caché: $e');
    }
  }

  // 🔥 GUARDAR PROPUESTAS EN CACHÉ LOCAL (solo las CERRADAS)
  Future<void> _guardarPropuestasEnCache() async {
    try {
      if (_cachePropuestas.isEmpty) return;

      // 🔥 Solo guardar las que NO están pendientes
      final cerradas = <String, Map<String, dynamic>>{};
      _cachePropuestas.forEach((key, prop) {
        final estado = prop['estado'] ?? 'pendiente';
        if (estado != 'pendiente') {
          cerradas[key] = prop;
        }
      });

      final prefs = await SharedPreferences.getInstance();
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final cacheKey = 'propuestas_cache_${uid}_$_conversacionIdActual';

      if (cerradas.isEmpty) {
        await prefs.remove(cacheKey);
        return;
      }

      await prefs.setString(cacheKey, jsonEncode(cerradas));
      print('>>> 💾 Propuestas CERRADAS cacheadas: ${cerradas.length}');
    } catch (e) {
      print('Error al guardar propuestas en caché: $e');
    }
  }

  // 🔥 CARGAR PROPUESTAS DESDE CACHÉ LOCAL (solo las CERRADAS)
  Future<void> _cargarPropuestasDesdeCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final cacheKey = 'propuestas_cache_${uid}_$_conversacionIdActual';
      final raw = prefs.getString(cacheKey);
      if (raw == null || raw.isEmpty) return;

      final Map<String, dynamic> data = jsonDecode(raw);
      _cachePropuestas.clear();
      data.forEach((key, value) {
        final prop = Map<String, dynamic>.from(value);
        // 🔥 Solo cachear las cerradas
        final estado = prop['estado'] ?? 'pendiente';
        if (estado != 'pendiente') {
          _cachePropuestas[key] = prop;
        }
      });
      print('>>> 💾 Propuestas CERRADAS cargadas desde caché: ${_cachePropuestas.length}');

      if (mounted) setState(() {});
    } catch (e) {
      print('Error al cargar propuestas desde caché: $e');
    }
  }

  Future<void> _cargarMensajes(
    String conversacionId, {
    bool esMensajeNuevo = false,
    bool forzar = false,
  }) async {
  if (conversacionId.isEmpty) {
    setState(() => _isLoading = false);
    return;
  }

  // 🔥 SOLO mostrar el loading la primera vez
  final bool esPrimeraCarga = _mensajes.isEmpty;

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    setState(() => _isLoading = false);
    return;
  }

  // 🔥 PRIMERO: consultar el estado de bloqueo y la verificación del encuentro.
  // 🔥 Se hace ANTES de _cargarEstadoEscudo para que el AppBar se pinte
  // 🔥 una sola vez con el botón correcto (escudo o emergencia).
  try {
    final rBloqueo = await http.get(
      Uri.parse('https://mimarketplace-production.up.railway.app/api/conversaciones/$_conversacionIdActual/estado-bloqueo'),
    );
    if (rBloqueo.statusCode == 200) {
      final dataBloqueo = jsonDecode(rBloqueo.body);
      final chatBloqueadoBD = dataBloqueo['chat_bloqueado'] == true;
      final cerradoPorEscudoBD = dataBloqueo['cerrado_por_escudo'] == true;

      print('>>> 🔒 Estado de bloqueo BD: chat_bloqueado=$chatBloqueadoBD, cerrado_por_escudo=$cerradoPorEscudoBD');

      // 🔥 Consultar el encuentro ANTES del setState, para no repintar el AppBar
      // con el escudo y medio segundo después con el botón de emergencia.
      bool escudoVerificado = false;
      if (!chatBloqueadoBD) {
        try {
          final rEnc = await http.get(
            Uri.parse('https://mimarketplace-production.up.railway.app/api/encuentro/agendado/$_conversacionIdActual'),
          );
          if (rEnc.statusCode == 200) {
            final dataEnc = jsonDecode(rEnc.body);
            final enc = dataEnc['encuentro'];
            escudoVerificado = enc != null && enc['escudo_verificado'] == true;
          }
        } catch (e) {
          debugPrint('>>> Error verificando escudo: $e');
        }
      }

      if (mounted) {
        // 🔥 Un solo setState con TODO el estado nuevo:
        // bloqueo + escudo rechazado + botón de emergencia.
        // Así el AppBar se pinta una sola vez con el botón correcto.
        setState(() {
          if (chatBloqueadoBD && !_chatBloqueado) {
            _chatBloqueado = true;
            if (cerradoPorEscudoBD) {
              _escudoOtroRechazo = true;
              _escudoResuelto = true;
            }
          } else if (!chatBloqueadoBD && _chatBloqueado) {
            _chatBloqueado = false;
            _escudoOtroRechazo = false;
          }

          if (escudoVerificado && !_chatDesbloqueadoPorVerificacion) {
            _chatDesbloqueadoPorVerificacion = true;
          }
        });
      }
    }
  } catch (e) {
    print('Error al consultar estado de bloqueo: $e');
  }

  // 🔥 MOSTRAR MODAL DEL ESCUDO SI EL OTRO LO ACTIVÓ Y YO NO HE RESPONDIDO
  // 🔥 Y SOLO si todavía no lo vi (para no mostrarlo cada vez que entra al chat)
  if (!_escudoYoAcepte &&
      !_escudoOtroRechazo &&
      _escudoActivadoPor != null &&
      _escudoActivadoPor != user.uid &&
      !_mostrarModalEscudo &&
      !_escudoYoViModal &&
      mounted &&
      !_chatBloqueado) {
    _mostrarModalEscudo = true;
    _marcarModalVisto(); // 🔥 Marcar en backend que ya se mostró
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _mostrarModalEscudoActivado();
    });
  }

  // 🔥 1. MOSTRAR CACHÉ INMEDIATAMENTE (si es la primera vez)
  if (_mensajes.isEmpty) {
    final cacheados = await _cargarMensajesDesdeCache(conversacionId);
    if (cacheados.isNotEmpty && mounted) {
      setState(() {
        _mensajes.clear();
        _mensajes.addAll(cacheados);
        _isLoading = false;
      });
      print('>>> 💾 Cargados ${cacheados.length} mensajes desde caché');
    }
  }

  try {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    final response = await http.get(
      Uri.parse('https://mimarketplace-production.up.railway.app/api/mensajes/$conversacionId?usuario_id=${user.uid}'),
      headers: {
        if (idToken != null) 'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      // 🔥 Pedir TODAS las fotos en paralelo (una por usuario único)
      final idsUnicos = data
          .map((i) => (i['usuario_id'] ?? '').toString())
          .where((id) => id.isNotEmpty && id != 'SYSTEM')
          .toSet();
      await Future.wait(idsUnicos.map(_getFotoPerfil));

      List<Map<String, String>> mensajesConFotos = [];
      for (var item in data) {
        final usuarioId = item['usuario_id'] ?? '';
        final fotoPerfil = await _getFotoPerfil(usuarioId);
        mensajesConFotos.add({
          'id': item['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'texto': item['texto'] ?? '',
          'usuario_id': usuarioId,
          'hora': item['fecha'] != null
              ? DateTime.parse(item['fecha']).toString().substring(11, 16)
              : '',
          'foto_perfil': fotoPerfil,
          'imagen': item['imagen'] ?? '',
        });
      }
      // 🔥 SOLO ACTUALIZAR SI HAY CAMBIOS
      final hayCambios = _mensajes.length != mensajesConFotos.length ||
          (_mensajes.isNotEmpty &&
              mensajesConFotos.isNotEmpty &&
              _mensajes.last['id'] != mensajesConFotos.last['id']);

      if (hayCambios) {
        setState(() {
          _mensajes.clear();
          _mensajes.addAll(mensajesConFotos);
          _isLoading = false;
        });
        print('>>> 🔄 Mensajes actualizados (${mensajesConFotos.length})');
      } else {
        // 🔥 No hay cambios, solo actualizar `_isLoading` si es necesario
        if (_isLoading) {
          setState(() => _isLoading = false);
        }
      }

      // 🔥 SI NO HAY CAMBIOS, no hace falta consultar nada más.
      // 🔥 Esto ahorra 5 requests cada 3 segundos cuando el chat está quieto.
      if (!hayCambios && _estadoCargado && !forzar) {
        // 🔥 El análisis de la IA llega después del mensaje: seguir consultándolo
        await _analizarMensajeConIA('', user.uid, esMensajeNuevo: esMensajeNuevo);
        return;
      }

      // 🔥 El bloque "seguir-conversando desde mensajes" se eliminó.
      // 🔥 El backend ya borra los ||SEGUIR_CONVERSANDO|| cuando DeepSeek detecta cierre.

      // 🔥 SIEMPRE VERIFICAR PROPUESTA PENDIENTE
      await _verificarPropuestaPendiente();

      // 🔥 2. GUARDAR EN CACHÉ DESPUÉS DE CARGAR DEL SERVIDOR
      await _guardarMensajesEnCache(conversacionId, mensajesConFotos);
      // 🔥 CONSULTAR SI ALGUIEN QUIERE CERRAR EL TRATO
      // 🔥 REGLA NUEVA: si el OTRO confirmó, a mí me aparece el recuadro para decidir
      try {
        final idTokenCerrar = await FirebaseAuth.instance.currentUser?.getIdToken();
        final r = await http.get(
          Uri.parse('https://mimarketplace-production.up.railway.app/api/conversaciones/$_conversacionIdActual/cerrar-trato'),
          headers: {
            if (idTokenCerrar != null) 'Authorization': 'Bearer $idTokenCerrar',
          },
        );
        if (r.statusCode == 200) {
          final data = jsonDecode(r.body);
          final ambos = data['ambos_confirmaron'] == true;
          final List usuarios = data['usuarios'] ?? [];
          final yoConfirme = usuarios.contains(user.uid);
          final otroConfirme = usuarios.any((u) => u != user.uid);

          print('>>> 🟢 CERRAR TRATO (DB): ambos=$ambos, yoConfirme=$yoConfirme, otroConfirme=$otroConfirme');

          if (mounted) {
            setState(() {
              if (ambos) {
                _usuarioConfirmoCerrarTrato = yoConfirme;
                _otroUsuarioConfirmoCerrarTrato = otroConfirme;
                _mostrarBotonesCerrarTrato = false;
                _esperandoConfirmacionCerrarTrato = false;
                _cerrarTratoForzado = false;
                _chatBloqueado = true;
              } else if (yoConfirme && !otroConfirme) {
                _usuarioConfirmoCerrarTrato = true;
                _otroUsuarioConfirmoCerrarTrato = false;
                _esperandoConfirmacionCerrarTrato = true;
                _usuarioDecidioSeguirConversando = false;
                // 🔥 Si el modal está abierto manualmente, NO lo cerramos
                if (!_cerrarTratoForzado) {
                  _mostrarBotonesCerrarTrato = false;
                }
              } else {
                _usuarioConfirmoCerrarTrato = yoConfirme;
                _otroUsuarioConfirmoCerrarTrato = otroConfirme;

                if (yoConfirme || otroConfirme) {
                  _mostrarBotonesConfirmar = false;
                  _usuarioDecidioSeguirConversando = false;
                }

                if (otroConfirme && !yoConfirme && !_chatBloqueado) {
                  _mostrarBotonesCerrarTrato = true;
                  _cerrarTratoForzado = true;
                  _yoAbriCerrarTrato = false; // 🔥 lo disparó el OTRO
                }

                // 🔥 Si nadie confirmó y el modal NO fue forzado por el usuario,
                // no lo abrimos. Si ya estaba forzado, lo respetamos.
                if (!yoConfirme && !otroConfirme) {
                  _esperandoConfirmacionCerrarTrato = false;
                }
              }
            });
          }
        }
      } catch (e) {
        print('Error al consultar cerrar-trato: $e');
      }
      // 🔥 CONSULTAR SI ALGUIEN DIJO "SEGUIR CONVERSANDO"
      try {
        final idTokenSeguir = await FirebaseAuth.instance.currentUser?.getIdToken();
        final r = await http.get(
          Uri.parse('https://mimarketplace-production.up.railway.app/api/conversaciones/$_conversacionIdActual/seguir-conversando'),
          headers: {
            if (idTokenSeguir != null) 'Authorization': 'Bearer $idTokenSeguir',
          },
        );
        if (r.statusCode == 200) {
          final data = jsonDecode(r.body);
          final List usuarios = data['usuarios'] ?? [];
          final alguienDijoSeguir = usuarios.isNotEmpty;
          print('>>> 🟢 SEGUIR CONVERSANDO (DB): usuarios=$usuarios, alguienDijoSeguir=$alguienDijoSeguir');

          if (mounted && !alguienDijoSeguir && _usuarioDecidioSeguirConversando) {
            setState(() => _usuarioDecidioSeguirConversando = false);
          }

          // 🔥 Si alguien ya confirmó cerrar trato, un "seguir conversando" viejo no debe pisarlo
          if (mounted &&
              alguienDijoSeguir &&
              !_usuarioConfirmoCerrarTrato &&
              !_otroUsuarioConfirmoCerrarTrato) {
            setState(() {
              _usuarioDecidioSeguirConversando = true;
              _esperandoRespuestaOtro = false;
              _mostrarBotonesConfirmar = false;
              // 🔥 Si el usuario abrió el modal a mano desde el escudo, no lo apagamos
              if (!_cerrarTratoForzado) _mostrarBotonesCerrarTrato = false;
              _usuarioConfirmoCerrarTrato = false;
              _otroUsuarioConfirmoCerrarTrato = false;
              _esperandoConfirmacionCerrarTrato = false;
              _quiereCerrarTrato = false;
            });
          }
        }
      } catch (e) {
        print('Error al consultar seguir-conversando: $e');
      }

      // 🔥 CONSULTAR EL ANÁLISIS AL FINAL, cuando ya se actualizaron
      // 🔥 todos los estados (cerrar-trato y seguir-conversando).
      await _analizarMensajeConIA('', user.uid, esMensajeNuevo: esMensajeNuevo);

      // 🔥 AHORA SÍ: verificar los botones de confirmar.
      await _verificarBotonConfirmar(user.uid);

      // 🔥 Ya se conoce el estado real: mostrar input y guardarlo para la próxima vez
      if (mounted && !_estadoCargado) {
        setState(() => _estadoCargado = true);
      }
      _guardarEstadoBloqueo();

    } else {
      setState(() {
        _isLoading = false;
        _estadoCargado = true;
      });
    }
  } catch (e) {
    print('Error al cargar mensajes: $e');
    if (mounted) {
      setState(() {
        _isLoading = false;
        _estadoCargado = true;
      });
    }
  }
}
  bool _esSolicitudCalificacion(String texto) {
    if (!texto.contains('EL_COMPRADOR_YA_PUEDE_CALIFICARTE')) return false;
    
    // 🔥 SI YA CALIFICÓ, NO MOSTRAR
    if (_calificacionRealizada) return false;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    return user.uid != _vendedorId;
  }

  bool _esConfirmacionCalificacion(String texto) {
    return texto.startsWith('||CALIFICACION_REALIZADA||');
  }

  String _extraerCalificadorId(String texto) {
    return texto.replaceAll('||CALIFICACION_REALIZADA||', '').trim();
  }

  // 🔥 VERIFICAR SI HAY PROPUESTA PENDIENTE (solo bloquea al que propuso)
  Future<void> _verificarPropuestaPendiente() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    for (final m in _mensajes) {
      final texto = m['texto'] ?? '';
      if (_esPropuestaEncuentro(texto)) {
        final propuestaId = _extraerPropuestaId(texto);

        String estado = 'pendiente';
        String? usuarioPropuso;

        // 🔥 SI NO ESTÁ EN CACHÉ, PEDIRLA AL SERVER
        if (!_cachePropuestas.containsKey(propuestaId)) {
          try {
            final response = await http.get(
              Uri.parse(
                  'https://mimarketplace-production.up.railway.app/api/encuentro/propuesta/$propuestaId'),
            );
            if (response.statusCode == 200) {
              final data = jsonDecode(response.body) as Map<String, dynamic>;
              _cachePropuestas[propuestaId] = data;
            }
          } catch (e) {
            print('Error al obtener propuesta: $e');
          }
        }

        if (_cachePropuestas.containsKey(propuestaId)) {
          final prop = _cachePropuestas[propuestaId]!;
          estado = prop['estado'] ?? 'pendiente';
          usuarioPropuso = prop['usuario_propone_id']?.toString();
        }

        // 🔥 Solo bloquea si YO propuse Y está pendiente
        if (estado == 'pendiente') {
          if (mounted) {
            setState(() => _propuestaEncuentroPendiente = true);
          }
          return;
        }
      }
    }

    if (mounted) {
      setState(() => _propuestaEncuentroPendiente = false);
    }
    // 🔥 Persistir el caché de propuestas
    _guardarPropuestasEnCache();
  }

  // 🔥 VERIFICAR SI HAY QUE MOSTRAR BOTONES DE CONFIRMAR
  Future<void> _verificarBotonConfirmar(String miUid) async {
    bool mostrar = false;

    // 1. ¿Hay propuesta de encuentro ACEPTADA?
    for (final m in _mensajes) {
      final texto = m['texto'] ?? '';
      if (_esPropuestaEncuentro(texto)) {
        final propuestaId = _extraerPropuestaId(texto);
        if (!_cachePropuestas.containsKey(propuestaId)) {
          try {
            final r = await http.get(Uri.parse(
                'https://mimarketplace-production.up.railway.app/api/encuentro/propuesta/$propuestaId'));
            if (r.statusCode == 200) {
              _cachePropuestas[propuestaId] = jsonDecode(r.body);
            }
          } catch (_) {}
        }
        final prop = _cachePropuestas[propuestaId];
        if (prop != null && prop['estado'] == 'aceptada') {
          mostrar = true;
          break;
        }
      }
    }

    // 2. ¿La IA dice que el acuerdo está cerrado?
    if (!mostrar && _analisisIA != null) {
      // No lo sabemos desde acá, así que consultamos al server
      try {
        final r = await http.get(Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/conversaciones/$_conversacionIdActual'));
        // (si no tenés ese endpoint, dejalo así por ahora)
      } catch (_) {}
    }

    if (mounted) {
      // 🔥 REGLA NUEVA: los botones de Confirmar/Seguir aparecen si:
      // - Hay propuesta aceptada
      // - Chat NO está bloqueado
      // - Nadie dijo "seguir conversando"
      // - Nadie dijo "cerrar trato" (porque si alguien dijo cerrar, se maneja aparte)
      // - No está el recuadro de "cerrar trato" mostrándose
      final resultado = mostrar &&
                        !_chatBloqueado &&
                        !_usuarioDecidioSeguirConversando &&  // ← ESTA LÍNEA VUELVE
                        !_usuarioConfirmoCerrarTrato &&
                        !_mostrarBotonesCerrarTrato &&
                        !_esperandoConfirmacionCerrarTrato;
      print('>>> 🔥 _verificarBotonConfirmar: resultado=$resultado (mostrar=$mostrar, bloqueado=$_chatBloqueado, decidioSeguir=$_usuarioDecidioSeguirConversando, confirmoCerrar=$_usuarioConfirmoCerrarTrato, mostrarCerrar=$_mostrarBotonesCerrarTrato, esperandoConfirmacion=$_esperandoConfirmacionCerrarTrato)');
      setState(() {
        _mostrarBotonesConfirmar = resultado;
      });
    }
    // 🔥 Persistir el caché de propuestas
    _guardarPropuestasEnCache();
  }

  // 🔥 DETECTAR SI ES UN MENSAJE DE PROPUESTA DE ENCUENTRO
  bool _esPropuestaEncuentro(String texto) {
    return texto.startsWith('||ENCUENTRO_PROPUESTA||');
  }

  // 🔥 EXTRAER EL ID DE LA PROPUESTA
  String _extraerPropuestaId(String texto) {
    return texto.replaceAll('||ENCUENTRO_PROPUESTA||', '').trim();
  }

  // 🔥 DETECTAR ACEPTACIÓN DE ENCUENTRO
  bool _esEncuentroAceptado(String texto) {
    return texto.startsWith('||ENCUENTRO_ACEPTADO||');
  }

  // 🔥 DETECTAR RECHAZO DE ENCUENTRO
  bool _esEncuentroRechazado(String texto) {
    return texto.startsWith('||ENCUENTRO_RECHAZADO||');
  }

  // 🔥 DETECTAR CONTRAPROPUESTA
  bool _esEncuentroContrapropuesta(String texto) {
    return texto.startsWith('||ENCUENTRO_CONTRAPROPUESTA||');
  }

  Future<void> _enviarCalificacion(int puntuacion) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/calificaciones/from-chat'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'conversacion_id': _conversacionIdActual,
          'calificador_id': user.uid,
          'calificado_id': widget.otroUsuarioId,
          'puntuacion': puntuacion,
          'comentario': 'Calificación desde el chat',
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Calificación enviada! Gracias por tu opinión.'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _calificacionSeleccionada = 0;
        });
        // 🔥 NO recargar mensajes al calificar
        // _cargarMensajes(_conversacionIdActual);
      } else {
        throw Exception('Error al calificar');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

     Widget _buildCalificacionButton() {
    final user = FirebaseAuth.instance.currentUser;
    
    // 🔥 SI EL USUARIO ACTUAL ES EL VENDEDOR → NO MOSTRAR NADA
    if (user != null && user.uid == _vendedorId) {
      return const SizedBox.shrink();
    }

    return CalificacionWidget(
      vendedorId: _vendedorId,
      vendedorNombre: widget.otroUsuario,
      productoId: _productoId.toString(),
      nombreProducto: widget.nombreProducto,
      onCalificacionEnviada: () {
        setState(() {
          _calificacionPendiente = false;
          _calificacionRealizada = true;
        });
        // 🔥 NO recargamos mensajes para evitar disparar análisis
      },
    );
  }
  // ============ 🔥 NUEVO: CARGAR TODOS LOS PRODUCTOS DEL VENDEDOR ============
  Future<void> _cargarProductosDelVendedor() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.get(
        Uri.parse(
          'https://mimarketplace-production.up.railway.app/api/conversaciones/${user.uid}',
        ),
        headers: {
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode != 200) return;

      final List data = jsonDecode(response.body);

      final delVendedor = data.where((c) {
        final usuario1 = c['usuario1_id'] ?? '';
        final usuario2 = c['usuario2_id'] ?? '';
        final otroId = usuario1 == user.uid ? usuario2 : usuario1;
        return otroId == widget.otroUsuarioId;
      }).toList();

      final Map<String, Map<String, dynamic>> unicos = {};
      for (final c in delVendedor) {
        final productoId = c['producto_id']?.toString() ?? '';
        if (productoId.isEmpty) continue;
        if (unicos.containsKey(productoId)) continue;

        unicos[productoId] = {
          'productoId': productoId,
          'productoNombre': c['producto_nombre'] ?? 'Producto',
          'productoImagen': c['producto_imagen'] ?? '',
          'productoImagenMiniatura': c['producto_imagen_miniatura'] ?? '',
          'productoPrecio': c['producto_precio']?.toString() ?? '0',
          'productoCategoria': c['productoCategoria'] ?? '',
          'productoDescripcion': c['productoDescripcion'] ?? '',
          'productoDireccion': c['productoDireccion'] ?? '',
          'productoImagenesReales': c['producto_imagenes_reales'] ?? '',
          'conversacionId': c['id'].toString(),
        };
      }

      if (mounted) {
        setState(() {
          _productosDelVendedor = unicos.values.toList();
        });
      }

      print('>>> 🔥 Productos del vendedor: ${_productosDelVendedor.length}');
    } catch (e) {
      print('Error al cargar productos del vendedor: $e');
    }
  }

  // 🔥 CONSULTAR SI EL OTRO USUARIO ESTÁ EN LÍNEA
  Future<void> _consultarPresencia() async {
    if (widget.otroUsuarioId.isEmpty) return;
    try {
      final r = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/usuarios/${widget.otroUsuarioId}/en-linea'),
      );
      if (r.statusCode == 200 && mounted) {
        final data = jsonDecode(r.body);
        final enLinea = data['en_linea'] == true;
        if (enLinea != _otroUsuarioEnLinea) {
          setState(() => _otroUsuarioEnLinea = enLinea);
        }

        // 🔥 SI ESTÁ OFFLINE, CONSULTAR ÚLTIMA CONEXIÓN
        if (!enLinea) {
          await _consultarUltimaConexion();
        }
      }
    } catch (e) {
      print('Error al consultar presencia: $e');
    }
  }

  // 🔥 CONSULTAR ÚLTIMA CONEXIÓN DEL OTRO USUARIO
  Future<void> _consultarUltimaConexion() async {
    try {
      final r = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/usuarios/${widget.otroUsuarioId}/ultima-conexion'),
      );
      if (r.statusCode == 200 && mounted) {
        final data = jsonDecode(r.body);
        final fecha = data['ultima_conexion']?.toString();
        if (fecha != null && fecha.isNotEmpty) {
          setState(() => _ultimaConexion = fecha);
        }
      }
    } catch (e) {
      print('Error al consultar última conexión: $e');
    }
  }

  // 🔥 FORMATEAR TEXTO DE ÚLTIMA CONEXIÓN (corto: sin "hace X min")
  String _formatearUltimaConexion() {
    if (_otroUsuarioEnLinea) return 'en línea';
    if (_ultimaConexion == null) return 'última vez';

    try {
      final fecha = DateTime.parse(_ultimaConexion!).toLocal();
      final ahora = DateTime.now();
      final diferencia = ahora.difference(fecha);

      if (diferencia.inHours < 24 && ahora.day == fecha.day) {
        return 'última vez hoy';
      } else if (diferencia.inDays < 2) {
        return 'última vez ayer';
      } else {
        final dia = DateFormat('dd/MM/yyyy').format(fecha);
        return 'última vez el $dia';
      }
    } catch (e) {
      return 'última vez';
    }
  }
  // 🔥 FORMATEAR SOLO LA HORA DE ÚLTIMA CONEXIÓN
  String _formatearHoraConexion() {
    if (_ultimaConexion == null) return '';
    try {
      final fecha = DateTime.parse(_ultimaConexion!).toLocal();
      return DateFormat('h:mm a').format(fecha);
    } catch (e) {
      return '';
    }
  }
Future<void> _obtenerFotoVendedorReal() async {
  try {
    print('>>> 1. ENTRE A _obtenerFotoVendedorReal()');
    print('>>> 2. widget.productoId: ${widget.productoId}');
    
    final url = 'https://mimarketplace-production.up.railway.app/api/productos/${widget.productoId}';
    print('>>> 3. URL COMPLETA: $url');
    
    final response = await http.get(Uri.parse(url));
    print('>>> 4. STATUS CODE: ${response.statusCode}');
    print('>>> 5. RESPONSE BODY: ${response.body}');
    
    if (response.statusCode == 200) {
      print('>>> 6. STATUS 200 OK');
      final data = jsonDecode(response.body);
      print('>>> 7. PRODUCTO COMPLETO: $data');
      
      final vendedorId = data['vendedor_id'] ?? '';
      print('>>> 8. VENDEDOR ID: $vendedorId');
      
      if (vendedorId.isNotEmpty) {
        final fotoResponse = await http.get(
          Uri.parse('https://mimarketplace-production.up.railway.app/api/perfil/foto/$vendedorId'),
        );
        print('>>> 9. FOTO STATUS: ${fotoResponse.statusCode}');
        if (fotoResponse.statusCode == 200) {
          final fotoData = jsonDecode(fotoResponse.body);
          print('>>> 10. FOTO DEL VENDEDOR: ${fotoData['foto_perfil']}');
          setState(() {
            _fotoVendedorReal = fotoData['foto_perfil'] ?? '';
          });
        }
      }
    } else {
      print('>>> 6. ERROR: STATUS CODE NO ES 200');
    }
  } catch (e) {
    print('>>> ERROR EN _obtenerFotoVendedorReal: $e');
  }
}
  // 🔥 DETECTAR NÚMEROS DE TELÉFONO DE COSTA RICA
  bool _contieneNumeroTelefono(String texto) {
    // 🔥 Patrones de números de Costa Rica (6, 7, 8 como primer dígito)
    final patrones = [
      RegExp(r'\b[678]\d{3}[- ]?\d{4}\b'),   // 8888-8888, 8888 8888
      RegExp(r'\b[678]\d{7}\b'),               // 88888888
      RegExp(r'\+506[- ]?\d{4}[- ]?\d{4}'),    // +506 8888-8888
      RegExp(r'00506[- ]?\d{4}[- ]?\d{4}'),    // 00506 8888-8888
      RegExp(r'\b506[- ]?\d{4}[- ]?\d{4}\b'),  // 506 8888-8888
    ];

    return patrones.any((p) => p.hasMatch(texto));
  }

  void _enviarMensaje() async {
    if (_controller.text.trim().isEmpty) return;
    if (_conversacionIdActual.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final mensaje = _controller.text;

    // 🔥 VERIFICAR SI EL ESCUDO ESTÁ ACTIVO Y EL MENSAJE TIENE UN NÚMERO
    if (_iaActiva && _contieneNumeroTelefono(mensaje)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.shield, color: Colors.blue),
              SizedBox(width: 8),
              Text('Mensaje bloqueado'),
            ],
          ),
          content: const Text(
            'El Escudo de Seguridad bloqueó este mensaje.\n\n'
            'Motivo: No se permiten números de teléfono.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return; // 🔥 No enviar
    }

    // 🔥 Mostrar el mensaje al instante (optimista) y limpiar el campo
    final tmpId = 'tmp_${DateTime.now().millisecondsSinceEpoch}';
    _controller.clear();
    setState(() {
      _mensajes.add({
        'id': tmpId,
        'texto': mensaje,
        'usuario_id': user?.uid ?? '',
        'hora': DateFormat('HH:mm').format(DateTime.now()),
        'foto_perfil': '',
        'imagen': '',
      });
    });

    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      print('>>> 📤 Enviando mensaje. Token: ${idToken != null ? "SÍ (${idToken.length} chars)" : "NO"}');
      final response = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/mensajes'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'conversacion_id': int.parse(_conversacionIdActual),
          'usuario_id': user?.uid ?? '',
          'texto': mensaje,
        }),
      );
      print('>>> 📤 Respuesta: ${response.statusCode}');
      if (response.statusCode != 201) {
        print('>>> ❌ Error body: ${response.body}');
      }

      if (response.statusCode == 201) {
        // 🔥 Sin await: no bloquea la UI mientras se sincroniza
        _cargarMensajes(_conversacionIdActual);

        // 🔥 Reintentar el análisis a los 5s (DeepSeek tarda en analizar)
        Timer(const Duration(seconds: 5), () {
          if (mounted) {
            _analizarMensajeConIA('', user?.uid ?? '', esMensajeNuevo: true);
          }
        });
      } else if (mounted) {
        // 🔥 Falló: quitar el mensaje temporal y devolver el texto
        setState(() => _mensajes.removeWhere((m) => m['id'] == tmpId));
        _controller.text = mensaje;
      }
    } catch (e) {
      if (mounted) {
        setState(() => _mensajes.removeWhere((m) => m['id'] == tmpId));
        _controller.text = mensaje;
      }
    }
  }

  // 🔥 CONSULTAR EL ANÁLISIS GUARDADO EN EL BACKEND
  Future<void> _analizarMensajeConIA(
    String mensaje,
    String usuarioId, {
    bool esMensajeNuevo = false,
  }) async {
    if (_conversacionIdActual.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/conversaciones/$_conversacionIdActual/analisis'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('>>> 🟡 ANÁLISIS COMPLETO: $data');
        final estado = data['estado_ia'] ?? 'neutral';
        final analisis = data['analisis_ia'] ?? '';

        if (analisis.isEmpty || analisis == null) {
          // Todavía no hay análisis
          setState(() {
            _analisisIA = 'Analizando conversación...';
          });
          return;
        }

        final quiereEncuentro = data['quiere_encuentro'] == true;
        final quiereCerrarTrato = data['quiere_cerrar_trato'] == true;

        print('>>> 🟡 quiere_cerrar_trato=$quiereCerrarTrato | usuarioConfirmo=$_usuarioConfirmoCerrarTrato');

        setState(() {
          _analisisIA = analisis;
          _quiereCerrarTrato = quiereCerrarTrato;
          switch (estado) {
            case 'good':
              _conversationStatus = ConversationStatus.good;
              break;
            case 'warning':
              _conversationStatus = ConversationStatus.warning;
              break;
            case 'danger':
              _conversationStatus = ConversationStatus.danger;
              break;
            default:
              _conversationStatus = ConversationStatus.neutral;
          }

          // 🔥 SI LA IA DETECTA QUE QUIEREN CERRAR EL TRATO
          // 🔥 PERO solo si NO hay que proponer encuentro primero.
          // 🔥 Si hay que proponer encuentro, el modal de cerrar trato se activa DESPUÉS.
          if (quiereCerrarTrato &&
              !_usuarioConfirmoCerrarTrato &&
              !_usuarioDecidioSeguirConversando &&
              !_chatBloqueado &&
              !quiereEncuentro) {
            _mostrarBotonesCerrarTrato = true;
            _mostrarBotonesConfirmar = false;
            print('>>> 🟩 MODAL CERRAR TRATO activado por IA');
          } else {
            // 🔥 Solo apagamos el modal si NO está forzado por el usuario.
            // Si el usuario lo abrió manualmente desde el escudo, lo respetamos.
            if (!quiereCerrarTrato && !_cerrarTratoForzado && !_quiereCerrarTrato) {
              _mostrarBotonesCerrarTrato = false;
            }
            print('>>> ⬜ IA no activó modal cerrar trato: quiereCerrarTrato=$quiereCerrarTrato, quiereEncuentro=$quiereEncuentro, forzado=$_cerrarTratoForzado');
          }
        });

        // 🔥 SI LA IA DETECTA QUE QUIEREN UN ENCUENTRO Y EL ESCUDO ESTÁ ACTIVO
        // (FUERA del setState, porque abre un modal)
        // 🔥 SOLO ABRIR SI:
        //   - El mensaje es NUEVO (no al abrir el chat)
        //   - No está abierto ya
        //   - No había ya una propuesta pendiente/aceptada
        //   - El valor de quiere_encuentro CAMBIÓ de false a true
        if (quiereEncuentro &&
            esMensajeNuevo &&
            _iaActiva &&
            _mensajes.isNotEmpty &&
            _mensajes.last['usuario_id'] == FirebaseAuth.instance.currentUser?.uid &&
            !_interfazEncuentroMostrada &&
            !(_mensajes.last['id'] ?? '').startsWith('tmp_') &&
            _mensajes.last['id'] != _ultimoMensajeEncuentroId) {
          _ultimoMensajeEncuentroId = _mensajes.last['id'];
          // 🔥 Marcar la bandera ANTES del await para bloquear dobles disparos
          // (Timer de 5s + WebSocket que llegan casi juntos).
          _interfazEncuentroMostrada = true;
          final yaHayPropuesta = await _hayPropuestaEncuentroPendienteOAceptada();
          if (!yaHayPropuesta && mounted) {
            _mostrarInterfazEncuentro();
          } else {
            // 🔥 Si no se abrió (ya hay propuesta o el widget se desmontó),
            // liberar la bandera para permitir futuros disparos.
            _interfazEncuentroMostrada = false;
          }
        }
        // 🔥 SOLO actualizar el último valor procesado si es un mensaje NUEVO.
        // 🔥 Si es la carga inicial del chat (esMensajeNuevo: false), NO actualizar,
        // 🔥 para que un análisis viejo con quiere_encuentro=true no bloquee
        // 🔥 el formulario cuando llegue un mensaje nuevo real.
        if (esMensajeNuevo) {
          _ultimoQuiereEncuentroProcesado = quiereEncuentro;
        }

        // 🔥 Si había que proponer encuentro Y ADEMÁS cerrar trato,
        // 🔥 activar el modal de cerrar trato AHORA (después del encuentro).
        if (quiereCerrarTrato &&
            quiereEncuentro &&
            !_usuarioConfirmoCerrarTrato &&
            !_usuarioDecidioSeguirConversando &&
            !_chatBloqueado &&
            mounted) {
          setState(() {
            _mostrarBotonesCerrarTrato = true;
            _mostrarBotonesConfirmar = false; // 🔥 instantáneo: apagar botones verdes
          });
          print('>>> 🟩 MODAL CERRAR TRATO activado DESPUÉS de proponer encuentro');
        }
      }
    } catch (e) {
      print('Error al consultar análisis: $e');
    }
  }

  void _mostrarOpcionesImagen() {
    // 🔥 SOLO EL VENDEDOR PUEDE COMPARTIR SU PORTAFOLIO
    final user = FirebaseAuth.instance.currentUser;
    final esVendedor = user != null && user.uid == _vendedorId;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.black),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.camera);
              },
            ),
            // 🔥 COMPARTIR UBICACIÓN SOLO SI EL ESCUDO ESTÁ APAGADO
            if (!_iaActiva)
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.red),
                title: const Text('Compartir ubicación'),
                onTap: () {
                  Navigator.pop(context);
                  _enviarUbicacion();
                },
              ),
            // 🔥 SOLO SI SOS EL VENDEDOR
            if (esVendedor)
              ListTile(
                leading: const Icon(Icons.storefront, color: Colors.amber),
                title: const Text('Compartir portafolio'),
                onTap: () {
                  Navigator.pop(context);
                  _enviarPortafolio();
                },
              ),
          ],
        ),
      ),
    );
  }

  // 📍 ENVIAR UBICACIÓN ACTUAL AL CHAT
  Future<void> _enviarUbicacion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _conversacionIdActual.isEmpty) return;

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Activa el GPS del teléfono para compartir tu ubicación'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se necesita permiso de ubicación'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📍 Obteniendo tu ubicación...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // 🔥 5 decimales (~1 m). Así no se confunde con un número de teléfono.
      final lat = pos.latitude.toStringAsFixed(5);
      final lng = pos.longitude.toStringAsFixed(5);

      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/mensajes'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'conversacion_id': int.parse(_conversacionIdActual),
          'usuario_id': user.uid,
          'texto': '||UBICACION||$lat,$lng',
        }),
      );

      if (response.statusCode == 201) {
        await _cargarMensajes(_conversacionIdActual);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo enviar la ubicación (${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener la ubicación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 📍 ABRIR UNA URL EN LA APP EXTERNA
  Future<void> _abrirEnlaceExterno(String url) async {
    try {
      final ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir la aplicación'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al abrir enlace: $e');
    }
  }

  // 📍 MENÚ: ABRIR UBICACIÓN EN GOOGLE MAPS / WAZE / UBER
  void _mostrarOpcionesNavegacion(String lat, String lng) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Abrir ubicación con...',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.map, color: Color(0xFF34A853), size: 28),
              title: const Text('Google Maps'),
              onTap: () {
                Navigator.pop(ctx);
                _abrirEnlaceExterno(
                    'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.navigation, color: Color(0xFF33CCFF), size: 28),
              title: const Text('Waze'),
              onTap: () {
                Navigator.pop(ctx);
                _abrirEnlaceExterno(
                    'https://waze.com/ul?ll=$lat,$lng&navigate=yes');
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.local_taxi, color: Colors.black, size: 28),
              title: const Text('Uber'),
              onTap: () {
                Navigator.pop(ctx);
                _abrirEnlaceExterno(
                    'https://m.uber.com/ul/?action=setPref&dropoff[latitude]=$lat&dropoff[longitude]=$lng');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // 🔥 ENVIAR PORTAFOLIO AL CHAT
  Future<void> _enviarPortafolio() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _conversacionIdActual.isEmpty) return;

    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/mensajes'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'conversacion_id': int.parse(_conversacionIdActual),
          'usuario_id': user.uid,
          'texto': '||PORTAFOLIO||${user.uid}',
        }),
      );

      if (response.statusCode == 201) {
        await _cargarMensajes(_conversacionIdActual);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📤 Portafolio compartido'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 🔥 DETECTAR PORTAFOLIO
  bool _esPortafolio(String texto) {
    return texto.startsWith('||PORTAFOLIO||');
  }

  // 🔥 EXTRAER EL UID DEL VENDEDOR
  String _extraerPortafolioUid(String texto) {
    return texto.replaceAll('||PORTAFOLIO||', '').trim();
  }

  // 🔥 TARJETA DE PORTAFOLIO
  Widget _buildTarjetaPortafolio(String vendedorId) {
    // 🔥 SI EL QUE COMPARTIÓ SOY YO, EL NOMBRE ES MI NOMBRE.
    // 🔥 SI ES EL OTRO, ES EL NOMBRE DEL OTRO.
    final user = FirebaseAuth.instance.currentUser;
    final esMio = vendedorId == user?.uid;
    final nombreMostrar = esMio
        ? 'Tu portafolio'
        : widget.otroUsuario;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF087FE8), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF087FE8).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront,
              color: Color(0xFF087FE8),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  esMio
                      ? 'Compartiste tu portafolio'
                      : 'Portafolio de $nombreMostrar',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF087FE8),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Toca para ver los productos',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PortafolioVendedorScreen(
                    vendedorId: vendedorId,
                    vendedorNombre: esMio
                        ? (user?.displayName ?? 'Tú')
                        : widget.otroUsuario,
                    vendedorFoto: _fotoVendedorReal,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF087FE8),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Ver',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    final picker = ImagePicker();
    
    // 1️⃣ Elegir imagen
    final XFile? imagen = await picker.pickImage(source: source);
    if (imagen == null) return;

    // 2️⃣ Abrir pantalla de recorte
    final CroppedFile? imagenRecortada = await ImageCropper().cropImage(
      sourcePath: imagen.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        // 🔥 Configuración Android
        AndroidUiSettings(
          toolbarTitle: 'Recortar imagen',
          toolbarColor: Colors.blue.shade700,   // igual que tu AppBar
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,               // permitir recorte libre
          hideBottomControls: false,            // mostrar rotar, proporciones, etc.
        ),
        // 🔥 Configuración iOS
        IOSUiSettings(
          title: 'Recortar imagen',
          cancelButtonTitle: 'Cancelar',
          doneButtonTitle: 'Listo',
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    // Si el usuario cancela el recorte, no enviamos nada
    if (imagenRecortada == null) return;

    // 3️⃣ Enviar la imagen recortada
    setState(() => _enviandoImagen = true);
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://mimarketplace-production.up.railway.app/api/mensajes'),
      );

      // 🔥 Mandar el token de Firebase para autenticar la subida
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken != null) {
        request.headers['Authorization'] = 'Bearer $idToken';
      }

      request.fields['conversacion_id'] = _conversacionIdActual;
      request.fields['usuario_id'] = FirebaseAuth.instance.currentUser?.uid ?? '';
      request.fields['texto'] = '📷 Imagen';
      request.files.add(
        await http.MultipartFile.fromPath('imagen', imagenRecortada.path),
      );
      final response = await request.send();
      if (response.statusCode == 201) {
        await _cargarMensajes(_conversacionIdActual);
      } else {
        throw Exception('Error al enviar (status ${response.statusCode})');
      }
    } catch (e) {
      print('Error al enviar imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _enviandoImagen = false);
    }
  }
   Future<void> _toggleRecording() async {
  // Pedir permisos
  final status = await Permission.microphone.request();
  if (status != PermissionStatus.granted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Se necesita permiso para grabar audio')),
    );
    return;
  }

  if (_isRecording) {
    // Detener grabación
    final path = await _audioRecorder?.stopRecorder();
    setState(() {
      _isRecording = false;
      _audioPath = path;
    });
    print('>>> Audio guardado en: $path');
    
    if (path != null && path.isNotEmpty) {
      // 🔥 ENVIAR AUDIO AL BACKEND
      await _enviarAudio(path);
    }
  } else {
    // Iniciar grabación
    try {
      await _audioRecorder?.startRecorder(
        toFile: 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
        codec: Codec.aacMP4,
      );
      setState(() {
        _isRecording = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎤 Grabando... toca de nuevo para detener'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error al grabar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al grabar: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
Future<void> _enviarAudio(String audioPath) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    print('>>> Enviando audio: $audioPath');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://mimarketplace-production.up.railway.app/api/mensajes/audio'),
    );

    // 🔥 Mandar el token de Firebase para autenticar la subida
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken != null) {
      request.headers['Authorization'] = 'Bearer $idToken';
    }

    request.fields['conversacion_id'] = _conversacionIdActual;
    request.fields['usuario_id'] = user.uid;
    request.fields['texto'] = '🎤 Mensaje de voz';

    request.files.add(
      await http.MultipartFile.fromPath('audio', audioPath),
    );

    final response = await request.send();

    if (response.statusCode == 201) {
      print('>>> Audio enviado correctamente');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎤 Audio enviado'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
      // Recargar mensajes para mostrar el audio
      await _cargarMensajes(_conversacionIdActual);
    } else {
      throw Exception('Error al enviar audio');
    }
  } catch (e) {
    print('Error al enviar audio: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al enviar audio: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
// ============ 🔥 NUEVO: INICIAR GRABACIÓN CON PRESIÓN LARGA ============
Future<void> _startRecording() async {
  // Pedir permisos
  final status = await Permission.microphone.request();
  if (status != PermissionStatus.granted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Se necesita permiso para grabar audio')),
    );
    return;
  }

  // Verificar que no se esté grabando ya
  if (_isRecording) return;

  try {
    // Iniciar grabación
    await _audioRecorder?.startRecorder(
      toFile: 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
      codec: Codec.aacMP4,
    );
    
    // 🔥 SONIDO AL PRESIONAR
    _reproducirSonidoUI('sounds/start_record.wav');
    
    setState(() {
      _isRecording = true;
      _isSwipedToCancel = false;
      _micScale = 1.3;  // Agrandar el botón
      _recordingTime = '00:00';
    });

    // 🔥 MOSTRAR CÍRCULO EN EL CENTRO DEL BOTÓN
    _mostrarCirculoGrabacion();
    _oscilacionController.repeat(reverse: true);

    // 🔥 Iniciar timer para mostrar el tiempo
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final seconds = timer.tick;
      final minutes = (seconds / 60).floor();
      final remainingSeconds = seconds % 60;
      setState(() {
        _recordingTime = '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
      });
    });


  } catch (e) {
    print('Error al iniciar grabación: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al grabar: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
// ============ 🔥 NUEVO: DETENER GRABACIÓN Y ENVIAR ============
Future<void> _stopRecordingAndSend() async {
  if (!_isRecording) return;
  
  // 🔥 ELIMINAR CÍRCULO
  _ocultarCirculoGrabacion();
  
  // 🔥 RESETEAR MENSAJE DE CANCELAR
  _mostrarMensajeCancelar = false;
  
  // 🔥 SONIDO AL SOLTAR
  _reproducirSonidoUI('sounds/stop_record.wav');
  
// 🔥 Cerrar cualquier SnackBar pendiente
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  try {
    // Cerrar el SnackBar de grabación
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // Detener el timer
    _recordingTimer?.cancel();
    
    // Detener grabación
    final path = await _audioRecorder?.stopRecorder();
    
    setState(() {
      _isRecording = false;
      _micScale = 1.0;
      _recordingTime = '00:00';
    });
    
    print('>>> Audio guardado en: $path');
    
    // 🔥 Si se deslizó para cancelar, NO enviar
    if (_isSwipedToCancel) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ Grabación cancelada'),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 1),
        ),
      );
      setState(() {
        _isSwipedToCancel = false;
      });
      return;
    }
    
    // Si hay audio, enviarlo
    if (path != null && path.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📤 Enviando audio...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 1),
        ),
      );
      
      await _enviarAudio(path);
    }
  } catch (e) {
    print('Error al detener grabación: $e');
    setState(() {
      _isRecording = false;
      _micScale = 1.0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al detener grabación: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// ============ 🔥 NUEVO: CANCELAR GRABACIÓN ============
void _cancelRecording() {
  if (!_isRecording) return;
  
  // 🔥 ELIMINAR CÍRCULO
  _ocultarCirculoGrabacion();
  
  // 🔥 RESETEAR MENSAJE DE CANCELAR
  _mostrarMensajeCancelar = false;
  
  // 🔥 SONIDO AL CANCELAR
  _reproducirSonidoUI('sounds/stop_record.wav');
  
  _recordingTimer?.cancel();
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  
  setState(() {
    _isRecording = false;
    _isSwipedToCancel = false;
    _micScale = 1.0;
    _recordingTime = '00:00';
    _isDraggingOut = false;
  });
}
// ============ 🔥 NUEVO: REPRODUCIR SONIDO DE UI ============
Future<void> _reproducirSonidoUI(String assetPath) async {
  try {
    await _uiSoundPlayer.stop();
    await _uiSoundPlayer.play(AssetSource(assetPath));
  } catch (e) {
    print('Error al reproducir sonido UI: $e');
  }
}

// 🚨 REPRODUCIR SONIDO DE EMERGENCIA
Future<void> _reproducirSonidoEmergencia() async {
  try {
    await _emergencySoundPlayer.stop();
    await _emergencySoundPlayer.play(AssetSource('sounds/click.wav'));
  } catch (e) {
    debugPrint('Error al reproducir sonido de emergencia: $e');
  }
}

// ============ 🔥 NUEVO: MOSTRAR CÍRCULO EN EL BOTÓN (CON ANIMACIÓN) ============
void _mostrarCirculoGrabacion() {
  final RenderBox? buttonBox =
      _audioButtonKey.currentContext?.findRenderObject() as RenderBox?;
  if (buttonBox == null) return;

  // 🔥 Centro del botón en coordenadas globales
  final Offset buttonCenter = buttonBox.localToGlobal(
    Offset(buttonBox.size.width / 2, buttonBox.size.height / 2),
  );

  _overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      left: buttonCenter.dx - 80,
      top: buttonCenter.dy - 80,
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          // 🔥 ANIMACIÓN DE ENTRADA
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            // 🔥 Curva personalizada: primer 20% rápido, resto suave
            curve: const Cubic(0.05, 0.9, 0.1, 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.mic, color: Colors.red, size: 40),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(_overlayEntry!);
}

// ============ 🔥 NUEVO: OCULTAR CÍRCULO ============
void _ocultarCirculoGrabacion() {
  _overlayEntry?.remove();
  _overlayEntry = null;
  _oscilacionController.stop();
}


// ============ 🔥 NUEVO: REPRODUCIR AUDIO ============
Future<void> _reproducirAudio(String audioUrl, String mensajeId) async {
  try {
    // Si ya se está reproduciendo este audio, pausar
    if (_audioPlayingId == mensajeId && _isAudioPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isAudioPlaying = false;
      });
      return;
    }
    
    // Si se está reproduciendo otro audio, detenerlo primero
    if (_isAudioPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isAudioPlaying = false;
        _audioPlayingId = null;
      });
    }
    
    // Reproducir el nuevo audio
    setState(() {
      _audioPlayingId = mensajeId;
      _isAudioPlaying = true;
    });
    
    await _audioPlayer.play(UrlSource(audioUrl));
    
  } catch (e) {
    print('Error al reproducir audio: $e');
    setState(() {
      _isAudioPlaying = false;
      _audioPlayingId = null;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al reproducir audio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ============ 🔥 NUEVO: WIDGET DE AUDIO (CORREGIDO) ============
Widget _buildAudioMessage({
  required String mensajeId,
  required String audioUrl,
  required bool esMio,
}) {
  final isThisAudioPlaying = _audioPlayingId == mensajeId && _isAudioPlaying;
  
  return GestureDetector(
    onTap: () => _reproducirAudio(audioUrl, mensajeId),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: esMio ? Colors.blue.shade700 : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isThisAudioPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: esMio ? Colors.white : Colors.black,
            size: 28,
          ),
          const SizedBox(width: 8),
          
          // 🔥 Barra de progreso animada (CORREGIDA)
          Container(
            width: 80,
            height: 4,
            decoration: BoxDecoration(
              color: (esMio ? Colors.white : Colors.black).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: isThisAudioPlaying
                ? StreamBuilder<Duration>(
                    stream: _audioPlayer.onPositionChanged,
                    builder: (context, positionSnapshot) {
                      final position = positionSnapshot.data ?? Duration.zero;
                      return StreamBuilder<Duration>(
                        stream: _audioPlayer.onDurationChanged,
                        builder: (context, durationSnapshot) {
                          final duration = durationSnapshot.data ?? Duration.zero;
                          final progress = duration.inMilliseconds > 0
                              ? position.inMilliseconds / duration.inMilliseconds
                              : 0.0;
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 80 * progress.clamp(0.0, 1.0),
                              height: 4,
                              decoration: BoxDecoration(
                                color: esMio ? Colors.white : Colors.black,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : Container(
                    width: 80,
                    height: 4,
                    decoration: BoxDecoration(
                      color: (esMio ? Colors.white : Colors.black).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          
          Text(
            isThisAudioPlaying ? '▶️ Reproduciendo...' : '🎤 Mensaje de voz',
            style: TextStyle(
              color: esMio ? Colors.white : Colors.black,
              fontSize: 12,
              fontWeight: isThisAudioPlaying ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}
  // 🔥 BOTÓN PARA EXPANDIR/COLAPSAR EL HEADER DE PRODUCTOS
  Widget _buildBotonExpandirHeader() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _headerExpandido = !_headerExpandido;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE3EEFF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _headerExpandido
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: const Color(0xFF0A5BE0),
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              _headerExpandido ? 'Ocultar productos' : 'Ver productos',
              style: const TextStyle(
                color: Color(0xFF0A5BE0),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ============ 🔥 HEADER CON CARRUSEL DE PRODUCTOS ============
  Widget _buildProductoHeader({Key? key}) {
    // 🔥 Si hay varios productos, mostrar carrusel. Si no, el header clásico.
    final mostrarCarrusel = _productosDelVendedor.length > 1;

    return Container(
      key: key,
      margin: const EdgeInsets.only(top: 0, left: 12, right: 12, bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 TÍTULO SI HAY VARIOS PRODUCTOS
          if (mostrarCarrusel) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 2), // 👈 era 8
              child: Row(
                children: [
                  const Icon(Icons.shopping_bag, size: 14, color: Colors.blue), // 👈 era 16
                  const SizedBox(width: 4),
                  Text(
                    '${_productosDelVendedor.length} productos consultados',
                    style: TextStyle(
                      fontSize: 11, // 👈 era 12
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 🔥 CARRUSEL HORIZONTAL O HEADER CLÁSICO
          if (mostrarCarrusel)
            SizedBox(
              height: 82, // 👈 era 90
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _productosDelVendedor.length,
                itemBuilder: (context, i) {
                  final p = _productosDelVendedor[i];
                  final productoId = p['productoId']?.toString() ?? '';
                  final esSeleccionado = productoId == widget.productoId;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleProductoScreen(
                            producto: Producto(
                              id: int.tryParse(productoId) ?? 0,
                              nombre: p['productoNombre'] ?? 'Producto',
                              categoria: p['productoCategoria'] ?? '',
                              precio: double.tryParse(
                                      p['productoPrecio']?.toString() ?? '0') ??
                                  0,
                              imagenUrl: p['productoImagen'] ?? '',
                              descripcion: p['productoDescripcion'] ?? '',
                              direccion: p['productoDireccion'] ?? '',
                              // 🔥 SI YO SOY EL VENDEDOR, el vendedor SOY YO
                              vendedorNombre: _esMiPropioProducto
                                  ? (FirebaseAuth.instance.currentUser?.displayName ?? widget.otroUsuario)
                                  : widget.otroUsuario,
                              vendedorId: _esMiPropioProducto
                                  ? (FirebaseAuth.instance.currentUser?.uid ?? widget.otroUsuarioId)
                                  : widget.otroUsuarioId,
                              vendedorFoto: _esMiPropioProducto
                                  ? _fotoVendedorReal
                                  : widget.fotoPerfil,
                              provincia: '',
                              imagenDestacada: '',
                              imagenesReales: p['productoImagenesReales'] ?? '',
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: esSeleccionado
                            ? Colors.blue.shade50
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: esSeleccionado
                              ? Colors.blue.shade400
                              : Colors.grey.shade300,
                          width: esSeleccionado ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: (p['productoImagenMiniatura'] ?? '')
                                    .toString()
                                    .isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl:
                                        'https://mimarketplace-production.up.railway.app${p['productoImagenMiniatura']}',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    placeholder: (_, _) => Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image,
                                          size: 20, color: Colors.grey),
                                    ),
                                    errorWidget: (_, _, _) => Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.broken_image,
                                          size: 20, color: Colors.grey),
                                    ),
                                  )
                                : (p['productoImagen'] ?? '')
                                        .toString()
                                        .isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl:
                                            'https://mimarketplace-production.up.railway.app${p['productoImagen']}',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        placeholder: (_, _) => Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.image,
                                              size: 20, color: Colors.grey),
                                        ),
                                        errorWidget: (_, _, _) => Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.broken_image,
                                              size: 20, color: Colors.grey),
                                        ),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.image,
                                            size: 20, color: Colors.grey),
                                      ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p['productoNombre'] ?? 'Producto',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: esSeleccionado
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: esSeleccionado
                                  ? Colors.blue.shade700
                                  : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          else
            // 🔥 HEADER CLÁSICO (cuando solo hay 1 producto)
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    image: widget.productoImagen.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(
                                'https://mimarketplace-production.up.railway.app${widget.productoImagen}'),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: widget.productoImagen.isEmpty
                      ? const Icon(Icons.image, color: Colors.grey, size: 24)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.nombreProducto,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₡${widget.productoPrecio}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleProductoScreen(
                          producto: Producto(
                            id: int.tryParse(widget.productoId) ?? 0,
                            nombre: widget.nombreProducto,
                            categoria: widget.productoCategoria,
                            precio: double.tryParse(widget.productoPrecio) ?? 0,
                            imagenUrl: widget.productoImagen,
                            descripcion: widget.productoDescripcion,
                            direccion: widget.productoDireccion,
                            // 🔥 SI YO SOY EL VENDEDOR, el vendedor SOY YO
                            vendedorNombre: _esMiPropioProducto
                                ? (FirebaseAuth.instance.currentUser?.displayName ?? widget.otroUsuario)
                                : widget.otroUsuario,
                            vendedorId: _esMiPropioProducto
                                ? (FirebaseAuth.instance.currentUser?.uid ?? widget.otroUsuarioId)
                                : widget.otroUsuarioId,
                            vendedorFoto: _esMiPropioProducto
                                ? _fotoVendedorReal
                                : widget.fotoPerfil,
                            provincia: '',
                            imagenDestacada: widget.productoImagenDestacada,
                            imagenesReales: widget.productoImagenesReales,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Ver producto',
                      style: TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

    // ============ 🔥 FUNCIONES PARA OPCIONES DEL VENDEDOR ============

  Future<bool> _verificarBloqueo(String vendedorId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/bloquear/verificar/${user.uid}/$vendedorId'),
        headers: {
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['bloqueado'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error al verificar bloqueo: $e');
      return false;
    }
  }

  Future<void> _bloquearVendedor(String vendedorId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final response = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/bloquear'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_bloquea': user.uid,
          'usuario_bloqueado': vendedorId,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vendedor bloqueado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error['error'] ?? 'Error al bloquear'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al bloquear: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _desbloquearVendedor(String vendedorId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final response = await http.delete(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/bloquear'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_bloquea': user.uid,
          'usuario_bloqueado': vendedorId,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vendedor desbloqueado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error['error'] ?? 'Error al desbloquear'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al desbloquear: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarDialogoDenuncia() {
    String motivoSeleccionado = 'Producto sospechoso';
    final List<String> motivos = [
      'Producto sospechoso',
      'Publicación de productos prohibidos',
      'Estafa o fraude',
      'Acoso o maltrato',
      'Información falsa o engañosa',
      'Otro motivo',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('⚠️ Denunciar vendedor'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona el motivo de la denuncia:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...motivos.map((motivo) => RadioListTile<String>(
                    title: Text(motivo),
                    value: motivo,
                    groupValue: motivoSeleccionado,
                    onChanged: (value) {
                      setState(() {
                        motivoSeleccionado = value!;
                      });
                    },
                    activeColor: Colors.red,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  )),
                  const SizedBox(height: 8),
                  const Text(
                    'Esta denuncia será revisada por nuestro equipo de moderación.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _enviarDenuncia(motivoSeleccionado);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Denunciar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _enviarDenuncia(String motivo) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para denunciar'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/denuncias'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'denunciante_id': user.uid,
          'denunciado_id': widget.otroUsuarioId,
          'producto_id': widget.productoId,
          'motivo': motivo,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Denuncia enviada. Será revisada por moderación.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Error al enviar denuncia');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar denuncia: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarOpcionesVendedor(BuildContext context) {
    final vendedorId = widget.otroUsuarioId;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: FutureBuilder<bool>(
            future: _verificarBloqueo(vendedorId),
            builder: (context, snapshot) {
              final bool estaBloqueado = snapshot.data ?? false;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Opciones del Vendedor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Icon(
                      estaBloqueado ? Icons.check_circle : Icons.block,
                      color: estaBloqueado ? Colors.green : Colors.red,
                      size: 28,
                    ),
                    title: Text(
                      estaBloqueado ? 'Desbloquear' : 'Bloquear',
                      style: const TextStyle(fontSize: 16),
                    ),
                    subtitle: Text(
                      estaBloqueado 
                          ? 'Desbloquear a ${widget.otroUsuario}'
                          : 'Bloquear a ${widget.otroUsuario}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      if (estaBloqueado) {
                        await _desbloquearVendedor(vendedorId);
                      } else {
                        await _bloquearVendedor(vendedorId);
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.person_outline,
                      color: Colors.green,
                      size: 28,
                    ),
                    title: const Text(
                      'Ver información de perfil',
                      style: TextStyle(fontSize: 16),
                    ),
                    subtitle: Text(
                      'Ver detalles de ${widget.otroUsuario}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PerfilVendedorScreen(
                            vendedorId: widget.otroUsuarioId,
                            vendedorNombre: widget.otroUsuario,
                            vendedorFoto: widget.fotoPerfil,
                          ),
                        ),
                      );
                    },
                  ),
                 const Divider(height: 1),
ListTile(
  leading: const Icon(
    Icons.storefront,
    color: Colors.blue,
    size: 28,
  ),
  title: const Text(
    'Ver Portafolio',
    style: TextStyle(fontSize: 16),
  ),
  subtitle: Text(
    'Ver todos los productos de ${widget.otroUsuario}',
    style: const TextStyle(fontSize: 12, color: Colors.grey),
  ),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PortafolioVendedorScreen(
          vendedorId: widget.otroUsuarioId,
          vendedorNombre: widget.otroUsuario,
          vendedorFoto: _fotoVendedorReal,
        ),
      ),
    );
  },
),
const Divider(height: 1),
ListTile(
  leading: const Icon(
    Icons.flag,
    color: Colors.red,
    size: 28,
  ),
  title: const Text(
    'Denunciar vendedor',
    style: TextStyle(fontSize: 16),
  ),
  subtitle: Text(
    'Reportar a ${widget.otroUsuario} por incumplir las reglas',
    style: const TextStyle(fontSize: 12, color: Colors.grey),
  ),
  onTap: () {
    Navigator.pop(context);
    _mostrarDialogoDenuncia();
  },
),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        );
      },
    );
  }
    void _mostrarMenuMensaje(BuildContext context, String mensajeId, String mensajeTexto) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // 🔥 OPCIÓN 1: TACHAR MENSAJE
              ListTile(
                leading: const Icon(
                  Icons.format_strikethrough,
                  color: Colors.orange,
                ),
                title: const Text(
                  'Tachar mensaje',
                  style: TextStyle(fontSize: 16),
                ),
                subtitle: const Text(
                  'Tachar este mensaje para indicar que está resuelto',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    final id = int.tryParse(mensajeId);
                    if (id != null) {
                      if (_mensajesTachados.contains(id)) {
                        _mensajesTachados.remove(id);
                      } else {
                        _mensajesTachados.add(id);
                      }
                    }
                    _mensajeSeleccionadoId = null; // 🔥 Limpiar borde
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _mensajesTachados.contains(int.tryParse(mensajeId))
                            ? '✅ Mensaje tachado'
                            : '❌ Tachado eliminado',
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              // 🔥 OPCIÓN 2: BUSCAR EN INTERNET
              ListTile(
                leading: const Icon(
                  Icons.search,
                  color: Colors.blue,
                ),
                title: const Text(
                  'Buscar en internet',
                  style: TextStyle(fontSize: 16),
                ),
                subtitle: const Text(
                  'Buscar este mensaje en Google',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _mensajeSeleccionadoId = null; // 🔥 Limpiar borde
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔍 Función "Buscar en internet" en desarrollo'),
                      backgroundColor: Colors.blue,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              // 🔥 OPCIÓN 3: SELECCIONAR TEXTO
              ListTile(
                leading: const Icon(
                  Icons.select_all,
                  color: Colors.purple,
                ),
                title: const Text(
                  'Seleccionar texto',
                  style: TextStyle(fontSize: 16),
                ),
                subtitle: const Text(
                  'Seleccionar parte del mensaje para copiar',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _mensajeSeleccionadoId = null; // 🔥 Limpiar borde
                  });
                  _seleccionarTextoMensaje(mensajeTexto);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _seleccionarTextoMensaje(String texto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('📝 Seleccionar texto'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selecciona el texto que quieres copiar:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(
                    texto,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // 🔥 PANEL DE ANÁLISIS DEL CHAT (reemplaza al modal)
  Widget _buildPanelAnalisis({Key? key}) {
    String analisisTexto = _analisisIA ?? 'No hay análisis disponible aún.';

    final Map<ConversationStatus, Map<String, String>> infoEstados = {
      ConversationStatus.neutral: {
        'titulo': '⚪ Estado Neutral',
        'color': '#9E9E9E',
        'descripcion':
            'La conversación está en curso. Aún no hay suficiente información para determinar el estado de la transacción.',
        'recomendacion': 'Continúa conversando de forma respetuosa y clara.',
        'icono': 'info',
      },
      ConversationStatus.good: {
        'titulo': '✅ Conversación Saludable',
        'color': '#4CAF50',
        'descripcion':
            'La conversación fluye de manera positiva. Ambos usuarios se están comunicando de forma respetuosa y clara.',
        'recomendacion':
            '¡Sigue así! La transacción tiene buenas probabilidades de éxito.',
        'icono': 'check',
      },
      ConversationStatus.warning: {
        'titulo': '⚠️ Precaución Recomendada',
        'color': '#FF9800',
        'descripcion':
            'Se han detectado algunos signos de alerta en la conversación. Podría haber malentendidos o tensión.',
        'recomendacion':
            'Revisa los mensajes anteriores. Intenta ser más claro y empático en tus respuestas.',
        'icono': 'warning',
      },
      ConversationStatus.danger: {
        'titulo': '🚨 Peligro Inminente',
        'color': '#F44336',
        'descripcion':
            'La conversación muestra signos de conflicto o riesgo. Podría haber mala comunicación o desacuerdos serios.',
        'recomendacion':
            'Detente y evalúa la situación. Considera contactar a soporte si es necesario.',
        'icono': 'danger',
      },
    };

    final info = infoEstados[_conversationStatus]!;
    final colorEstado = Color(
      int.parse(info['color']!.replaceFirst('#', '0xFF')),
    );

    IconData iconoEstado;
    switch (info['icono']) {
      case 'check':
        iconoEstado = Icons.check_circle;
        break;
      case 'warning':
        iconoEstado = Icons.warning_amber_rounded;
        break;
      case 'danger':
        iconoEstado = Icons.gpp_bad;
        break;
      default:
        iconoEstado = Icons.info;
    }

    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorEstado.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorEstado.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorEstado.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconoEstado, color: colorEstado, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  info['titulo']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorEstado,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _panelAnalisisAbierto = false;
                  });
                },
                tooltip: 'Cerrar',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.blue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🔍 $analisisTexto',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            info['descripcion']!,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorEstado.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: colorEstado, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '💡 ${info['recomendacion']!}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 NUEVO MÉTODO PARA ENVIAR CALIFICACIÓN CON COMENTARIO
  Future<void> _enviarCalificacionConComentario(int puntuacion, String comentario) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('❌ No hay usuario autenticado');
      return;
    }

    print('>>> 1. Enviando calificación:');
    print('>>> calificado_id: ${widget.otroUsuarioId}');
    print('>>> calificador_id: ${user.uid}');
    print('>>> producto_id: ${widget.productoId}');
    print('>>> puntuacion: $puntuacion');
    print('>>> comentario: $comentario');

    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/calificaciones'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'calificado_id': widget.otroUsuarioId,
          'calificador_id': user.uid,
          'producto_id': widget.productoId,
          'puntuacion': puntuacion,
          'comentario': comentario.isEmpty ? 'Calificación desde el chat' : comentario,
        }),
      );

      print('>>> 2. STATUS CODE: ${response.statusCode}');
      print('>>> 3. RESPONSE BODY: ${response.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Calificación enviada! Gracias por tu opinión.'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _calificacionSeleccionada = 0;
          _calificacionRealizada = true;
          _calificacionPendiente = false;
        });
        // 🔥 NO recargar mensajes al calificar para evitar disparar análisis
        // _cargarMensajes(_conversacionIdActual);
      } else {
        throw Exception('Error al calificar: ${response.body}');
      }
    } catch (e) {
      print('>>> 4. EXCEPCIÓN: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🔥 INTERFAZ DE AGENDAMIENTO DE ENCUENTRO (CON MÚLTIPLES PROPUESTAS)
  void _mostrarInterfazEncuentro() {
    // 🔥 LISTA TEMPORAL DE PROPUESTAS (máximo 3)
    List<Map<String, dynamic>> propuestasTemporales = [];
    String paso = 'formulario'; // 'formulario' | 'resumen'

    List<String> provincias = [];
    List<String> cantones = [];
    List<String> distritos = [];
    List<dynamic> lugaresSeguros = [];
    String? provinciaSeleccionada;
    String? cantonSeleccionado;
    String? distritoSeleccionado;
    DateTime? fechaSeleccionada;
    int? lugarSeleccionadoId;
    String? lugarSeleccionadoNombre;
    bool cargando = true;
    bool provinciasYaCargadas = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> cargarProvincias() async {
            try {
              final r = await http.get(Uri.parse(
                'https://mimarketplace-production.up.railway.app/api/lugares-seguros/provincias',
              ));
              if (r.statusCode == 200) {
                final List data = jsonDecode(r.body);
                setModalState(() {
                  provincias = data.map((e) => e.toString()).toList();
                  cargando = false;
                });
              } else {
                setModalState(() => cargando = false);
              }
            } catch (e) {
              setModalState(() => cargando = false);
            }
          }

          Future<void> cargarCantones(String prov) async {
            setModalState(() {
              cantones = [];
              distritos = [];
              lugaresSeguros = [];
              cantonSeleccionado = null;
              distritoSeleccionado = null;
              lugarSeleccionadoId = null;
            });
            try {
              final r = await http.get(Uri.parse(
                'https://mimarketplace-production.up.railway.app/api/lugares-seguros/cantones?provincia=${Uri.encodeComponent(prov)}',
              ));
              if (r.statusCode == 200) {
                final List data = jsonDecode(r.body);
                setModalState(() {
                  cantones = data.map((e) => e.toString()).toList();
                });
              }
            } catch (e) {}
          }

          Future<void> cargarDistritos(String prov, String cant) async {
            setModalState(() {
              distritos = [];
              lugaresSeguros = [];
              distritoSeleccionado = null;
              lugarSeleccionadoId = null;
            });
            try {
              final r = await http.get(Uri.parse(
                'https://mimarketplace-production.up.railway.app/api/lugares-seguros/distritos?provincia=${Uri.encodeComponent(prov)}&canton=${Uri.encodeComponent(cant)}',
              ));
              if (r.statusCode == 200) {
                final List data = jsonDecode(r.body);
                setModalState(() {
                  distritos = data.map((e) => e.toString()).toList();
                });
              }
            } catch (e) {}
          }

          Future<void> cargarLugares(String prov, String cant, String dist) async {
            setModalState(() {
              lugaresSeguros = [];
              lugarSeleccionadoId = null;
            });
            try {
              final url = dist.isEmpty
                  ? 'https://mimarketplace-production.up.railway.app/api/lugares-seguros'
                    '?provincia=${Uri.encodeComponent(prov)}'
                    '&canton=${Uri.encodeComponent(cant)}'
                  : 'https://mimarketplace-production.up.railway.app/api/lugares-seguros'
                    '?provincia=${Uri.encodeComponent(prov)}'
                    '&canton=${Uri.encodeComponent(cant)}'
                    '&distrito=${Uri.encodeComponent(dist)}';
              final r = await http.get(Uri.parse(url));
              if (r.statusCode == 200) {
                final List data = jsonDecode(r.body);
                setModalState(() {
                  lugaresSeguros = data;
                });
              }
            } catch (e) {}
          }

          if (!provinciasYaCargadas) {
            provinciasYaCargadas = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              cargarProvincias();
            });
          }

          // 🔥 RESET del formulario (para cuando agrega otra propuesta)
          void resetFormulario() {
            provinciaSeleccionada = null;
            cantonSeleccionado = null;
            distritoSeleccionado = null;
            fechaSeleccionada = null;
            lugarSeleccionadoId = null;
            lugarSeleccionadoNombre = null;
            cantones = [];
            distritos = [];
            lugaresSeguros = [];
          }

          return Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: cargando
                  ? const Center(child: CircularProgressIndicator())
                  : paso == 'resumen'
                      ? _buildResumenPropuestas(
                          propuestasTemporales: propuestasTemporales,
                          onEliminar: (index) {
                            setModalState(() {
                              propuestasTemporales.removeAt(index);
                              if (propuestasTemporales.isEmpty) {
                                paso = 'formulario';
                              }
                            });
                          },
                          onAgregarOtra: () {
                            setModalState(() {
                              resetFormulario();
                              paso = 'formulario';
                            });
                          },
                          onEnviar: () async {
                            // 🔥 ENVIAR TODAS LAS PROPUESTAS (POST POR CADA UNA)
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            );

                            try {
                              final user = FirebaseAuth.instance.currentUser;
                              int enviadas = 0;

                              final idTokenProp = await FirebaseAuth.instance.currentUser?.getIdToken();
                              for (final prop in propuestasTemporales) {
                                final response = await http.post(
                                  Uri.parse('https://mimarketplace-production.up.railway.app/api/encuentro/proponer'),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    if (idTokenProp != null) 'Authorization': 'Bearer $idTokenProp',
                                  },
                                  body: jsonEncode({
                                    'conversacion_id': int.parse(_conversacionIdActual),
                                    'usuario_propone_id': user?.uid ?? '',
                                    'usuario_recibe_id': widget.otroUsuarioId,
                                    'lugar_id': prop['lugar_id'],
                                    'fecha_encuentro': prop['fecha_encuentro'],
                                  }),
                                );

                                if (response.statusCode == 201) {
                                  enviadas++;
                                }
                              }

                              if (mounted) Navigator.pop(context); // cerrar loading
                              if (mounted) Navigator.pop(context); // cerrar modal

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('✅ $enviadas propuesta${enviadas == 1 ? '' : 's'} enviada${enviadas == 1 ? '' : 's'}'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }

                              await _cargarMensajes(_conversacionIdActual);
                            } catch (e) {
                              if (mounted) Navigator.pop(context);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        )
                      : SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.event, color: Colors.blue, size: 28),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Proponer encuentro',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                propuestasTemporales.isEmpty
                                    ? 'Elegí un lugar seguro de la lista.'
                                    : 'Propuesta ${propuestasTemporales.length + 1} de 3',
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                              const SizedBox(height: 20),

                              // PROVINCIA
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Provincia',
                                  border: OutlineInputBorder(),
                                ),
                                initialValue: provinciaSeleccionada,
                                items: provincias.map((p) {
                                  return DropdownMenuItem(value: p, child: Text(p));
                                }).toList(),
                                onChanged: (value) {
                                  setModalState(() => provinciaSeleccionada = value);
                                  if (value != null) cargarCantones(value);
                                },
                              ),
                              const SizedBox(height: 12),

                              // CANTÓN
                              if (provinciaSeleccionada != null)
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Cantón',
                                    border: OutlineInputBorder(),
                                  ),
                                  initialValue: cantonSeleccionado,
                                  items: cantones.map((c) {
                                    return DropdownMenuItem(value: c, child: Text(c));
                                  }).toList(),
                                  onChanged: (value) {
                                    setModalState(() {
                                      cantonSeleccionado = value;
                                      distritoSeleccionado = null;
                                      lugaresSeguros = [];
                                      lugarSeleccionadoId = null;
                                    });
                                    if (value != null) {
                                      cargarDistritos(provinciaSeleccionada!, value)
                                          .then((_) {
                                        if (distritos.isEmpty) {
                                          cargarLugares(provinciaSeleccionada!, value, '');
                                        }
                                      });
                                    }
                                  },
                                ),
                              if (provinciaSeleccionada != null) const SizedBox(height: 12),

                              // DISTRITO
                              if (cantonSeleccionado != null && distritos.isNotEmpty) ...[
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Distrito',
                                    border: OutlineInputBorder(),
                                  ),
                                  initialValue: distritoSeleccionado,
                                  items: distritos.map((d) {
                                    return DropdownMenuItem(value: d, child: Text(d));
                                  }).toList(),
                                  onChanged: (value) {
                                    setModalState(() => distritoSeleccionado = value);
                                    if (value != null) {
                                      cargarLugares(
                                        provinciaSeleccionada!,
                                        cantonSeleccionado!,
                                        value,
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),
                              ],

                              // LISTA DE LUGARES
                              if (lugaresSeguros.isNotEmpty) ...[
                                const Text(
                                  'Lugares seguros:',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ...lugaresSeguros.map<Widget>((lugar) {
                                  final seleccionado = lugarSeleccionadoId == lugar['id'];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: seleccionado ? Colors.blue.shade50 : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: seleccionado ? Colors.blue : Colors.grey.shade300,
                                        width: seleccionado ? 2 : 1,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.place,
                                          color: seleccionado ? Colors.blue : Colors.grey,
                                        ),
                                        title: Text(
                                          lugar['nombre'] ?? '',
                                          style: TextStyle(
                                            fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${lugar['canton'] ?? ''}, ${lugar['provincia'] ?? ''}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        onTap: () {
                                          setModalState(() {
                                            lugarSeleccionadoId = lugar['id'];
                                            lugarSeleccionadoNombre = lugar['nombre'];
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 12),
                              ],

                              // FECHA Y HORA
                              InkWell(
                                onTap: () async {
                                  final fecha = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().add(const Duration(days: 1)),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 90)),
                                  );
                                  if (fecha == null) return;

                                  // 🔥 SELECTOR CUSTOM: solo horas de 7:00 a 18:00 cada 30 min
                                  final horaElegida = await showModalBottomSheet<TimeOfDay>(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                    ),
                                    builder: (ctx) {
                                      // 🔥 Generar las opciones: 7:00, 7:30, ..., 18:00
                                      final opciones = <TimeOfDay>[];
                                      for (int h = 7; h <= 18; h++) {
                                        opciones.add(TimeOfDay(hour: h, minute: 0));
                                        if (h < 18) {
                                          opciones.add(TimeOfDay(hour: h, minute: 30));
                                        }
                                      }
                                      // Índice inicial: 10:00 AM (posición 6 dentro de la lista)
                                      int indiceInicial = opciones.indexWhere(
                                        (o) => o.hour == 10 && o.minute == 0,
                                      );
                                      if (indiceInicial < 0) indiceInicial = 0;
                                      int indiceActual = indiceInicial;

                                      return StatefulBuilder(
                                        builder: (ctx, setSheetState) {
                                          return SafeArea(
                                            top: false,
                                            bottom: true,
                                            child: Container(
                                            height: 360,
                                            padding: EdgeInsets.only(
                                              top: 12,
                                              bottom: MediaQuery.of(ctx).viewPadding.bottom + 8,
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade300,
                                                    borderRadius: BorderRadius.circular(2),
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                const Text(
                                                  'Elegí una hora (7:00 AM – 6:00 PM)',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Expanded(
                                                  child: CupertinoPicker(
                                                    scrollController: FixedExtentScrollController(
                                                      initialItem: indiceInicial,
                                                    ),
                                                    itemExtent: 44,
                                                    onSelectedItemChanged: (index) {
                                                      indiceActual = index;
                                                    },
                                                    children: opciones.map((o) {
                                                      final hora12 = o.hourOfPeriod == 0 ? 12 : o.hourOfPeriod;
                                                      final ampm = o.period == DayPeriod.am ? 'AM' : 'PM';
                                                      return Center(
                                                        child: Text(
                                                          '${hora12.toString().padLeft(2, '0')}:${o.minute.toString().padLeft(2, '0')} $ampm',
                                                          style: const TextStyle(fontSize: 20),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(16),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: OutlinedButton(
                                                          onPressed: () => Navigator.pop(ctx),
                                                          child: const Text('Cancelar'),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.pop(ctx, opciones[indiceActual]);
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.blue,
                                                            foregroundColor: Colors.white,
                                                          ),
                                                          child: const Text('Aceptar'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );

                                  if (horaElegida == null) return;

                                  setModalState(() {
                                    fechaSeleccionada = DateTime(
                                      fecha.year, fecha.month, fecha.day,
                                      horaElegida.hour, horaElegida.minute,
                                    );
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, color: Colors.blue),
                                      const SizedBox(width: 12),
                                      Text(
                                        fechaSeleccionada == null
                                            ? 'Seleccionar fecha y hora'
                                            : DateFormat('dd/MM/yyyy HH:mm').format(fechaSeleccionada!),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // BOTÓN AGREGAR
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (lugarSeleccionadoId == null || fechaSeleccionada == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('⚠️ Elegí un lugar y una fecha'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }

                                    setModalState(() {
                                      propuestasTemporales.add({
                                        'lugar_id': lugarSeleccionadoId,
                                        'lugar_nombre': lugarSeleccionadoNombre ?? '',
                                        'distrito': distritoSeleccionado ?? '',
                                        'canton': cantonSeleccionado ?? '',
                                        'provincia': provinciaSeleccionada ?? '',
                                        'fecha_encuentro': fechaSeleccionada!.toIso8601String(),
                                      });
                                      paso = 'resumen';
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: Text(
                                    propuestasTemporales.isEmpty
                                        ? 'Agregar propuesta'
                                        : 'Agregar y ver resumen',
                                  ),
                                ),
                              ),

                              // 🔥 BOTÓN "VER RESUMEN" SI YA HAY PROPUESTAS
                              if (propuestasTemporales.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    onPressed: () {
                                      setModalState(() => paso = 'resumen');
                                    },
                                    child: Text(
                                      'Ver resumen (${propuestasTemporales.length})',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      // 🔥 Cuando se cierra el formulario (cancelar o enviar),
      // permitir que la IA lo vuelva a abrir si detecta otro encuentro.
      _interfazEncuentroMostrada = false;
    });
  }

  // 🔥 RESUMEN DE PROPUESTAS (pantalla de confirmación)
  Widget _buildResumenPropuestas({
    required List<Map<String, dynamic>> propuestasTemporales,
    required void Function(int) onEliminar,
    required VoidCallback onAgregarOtra,
    required Future<void> Function() onEnviar,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.checklist, color: Colors.blue, size: 28),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Resumen de propuestas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${propuestasTemporales.length} de 3 propuestas agregadas',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 20),

        // 🔥 LISTA DE PROPUESTAS
        Expanded(
          child: ListView.builder(
            itemCount: propuestasTemporales.length,
            itemBuilder: (context, index) {
              final prop = propuestasTemporales[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prop['lugar_nombre'] ?? 'Lugar',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${prop['distrito'] ?? ''}, ${prop['canton'] ?? ''}, ${prop['provincia'] ?? ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatearFechaPropuesta(prop['fecha_encuentro']),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => onEliminar(index),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // 🔥 BOTÓN AGREGAR OTRA (deshabilitado si ya hay 3)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: propuestasTemporales.length >= 3 ? null : onAgregarOtra,
            icon: const Icon(Icons.add),
            label: Text(
              propuestasTemporales.length >= 3
                  ? 'Máximo 3 propuestas'
                  : 'Agregar otra propuesta',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // 🔥 BOTÓN ENVIAR
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onEnviar,
            icon: const Icon(Icons.send),
            label: Text(
              'Enviar ${propuestasTemporales.length} propuesta${propuestasTemporales.length == 1 ? '' : 's'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  // 🔥 TARJETA DE PROPUESTA DIRECTA (SIN FUTUREBUILDER)
  Widget _buildTarjetaPropuestaDirecta(Map<String, dynamic> propuesta) {
    final estado = propuesta['estado'] ?? 'pendiente';
    final user = FirebaseAuth.instance.currentUser;
    final yoPropuse = propuesta['usuario_propone_id'] == user?.uid;



    final tarjeta = GestureDetector(
      onTap: () => _mostrarDetallePropuesta(propuesta),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // 🔥 IMAGEN DE FONDO
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/escudo/plantilla_encuentro.png'),
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
              Colors.white.withValues(alpha: 0.0), // 👈 0.0 = normal, 0.5 = muy claro
              BlendMode.lighten,
            ),
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        // 🔥 ALTURA reducida
        constraints: const BoxConstraints(minHeight: 140),
        // 🔥 POSICIÓN del texto ajustada
        padding: const EdgeInsets.fromLTRB(55, 45, 20, 15),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 🔥 CONTENIDO (LUGAR + FECHA)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12), // 👈 BAJA "universidad..."
                  child: Text(
                    '${propuesta['lugar_nombre'] ?? ''}, ${propuesta['provincia'] ?? ''}',
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 18),
                Transform.translate(
                  offset: const Offset(0, -16), // 👈 SUBE más la fecha
                  child: Text(
                    _formatearFechaPropuesta(propuesta['fecha_encuentro']),
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ),
              ],
            ),
            // 🔥 ESTADO EN ESQUINA SUPERIOR DERECHA
            Positioned(
              top: -25, // 👈 BAJA más la etiqueta
              right: 10,
              child: Text(
                estado == 'rechazada'
                    ? 'ANULADA'
                    : (estado == 'aceptada' || estado == 'confirmada')
                        ? 'ACEPTADA'
                        : 'PENDIENTE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: estado == 'rechazada'
                      ? Colors.red
                      : (estado == 'aceptada' || estado == 'confirmada')
                          ? Colors.green
                          : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // 🔥 Solo las pendientes llevan el borde animado
    if (estado != 'pendiente') return tarjeta;
    return BordePunteadoAnimado(controller: _bordeController, child: tarjeta);
  }
  // 🔥 TARJETA DE PROPUESTA: mismo diseño (imagen del asset) desde el primer frame
  Widget _buildTarjetaPropuesta(String propuestaId) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _obtenerPropuesta(propuestaId),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return _buildTarjetaPropuestaDirecta(snapshot.data!);
        }

        // 🔥 Cargando: misma plantilla, sin datos todavía (sin saltos de diseño)
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/escudo/plantilla_encuentro.png'),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          constraints: const BoxConstraints(minHeight: 180),
        );
      },
    );
  }
  // 🔥 (DISEÑO VIEJO, YA NO SE USA)
  Widget _buildTarjetaPropuestaVieja(String propuestaId) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _obtenerPropuesta(propuestaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final propuesta = snapshot.data!;
        final estado = propuesta['estado'] ?? 'pendiente';
        final user = FirebaseAuth.instance.currentUser;

        // 🔥 SI YO PROPUSE, ESPERO RESPUESTA DEL OTRO
        final yoPropuse = propuesta['usuario_propone_id'] == user?.uid;

        return GestureDetector(
          onTap: () => _mostrarDetallePropuesta(propuesta),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: estado == 'confirmada'
                    ? Colors.green
                    : estado == 'rechazada'
                        ? Colors.grey.shade400
                        : Colors.blue,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      color: estado == 'confirmada'
                          ? Colors.green
                          : estado == 'rechazada'
                              ? Colors.red
                              : Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Propuesta de encuentro',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: estado == 'confirmada'
                              ? Colors.green
                              : estado == 'rechazada'
                                  ? Colors.red
                                  : Colors.blue,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: estado == 'confirmada'
                            ? Colors.green.shade50
                            : estado == 'rechazada'
                                ? Colors.grey.shade200
                                : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        estado == 'rechazada'
                            ? 'ANULADA'
                            : estado.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: estado == 'confirmada'
                              ? Colors.green
                              : estado == 'rechazada'
                                  ? Colors.grey.shade700
                                  : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${propuesta['lugar_nombre'] ?? ''}\n'
                        '${propuesta['distrito'] ?? ''}, ${propuesta['canton'] ?? ''}, ${propuesta['provincia'] ?? ''}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      _formatearFechaPropuesta(propuesta['fecha_encuentro']),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  estado == 'rechazada'
                      ? '🚫 Esta propuesta fue anulada'
                      : estado == 'confirmada'
                          ? '✅ Esta propuesta fue aceptada'
                          : yoPropuse
                              ? 'Esperando respuesta...'
                              : 'Toca para ver detalles y responder',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔥 FORMATEAR FECHA DE PROPUESTA
  String _formatearFechaPropuesta(String? fecha) {
    if (fecha == null) return '';
    try {
      final date = DateTime.parse(fecha);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return fecha;
    }
  }

  // 🔥 OBTENER PROPUESTA DEL BACKEND (con caché, sin async en la devolución)
  Future<Map<String, dynamic>?> _obtenerPropuesta(String propuestaId) {
    // 🔥 SI YA ESTÁ EN CACHÉ, DEVOLVER UN FUTURE YA RESUELTO
    if (_cachePropuestas.containsKey(propuestaId)) {
      return Future.value(_cachePropuestas[propuestaId]);
    }

    // 🔥 SI NO, PEDIR AL SERVER
    return http.get(
      Uri.parse(
          'https://mimarketplace-production.up.railway.app/api/encuentro/propuesta/$propuestaId'),
    ).then<Map<String, dynamic>?>((response) {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _cachePropuestas[propuestaId] = data;
        return data;
      }
      return null;
    }).catchError((e) {
      print('Error al obtener propuesta: $e');
      return null;
    });
  }

  // 🔥 MOSTRAR DETALLE DE LA PROPUESTA
  void _mostrarDetallePropuesta(Map<String, dynamic> propuesta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.event, color: Colors.blue, size: 28),
                    const SizedBox(width: 8),
                    const Text(
                      'Detalle del encuentro',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 🔥 LUGAR
                _buildInfoRow(Icons.location_on, 'Lugar',
                    propuesta['lugar_nombre'] ?? ''),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.map, 'Distrito',
                    '${propuesta['distrito'] ?? ''}, ${propuesta['canton'] ?? ''}, ${propuesta['provincia'] ?? ''}'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.access_time, 'Fecha y hora',
                    _formatearFechaPropuesta(propuesta['fecha_encuentro'])),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.info, 'Estado', propuesta['estado'] ?? ''),
                const SizedBox(height: 20),

                // 🔥 BOTONES DE ACCIÓN
                if (propuesta['estado'] == 'pendiente' &&
                    propuesta['usuario_recibe_id'] ==
                        FirebaseAuth.instance.currentUser?.uid) ...[
                  const Text(
                    '¿Aceptas esta propuesta?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _responderPropuesta(
                              propuesta['id'].toString(), 'rechazar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Rechazar'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _responderPropuesta(
                              propuesta['id'].toString(), 'aceptar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Aceptar'),
                        ),
                      ),
                    ],
                  ),
                ] else if (propuesta['estado'] == 'pendiente') ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.hourglass_top, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Esperando respuesta del otro usuario...',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 FILA DE INFO
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🔥 CONFIRMAR ENCUENTRO (BLOQUEA EL CHAT)
  Future<void> _confirmarEncuentro() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Confirmar encuentro?'),
        content: const Text(
          'Una vez confirmado, no podrán escribir por chat hasta que se vean en persona.\n\n'
          '• No llegues tarde\n'
          '• Se pedirá reconocimiento facial\n'
          '• Se activará el GPS el día del encuentro',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final r = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/encuentro/confirmar'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'conversacion_id': _conversacionIdActual,
          'usuario_confirma_id': user.uid,
        }),
      );

      if (r.statusCode == 200) {
        if (mounted) {
          setState(() {
            _chatBloqueado = true;
            _mostrarBotonesConfirmar = false;
            _usuarioConfirmoCerrarTrato = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Encuentro confirmado'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Error ${r.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 🔥 RESPONDER PROPUESTA (ACEPTAR O RECHAZAR)
  Future<void> _responderPropuesta(String propuestaId, String accion) async {
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.put(
        Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/encuentro/propuesta/$propuestaId/$accion'),
        headers: {
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context); // Cerrar modal
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  accion == 'aceptar'
                      ? '✅ Propuesta aceptada'
                      : '❌ Propuesta rechazada'),
              backgroundColor:
                  accion == 'aceptar' ? Colors.green : Colors.red,
            ),
          );

          // 🔥 LIMPIAR CACHÉ DE ESA PROPUESTA PARA FORZAR REFRESCO
          _cachePropuestas.remove(propuestaId);
          await _guardarPropuestasEnCache();

          await _cargarMensajes(_conversacionIdActual);
          _verificarPropuestaPendiente();
        }
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🔥 SI EL USUARIO ACTUAL ES EL VENDEDOR DE ESTE CHAT
  bool get _esMiPropioProducto {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    return user.uid == _vendedorId;
  }

  // 🔥 TÍTULO DEL MODAL DE CERRAR TRATO
  // - Si YO abrí el modal desde el escudo, o lo disparó la IA → texto genérico
  // - Si el modal lo disparó la confirmación del OTRO        → "{Nombre del otro} desea saber..."
  String get _tituloModalCerrarTrato {
    if (_cerrarTratoForzado && !_yoAbriCerrarTrato) {
      return '${widget.otroUsuario} desea saber si ya todo está listo para el encuentro';
    }
    return '¿Ya está todo listo para el encuentro?';
  }

  // 🔥 SUBTÍTULO DEL MODAL
  // - Si el texto es el del otro → explicación de bloqueo
  // - Si es el genérico          → explicación de acuerdo
  String get _subtituloModalCerrarTrato {
    if (_cerrarTratoForzado && !_yoAbriCerrarTrato) {
      return 'Si ambos confirman, el chat se bloquea hasta que se vean en persona.';
    }
    return 'La conversación parece haber llegado a un acuerdo.';
  }

  // 🔥 SI YA HAY UNA PROPUESTA DE ENCUENTRO ACEPTADA O CONFIRMADA
  // 🔥 (sirve para ocultar "Proponer encuentro" en el menú del escudo)
  bool get _hayPropuestaAceptadaEnCache {
    for (final prop in _cachePropuestas.values) {
      final estado = prop['estado'] ?? 'pendiente';
      if (estado == 'aceptada' || estado == 'confirmada') {
        return true;
      }
    }
    return false;
  }

  // 🔥 DIÁLOGO: CANCELAR TRATO (con regla de 1 hora mínima)
  Future<void> _mostrarDialogoCancelarTrato() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Consultar el encuentro agendado para saber la fecha
    Map<String, dynamic>? encuentro;
    try {
      final r = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/encuentro/agendado/$_conversacionIdActual'),
      );
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        encuentro = data['encuentro'];
      }
    } catch (e) {
      debugPrint('Error al consultar encuentro: $e');
    }

    if (encuentro == null || encuentro['id'] == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró el encuentro agendado'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Verificar cuánto falta
    final fechaStr = encuentro['fecha_encuentro']?.toString();
    DateTime? fecha;
    if (fechaStr != null) {
      fecha = DateTime.tryParse(fechaStr)?.toLocal();
    }
    final minutosRestantes = fecha != null
        ? fecha.difference(DateTime.now()).inMinutes
        : null;
    final puedeCancelar = minutosRestantes == null || minutosRestantes >= 60;

    if (!mounted) return;

    final confirmar = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            // 🔥 Gradiente azul profundo (igual familia que el modal de cerrar trato)
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A3D91),
                Color(0xFF0A5BE0),
                Color(0xFF1E9BF0),
                Color(0xFF0A5BE0),
              ],
              stops: [0.0, 0.35, 0.7, 1.0],
            ),
            // 🔥 Borde negro fino (armoniza con el otro modal)
            border: Border.all(color: Colors.black, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: const Color(0xFF1E9BF0).withValues(alpha: 0.25),
                blurRadius: 40,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.14),
                  Colors.white.withValues(alpha: 0.04),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔥 ÍCONO CON HALO PULSANTE (azul si puede cancelar, rojo si no)
                _buildIconoHaloCancelar(puedeCancelar: puedeCancelar),

                const SizedBox(height: 14),

                // 🔥 TÍTULO CON DEGRADADO
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Color(0xFFBFDBFE),
                      Color(0xFF7CC4FF),
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    '¿Cancelar el trato?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: Colors.white,
                      height: 1.25,
                      shadows: [
                        Shadow(
                          color: Color(0x660A3D91),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 6),

                // 🔥 SUBTÍTULO
                const Text(
                  'Esta acción anula el encuentro para ambos.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 18),

                // 🔥 CHIP DE FECHA (estilo "cristal")
                if (fecha != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.12),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFF7CC4FF).withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF7CC4FF).withValues(alpha: 0.2),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Color(0xFFBFDBFE),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ENCUENTRO',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFBFDBFE),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('dd/MM/yyyy · h:mm a').format(fecha),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 🔥 CAJA DE REGLA (siempre visible)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1E9BF0).withValues(alpha: 0.18),
                        const Color(0xFF0A5BE0).withValues(alpha: 0.12),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF7CC4FF).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF7CC4FF).withValues(alpha: 0.25),
                            ),
                            child: const Icon(
                              Icons.shield_outlined,
                              size: 14,
                              color: Color(0xFFBFDBFE),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Regla de cancelación',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Solo podés cancelar el trato hasta 1 hora antes del encuentro. '
                        'Si falta menos de 1 hora, ya no se permite cancelar y deben '
                        'presentarse en el lugar acordado.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 🔥 CAJA DE ADVERTENCIA / AVISO (según puedeCancelar)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: puedeCancelar
                        ? Colors.orange.withValues(alpha: 0.18)
                        : Colors.red.withValues(alpha: 0.20),
                    border: Border(
                      left: BorderSide(
                        color: puedeCancelar ? Colors.orange : Colors.red,
                        width: 3,
                      ),
                      top: BorderSide(
                        color: (puedeCancelar ? Colors.orange : Colors.red)
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                      right: BorderSide(
                        color: (puedeCancelar ? Colors.orange : Colors.red)
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                      bottom: BorderSide(
                        color: (puedeCancelar ? Colors.orange : Colors.red)
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        puedeCancelar
                            ? Icons.warning_amber_rounded
                            : Icons.lock_clock,
                        color: puedeCancelar ? Colors.orange : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          puedeCancelar
                              ? 'Al cancelar, el encuentro se anula para los dos y el chat vuelve a abrirse. '
                                'El otro usuario recibirá una notificación.'
                              : 'Ya no podés cancelar este encuentro porque falta menos de 1 hora. '
                                'Deben presentarse en el lugar acordado.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: puedeCancelar
                                ? const Color(0xFFFFE0B2)
                                : const Color(0xFFFFCDD2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔥 BOTONES estilo app (radio 26, altura 48)
                Row(
                  children: [
                    // VOLVER (outlined tipo cristal)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(ctx, false),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: Color(0xFFBFDBFE),
                        ),
                        label: const Text(
                          'Volver',
                          style: TextStyle(
                            color: Color(0xFFBFDBFE),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          side: BorderSide(
                            color: const Color(0xFF7CC4FF).withValues(alpha: 0.55),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                      ),
                    ),
                    if (puedeCancelar) ...[
                      const SizedBox(width: 10),
                      // SÍ, CANCELAR (rojo con glow)
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFF6B6B),
                                Color(0xFFE53935),
                                Color(0xFFB71C1C),
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.6),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE53935).withValues(alpha: 0.55),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                              BoxShadow(
                                color: const Color(0xFFB71C1C).withValues(alpha: 0.4),
                                blurRadius: 24,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(26),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(26),
                              onTap: () => Navigator.pop(ctx, true),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event_busy,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Sí, cancelar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        shadows: [
                                          Shadow(
                                            color: Color(0x66000000),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmar != true) return;

    // Llamar al backend
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final r = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/encuentro/cancelar/${encuentro['id']}'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );

      if (r.statusCode == 200) {
        if (mounted) {
          setState(() {
            _chatBloqueado = false;
            _escudoOtroRechazo = false;
            _usuarioConfirmoCerrarTrato = false;
            _otroUsuarioConfirmoCerrarTrato = false;
            _esperandoConfirmacionCerrarTrato = false;
            _mostrarBotonesCerrarTrato = false;
            _quiereCerrarTrato = false;
          });
          _guardarEstadoBloqueo();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Encuentro cancelado. El chat volvió a abrirse.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        await _cargarMensajes(_conversacionIdActual);
      } else {
        final err = jsonDecode(r.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err['error'] ?? 'No se pudo cancelar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🔥 Devuelve true SOLO si hay una propuesta de encuentro ACEPTADA.
  // 🔥 Si solo hay pendiente o rechazada, devuelve false.
  Future<bool> _hayPropuestaEncuentro() async {
    try {
      final r = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/encuentro/conversacion/$_conversacionIdActual'),
      );
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        final encuentro = data['encuentro'];
        if (encuentro == null) return false;
        final estado = encuentro['estado'] ?? '';
        return estado == 'aceptada' || estado == 'confirmada';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 🔥 Devuelve true si hay CUALQUIER propuesta de encuentro en el chat
  // 🔥 (pendiente, aceptada o confirmada). Sirve para NO abrir el formulario
  // 🔥 de proponer encuentro cuando ya hay una propuesta esperando respuesta.
  Future<bool> _hayPropuestaEncuentroPendienteOAceptada() async {
    try {
      final r = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/encuentro/conversacion/$_conversacionIdActual'),
      );
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        final encuentro = data['encuentro'];
        if (encuentro == null) return false;
        final estado = encuentro['estado'] ?? '';
        return estado == 'pendiente' ||
               estado == 'aceptada' ||
               estado == 'confirmada';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 🔥 ÍCONO CON HALO AZUL ANIMADO (pulso lento, NO gira)
  Widget _buildIconoHaloAzul() {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _bordeController,
            builder: (context, _) {
              final t = _bordeController.value;
              final pulso = (math.sin(t * 2 * math.pi) + 1) / 2;
              return Container(
                width: 78 + pulso * 8,
                height: 78 + pulso * 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF3B9BFF).withValues(alpha: 0.55 + pulso * 0.15),
                      const Color(0xFF0A5BE0).withValues(alpha: 0.25),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B9BFF).withValues(alpha: 0.45 + pulso * 0.2),
                      blurRadius: 20 + pulso * 8,
                      spreadRadius: 2 + pulso * 2,
                    ),
                  ],
                ),
              );
            },
          ),
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(
                color: const Color(0xFFBFDBFE).withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
          ),
          ClipOval(
            child: Container(
              width: 56,
              height: 56,
              color: Colors.white.withValues(alpha: 0.95),
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                'assets/icon/icon.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.handshake,
                  color: Color(0xFF0A5BE0),
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 ÍCONO CON HALO PULSANTE PARA EL DIÁLOGO DE CANCELAR TRATO
  // 🔥 Azul si se puede cancelar, rojo si ya no se permite.
  Widget _buildIconoHaloCancelar({required bool puedeCancelar}) {
    final colorBase = puedeCancelar ? const Color(0xFF3B9BFF) : const Color(0xFFE53935);
    final colorClaro = puedeCancelar ? const Color(0xFF7CC4FF) : const Color(0xFFFF8A80);

    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo pulsante
          AnimatedBuilder(
            animation: _bordeController,
            builder: (context, _) {
              final t = _bordeController.value;
              final pulso = (math.sin(t * 2 * math.pi) + 1) / 2;
              return Container(
                width: 100 + pulso * 10,
                height: 100 + pulso * 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorBase.withValues(alpha: 0.55 + pulso * 0.15),
                      colorBase.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorBase.withValues(alpha: 0.5 + pulso * 0.2),
                      blurRadius: 22 + pulso * 10,
                      spreadRadius: 3 + pulso * 2,
                    ),
                  ],
                ),
              );
            },
          ),
          // Anillo interior
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.10),
              border: Border.all(
                color: colorClaro.withValues(alpha: 0.65),
                width: 2,
              ),
            ),
          ),
          // Ícono central
          Icon(
            puedeCancelar ? Icons.event_busy : Icons.lock_clock,
            color: colorClaro,
            size: 46,
            shadows: [
              Shadow(
                color: colorBase.withValues(alpha: 0.8),
                blurRadius: 12,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🚨 Botón de llamada a emergencias con efecto neón intermitente
  Widget _buildBotonEmergencias() {
    return GestureDetector(
      onTap: () {
        // 🚨 Sonido de emergencia
        _reproducirSonidoEmergencia();

        // 🔥 Rebote (1.0 → 1.25 → 0.92 → 1.0)
        _emergencyReboteController.forward(from: 0);
      },
      child: ScaleTransition(
        scale: _emergencyReboteAnim,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _bordeController,
              builder: (context, _) {
                final t = _bordeController.value;
                final pulso = (math.sin(t * 2 * math.pi) + 1) / 2;

                return Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.lerp(Colors.red.shade400, Colors.red.shade900, pulso)!,
                        Color.lerp(Colors.red.shade700, Colors.red.shade900, pulso)!,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.4 + pulso * 0.6),
                        blurRadius: 12 + pulso * 20,
                        spreadRadius: 2 + pulso * 6,
                      ),
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.2 + pulso * 0.4),
                        blurRadius: 24 + pulso * 30,
                        spreadRadius: 4 + pulso * 8,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.85 + pulso * 0.15),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.emergency,
                      color: Colors.white.withValues(alpha: 0.9 + pulso * 0.1),
                      size: 28,
                      shadows: [
                        Shadow(
                          color: Colors.red.withValues(alpha: 0.5 + pulso * 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 2),
            AnimatedBuilder(
              animation: _bordeController,
              builder: (context, _) {
                final t = _bordeController.value;
                final pulso = (math.sin(t * 2 * math.pi) + 1) / 2;
                return Text(
                  'EMERGENCIA',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    color: Colors.white.withValues(alpha: 0.6 + pulso * 0.4),
                    shadows: [
                      Shadow(
                        color: Colors.red.withValues(alpha: 0.3 + pulso * 0.5),
                        blurRadius: 4 + pulso * 4,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🔘 Botón circular estilo "cristal" del app bar
  Widget _botonCircularApp({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFCFE6FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
  // 🔥 PANTALLA QUE SE MUESTRA CUANDO EL CHAT ESTÁ BLOQUEADO (TRATO CERRADO)
  Widget _buildPantallaTratoCerrado() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔥 LOGO DE LA APP
          Image.asset(
            'assets/icon/icon.png',
            width: 72,
            height: 72,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.handshake,
              size: 72,
              color: Color(0xFF0A5BE0),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '🤝 Trato cerrado',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A3D91),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'El chat quedó bloqueado. Nos vemos en el encuentro.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // 🔥 PASOS DEL PROCESO
          _buildPasoTratoCerrado(
            icono: Icons.notifications_active,
            titulo: '1. Revisá tus alertas',
            descripcion:
                'Entrá a la sección de Alertas para ver la fecha, hora y lugar del encuentro confirmado.',
          ),
          const SizedBox(height: 14),
          _buildPasoTratoCerrado(
            icono: Icons.face,
            titulo: '2. Reconocimiento facial',
            descripcion:
                'El día del encuentro, la app te va a pedir una selfie para verificar tu identidad antes de salir.',
          ),
          const SizedBox(height: 14),
          _buildPasoTratoCerrado(
            icono: Icons.location_on,
            titulo: '3. Activá el GPS',
            descripcion:
                'Al llegar al lugar, activá la ubicación. La app confirma que estás en el punto seguro.',
          ),
          const SizedBox(height: 14),
          _buildPasoTratoCerrado(
            icono: Icons.lock_open,
            titulo: '4. Se desbloquea el chat',
            descripcion:
                'Cuando ambos estén presentes y verificados, el chat vuelve a abrirse.',
          ),
          const SizedBox(height: 32),

          // 🔥 AVISO IMPORTANTE
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Llegá 10 minutos antes. Si no llegás, el encuentro se marca como "no presentado" y el chat queda cerrado.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 🔥 BOTÓN PARA IR A VERIFICAR IDENTIDAD Y UBICACIÓN
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  final r = await http.get(
                    Uri.parse('https://mimarketplace-production.up.railway.app/api/encuentro/agendado/$_conversacionIdActual'),
                  );
                  if (r.statusCode == 200) {
                    final data = jsonDecode(r.body);
                    final encuentro = data['encuentro'];
                    if (encuentro != null && encuentro['id'] != null && mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PantallaVerificacionEncuentro(
                            encuentroId: int.parse(encuentro['id'].toString()),
                          ),
                        ),
                      );
                      return;
                    }
                  }
                } catch (e) {
                  debugPrint('Error al abrir verificación: $e');
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No se encontró el encuentro agendado'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.verified_user, size: 22),
              label: const Text(
                'Verificar identidad y ubicación',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A5BE0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasoTratoCerrado({
    required IconData icono,
    required String titulo,
    required String descripcion,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3EEFF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0A5BE0).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: const Color(0xFF0A5BE0), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0A3D91),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final top = MediaQuery.viewPaddingOf(context).top;
    final fotoUrl = widget.fotoPerfil.isNotEmpty ? widget.fotoPerfil : _fotoVendedorReal;

    return PreferredSize(
      preferredSize: Size.fromHeight(top + 124),
      child: ClipPath(
        clipper: _OlaAppBarClipper(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A5BE0), Color(0xFF1E9BF0), Color(0xFF0A5BE0)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, top + 8, 12, 26),
            child: SizedBox(
              height: 78, // 🔥 altura fija de la fila: todos se centran en el mismo eje
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ⬅️ Atrás
                _botonCircularApp(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back,
                      color: Color(0xFF0A5BE0), size: 24),
                ),
                const SizedBox(width: 10),

                // 👤 Avatar con borde y punto verde
                GestureDetector(
                  onTap: () => _mostrarOpcionesVendedor(context),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Colors.white, Color(0xFF7CC4FF)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: fotoUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl:
                                      'https://mimarketplace-production.up.railway.app$fotoUrl',
                                  fit: BoxFit.cover,
                                  placeholder: (_, _) => const Icon(Icons.person,
                                      color: Colors.grey),
                                  errorWidget: (_, _, _) => const Icon(
                                      Icons.person,
                                      color: Colors.grey),
                                )
                              : Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.person,
                                      color: Colors.grey),
                                ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _otroUsuarioEnLinea
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF9CA3AF),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: _otroUsuarioEnLinea
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF22C55E).withValues(alpha: 0.6),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // 📝 Nombre + producto con check
                Expanded(
                  child: GestureDetector(
                    onTap: () => _mostrarOpcionesVendedor(context),
                    child: SizedBox(
                      height: 72, // 🔥 altura fija: no cambia entre "en línea" y "última vez"
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.otroUsuario,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(color: Colors.black26, blurRadius: 4)
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.nombreProducto,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  // 🔥 Cuando aparece el botón de emergencia,
                                  // achicamos un poco la fuente del producto
                                  // para que no se corte tanto
                                  fontSize: _chatDesbloqueadoPorVerificacion ? 12 : 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified,
                                color: Color(0xFF9AD0FF), size: 18),
                          ],
                        ),
                        // 🔥 ÚLTIMA CONEXIÓN / EN LÍNEA (siempre 1 línea, no cambia la altura)
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _otroUsuarioEnLinea
                                    ? 'en línea'
                                    : (_ultimaConexion == null
                                        ? ''
                                        : _formatearUltimaConexion()),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _otroUsuarioEnLinea
                                      ? const Color(0xFF4ADE80)
                                      : Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            if (!_otroUsuarioEnLinea && _ultimaConexion != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                _formatearHoraConexion(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ), // cierra Column
                    ), // cierra SizedBox (altura fija del texto)
                  ),   // cierra GestureDetector
                ),     // cierra Expanded

                // 🚨 Si ya pasó la verificación → botón de emergencias
                // 🛡️ Si no → escudo normal
                if (_chatDesbloqueadoPorVerificacion)
                  Transform.translate(
                    offset: const Offset(0, 7), // 🔥 baja solo 4px
                    child: _buildBotonEmergencias(),
                  )
                else
                  EscudoSeguridadWidget(
                    estado: _conversationStatus,
                    isActive: _iaActiva,
                    videoVistoInicial: _iaActiva,
                    emojiDesdeEstado: _conversationStatus,
                    hayPropuestaAceptada: _hayPropuestaAceptadaEnCache,
                    tratoCerrado: _chatBloqueado,
                    onCancelarTrato: _mostrarDialogoCancelarTrato,
                    onCerrarTrato: () {
                      setState(() {
                        _mostrarBotonesCerrarTrato = true;
                        _cerrarTratoForzado = true;
                        _yoAbriCerrarTrato = true;   // 🔥 YO lo abrí
                        _usuarioDecidioSeguirConversando = false;
                        _mostrarBotonesConfirmar = false;
                      });
                    },
                    onProponerEncuentro: () {
                      _mostrarInterfazEncuentro();
                    },
                    onToggle: () {
                      if (_iaActiva) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                '🛡️ El Escudo ya está activo y no se puede desactivar'),
                            backgroundColor: Colors.blue,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      setState(() => _iaActiva = true);
                      _guardarEstadoEscudo(true);
                    },
                    onAdCompleted: () {
                      setState(() {
                        _analisisIA = '🛡️ Escudo activado. Analizando mensajes...';
                        _iaActiva = true;
                        _panelAnalisisAbierto = false;
                      });
                      _guardarEstadoEscudo(true);
                    },
                    onInfoTap: () {
                      if (!_iaActiva) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                '🛡️ Activa el Escudo para ver el análisis de la conversación'),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      setState(() => _panelAnalisisAbierto = !_panelAnalisisAbierto);
                    },
                  ),
              ],
            ),   // cierra Row
            ),   // cierra SizedBox(height: 70)
          ),     // cierra Padding
        ),       // cierra Container
      ),         // cierra ClipPath
    );           // cierra PreferredSize
  }

  @override
  Widget build(BuildContext context) {

  final user = FirebaseAuth.instance.currentUser;

  print('>>> BUILD: loading=$_isLoading, msgs=${_mensajes.length}, bloqueado=$_chatBloqueado');

    return Scaffold(
 appBar: _buildAppBar(context),
      body: Column(
        children: [
          // 🔥 LÍNEA DIVISORIA ARRIBA DEL HEADER DEL PRODUCTO
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),

          // 🔥 BOTÓN DE EXPANDIR HEADER (siempre visible)
          _buildBotonExpandirHeader(),

          // 🔥 PANEL DE ANÁLISIS O HEADER DE PRODUCTOS
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _panelAnalisisAbierto
                ? _buildPanelAnalisis(key: const ValueKey('panel'))
                : _headerExpandido
                    ? _buildProductoHeader(key: const ValueKey('header'))
                    : const SizedBox.shrink(key: ValueKey('vacio')),
          ),
          // 🔥 BOTONES DE CERRAR TRATO (ARRIBA DEL LISTVIEW)
          // 🔥 Solo se muestra si NO confirmé. Si ya confirmé, se muestra el cartel azul abajo.
          if (_mostrarBotonesCerrarTrato && !_usuarioConfirmoCerrarTrato)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A3D91),
                    Color(0xFF0A5BE0),
                    Color(0xFF1E9BF0),
                    Color(0xFF0A5BE0),
                  ],
                  stops: [0.0, 0.35, 0.7, 1.0],
                ),
                border: Border.all(
                  color: Colors.black,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E9BF0).withValues(alpha: 0.45),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: const Color(0xFF0A5BE0).withValues(alpha: 0.35),
                    blurRadius: 50,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // 🔥 ÍCONO CON HALO AZUL ANIMADO
                    _buildIconoHaloAzul(),
                    const SizedBox(height: 12),
                    // 🔥 TÍTULO CON DEGRADADO AZUL CLARO (VARÍA SEGÚN ORIGEN)
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Color(0xFFBFDBFE),
                          Color(0xFF7CC4FF),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        _tituloModalCerrarTrato,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              color: Color(0x660A3D91),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // 🔥 SUBTÍTULO (VARÍA SEGÚN ORIGEN)
                    Text(
                      _subtituloModalCerrarTrato,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // 🔥 BOTÓN CONFIRMAR CON DEGRADADO AZUL TIPO INPUT
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final hayPropuesta = await _hayPropuestaEncuentro();
                              if (!hayPropuesta) {
                                setState(() {
                                  _mostrarBotonesCerrarTrato = false;
                                });

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '📍 Primero proponé un lugar y una fecha para el encuentro.\n'
                                        'Cuando el otro acepte, vas a poder cerrar el trato.',
                                      ),
                                      backgroundColor: Colors.blue,
                                      duration: Duration(seconds: 4),
                                    ),
                                  );
                                }

                                _mostrarInterfazEncuentro();
                                return;
                              }

                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) return;

                              try {
                                final idTokenCerrar2 = await FirebaseAuth.instance.currentUser?.getIdToken();
                                final r = await http.post(
                                  Uri.parse('https://mimarketplace-production.up.railway.app/api/conversaciones/$_conversacionIdActual/cerrar-trato'),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    if (idTokenCerrar2 != null) 'Authorization': 'Bearer $idTokenCerrar2',
                                  },
                                  body: jsonEncode({'usuario_id': user.uid}),
                                );

                                if (r.statusCode == 200) {
                                  final data = jsonDecode(r.body);
                                  final ambos = data['ambos_confirmaron'] == true;

                                  setState(() {
                                    _usuarioConfirmoCerrarTrato = true;
                                    _mostrarBotonesCerrarTrato = false;
                                    _cerrarTratoForzado = false;
                                    _yoAbriCerrarTrato = false; // 🔥 limpiar
                                    _usuarioDecidioSeguirConversando = false;
                                    if (ambos) {
                                      _esperandoConfirmacionCerrarTrato = false;
                                    } else {
                                      _esperandoConfirmacionCerrarTrato = true;
                                    }
                                  });

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(ambos
                                            ? '✅ Trato cerrado. Esperando el encuentro.'
                                            : '⏳ Esperando que el otro usuario confirme...'),
                                        backgroundColor: ambos ? Colors.green : Colors.blue,
                                      ),
                                    );
                                  }

                                  await _cargarMensajes(_conversacionIdActual);
                                }
                              } catch (e) {
                                print('Error al cerrar trato: $e');
                              }
                            },
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(26),
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Color(0xFF3B9BFF), Color(0xFF0A5BE0)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0A5BE0).withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle, size: 18, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      'Confirmar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 🔥 BOTÓN "TENGO MÁS PREGUNTAS" CON EL MISMO ESTILO QUE "CONFIRMAR"
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              setState(() {
                                _mostrarBotonesCerrarTrato = false;
                                _cerrarTratoForzado = false;
                                _yoAbriCerrarTrato = false; // 🔥 limpiar
                                _quiereCerrarTrato = false;
                              });

                              try {
                                final idTokenCancelar = await FirebaseAuth.instance.currentUser?.getIdToken();
                                await http.post(
                                  Uri.parse('https://mimarketplace-production.up.railway.app/api/conversaciones/$_conversacionIdActual/cancelar-cierre-trato'),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    if (idTokenCancelar != null) 'Authorization': 'Bearer $idTokenCancelar',
                                  },
                                );

                                final idTokenReset = await FirebaseAuth.instance.currentUser?.getIdToken();
                                await http.post(
                                  Uri.parse('https://mimarketplace-production.up.railway.app/api/conversaciones/$_conversacionIdActual/reset-seguir-conversando'),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    if (idTokenReset != null) 'Authorization': 'Bearer $idTokenReset',
                                  },
                                );

                                // 🔥 Avisar al otro usuario que quieres seguir conversando
                                // (se envía DESPUÉS del reset, porque el reset borra estos mensajes)
                                final uidSeguir = FirebaseAuth.instance.currentUser?.uid;
                                if (uidSeguir != null) {
                                  final idTokenMsg = await FirebaseAuth.instance.currentUser?.getIdToken();
                                  await http.post(
                                    Uri.parse('https://mimarketplace-production.up.railway.app/api/mensajes'),
                                    headers: {
                                      'Content-Type': 'application/json',
                                      if (idTokenMsg != null) 'Authorization': 'Bearer $idTokenMsg',
                                    },
                                    body: jsonEncode({
                                      'conversacion_id': int.parse(_conversacionIdActual),
                                      'usuario_id': uidSeguir,
                                      'texto': '||SEGUIR_CONVERSANDO||$uidSeguir',
                                    }),
                                  );
                                }

                                // 🔥 Guardar el estado ya sin el recuadro, para que no reaparezca desde la caché
                                _guardarEstadoBloqueo();

                                await _cargarMensajes(_conversacionIdActual);
                              } catch (e) {
                                print('Error al cancelar cierre de trato: $e');
                              }
                            },
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(26),
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Color(0xFF3B9BFF), Color(0xFF0A5BE0)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0A5BE0).withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.help_outline, size: 15, color: Colors.white),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Tengo más preguntas',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _mensajes.isEmpty
                    ? (_chatBloqueado
                        ? _buildPantallaTratoCerrado()
                        : const Center(
                            child: Text(
                              'No hay mensajes aún',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ))
                    : RepaintBoundary(
                        child: ListView.builder(
                        reverse: true,
                        padding: EdgeInsets.only(
                          bottom: (_propuestaEncuentroPendiente || _chatBloqueado)
                              ? MediaQuery.of(context).size.height * 0.25
                              : 30,
                          top: 120,
                        ),
                        itemCount: _mensajes.length,
              itemBuilder: (context, index) {
  final mensaje = _mensajes[_mensajes.length - 1 - index];
  final esMio = mensaje['usuario_id'] == user?.uid;
  final fotoPerfil = mensaje['foto_perfil'] ?? '';

  // 🔥 VERIFICAR SI ES AUDIO (archivo .m4a)
  final bool esAudio = mensaje['imagen'] != null && 
      mensaje['imagen']!.isNotEmpty && 
      mensaje['imagen']!.endsWith('.m4a');

 

  // 🔥 ARTÍCULO VENDIDO
  if ((mensaje['texto'] ?? '').startsWith('||ARTICULO_VENDIDO||')) {
    final nombreProducto = (mensaje['texto'] ?? '')
        .replaceAll('||ARTICULO_VENDIDO||', '')
        .trim();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.sell, color: Colors.red, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ARTÍCULO VENDIDO',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nombreProducto,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 PORTAFOLIO COMPARTIDO
  if (_esPortafolio(mensaje['texto'] ?? '')) {
    final vendedorId = _extraerPortafolioUid(mensaje['texto']!);
    return _buildTarjetaPortafolio(vendedorId);
  }

  // 🔥 PROPUESTA DE ENCUENTRO
  if (_esPropuestaEncuentro(mensaje['texto'] ?? '')) {
    final propuestaId = _extraerPropuestaId(mensaje['texto']!);
    // 🔥 SI YA ESTÁ EN CACHÉ, MOSTRAR DIRECTO SIN FUTUREBUILDER
    if (_cachePropuestas.containsKey(propuestaId)) {
      return _buildTarjetaPropuestaDirecta(_cachePropuestas[propuestaId]!);
    }
    return _buildTarjetaPropuesta(propuestaId);
  }

  // 🔥 ACEPTACIÓN DE ENCUENTRO
  if (_esEncuentroAceptado(mensaje['texto'] ?? '')) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/escudo/encuentro_aceptado.png',
          width: double.infinity,
          height: 60,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF166534), size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'El encuentro ha sido aceptado',
                    style: TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 RECHAZO / ANULACIÓN DE ENCUENTRO
  // 🚫 No se muestra como mensaje separado. La tarjeta de la propuesta
  // se encarga de mostrar el estado "ANULADA".
  if (_esEncuentroRechazado(mensaje['texto'] ?? '')) {
    return const SizedBox.shrink();
  }
  // 🔥 MENSAJE DE "TRATO CERRADO"
  if ((mensaje['texto'] ?? '').startsWith('||TRATO_CERRADO||')) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200, width: 2),
      ),
      child: const Row(
        children: [
          Icon(Icons.handshake, color: Colors.green, size: 24),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '✅ Trato cerrado. Ambos confirmaron. ¡Nos vemos el día del encuentro!',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 MENSAJE DE "CERRAR TRATO" CONFIRMADO POR UNO
  if ((mensaje['texto'] ?? '').startsWith('||CERRAR_TRATO||')) {
    return const SizedBox.shrink(); // No mostrar este mensaje directamente
  }

  // 🔥 MENSAJE DE "AMBOS SIGUEN CONVERSANDO"
  if ((mensaje['texto'] ?? '').startsWith('||AMBOS_SEGUIR_CONVERSANDO||')) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '✅ Ambos decidieron seguir conversando',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 MENSAJE "SEGUIR CONVERSANDO": solo lo ve el OTRO usuario.
  // 🔥 Se dibuja UNA SOLA VEZ (el último), no por cada mensaje.
  if ((mensaje['texto'] ?? '').startsWith('||SEGUIR_CONVERSANDO||')) {
    final ultimoSeguirIndex = _mensajes.lastIndexWhere(
      (m) => (m['texto'] ?? '').startsWith('||SEGUIR_CONVERSANDO||'),
    );
    if (index != _mensajes.length - 1 - ultimoSeguirIndex) {
      return const SizedBox.shrink();
    }

    final proponenteId = (mensaje['texto'] ?? '')
        .replaceAll('||SEGUIR_CONVERSANDO||', '')
        .trim();
    final yoPropuse = user?.uid == proponenteId;

    // Quien dio "Seguir conversando" no ve nada
    if (yoPropuse) {
      return const SizedBox.shrink();
    }

    // El otro usuario sí ve el aviso
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/escudo/seguir_conversando.png',
          width: double.infinity,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: Color(0xFF92400E), size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'El usuario quiere seguir conversando',
                    style: TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 CONFIRMACIÓN DE CALIFICACIÓN (solo la ve el que calificó) 🔥
  if (_esConfirmacionCalificacion(mensaje['texto'] ?? '')) {
    final calificadorId = _extraerCalificadorId(mensaje['texto']!);
    final user = FirebaseAuth.instance.currentUser;

    // 🔥 SOLO MOSTRAR SI YO FUI EL QUE CALIFICÓ
    if (user == null || user.uid != calificadorId) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '✅ Has calificado. ¡Gracias por tu opinión!',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
  // 🔥 SOLICITUD DE CALIFICACIÓN - SOLO PARA EL COMPRADOR
 // 🔥 PRINT 5: ANTES DEL IF




  // 🔥 SOLICITUD DE CALIFICACIÓN - SOLO PARA EL COMPRADOR
if (_esSolicitudCalificacion(mensaje['texto'] ?? '')) {
  final user = FirebaseAuth.instance.currentUser;
  
  if (user != null && user.uid == _vendedorId) {
    return const SizedBox.shrink();
  }
  
  // 🔥 NO MOSTRAR SI YA CALIFICÓ
  if (_calificacionRealizada) {
    return const SizedBox.shrink();
  }
  
  // 🔥 NO MOSTRAR SI YA NO ESTÁ PENDIENTE
  if (!_calificacionPendiente) {
    return const SizedBox.shrink();
  }
  
  return _buildCalificacionButton();
}
  // 📍 UBICACIÓN COMPARTIDA
  // 🔥 SI EL ESCUDO ESTÁ ACTIVO, OCULTAR LA TARJETA DE UBICACIÓN
  if ((mensaje['texto'] ?? '').startsWith('||UBICACION||') && _iaActiva) {
    return const SizedBox.shrink();
  }
  if ((mensaje['texto'] ?? '').startsWith('||UBICACION||')) {
    final partes = (mensaje['texto'] ?? '')
        .replaceAll('||UBICACION||', '')
        .trim()
        .split(',');
    if (partes.length != 2) return const SizedBox.shrink();
    final latU = partes[0];
    final lngU = partes[1];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Align(
        alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => _mostrarOpcionesNavegacion(latU, lngU),
          child: Container(
            width: 240,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2447), Color(0xFF0A5BE0)],
              ),
              border: Border.all(
                color: const Color(0xFF00E676).withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E676).withValues(alpha: 0.25),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00E676).withValues(alpha: 0.15),
                    border: Border.all(color: const Color(0xFF00E676), width: 1.5),
                  ),
                  child: const Icon(Icons.location_on,
                      color: Color(0xFF00E676), size: 26),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        esMio ? 'Compartiste tu ubicación' : 'Ubicación compartida',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Toca para abrir en mapas',
                        style: TextStyle(color: Color(0xFFBBD7FF), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 TRATO CANCELADO
  if ((mensaje['texto'] ?? '').startsWith('||TRATO_CANCELADO||')) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300, width: 2),
      ),
      child: const Row(
        children: [
          Icon(Icons.event_busy, color: Colors.orange, size: 24),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '❌ El encuentro fue cancelado. El chat volvió a abrirse.',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 MENSAJE NORMAL CON MENÚ
  final mensajeId = mensaje['id'] ?? '';
  final mensajeTexto = mensaje['texto'] ?? '';

  return GestureDetector(
    onTap: () {
      // 🔥 Primero: mostrar el borde rojo
      setState(() {
        if (_mensajeSeleccionadoId == mensajeId) {
          _mensajeSeleccionadoId = null;
        } else {
          _mensajeSeleccionadoId = mensajeId;
        }
      });
      // 🔥 Segundo: abrir el menú automáticamente (con un pequeño delay para que se vea el borde)
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _mostrarMenuMensaje(context, mensajeId, mensajeTexto);
        }
      });
    },
    onLongPress: () {
      // 🔥 Si presiona largo, también mostrar borde y menú
      setState(() {
        _mensajeSeleccionadoId = mensajeId;
      });
      _mostrarMenuMensaje(context, mensajeId, mensajeTexto);
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: esMio ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!esMio)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              child: ClipOval(
                child: fotoPerfil.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl:
                            'https://mimarketplace-production.up.railway.app$fotoPerfil',
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            const Icon(Icons.person, size: 16),
                        errorWidget: (_, _, _) =>
                            const Icon(Icons.person, size: 16),
                      )
                    : const Icon(Icons.person, size: 16),
              ),
            ),
          if (!esMio) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: esMio ? const Color(0xFF3B82F6) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: esMio ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: esMio ? const Radius.circular(4) : const Radius.circular(16),
                ),
                border: _mensajeSeleccionadoId == mensajeId
                    ? Border.all(color: Colors.orange.shade700, width: 3)
                    : null,
                boxShadow: esMio ? [] : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 SI ES AUDIO, MOSTRAR REPRODUCTOR
                  if (esAudio) ...[
                    _buildAudioMessage(
                      mensajeId: mensaje['id']!,
                      audioUrl: 'https://mimarketplace-production.up.railway.app${mensaje['imagen']}',
                      esMio: esMio,
                    ),
                    const SizedBox(height: 4),
                  ],
                  // 🔥 SI ES IMAGEN (NO AUDIO)
                  if (mensaje['imagen'] != null && 
                      mensaje['imagen']!.isNotEmpty && 
                      !mensaje['imagen']!.endsWith('.m4a'))
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageViewerScreen(
                              imageUrl:
                                  'https://mimarketplace-production.up.railway.app${mensaje['imagen']}',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://mimarketplace-production.up.railway.app${mensaje['imagen']}',
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (_, _, _) => Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, size: 50),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // 🔥 TEXTO DEL MENSAJE (CON TACHADO)
                  if (mensaje['texto'] != null && mensaje['texto']!.isNotEmpty)
                    Text(
                      mensaje['texto']!,
                      style: TextStyle(
                        color: esMio ? Colors.white : Colors.black,
                        decoration: _mensajesTachados.contains(int.tryParse(mensajeId))
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: esMio ? Colors.white : Colors.black,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    mensaje['hora']!,
                    style: TextStyle(
                      fontSize: 10,
                      color: esMio ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (esMio) const SizedBox(width: 32),
        ],
      ),
    ),
  );
},
                      ),
          ),
                ),

          // 🔥 LÍNEA DIVISORIA ENTRE EL CHAT Y EL INPUT
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),

         // 🔥 BOTÓN DE CALIFICACIÓN ELIMINADO - AHORA SOLO APARECE EN EL LISTVIEW
              // 🔥 BOTÓN DE CALIFICACIÓN ELIMINADO - AHORA SOLO APARECE EN EL LISTVIEW
         // 🔥 EL ÓVALO COMPLETO DEL INPUT SE OCULTA SI HAY PROPUESTA PENDIENTE O CHAT BLOQUEADO
         if (!_propuestaEncuentroPendiente && !_chatBloqueado)
  SafeArea(
  top: false,
  bottom: true,
  child: Container(
  margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 8),
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(34),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF0A5BE0).withValues(alpha: 0.18),
        blurRadius: 18,
        offset: const Offset(0, 4),
      ),
    ],
    border: Border.all(color: const Color(0xFFE3EEFF)),
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // 🔥 BOTONES DE CONFIRMAR / SEGUIR CONVERSANDO
      // 🔥 NO se muestran si el modal azul de "¿Ya está todo listo?" está visible.
      if (_mostrarBotonesConfirmar && !_chatBloqueado && !_mostrarBotonesCerrarTrato)
        Builder(builder: (context) {

          return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    try {
                      // 🔥 1. Agendar el encuentro
                      final idTokenConf = await FirebaseAuth.instance.currentUser?.getIdToken();
                      await http.post(
                        Uri.parse('https://mimarketplace-production.up.railway.app/api/encuentro/confirmar'),
                        headers: {
                          'Content-Type': 'application/json',
                          if (idTokenConf != null) 'Authorization': 'Bearer $idTokenConf',
                        },
                        body: jsonEncode({
                          'conversacion_id': _conversacionIdActual,
                          'usuario_confirma_id': user.uid,
                        }),
                      );

                      // 🔥 2. Cerrar trato (inserta ||CERRAR_TRATO|| en la BD)
                      final idTokenCerrar1 = await FirebaseAuth.instance.currentUser?.getIdToken();
                      final r = await http.post(
                        Uri.parse('https://mimarketplace-production.up.railway.app/api/conversaciones/$_conversacionIdActual/cerrar-trato'),
                        headers: {
                          'Content-Type': 'application/json',
                          if (idTokenCerrar1 != null) 'Authorization': 'Bearer $idTokenCerrar1',
                        },
                        body: jsonEncode({'usuario_id': user.uid}),
                      );

                      if (r.statusCode == 200) {
                        final data = jsonDecode(r.body);
                        final ambos = data['ambos_confirmaron'] == true;

                        if (mounted) {
                          setState(() {
                            _mostrarBotonesConfirmar = false;
                            _usuarioConfirmoCerrarTrato = true;
                            if (ambos) {
                              _esperandoConfirmacionCerrarTrato = false;
                              _chatBloqueado = true;
                            } else {
                              _esperandoConfirmacionCerrarTrato = true;
                            }
                          });
                          _guardarEstadoBloqueo();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ambos
                                  ? '✅ Trato cerrado. ¡Nos vemos!'
                                  : '⏳ Confirmaste cerrar el trato. Esperando al otro...'),
                              backgroundColor: ambos ? Colors.green : Colors.blue,
                            ),
                          );
                        }
                        await _cargarMensajes(_conversacionIdActual);
                      }
                    } catch (e) {
                      print('Error al confirmar encuentro: $e');
                    }
                  },
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Confirmar encuentro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // 🔥 UNO SOLO BASTA: ocultar botones para ambos inmediatamente
                    setState(() {
                      _mostrarBotonesConfirmar = false;
                      _esperandoRespuestaOtro = false;
                      _usuarioDecidioSeguirConversando = true;
                      _mostrarBotonesCerrarTrato = false;
                      _quiereCerrarTrato = false;
                    });
                    _guardarEstadoBloqueo();

                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    try {
                      // 🔥 PASO 1: ENVIAR MENSAJE AL CHAT (el backend lo va a interpretar
                      // como "alguien quiere seguir", y va a ocultar los botones para los 2)
                      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
                      await http.post(
                        Uri.parse('https://mimarketplace-production.up.railway.app/api/mensajes'),
                        headers: {
                          'Content-Type': 'application/json',
                          if (idToken != null) 'Authorization': 'Bearer $idToken',
                        },
                        body: jsonEncode({
                          'conversacion_id': int.parse(_conversacionIdActual),
                          'usuario_id': user.uid,
                          'texto': '||SEGUIR_CONVERSANDO||${user.uid}',
                        }),
                      );

                      // 🔥 PASO 2: CONSULTAR ENDPOINT (por si el backend necesita marcar algo)
                      final idTokenSeguir = await FirebaseAuth.instance.currentUser?.getIdToken();
                      await http.post(
                        Uri.parse('https://mimarketplace-production.up.railway.app/api/conversaciones/$_conversacionIdActual/seguir-conversando'),
                        headers: {
                          'Content-Type': 'application/json',
                          if (idTokenSeguir != null) 'Authorization': 'Bearer $idTokenSeguir',
                        },
                        body: jsonEncode({'usuario_id': user.uid}),
                      );

                      // 🔥 PASO 3: RECARGAR MENSAJES
                      await _cargarMensajes(_conversacionIdActual);
                    } catch (e) {
                      print('>>> 🟠 ERROR: $e');
                    }
                  },
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('Seguir conversando'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
        }),

      // 🔥 CARTEL: YO CONFIRMÉ CERRAR TRATO, ESPERANDO AL OTRO
      if (_usuarioConfirmoCerrarTrato &&
          !_otroUsuarioConfirmoCerrarTrato &&
          !_usuarioDecidioSeguirConversando &&
          !_chatBloqueado)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.hourglass_top, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '⏳ Confirmaste cerrar el trato. Esperando la respuesta del otro usuario...',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      // 🔥 MENSAJE DE ESPERA - CONFIRMÉ CERRAR TRATO
      if (_esperandoRespuestaOtro && !_mostrarBotonesConfirmar)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.hourglass_top, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '⏳ Esperando que el otro usuario decida...',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

      // 🔥 INPUT (solo si NO hay botones de cerrar trato ni espera)
      // 🔥 El input se muestra si NO hay modal de decisión pendiente
      if ((!_mostrarBotonesConfirmar &&
           !_esperandoRespuestaOtro &&
           (!_mostrarBotonesCerrarTrato || _usuarioConfirmoCerrarTrato) &&
           !_esperandoConfirmacionCerrarTrato) || _chatBloqueado)
      Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
           // 🔥 BOTÓN DE GRABACIÓN CON PRESIÓN LARGA Y DESLIZAR PARA CANCELAR
           // 🔥 BOTÓN DE GRABACIÓN CON ANIMACIÓN (CRECE AL GRABAR)
            // 🔥 BOTÓN DE GRABACIÓN CON PRESIÓN LARGA (VERSIÓN SIMPLE)
          // 🔥 BOTÓN DE GRABACIÓN - DESLIZAR FUERA = CANCELAR CON SNACKBAR
      // 🔥 CHAT BLOQUEADO POR ENCUENTRO CONFIRMADO
      if (_chatBloqueado && !_isRecording)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _escudoOtroRechazo ? Icons.gpp_bad : Icons.lock,
                color: Colors.red,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _escudoOtroRechazo
                      ? 'Chat cerrado. Uno de los participantes no aceptó el Escudo de Seguridad.'
                      : 'Chat bloqueado. Se verán en persona. No llegues tarde.',
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            ],
          ),
        )

      // 🔥 BLOQUEAR TODO EL INPUT SI HAY PROPUESTA PENDIENTE
      else if (_propuestaEncuentroPendiente && !_isRecording)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_top, color: Colors.orange, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Propuesta de encuentro pendiente. Esperá a que se resuelva para escribir.',
                  style: TextStyle(color: Colors.orange, fontSize: 13),
                ),
              ),
            ],
          ),
        )
      else ...[
        BotonGrabacion(
          buttonKey: _audioButtonKey,
          isRecording: _isRecording,
          recordingTime: _recordingTime,
          mostrarMensajeCancelar: _mostrarMensajeCancelar,
          onStart: _startRecording,
          onStop: _stopRecordingAndSend,
          onCancel: _cancelRecording,
          onDragChange: (mostrar) {
            if (_mostrarMensajeCancelar != mostrar) {
              setState(() {
                _mostrarMensajeCancelar = mostrar;
              });
            }
          },
        ),
        // 🔥 OCULTAR BOTÓN DE IMAGEN SI ESTÁ GRABANDO
        if (!_isRecording) ...[
          // 🖼️ Botón imagen (círculo gris claro)
          GestureDetector(
            onTap: _enviandoImagen ? null : _mostrarOpcionesImagen,
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF1F5FB),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.image, color: Color(0xFF4B5563), size: 24),
            ),
          ),
          // ✏️ Campo de texto que arranca en 1 línea y crece hasta 5 (como WhatsApp)
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 40,
                maxHeight: 120,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFE3EAF5)),
              ),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(fontSize: 15, height: 1.2),
                decoration: const InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) {},
              ),
            ),
          ),
          // ➤ Botón enviar (círculo azul con degradado)
          GestureDetector(
            onTap: _enviandoImagen ? null : _enviarMensaje,
            child: Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF3B9BFF), Color(0xFF0A5BE0)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A5BE0).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _enviandoImagen
                  ? const Padding(
                      padding: EdgeInsets.all(13),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 24),
            ),
          ),
        ] else ...[
          // 🔥 MIENTRAS GRABAS: círculo oscilante + texto + tiempo
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 50, right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _oscilacionAnim,
                    builder: (context, child) {
                      final t = _oscilacionAnim.value;
                      final distanciaAlCentro = (t - 0.5).abs() * 2;
                      final tamano = 6.0 + (distanciaAlCentro * 8.0);

                      return Container(
                        width: 120,
                        height: 20,
                        alignment: Alignment.center,
                        child: Align(
                          alignment: Alignment(-1.0 + (t * 2.0), 0.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 80),
                            width: tamano,
                            height: tamano,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '🎤 Grabando... desliza para cancelar',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _recordingTime,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_mostrarMensajeCancelar)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline,
                              color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Suelta para cancelar',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
        ],
      ),
    ],
  ),
),
  ),
        ],
      ),
    );
  }
}

// 🌊 Recorte con ola para la parte baja del app bar
class _OlaAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // 🔥 Ola más baja: recorta menos, deja más espacio abajo
    path.lineTo(0, size.height - 6);
    path.quadraticBezierTo(
        size.width * 0.25, size.height - 26, size.width * 0.5, size.height - 10);
    path.quadraticBezierTo(
        size.width * 0.78, size.height + 2, size.width, size.height - 14);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ✨ Borde punteado que gira y "respira" alrededor de un widget
class BordePunteadoAnimado extends StatelessWidget {
  final AnimationController controller;
  final Widget child;
  final Color color;
  const BordePunteadoAnimado({
    super.key,
    required this.controller,
    required this.child,
    this.color = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _BordePunteadoPainter(controller, color),
      child: child,
    );
  }
}

class _BordePunteadoPainter extends CustomPainter {
  final AnimationController controller;
  final Color color;
  _BordePunteadoPainter(this.controller, this.color) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final t = controller.value;

    // 🔥 Pulso: se agranda y se encoge (2 veces por vuelta)
    final pulso = (math.sin(t * 2 * math.pi) + 1) / 2; // 0..1 (1 pulso por ciclo)
    final inflar = 1 + pulso * 6;

    // 🔥 Rectángulo base = tarjeta sin su margen (16 horizontal, 8 vertical)
    final rect = Rect.fromLTWH(16, 8, size.width - 32, size.height - 16)
        .inflate(inflar);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(18)));

    final paint = Paint()
      ..color = color.withValues(alpha: 0.6 + pulso * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const dash = 10.0;
    const gap = 6.0;
    const ciclo = dash + gap;

    // 🔥 Las rayas avanzan alrededor de la tarjeta
    final desplazamiento = (t * ciclo * 20) % ciclo;

    for (final metric in path.computeMetrics()) {
      double d = desplazamiento - ciclo;
      while (d < metric.length) {
        final inicio = d < 0 ? 0.0 : d;
        final fin = (d + dash) > metric.length ? metric.length : (d + dash);
        if (fin > inicio) {
          canvas.drawPath(metric.extractPath(inicio, fin), paint);
        }
        d += ciclo;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BordePunteadoPainter old) => false;
}