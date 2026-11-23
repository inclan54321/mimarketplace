import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'producto_form_screen.dart';
import '../widgets/rewarded_ad_prueba.dart';
import '../l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.agregarImagenes),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A56DB),
                Color(0xFF087FE8),
                Color(0xFF3B82F6),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFF8FAFC),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // IMAGEN DESTACADA + IA
              // ============================================================
              // ===== HEADER CON ÍCONO CIRCULAR =====
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1A56DB),
                          Color(0xFF3B82F6),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.imagenDestacada,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Text(
                  l10n.estaImagenApareceraPortada,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 🔥 ADVERTENCIA DE CALIDAD FOTOGRÁFICA
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.red.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.soloImagenesCalidadEstudio,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Selector de imagen
              GestureDetector(
                onTap: _enRevision ? null : _seleccionarImagenDestacada,
                child: Container(
                  width: double.infinity,
                  height: 130,
                  decoration: BoxDecoration(
                    color: _imagenDestacada != null
                        ? Colors.grey.shade200
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _enRevision
                          ? Colors.orange
                          : (_imagenDestacada != null
                              ? Colors.grey.shade300
                              : const Color(0xFF93C5FD)),
                      width: 1.5,
                    ),
                    image: _imagenDestacada != null
                        ? DecorationImage(
                            image: FileImage(File(_imagenDestacada!.path)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imagenDestacada == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 🔥 ÍCONO CIRCULAR CON GRADIENTE
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF3B82F6),
                                      Color(0xFF1A56DB),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_photo_alternate,
                                  size: 28,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.tocaParaSeleccionarImagen,
                                style: TextStyle(
                                  color: Color(0xFF1E40AF),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.formatosImagenPermitidos,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _enRevision
                          ? Container(
                              color: Colors.black.withValues(alpha: 0.3),
                              child: Center(
                                child: Text(
                                  l10n.enRevisionPuntos,
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
                    _enRevision ? l10n.enviadoARevision : '✅ ${_imagenDestacada!.name}',
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
      SnackBar(
        content: Text(l10n.debesIniciarSesion),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shield, size: 20),
                        const SizedBox(width: 8),
                        Text(l10n.enviarARevision)
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.imagenRevisadaIA,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],

              const SizedBox(height: 12),

              // ============================================================
              // IMÁGENES REALES (SEPARADO)
              // ============================================================
              Divider(
                color: Colors.grey.withValues(alpha: 0.2),
                thickness: 1,
              ),
              const SizedBox(height: 12),
              // ===== HEADER CON ÍCONO CIRCULAR =====
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1A56DB),
                          Color(0xFF3B82F6),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.imagenesRealesProducto,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 56),
                child: Text(
                  l10n.subeHasta4Fotos,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              const SizedBox(height: 4),

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
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF93C5FD),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add,
                              size: 32,
                              color: Color(0xFF3B82F6),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.agregar,
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color(0xFF1E40AF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
                        ? l10n.seleccionaAlMenos1Imagen
                        : l10n.siguienteConFlecha,
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
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 95,
    );
    if (imagen != null) {
      setState(() {
        _imagenDestacada = imagen;
      });
    }
  }

  Future<void> _seleccionarImagenReal() async {
    final l10n = AppLocalizations.of(context)!;
    // 🔥 LIMITAR A 4 IMÁGENES REALES
    if (_imagenesReales.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.maximo4ImagenesReales),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final imagen = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 95,
    );
    if (imagen != null) {
      setState(() {
        _imagenesReales.add(imagen);
      });
    }
  }

  Future<void> _generarImagenConIA() async {
    final l10n = AppLocalizations.of(context)!;
    print('>>> ENTRE A _generarImagenConIA');

    if (_descripcionIAController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.primeroSeleccionaImagen),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_imagenDestacada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.primeroSeleccionaImagen),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _generandoIA = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://mimarketplace-production.up.railway.app/api/mejorar-imagen-ia'),
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
          SnackBar(
            content: Text(l10n.imagenMejoradaCorrectamente),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(l10n.errorGenerarImagen);
      }
    } catch (e) {
      setState(() => _generandoIA = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorGenerico('$e')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
    Future<void> _enviarImagenARevision(String vendedorId) async {
  final l10n = AppLocalizations.of(context)!;
  print('>>> 1. ENTRE A _enviarImagenARevision');
  print('>>> 2. vendedorId: $vendedorId');
  
  if (_imagenDestacada == null) {
    print('>>> 3. NO HAY IMAGEN SELECCIONADA');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.primeroSeleccionaImagen),
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
      Uri.parse('https://mimarketplace-production.up.railway.app/api/revisar-imagen-destacada'),
    );

    // 🔥 Mandar el token de Firebase
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken != null) {
      request.headers['Authorization'] = 'Bearer $idToken';
    }
    print('>>> 5b. Token: ${idToken != null ? "SÍ" : "NO"}');

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
        _mensajeRevision = l10n.imagenEnviadaRevision;
        _generandoIA = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${data['mensaje'] ?? l10n.imagenEnviadaRevision}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print('>>> 12. ERROR: STATUS ${response.statusCode}');
      throw Exception(l10n.errorEnviarImagen('${response.statusCode}'));
    }
  } catch (e) {
    print('>>> 13. EXCEPCIÓN CAPTURADA: $e');
    setState(() => _generandoIA = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.errorGenerico('$e')),
        backgroundColor: Colors.red,
      ),
    );
  }
}
    // ============ 🔥 MOSTRAR POPUP DE ANUNCIO ============
  void _mostrarPopupAnuncio(String vendedorId) {
    final l10n = AppLocalizations.of(context)!;
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
                Text(
                  l10n.revisionDeImagen,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.tuImagenSeraEnviadaModeracion,
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
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.revisionPuedeTomar24Horas,
                          style: const TextStyle(fontSize: 13, color: Colors.orange),
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
                        child: Text(
                          l10n.cancelar,
                          style: const TextStyle(
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
                            children: [
                              const Icon(Icons.play_circle_filled, size: 18),
                              const SizedBox(width: 6),
                              Text(l10n.verAnuncioConEmoji),
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
  final l10n = AppLocalizations.of(context)!;
  if (!RewardedAdManager.isAdLoaded) {
    RewardedAdManager.loadRewardedAd();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.cargandoAnuncio),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  RewardedAdManager.showRewardedAd(
    onRewarded: () {
      print('>>> 🔥 onRewarded EJECUTADO ✅');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.anuncioCompletadoEnviandoImagen),
          backgroundColor: Colors.green,
        ),
      );
     _enviarImagenARevision(vendedorId);  // ✅ USAR vendedorId
    },
    onDismissed: () {
      print('>>> 🔥 onDismissed EJECUTADO ❌');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.debesVerAnuncioParaEnviarImagen),
          backgroundColor: Colors.red,
        ),
      );
    },
  );
}
}