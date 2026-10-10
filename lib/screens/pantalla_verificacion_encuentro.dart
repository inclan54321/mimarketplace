import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:smart_liveliness_detection/smart_liveliness_detection.dart';
import 'package:face_detection_tflite/face_detection_tflite.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart' hide FaceDetector;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart' as mlkit;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'chat_screen.dart';

class PantallaVerificacionEncuentro extends StatefulWidget {
  final int encuentroId;

  const PantallaVerificacionEncuentro({super.key, required this.encuentroId});

  @override
  State<PantallaVerificacionEncuentro> createState() =>
      _PantallaVerificacionEncuentroState();
}

class _PantallaVerificacionEncuentroState
    extends State<PantallaVerificacionEncuentro> {
  static const String _baseUrl =
      'https://mimarketplace-production.up.railway.app';

  bool _cargando = true;
  String? _error;
  String _mensajeEstado = 'Iniciando...';

  Map<String, dynamic>? _encuentro;
  bool _enLugar = false;
  int _distanciaMetros = 0;
  final bool _verificadoFacial = false;
  bool _ambosPresentes = false;

  Timer? _polling;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  @override
  void dispose() {
    _polling?.cancel();
    super.dispose();
  }

  Future<void> _iniciar() async {
    setState(() {
      _cargando = true;
      _error = null;
      _mensajeEstado = 'Cargando encuentro...';
    });

    try {
      // 1. Cargar datos del encuentro
      final enc = await _cargarEncuentro();
      if (enc == null) {
        setState(() {
          _error = 'No se encontró el encuentro';
          _cargando = false;
        });
        return;
      }
      _encuentro = enc;

      // 2. Verificar ubicación
      setState(() => _mensajeEstado = 'Verificando ubicación...');
      final ubicacion = await _verificarUbicacion();
      if (ubicacion == null) {
        setState(() {
          _error = 'No se pudo obtener tu ubicación. Verificá los permisos.';
          _cargando = false;
        });
        return;
      }

      _enLugar = ubicacion['en_lugar'] == true;
      _distanciaMetros = (ubicacion['distancia_metros'] ?? 0) as int;

      if (!_enLugar) {
        setState(() {
          _mensajeEstado = 'Estás a $_distanciaMetros metros del lugar';
          _cargando = false;
        });
        return;
      }

      // 3. Verificar estado inicial (¿ya verifiqué antes?)
      await _consultarEstado();

      if (_verificadoFacial) {
        setState(() {
          _mensajeEstado = 'Ya verificaste tu identidad';
          _cargando = false;
        });
        _empezarPolling();
        return;
      }

      setState(() {
        _mensajeEstado = 'Estás en el lugar. Iniciá el reconocimiento facial.';
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _cargando = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _cargarEncuentro() async {
    try {
      final r = await http.get(
        Uri.parse('$_baseUrl/api/encuentro/propuesta/${widget.encuentroId}'),
      );
      if (r.statusCode == 200) {
        return jsonDecode(r.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> _verificarUbicacion() async {
    try {
      // Permisos
      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.denied) return null;
      }
      if (permiso == LocationPermission.deniedForever) return null;

      // Ubicación actual
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final r = await http.post(
        Uri.parse(
            '$_baseUrl/api/encuentro/${widget.encuentroId}/verificar-ubicacion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': user.uid,
          'lat': pos.latitude,
          'lng': pos.longitude,
        }),
      );

      if (r.statusCode == 200) {
        return jsonDecode(r.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('>>> Error verificando ubicación: $e');
    }
    return null;
  }

  Future<void> _verificarFacial() async {
    setState(() {
      _mensajeEstado = 'Iniciando reconocimiento facial...';
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _mensajeEstado = 'No hay cámara disponible.');
        return;
      }

      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final result = await Navigator.of(context).push<Map<String, dynamic>?>(
        MaterialPageRoute(
          builder: (_) => LivenessDetectionScreen(
            cameras: [frontCamera],
            config: LivenessConfig(
              challengeTypes: [
                ChallengeType.blink,
                ChallengeType.turnLeft,
              ],
            ),
            captureFinalImage: false,
            showCaptureImageButton: true,
            captureButtonText: 'Capturar foto',
            onLivenessCompleted: (sessionId, isSuccessful, metadata) {
              debugPrint('>>> Liveness completado: $isSuccessful');
            },
            onManualImageCaptured: (sessionId, imageFile) {
              debugPrint('>>> Foto capturada manualmente: ${imageFile.path}');
              Navigator.of(context).pop({
                'imageFile': imageFile,
                'metadata': {'sessionId': sessionId},
              });
            },
          ),
        ),
      );

      debugPrint('>>> Resultado liveness: $result');

      if (result == null || result['imageFile'] == null) {
        debugPrint('>>> Resultado nulo, abortando');
        setState(() => _mensajeEstado = 'Reconocimiento fallido. Intentá de nuevo.');
        return;
      }

      debugPrint('>>> Leyendo bytes de la selfie...');
      final XFile imageFile = result['imageFile'] as XFile;
      final selfieBytes = await imageFile.readAsBytes();
      debugPrint('>>> Selfie bytes: ${selfieBytes.length}');

      // 🔥 VALIDAR QUE LA CARA ESTÉ DENTRO DEL ÓVALO
      final caraValida = await _validarCaraCentrada(selfieBytes);
      if (!caraValida) {
        setState(() => _mensajeEstado = 'Tu cara no estaba centrada. Intentá de nuevo.');
        return;
      }

      // Marcar como verificado en el server Y GUARDAR LA SELFIE
      final user = FirebaseAuth.instance.currentUser;
      try {
        // Convertir selfie a base64
        final selfieBase64 = base64Encode(selfieBytes);
        debugPrint('>>> Selfie base64 length: ${selfieBase64.length}');

        final r = await http.post(
          Uri.parse('$_baseUrl/api/encuentro/verificar-facial'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'encuentro_id': widget.encuentroId,
            'usuario_id': user?.uid ?? '',
            'aprobado': true,
            'confianza': 1.0,
            'selfie_base64': selfieBase64,
          }),
        );

        debugPrint('>>> Verificar-facial status: ${r.statusCode}');
        debugPrint('>>> Verificar-facial body: ${r.body}');
      } catch (e) {
        debugPrint('>>> Error marcando verificación: $e');
      }

      // 🔥 Obtener los datos para abrir el chat
      final datosChat = await _obtenerDatosParaChat();

      if (datosChat == null) {
        setState(() => _mensajeEstado = 'No se pudieron cargar los datos del chat.');
        return;
      }

      // 🔥 Volver y abrir el chat de la conversación
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar pantalla de verificación

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversacionId: datosChat['conversacion_id'].toString(),
              otroUsuario: datosChat['otro_usuario_nombre'] ?? 'Usuario',
              otroUsuarioId: datosChat['otro_usuario_id'] ?? '',
              nombreProducto: datosChat['producto_nombre'] ?? 'Producto',
              productoImagen: datosChat['producto_imagen'] ?? '',
              productoId: datosChat['producto_id']?.toString() ?? '',
              productoPrecio: datosChat['producto_precio']?.toString() ?? '0',
              productoCategoria: datosChat['producto_categoria'] ?? '',
              productoDescripcion: datosChat['producto_descripcion'] ?? '',
              productoDireccion: datosChat['producto_direccion'] ?? '',
              fotoPerfil: datosChat['otro_usuario_foto'] ?? '',
              productoImagenesReales: datosChat['producto_imagenes_reales'] ?? '',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _mensajeEstado = 'Error en reconocimiento: $e';
      });
    }
  }


  Future<bool> _validarCaraCentrada(Uint8List imageBytes) async {
    debugPrint('>>> >>> Entré a _validarCaraCentrada');
    try {
      // 🔥 Guardar en archivo temporal para que ML Kit lea el formato real (JPEG)
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/selfie_temp.jpg');
      await tempFile.writeAsBytes(imageBytes);
      final inputImage = mlkit.InputImage.fromFilePath(tempFile.path);

      final faceDetector = mlkit.FaceDetector(
        options: mlkit.FaceDetectorOptions(performanceMode: mlkit.FaceDetectorMode.fast),
      );

      debugPrint('>>> Procesando imagen con ML Kit...');
      final faces = await faceDetector.processImage(inputImage);
      await faceDetector.close();
      debugPrint('>>> Caras detectadas: ${faces.length}');

      if (faces.isEmpty) {
        debugPrint('>>> Sin caras, retornando false');
        return false;
      }

      final boundingBox = faces.first.boundingBox;
      final imageCenterX = 300.0;
      final imageCenterY = 400.0;
      final toleranceX = 120.0;
      final toleranceY = 160.0;

      final distanciaX = (boundingBox.center.dx - imageCenterX).abs();
      final distanciaY = (boundingBox.center.dy - imageCenterY).abs();
      debugPrint('>>> boundingBox center: ${boundingBox.center}');
      debugPrint('>>> distanciaX: $distanciaX (tolerance: $toleranceX)');
      debugPrint('>>> distanciaY: $distanciaY (tolerance: $toleranceY)');

      final resultado = distanciaX < toleranceX && distanciaY < toleranceY;
      debugPrint('>>> resultado: $resultado');
      return resultado;
    } catch (e) {
      debugPrint('>>> ❌ Error en _validarCaraCentrada: $e');
      return true;
    }
  }

  // 🔥 OBTENER DATOS COMPLETOS PARA ABRIR EL CHAT
  Future<Map<String, dynamic>?> _obtenerDatosParaChat() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final r = await http.get(
        Uri.parse(
            '$_baseUrl/api/encuentro/${widget.encuentroId}/datos?usuario_id=${user.uid}'),
      );
      if (r.statusCode != 200) return null;

      return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('>>> Error obteniendo datos para chat: $e');
      return null;
    }
  }

  // 🔥 OBTENER FOTO DE PERFIL DEL OTRO USUARIO
  Future<String?> _obtenerFotoPerfilOtroUsuario() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final r = await http.get(
        Uri.parse('$_baseUrl/api/encuentro/${widget.encuentroId}/datos?usuario_id=${user.uid}'),
      );
      if (r.statusCode != 200) return null;

      final data = jsonDecode(r.body) as Map<String, dynamic>;
      return data['otro_usuario_foto'] as String?;
    } catch (e) {
      print('>>> Error obteniendo foto de perfil: $e');
      return null;
    }
  }

  Future<void> _consultarEstado() async {
    try {
      final r = await http.get(
        Uri.parse('$_baseUrl/api/encuentro/${widget.encuentroId}/estado'),
      );
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body) as Map<String, dynamic>;

        setState(() {
          _ambosPresentes = data['ambos_presentes'] == true;
          if (_ambosPresentes) {
            _mensajeEstado = '✅ Ambos están presentes. Chat desbloqueado.';
          }
        });
      }
    } catch (_) {}
  }

  void _empezarPolling() {
    _polling?.cancel();
    _polling = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _consultarEstado();
      if (_ambosPresentes) {
        _polling?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación del encuentro'),
        backgroundColor: const Color(0xFF087FE8),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: _cargando
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(_mensajeEstado, textAlign: TextAlign.center),
                  ],
                )
              : _error != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 64),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _iniciar,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    )
                  : _construirContenido(),
        ),
      ),
    );
  }

  Widget _construirContenido() {
    // Si ambos están presentes
    if (_ambosPresentes) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 96),
          const SizedBox(height: 16),
          const Text(
            '¡Ambos están presentes!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'El chat ha sido desbloqueado.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check),
            label: const Text('Cerrar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
          ),
        ],
      );
    }

    // Si ya verifiqué pero el otro no
    if (_verificadoFacial) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          const Text(
            '✅ Tu identidad fue verificada',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Esperando a que la otra persona también verifique...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    // Si no estoy en el lugar
    if (!_enLugar) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, color: Colors.orange, size: 96),
          const SizedBox(height: 16),
          Text(
            'Estás a $_distanciaMetros m del lugar',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Acercate al punto de encuentro para continuar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _iniciar,
            icon: const Icon(Icons.refresh),
            label: const Text('Volver a verificar'),
          ),
        ],
      );
    }

    // Si estoy en el lugar y no verifiqué
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.location_on, color: Colors.green, size: 96),
        const SizedBox(height: 16),
        const Text(
          '✅ Estás en el lugar',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _encuentro?['lugar_nombre'] ?? '',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          onPressed: _verificarFacial,
          icon: const Icon(Icons.face),
          label: const Text('Iniciar reconocimiento facial'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF087FE8),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ],
    );
  }
}