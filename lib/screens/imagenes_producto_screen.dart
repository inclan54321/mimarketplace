import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'producto_form_screen.dart';
import '../widgets/rewarded_ad_prueba.dart';

class ImagenesProductoScreen extends StatefulWidget {
  final String categoria;
  final String subcategoria;
  final String direccion;

  const ImagenesProductoScreen({
    super.key,
    required this.categoria,
    required this.subcategoria,
    required this.direccion,
  });

  @override
  State<ImagenesProductoScreen> createState() => _ImagenesProductoScreenState();
}

class _ImagenesProductoScreenState extends State<ImagenesProductoScreen> {
  
   XFile? _imagenDestacada;
  final List<XFile> _imagenesReales = [];
  String? _imagenIAGenerada;
  bool _generandoIA = false;

  final TextEditingController _descripcionIAController = TextEditingController();
  bool _enRevision = false;  // ✅ NUEVO
  String? _mensajeRevision;  // ✅ NUEVO
    @override
  void initState() {
    super.initState();
    // 🔥 Cargar el anuncio recompensado al entrar
    RewardedAdManager.loadRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar imágenes'),
        backgroundColor: const Color(0xFF087FE8),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // IMAGEN DESTACADA + IA
              // ============================================================
              const Text(
                '🌟 Imagen Destacada',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Esta imagen aparecerá en la portada del producto y en la sección de destacados.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              // Selector de imagen
              GestureDetector(
                onTap: _enRevision ? null : _seleccionarImagenDestacada,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _enRevision ? Colors.orange : Colors.grey.shade400,
                      width: _enRevision ? 2 : 1,
                    ),
                    image: _imagenDestacada != null
                        ? DecorationImage(
                            image: FileImage(File(_imagenDestacada!.path)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imagenDestacada == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Toca para seleccionar una imagen',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : _enRevision
                          ? Container(
                              color: Colors.black.withOpacity(0.3),
                              child: const Center(
                                child: Text(
                                  '🔍 En revisión...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                ),
              ),
              if (_imagenDestacada != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _enRevision ? '🔄 Enviado a revisión' : '✅ ${_imagenDestacada!.name}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _enRevision ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
              if (_enRevision && _mensajeRevision != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _mensajeRevision!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // 🔥 BOTÓN ENVIAR A REVISIÓN
              if (_imagenDestacada != null && !_enRevision) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                   onPressed: () {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Debes iniciar sesión'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }
  print('>>> 🔥 BOTÓN ENVIAR A REVISIÓN PRESIONADO');
  print('>>> 🔥 VENDEDOR_ID: ${user.uid}');
  _mostrarPopupAnuncio(user.uid);  // ✅ ENVIAR UID DEL USUARIO
},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield, size: 20),
                        SizedBox(width: 8),
                        Text('🛡️ Enviar a revisión'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'La imagen será revisada por IA. Recibirás una notificación cuando sea aprobada.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],

              const SizedBox(height: 32),

              // ============================================================
              // IMÁGENES REALES (SEPARADO)
              // ============================================================
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                '📷 Imágenes Reales del Producto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sube hasta 4 fotos reales del producto (obligatorio)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (int i = 0; i < _imagenesReales.length; i++)
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(File(_imagenesReales[i].path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -8,
                          right: -8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _imagenesReales.removeAt(i);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (_imagenesReales.length < 4)
                    GestureDetector(
                      onTap: _seleccionarImagenReal,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: const Icon(Icons.add, size: 40, color: Colors.grey),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // ============================================================
              // BOTÓN SIGUIENTE
              // ============================================================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _imagenesReales.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductoFormScreen(
                                categoria: widget.categoria,
                                subcategoria: widget.subcategoria,
                                direccion: widget.direccion,
                                imagenDestacada: _imagenDestacada,
                                imagenesReales: _imagenesReales,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF087FE8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _imagenesReales.isEmpty
                        ? 'Selecciona al menos 1 imagen real'
                        : 'Siguiente →',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FUNCIONES
  // ============================================================

  Future<void> _seleccionarImagenDestacada() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (imagen != null) {
      setState(() {
        _imagenDestacada = imagen;
      });
    }
  }

  Future<void> _seleccionarImagenReal() async {
    // 🔥 LIMITAR A 4 IMÁGENES REALES
    if (_imagenesReales.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Solo puedes subir máximo 4 imágenes reales'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final imagen = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (imagen != null) {
      setState(() {
        _imagenesReales.add(imagen);
      });
    }
  }

  Future<void> _generarImagenConIA() async {
    print('>>> ENTRE A _generarImagenConIA');

    if (_descripcionIAController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe una descripción para mejorar la imagen'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_imagenDestacada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero selecciona una imagen'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _generandoIA = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.100.248:3000/api/mejorar-imagen-ia'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'imagen',
          _imagenDestacada!.path,
        ),
      );

      request.fields['prompt'] = _descripcionIAController.text;

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        final productoId = data['producto_id'];  // ✅ GUARDAR ESTO
        setState(() {
          _imagenIAGenerada = data['imagenUrl'];
          _generandoIA = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Imagen mejorada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Error al generar imagen');
      }
    } catch (e) {
      setState(() => _generandoIA = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
    Future<void> _enviarImagenARevision(String vendedorId) async {
  print('>>> 1. ENTRE A _enviarImagenARevision');
  print('>>> 2. vendedorId: $vendedorId');
  
  if (_imagenDestacada == null) {
    print('>>> 3. NO HAY IMAGEN SELECCIONADA');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Primero selecciona una imagen'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  print('>>> 4. IMAGEN SELECCIONADA: ${_imagenDestacada!.path}');
  setState(() => _generandoIA = true);

  try {
    print('>>> 5. CREANDO REQUEST MULTIPART');
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.100.248:3000/api/revisar-imagen-destacada'),
    );

    print('>>> 6. AGREGANDO ARCHIVO...');
    request.files.add(
      await http.MultipartFile.fromPath(
        'imagen',
        _imagenDestacada!.path,
      ),
    );

    request.fields['vendedor_id'] = vendedorId;
    print('>>> 7. ENVIANDO PETICIÓN AL SERVIDOR...');
    
    final response = await request.send();
    print('>>> 8. STATUS CODE: ${response.statusCode}');
    
    final responseData = await response.stream.bytesToString();
    print('>>> 9. RESPUESTA DEL SERVIDOR: $responseData');
    
    final data = jsonDecode(responseData);
    print('>>> 10. DATA DECODEADA: $data');

    if (response.statusCode == 200) {
      print('>>> 11. PETICIÓN EXITOSA ✅');
      setState(() {
        _enRevision = true;
        _mensajeRevision = '🔄 Imagen enviada a revisión. Recibirás una notificación cuando sea aprobada.';
        _generandoIA = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${data['mensaje'] ?? 'Imagen enviada a revisión'}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print('>>> 12. ERROR: STATUS ${response.statusCode}');
      throw Exception('Error al enviar imagen: ${response.statusCode}');
    }
  } catch (e) {
    print('>>> 13. EXCEPCIÓN CAPTURADA: $e');
    setState(() => _generandoIA = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
    // ============ 🔥 MOSTRAR POPUP DE ANUNCIO ============
  void _mostrarPopupAnuncio(String vendedorId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield,
                    size: 48,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '🛡️ Revisión de imagen',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tu imagen será enviada a nuestro equipo de moderación para su revisión. Para continuar, necesitas ver un breve anuncio.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'La revisión puede tomar hasta 24 horas.',
                          style: TextStyle(fontSize: 13, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
  Navigator.pop(context);
  _verAnuncioYGenerar(vendedorId);
},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.play_circle_filled, size: 18),
                              SizedBox(width: 6),
                              Text('Ver anuncio 🎬'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _verAnuncioYGenerar(String vendedorId) {
  if (!RewardedAdManager.isAdLoaded) {
    RewardedAdManager.loadRewardedAd();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⏳ Cargando anuncio... espera un momento'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  RewardedAdManager.showRewardedAd(
    onRewarded: () {
      print('>>> 🔥 onRewarded EJECUTADO ✅');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Anuncio completado. Enviando imagen a revisión...'),
          backgroundColor: Colors.green,
        ),
      );
     _enviarImagenARevision(vendedorId);  // ✅ USAR vendedorId
    },
    onDismissed: () {
      print('>>> 🔥 onDismissed EJECUTADO ❌');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Debes ver el anuncio completo para enviar la imagen'),
          backgroundColor: Colors.red,
        ),
      );
    },
  );
}
}