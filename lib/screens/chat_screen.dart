import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:animated_emoji/animated_emoji.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../models/producto.dart';
import 'detalle_producto_screen.dart';
import 'perfil_vendedor_screen.dart';
import '../widgets/conversation_status_indicator.dart';
import 'image_viewer_screen.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/ia_chat_button.dart';
import '../services/chat_service.dart';        // 🔥 NUEVO
import 'calificar_screen.dart';     
import '../widgets/calificacion_widget.dart';    
import 'package:shared_preferences/shared_preferences.dart';       // 🔥 NUEVO



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
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _comentarioController = TextEditingController(); // 🔥 NUEVO
  final List<Map<String, String>> _mensajes = [];
  bool _isLoading = true;
  bool _enviandoImagen = false;
  String _conversacionIdActual = '';
  Timer? _timer;
  String _fotoVendedorReal = '';

  // 🔥 NUEVO: CACHÉ DE FOTOS DE PERFIL EN MEMORIA
  final Map<String, String> _cacheFotosPerfil = {};
  int _calificacionSeleccionada = 0;
  ConversationStatus _conversationStatus = ConversationStatus.neutral;
  Set<int> _mensajesTachados = {};
  String? _mensajeSeleccionadoId;
  bool _iaActiva = false;
  String? _analisisIA;

  // 🔥 VARIABLES PARA CALIFICACIÓN PENDIENTE
  bool _calificacionPendiente = false;
  bool _calificacionRealizada = false;
  String _vendedorId = '';
  int _productoId = 0;

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

  // ============ 🔥 NUEVO: GRABACIÓN CON PRESIÓN LARGA ============
  double _micScale = 1.0;              // Para animación del botón
  bool _isSwipedToCancel = false;      // Para detectar deslizamiento
  Timer? _recordingTimer;              // Timer para mostrar tiempo
  String _recordingTime = '00:00';     // Tiempo de grabación
  Offset _startPosition = Offset.zero;  // 🔥 NUEVO: Posición donde se presionó
  bool _isDraggingOut = false;          // 🔥 NUEVO: Si el dedo está fuera del botón
  bool _mostrarMensajeCancelar = false; // 🔥 NUEVO: Mostrar texto verde de cancelar

  // 🔥 NUEVO: OVERLAY DEL CÍRCULO ROJO
  final GlobalKey _audioButtonKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  // 🔥 NUEVO: ANIMACIÓN DEL CÍRCULO OSCILANTE
  late AnimationController _oscilacionController;
  late Animation<double> _oscilacionAnim;
    

  final List<AnimatedEmoji> _emociones = const [
    AnimatedEmoji(AnimatedEmojis.joy, size: 40, repeat: true),
    AnimatedEmoji(AnimatedEmojis.heartEyes, size: 40, repeat: true),
    AnimatedEmoji(AnimatedEmojis.smile, size: 40, repeat: true),
    AnimatedEmoji(AnimatedEmojis.sad, size: 40, repeat: true),
    AnimatedEmoji(AnimatedEmojis.angry, size: 40, repeat: true),
    AnimatedEmoji(AnimatedEmojis.sleep, size: 40, repeat: true),
  ];
  int _indiceEmocion = 0;
  late Timer _timerEmociones;

  AnimatedEmoji get _emojiActual => _emociones[_indiceEmocion];
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
    
    setState(() {
      _calificacionPendiente = result['pendiente'] ?? false;
      _vendedorId = result['vendedor_id'] ?? '';
      _productoId = int.tryParse(result['producto_id']?.toString() ?? '0') ?? 0;
    });
    
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

  // 🔥 Repetir infinitamente (reverse: true hace que vaya y vuelva)
  _oscilacionController.repeat(reverse: true);
  
  // 🔥 CONFIGURAR REPRODUCTOR DE AUDIO
  _audioPlayer.onPlayerComplete.listen((event) {
    if (mounted) {
      setState(() {
        _isAudioPlaying = false;
        _audioPlayingId = null;
      });
    }
  });
  
  _timerEmociones = Timer.periodic(const Duration(seconds: 3), (timer) {
    if (mounted) {
      setState(() {
        _indiceEmocion = (_indiceEmocion + 1) % _emociones.length;
      });
    }
  });
  _conversacionIdActual = widget.conversacionId;
  _obtenerOCrearConversacion();
  _obtenerFotoVendedorReal();
  print('>>> DESPUÉS de llamar _obtenerFotoVendedorReal()');
  print('>>> _fotoVendedorReal: $_fotoVendedorReal');
  _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
    if (_conversacionIdActual.isNotEmpty) {
      _cargarMensajes(_conversacionIdActual);
    }
  });

  // 🔥 VERIFICAR CALIFICACIÓN PENDIENTE - DESPUÉS DEL PRIMER BUILD
  WidgetsBinding.instance.addPostFrameCallback((_) {
    print('>>> 🔥 addPostFrameCallback - LLAMANDO A _verificarCalificacion()');
    _verificarCalificacion();
  });

  // 🔥 SIMULAR CAMBIO DE ESTADO (PARA PRUEBAS)
  Timer.periodic(const Duration(seconds: 10), (timer) {
    if (mounted) {
      final estados = [
        ConversationStatus.neutral,
        ConversationStatus.good,
        ConversationStatus.warning,
        ConversationStatus.danger,
      ];
      setState(() {
        _conversationStatus = estados[DateTime.now().second % 4];
      });
    }
  });
}


