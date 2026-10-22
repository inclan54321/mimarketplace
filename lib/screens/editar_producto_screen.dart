import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart' hide PlayerState;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/producto.dart';

class EditarProductoScreen extends StatefulWidget {
  final Producto producto;

  const EditarProductoScreen({
    super.key,
    required this.producto,
  });

  @override
  State<EditarProductoScreen> createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _descripcionController;
  bool _guardando = false;
  XFile? _nuevaImagen;

  // 🔥 AUDIO
  FlutterSoundRecorder? _audioRecorder;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _audioPath;
  String? _audioRemotoUrl;
  Timer? _recordingTimer;
  String _recordingTime = '00:00';
  bool _audioGrabado = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.producto.nombre);
    _precioController =
        TextEditingController(text: widget.producto.precio.toString());
    _descripcionController =
        TextEditingController(text: widget.producto.descripcion ?? '');

    _audioRecorder = FlutterSoundRecorder();
    _audioRecorder!.openRecorder();
    _audioRemotoUrl = widget.producto.audioUrl ?? '';
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.gallery);
    if (imagen != null) {
      setState(() {
        _nuevaImagen = imagen;
      });
    }
  }

  // ============================================================
  // 🔥 AUDIO
  // ============================================================
  Future<void> _empezarGrabacion() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Se necesita permiso para grabar audio')),
        );
      }
      return;
    }

    if (_isRecording) return;

    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/audio_producto_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder?.startRecorder(
        toFile: path,
        codec: Codec.aacMP4,
      );

      setState(() {
        _isRecording = true;
        _recordingTime = '00:00';
        _audioGrabado = false;
        _audioPath = null;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final seg = timer.tick;
        final min = (seg / 60).floor();
        final rem = seg % 60;
        setState(() {
          _recordingTime =
              '${min.toString().padLeft(2, '0')}:${rem.toString().padLeft(2, '0')}';
        });
        if (seg >= 20) {
          _detenerGrabacion();
        }
      });
    } catch (e) {
      debugPrint('>>> ❌ Error al grabar: $e');
    }
  }

  Future<void> _detenerGrabacion() async {
    if (!_isRecording) return;

    _recordingTimer?.cancel();
    _recordingTimer = null;

    try {
      final path = await _audioRecorder?.stopRecorder();
      setState(() {
        _isRecording = false;
        _recordingTime = '00:00';
        if (path != null && path.isNotEmpty) {
          _audioPath = path;
          _audioGrabado = true;
        }
      });
      debugPrint('>>> 🎤 Audio grabado en: $path');
    } catch (e) {
      debugPrint('>>> ❌ Error al detener: $e');
      setState(() => _isRecording = false);
    }
  }

  Future<void> _reproducirAudioGrabado() async {
    if (_audioPath == null) return;
    try {
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(DeviceFileSource(_audioPath!));
      }
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('>>> ❌ Error al reproducir: $e');
    }
  }

  Future<void> _eliminarAudioGrabado() async {
    await _audioPlayer.stop();
    setState(() {
      _audioPath = null;
      _audioGrabado = false;
      _audioRemotoUrl = '';
    });
  }

  // ============================================================
  // 🔥 GUARDAR CAMBIOS
  // ============================================================
  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _guardando = false);
        return;
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/productos/${widget.producto.id}'),
      );

      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken != null) {
        request.headers['Authorization'] = 'Bearer $idToken';
      }
      print('>>> ✏️ Editar producto. Token: ${idToken != null ? "SÍ" : "NO"}');

      request.fields['nombre'] = _nombreController.text;
      request.fields['precio'] = _precioController.text;
      request.fields['descripcion'] = _descripcionController.text;
      request.fields['vendedor_id'] = user.uid;

      if (_nuevaImagen != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'imagen',
            _nuevaImagen!.path,
          ),
        );
      }

      // 🔥 Enviar audio si hay uno grabado
      if (_audioGrabado && _audioPath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'audio',
            _audioPath!,
          ),
        );
      }

      print('>>> Enviando actualización...');
      final response = await request.send();
      print('>>> ✏️ Respuesta: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        print('>>> Producto actualizado: ${data['mensaje']}');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Producto actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        final errBody = await response.stream.bytesToString();
        print('>>> ❌ Error body: $errBody');
        throw Exception('Error al actualizar producto (${response.statusCode})');
      }
    } catch (e) {
      print('>>> ❌ ERROR AL ACTUALIZAR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = 'https://mimarketplace-production.up.railway.app';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
        backgroundColor: const Color(0xFF087FE8),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  image: _nuevaImagen != null
                      ? DecorationImage(
                          image: FileImage(File(_nuevaImagen!.path)),
                          fit: BoxFit.cover,
                        )
                      : (widget.producto.imagenUrl != null &&
                              widget.producto.imagenUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(
                                  '$baseUrl${widget.producto.imagenUrl}'),
                              fit: BoxFit.cover,
                            )
                          : null),
                ),
                child: (widget.producto.imagenUrl == null ||
                            widget.producto.imagenUrl!.isEmpty) &&
                        _nuevaImagen == null
                    ? const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      )
                    : null,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _seleccionarImagen,
                icon: const Icon(Icons.photo_library),
                label: Text(_nuevaImagen != null
                    ? 'Cambiar imagen'
                    : 'Seleccionar nueva imagen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade700,
                ),
              ),
              if (_nuevaImagen != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '✅ ${_nuevaImagen!.name}',
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ),
              const SizedBox(height: 20),

              // 🔥 AUDIO
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.mic, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Audio del producto (máx 20s)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRecording
                          ? '🎤 Grabando... $_recordingTime / 00:20'
                          : (_audioGrabado
                              ? '✅ Audio listo para enviar'
                              : (_audioRemotoUrl != null &&
                                      _audioRemotoUrl!.isNotEmpty
                                  ? '✅ Ya tiene un audio guardado'
                                  : 'Sin audio')),
                      style: TextStyle(
                        fontSize: 12,
                        color: _isRecording ? Colors.red : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isRecording
                                ? _detenerGrabacion
                                : _empezarGrabacion,
                            icon: Icon(
                              _isRecording ? Icons.stop : Icons.mic,
                              size: 18,
                            ),
                            label: Text(_isRecording ? 'Detener' : 'Grabar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isRecording
                                  ? Colors.red
                                  : Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        if (_audioGrabado) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _reproducirAudioGrabado,
                            icon: const Icon(Icons.play_arrow,
                                color: Colors.blue),
                            tooltip: 'Escuchar',
                          ),
                          IconButton(
                            onPressed: _eliminarAudioGrabado,
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            tooltip: 'Eliminar',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el nombre del producto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(
                  labelText: 'Precio (₡)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el precio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardarCambios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF087FE8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Guardar Cambios',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioRecorder?.closeRecorder();
    _audioRecorder = null;
    _audioPlayer.dispose();
    _nombreController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}