@override
void dispose() {
  _ocultarCirculoGrabacion(); // 🔥 ELIMINAR OVERLAY
  _oscilacionController.dispose(); // 🔥 LIBERAR ANIMACIÓN
  _timerEmociones.cancel();
  _timer?.cancel();
  _controller.dispose();
  _audioRecorder?.closeRecorder();
  _audioPlayer.dispose();
  _uiSoundPlayer.dispose();  // 🔥 LIBERAR REPRODUCTOR DE UI
  _recordingTimer?.cancel();  // 🔥 NUEVO
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
      final response = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/conversaciones'),
        headers: {'Content-Type': 'application/json'},
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
      final key = 'chat_cache_$conversacionId';
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
      final key = 'chat_cache_$conversacionId';
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
      await prefs.remove('chat_cache_$conversacionId');
    } catch (e) {
      print('Error al limpiar caché: $e');
    }
  }

  Future<void> _cargarMensajes(String conversacionId) async {
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
    final response = await http.get(
      Uri.parse('https://mimarketplace-production.up.railway.app/api/mensajes/$conversacionId?usuario_id=${user.uid}'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
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

      // 🔥 2. GUARDAR EN CACHÉ DESPUÉS DE CARGAR DEL SERVIDOR
      await _guardarMensajesEnCache(conversacionId, mensajesConFotos);

    } else {
      setState(() => _isLoading = false);
    }
  } catch (e) {
    print('Error al cargar mensajes: $e');
    setState(() => _isLoading = false);
  }
}
  bool _esSolicitudCalificacion(String texto) {
  // 🔥 PRINT 3: CADA VEZ QUE SE LLAMA
  print('>>> 🔥 _esSolicitudCalificacion() LLAMADO');
  print('>>> 🔥 texto contiene EL_COMPRADOR_YA_PUEDE_CALIFICARTE: ${texto.contains('EL_COMPRADOR_YA_PUEDE_CALIFICARTE')}');
  
  if (!texto.contains('EL_COMPRADOR_YA_PUEDE_CALIFICARTE')) return false;
  
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  
  // 🔥 PRINT 4: COMPARACIÓN
  print('>>> 🔥 COMPARANDO - user.uid: ${user.uid}');
  print('>>> 🔥 COMPARANDO - _vendedorId: $_vendedorId');
  print('>>> 🔥 COMPARANDO - user.uid == _vendedorId: ${user.uid == _vendedorId}');
  print('>>> 🔥 COMPARANDO - ¿ES VENDEDOR? ${user.uid == _vendedorId}');
  
  return user.uid != _vendedorId;
}

  bool _esConfirmacionCalificacion(String texto) {
    return texto.contains('✅ Has calificado');
  }

  Future<void> _enviarCalificacion(int puntuacion) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final response = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/calificaciones/from-chat'),
        headers: {'Content-Type': 'application/json'},
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
        _cargarMensajes(_conversacionIdActual);
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
      },
    );
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
  void _enviarMensaje() async {
    if (_controller.text.trim().isEmpty) return;
    if (_conversacionIdActual.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final mensaje = _controller.text;

    if (_iaActiva) {
      await _analizarMensajeConIA(mensaje, user?.uid ?? '');
    }

    try {
      final response = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/mensajes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'conversacion_id': int.parse(_conversacionIdActual),
          'usuario_id': user?.uid ?? '',
          'texto': mensaje,
        }),
      );

      if (response.statusCode == 201) {
        _controller.clear();
        await _cargarMensajes(_conversacionIdActual);
      }
    } catch (e) {}
  }

  Future<void> _analizarMensajeConIA(String mensaje, String usuarioId) async {
    if (!_iaActiva) return;

    try {
      final response = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/analizar-chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mensaje': mensaje,
          'usuario_id': usuarioId,
          'conversacion_id': _conversacionIdActual,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final estado = data['estado'] ?? 'neutral';
        final analisis = data['analisis'] ?? '';

        setState(() {
          _analisisIA = analisis;
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
        });
      }
    } catch (e) {}
  }

  void _mostrarOpcionesImagen() {
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
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.camera);
              },
            ),
          ],
        ),
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
 Widget _buildProductoHeader() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.15),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            image: widget.productoImagen.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage('https://mimarketplace-production.up.railway.app${widget.productoImagen}'),
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
                    id: int.parse(widget.productoId),
                    nombre: widget.nombreProducto,
                    categoria: widget.productoCategoria,
                    precio: double.parse(widget.productoPrecio),
                    imagenUrl: widget.productoImagen,
                    descripcion: widget.productoDescripcion,
                    direccion: widget.productoDireccion,
                    vendedorNombre: widget.otroUsuario,
                    vendedorId: widget.otroUsuarioId,
                    vendedorFoto: _fotoVendedorReal,
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
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Ver producto',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
      final response = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/bloquear/verificar/${user.uid}/$vendedorId'),
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
                  )).toList(),
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

      final response = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/denuncias'),
        headers: {'Content-Type': 'application/json'},
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
                            vendedorFoto: _fotoVendedorReal,
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de ver portafolio en desarrollo'),
        backgroundColor: Colors.blue,
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
          content: Container(
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

  void _mostrarInfoEstado() {
    String analisisTexto = _analisisIA ?? 'No hay análisis disponible aún.';

    final Map<ConversationStatus, Map<String, String>> infoEstados = {
      ConversationStatus.neutral: {
        'titulo': '⚪ Estado Neutral',
        'descripcion': 'La conversación está en curso. Aún no hay suficiente información para determinar el estado de la transacción.',
        'recomendacion': 'Continúa conversando de forma respetuosa y clara.',
      },
      ConversationStatus.good: {
        'titulo': '✅ Conversación Saludable',
        'descripcion': 'La conversación fluye de manera positiva. Ambos usuarios se están comunicando de forma respetuosa y clara.',
        'recomendacion': '¡Sigue así! La transacción tiene buenas probabilidades de éxito.',
      },
      ConversationStatus.warning: {
        'titulo': '⚠️ Precaución Recomendada',
        'descripcion': 'Se han detectado algunos signos de alerta en la conversación. Podría haber malentendidos o tensión.',
        'recomendacion': 'Revisa los mensajes anteriores. Intenta ser más claro y empático en tus respuestas.',
      },
      ConversationStatus.danger: {
        'titulo': '🚨 Peligro Inminente',
        'descripcion': 'La conversación muestra signos de conflicto o riesgo. Podría haber mala comunicación o desacuerdos serios.',
        'recomendacion': 'Detente y evalúa la situación. Considera contactar a soporte si es necesario.',
      },
    };

    final info = infoEstados[_conversationStatus]!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Text(info['titulo']!),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '🔍 Análisis: $analisisTexto',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '📊 Resumen',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                info['descripcion']!,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '💡 ${info['recomendacion']!}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
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
      final response = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/calificaciones'),
        headers: {'Content-Type': 'application/json'},
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
        _cargarMensajes(_conversacionIdActual);
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

  @override
  Widget build(BuildContext context) {
  print('>>> productoImagen en ChatScreen: ${widget.productoImagen}');
  print('>>> productoId en ChatScreen: ${widget.productoId}');
  print('>>> productoPrecio en ChatScreen: ${widget.productoPrecio}');
  final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
 appBar: AppBar(
  title: GestureDetector(
    onTap: () => _mostrarOpcionesVendedor(context),
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade200,
          child: ClipOval(
            child: widget.fotoPerfil.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl:
                        'https://mimarketplace-production.up.railway.app${widget.fotoPerfil}',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const Icon(Icons.person, size: 24, color: Colors.grey),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.person, size: 24, color: Colors.grey),
                  )
                : const Icon(Icons.person, size: 24, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.otroUsuario,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.nombreProducto,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // 🔥 CARITA + BOTÓN DE IA + INFO
        Row(
          children: [
            ConversationStatusIndicator(
              status: _conversationStatus,
              size: 40,
              onTap: () => _mostrarInfoEstado(),
            ),
            const SizedBox(width: 4),
            IaChatButton(
              isActive: _iaActiva,
              onToggle: () {
                setState(() {
                  _iaActiva = !_iaActiva;
                  if (!_iaActiva) {
                    _analisisIA = null;
                  }
                });
              },
              onAdCompleted: () {
                setState(() {
                  _analisisIA = '🤖 IA activada. Analizando mensajes...';
                });
              },
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white, size: 22),
              onPressed: () => _mostrarInfoEstado(),
              tooltip: 'Estado de la conversación',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    ),
  ),
  backgroundColor: const Color(0xFF087FE8),
  foregroundColor: Colors.white,
  elevation: 0,
),
      body: Column(
        children: [
          _buildProductoHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _mensajes.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay mensajes aún',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        itemCount: _mensajes.length,
              itemBuilder: (context, index) {
  final mensaje = _mensajes[_mensajes.length - 1 - index];
  final esMio = mensaje['usuario_id'] == user?.uid;
  final fotoPerfil = mensaje['foto_perfil'] ?? '';

  // 🔥 VERIFICAR SI ES AUDIO (archivo .m4a)
  final bool esAudio = mensaje['imagen'] != null && 
      mensaje['imagen']!.isNotEmpty && 
      mensaje['imagen']!.endsWith('.m4a');

 

  // 🔥 CONFIRMACIÓN DE CALIFICACIÓN 🔥
  if (_esConfirmacionCalificacion(mensaje['texto'] ?? '')) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje['texto']!.replaceAll('||CALIFICACION_REQUEST||', ''),
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
  // 🔥 SOLICITUD DE CALIFICACIÓN - SOLO PARA EL COMPRADOR
 // 🔥 PRINT 5: ANTES DEL IF
print('>>> 🔥 LISTVIEW - ANTES DEL IF');
print('>>> 🔥 LISTVIEW - mensaje: ${mensaje['texto']}');
print('>>> 🔥 LISTVIEW - _vendedorId: $_vendedorId');
print('>>> 🔥 LISTVIEW - user.uid: ${FirebaseAuth.instance.currentUser?.uid}');

if (_esSolicitudCalificacion(mensaje['texto'] ?? '')) {
  final user = FirebaseAuth.instance.currentUser;
  
  // 🔥 PRINT 6: DENTRO DEL IF
  print('>>> 🔥 LISTVIEW - DENTRO DEL IF');
  print('>>> 🔥 LISTVIEW - user.uid: ${user?.uid}');
  print('>>> 🔥 LISTVIEW - _vendedorId: $_vendedorId');
  print('>>> 🔥 LISTVIEW - user.uid == _vendedorId: ${user?.uid == _vendedorId}');
  
  if (user != null && user.uid == _vendedorId) {
    print('>>> 🔥 LISTVIEW - VENDEDOR DETECTADO - OCULTANDO');
    return const SizedBox.shrink();
  }
  print('>>> 🔥 LISTVIEW - COMPRADOR DETECTADO - MOSTRANDO');
  return _buildCalificacionButton();
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
                        placeholder: (_, __) =>
                            const Icon(Icons.person, size: 16),
                        errorWidget: (_, __, ___) =>
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
                color: esMio ? Colors.blue : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
                border: _mensajeSeleccionadoId == mensajeId
                    ? Border.all(
                        color: Colors.orange.shade700,
                        width: 3,
                      )
                    : null,
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
                            placeholder: (_, __) => Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
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
          
         // 🔥 BOTÓN DE CALIFICACIÓN ELIMINADO - AHORA SOLO APARECE EN EL LISTVIEW
         Padding(
  padding: const EdgeInsets.fromLTRB(16, 8, 8, 56),
  child: Row(
    children: [
           // 🔥 BOTÓN DE GRABACIÓN CON PRESIÓN LARGA Y DESLIZAR PARA CANCELAR
           // 🔥 BOTÓN DE GRABACIÓN CON ANIMACIÓN (CRECE AL GRABAR)
            // 🔥 BOTÓN DE GRABACIÓN CON PRESIÓN LARGA (VERSIÓN SIMPLE)
          // 🔥 BOTÓN DE GRABACIÓN - DESLIZAR FUERA = CANCELAR CON SNACKBAR
      Listener(
        key: _audioButtonKey,  // 🔥 AGREGAR KEY
        onPointerDown: (event) {
          _startRecording();
          _startPosition = event.localPosition;
        },
        onPointerUp: (event) {
          if (_isRecording) {
            final distance = (event.localPosition - _startPosition).distance;
            if (distance > 80) {
              _cancelRecording();
            } else {
              _stopRecordingAndSend();
            }
          }
        },
        onPointerCancel: (event) {
          if (_isRecording) {
            _cancelRecording();
          }
        },
        onPointerMove: (event) {
          if (_isRecording) {
            final distance = (event.localPosition - _startPosition).distance;
            setState(() {
              _isDraggingOut = distance > 80;
              _mostrarMensajeCancelar = distance > 80;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          // 🔥 TRANSICIÓN SUAVE DEL ÍCONO
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: RotationTransition(
                  turns: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                ),
              );
            },
            child: _isRecording
                ? const SizedBox(
                    key: ValueKey('empty'),
                    width: 28,
                    height: 28,
                  )
                : Icon(
                    key: const ValueKey('mic'),
                    Icons.mic,
                    color: Colors.grey.shade600,
                    size: 28,
                  ),
          ),
        ),
      ),
      // 🔥 OCULTAR BOTÓN DE IMAGEN SI ESTÁ GRABANDO
      if (!_isRecording) ...[
        IconButton(
          icon: const Icon(Icons.image, color: Colors.grey),
          onPressed: _enviandoImagen ? null : _mostrarOpcionesImagen,
          tooltip: 'Adjuntar imagen',
        ),
        const SizedBox(width: 4),
        Expanded(
          child: TextField(
            controller: _controller,
            maxLines: null,
            minLines: 1,
            decoration: const InputDecoration(
              hintText: 'Escribe un mensaje...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onSubmitted: (_) => _enviarMensaje(),
          ),
        ),
        IconButton(
          icon: _enviandoImagen
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send, color: Colors.blue),
          onPressed: _enviandoImagen ? null : _enviarMensaje,
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
                // 🔥 CÍRCULO OSCILANTE (izquierda ↔ derecha, grande ↔ pequeño)
                AnimatedBuilder(
                  animation: _oscilacionAnim,
                  builder: (context, child) {
                    // t va de 0.0 (izquierda) → 1.0 (derecha) → 0.0 ...
                    final t = _oscilacionAnim.value;

                    // 🔥 Tamaño: máximo en extremos, mínimo en el centro
                    // Distancia al centro: 0.5 en extremos, 0.0 en el centro
                    // Multiplicamos x2 para que vaya de 0.0 a 1.0
                    final distanciaAlCentro = (t - 0.5).abs() * 2;

                    // Tamaño entre 6px (centro) y 14px (extremos)
                    final tamano = 6.0 + (distanciaAlCentro * 8.0);

                    return Container(
                      width: 120,
                      height: 20,
                      alignment: Alignment.center,
                      child: Align(
                        // 🔥 Movimiento horizontal progresivo
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

                // 🔥 MENSAJE VERDE CON TRANSICIÓN SUAVE
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    opacity: _mostrarMensajeCancelar ? 1.0 : 0.0,
                    child: _mostrarMensajeCancelar
                        ? const Padding(
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
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ],
  ),
),
        ],
      ),
    );
  }
}