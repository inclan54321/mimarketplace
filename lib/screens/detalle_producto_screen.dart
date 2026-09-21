import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/producto.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'perfil_vendedor_screen.dart';


class DetalleProductoScreen extends StatefulWidget {
  final Producto producto;
  final VoidCallback? onBloqueoCambiado; // ✅ ESTE PARÁMETRO ES OBLIGATORIO

  const DetalleProductoScreen({
    super.key,
    required this.producto,
    this.onBloqueoCambiado, // ✅ ESTO VA AQUÍ
  });

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  bool _isFavorito = false;
  final String _usuarioId = FirebaseAuth.instance.currentUser?.uid ?? '';
  int _imagenActual = 0;
  late Producto _producto;

  @override
  void initState() {
    super.initState();
    _producto = widget.producto;
    _verificarFavorito();
  }

  Future<void> _verificarFavorito() async {
    try {
      final response = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/favoritos/$_usuarioId'),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final productoId = _producto.id.toString();
        setState(() {
          _isFavorito = data.any((p) => p['id'].toString() == productoId);
        });
      }
    } catch (e) {
      print('Error al verificar favorito: $e');
    }
  }

  Future<void> _toggleFavorito() async {
    final id = _producto.id.toString();

    if (_isFavorito) {
      final response = await http.delete(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/favoritos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': _usuarioId,
          'producto_id': id,
        }),
      );
      if (response.statusCode == 200) {
        setState(() => _isFavorito = false);
        _actualizarLikesManual();
      }
    } else {
      final response = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/favoritos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': _usuarioId,
          'producto_id': id,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => _isFavorito = true);
        _actualizarLikesManual();
      }
    }
  }

  void _actualizarLikesManual() {
    setState(() {
      _producto = Producto(
        id: _producto.id,
        nombre: _producto.nombre,
        categoria: _producto.categoria,
        precio: _producto.precio,
        imagenUrl: _producto.imagenUrl,
        descripcion: _producto.descripcion,
        direccion: _producto.direccion,
        vendedorNombre: _producto.vendedorNombre,
        vendedorFoto: _producto.vendedorFoto,
        vendedorId: _producto.vendedorId,
        provincia: _producto.provincia,
        imagenDestacada: _producto.imagenDestacada,
        imagenesReales: _producto.imagenesReales,
        likes: _isFavorito 
            ? _producto.likes + 1
            : _producto.likes - 1,
      );
    });
  }

  void _compartirProducto() {
    final String enlace = 'https://mimarketplace.com';
    Share.share(
      '📱 Mira este producto en MiMarketplace:\n\n$enlace',
    );
  }

  Future<bool> _verificarBloqueo(String vendedorId) async {
    try {
      final response = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/bloquear/verificar/$_usuarioId/$vendedorId'),
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
  try {
    print('>>> INICIO BLOQUEO - Vendedor: $vendedorId');
    print('>>> Usuario que bloquea: $_usuarioId');
    
    final response = await http.post(
      Uri.parse('https://mimarketplace-production.up.railway.app/api/bloquear'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuario_bloquea': _usuarioId,
        'usuario_bloqueado': vendedorId,
      }),
    );

    print('>>> STATUS CODE BLOQUEO: ${response.statusCode}');
    print('>>> RESPUESTA BLOQUEO: ${response.body}');

    if (response.statusCode == 201) {
      print('>>> BLOQUEO EXITOSO');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vendedor bloqueado correctamente. Reiniciando...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // ✅ NOTIFICAR AL HOME
      if (widget.onBloqueoCambiado != null) {
        print('>>> NOTIFICANDO A HOME');
        widget.onBloqueoCambiado!();
      }
      
      print('>>> ESPERANDO 1 SEGUNDO PARA REINICIAR');
      await Future.delayed(const Duration(seconds: 1));
      
      print('>>> REINICIANDO APP CON Phoenix.rebirth(context)');
      // 🔥 REINICIAR LA APP 🔥
      Phoenix.rebirth(context);
      
      // ⚠️ EL CÓDIGO DESPUÉS DE Phoenix.rebirth() NO SE EJECUTA
    } else {
      print('>>> ERROR EN BLOQUEO: ${response.statusCode}');
      final error = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error['error'] ?? 'Error al bloquear'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    print('>>> EXCEPCIÓN EN BLOQUEO: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error al bloquear usuario'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  Future<void> _desbloquearVendedor(String vendedorId) async {
  try {
    print('>>> INICIO DESBLOQUEO - Vendedor: $vendedorId');
    print('>>> Usuario que desbloquea: $_usuarioId');
    
    final response = await http.delete(
      Uri.parse('https://mimarketplace-production.up.railway.app/api/bloquear'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuario_bloquea': _usuarioId,
        'usuario_bloqueado': vendedorId,
      }),
    );

    print('>>> STATUS CODE DESBLOQUEO: ${response.statusCode}');
    print('>>> RESPUESTA DESBLOQUEO: ${response.body}');

    if (response.statusCode == 200) {
      print('>>> DESBLOQUEO EXITOSO');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vendedor desbloqueado correctamente. Reiniciando...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // ✅ NOTIFICAR AL HOME
      if (widget.onBloqueoCambiado != null) {
        print('>>> NOTIFICANDO A HOME');
        widget.onBloqueoCambiado!();
      }
      
      print('>>> ESPERANDO 1 SEGUNDO PARA REINICIAR');
      await Future.delayed(const Duration(seconds: 1));
      
      print('>>> REINICIANDO APP CON Phoenix.rebirth(context)');
      // 🔥 REINICIAR LA APP 🔥
      Phoenix.rebirth(context);
      
      // ⚠️ EL CÓDIGO DESPUÉS DE Phoenix.rebirth() NO SE EJECUTA
    } else {
      print('>>> ERROR EN DESBLOQUEO: ${response.statusCode}');
      final error = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error['error'] ?? 'Error al desbloquear'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    print('>>> EXCEPCIÓN EN DESBLOQUEO: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error al desbloquear usuario'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _mostrarOpcionesVendedor(BuildContext context) {
    final vendedorId = _producto.vendedorId ?? '';

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
                          ? 'Desbloquear a ${_producto.vendedorNombre ?? 'este vendedor'}'
                          : 'Bloquear a ${_producto.vendedorNombre ?? 'este vendedor'}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () async {
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
                      'Ver detalles de ${_producto.vendedorNombre ?? 'este vendedor'}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      print('>>> VER PERFIL: ${_producto.vendedorId}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PerfilVendedorScreen(
                            vendedorId: _producto.vendedorId ?? '',
                            vendedorNombre: _producto.vendedorNombre ?? 'Vendedor',
                            vendedorFoto: _producto.vendedorFoto,
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
                      'Ver todos los productos de ${_producto.vendedorNombre ?? 'este vendedor'}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      print('>>> VER PORTAFOLIO: ${_producto.vendedorId}');
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
                      'Reportar a ${_producto.vendedorNombre ?? 'este vendedor'} por incumplir las reglas',
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
        'denunciado_id': _producto.vendedorId,
        'producto_id': _producto.id,
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
  Future<String> _getUbicacion() async {
    print('>>> direccion: ${_producto.direccion}');
    if (_producto.direccion.isEmpty) return '';

    try {
      final latLng = _producto.direccion.split(',');
      if (latLng.length < 2) return '';

      final lat = latLng[0].replaceAll('Lat: ', '').trim();
      final lng = latLng[1].replaceAll('Lng: ', '').trim();

      final response = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/geocode/$lat/$lng'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['provincia'].isNotEmpty && data['canton'].isNotEmpty) {
          return '${data['provincia']}, ${data['canton']}';
        }
      }
      return '';
    } catch (e) {
      print('Error al obtener ubicación: $e');
      return '';
    }
  }

  Widget _buildImageCarousel() {
  List<String> imagenes = [];
  final baseUrl = 'https://mimarketplace-production.up.railway.app';

  if (_producto.imagenUrl != null && _producto.imagenUrl!.isNotEmpty) {
    imagenes.add(_producto.imagenUrl!);
  }

  if (_producto.imagenDestacada != null && _producto.imagenDestacada!.isNotEmpty) {
    imagenes.add(_producto.imagenDestacada!);
  }

  if (_producto.imagenesReales != null && _producto.imagenesReales!.isNotEmpty) {
    try {
      List<dynamic> reales = jsonDecode(_producto.imagenesReales!);
      for (var img in reales) {
        if (img.toString().isNotEmpty) {
          imagenes.add(img.toString());
        }
      }
    } catch (e) {
      print('Error al parsear imagenes reales: $e');
    }
  }

  if (imagenes.isEmpty) {
    return const Center(
      child: Icon(Icons.image, size: 80, color: Colors.grey),
    );
  }

  return Stack(
    children: [
      // Imagen Principal ajustada a BoxFit.contain para no forzar zoom gigante
      Positioned.fill(
        child: PageView.builder(
          itemCount: imagenes.length,
          onPageChanged: (index) {
            setState(() {
              _imagenActual = index;
            });
          },
          itemBuilder: (context, index) {
            return CachedNetworkImage(
  imageUrl: '$baseUrl${imagenes[index]}',
  fit: BoxFit.contain,
  placeholder: (context, url) => const Center(
    child: CircularProgressIndicator(color: Colors.white),
  ),
  errorWidget: (context, url, error) => const Center(
    child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
  ),
);
          },
        ),
      ),
      // Miniaturas superiores ajustadas en tamaño
      Positioned(
        top: 60,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  imagenes.length,
                  (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _imagenActual = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 40,  // Reducido de 50 a 40
                      height: 40, // Reducido de 50 a 40
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _imagenActual == index ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                        image: DecorationImage(
  image: CachedNetworkImageProvider('$baseUrl${imagenes[index]}'),
  fit: BoxFit.cover,
),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      if (imagenes.length > 1)
        Positioned(
          bottom: 200, // Ajustado para elevar el contador y no solaparse con los textos
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_imagenActual + 1} / ${imagenes.length}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    print('>>> DETALLE PRODUCTO - build ejecutado');
    print('>>> Producto: ${_producto.nombre}');
    print('>>> Vendedor ID: ${_producto.vendedorId}');
    print('>>> Vendedor Nombre: ${_producto.vendedorNombre}');
    print('>>> imagenUrl: ${_producto.imagenUrl}');
    print('>>> imagenDestacada: ${_producto.imagenDestacada}');
    print('>>> imagenesReales: ${_producto.imagenesReales}');
    print('>>> vendedorFoto en Detalle: ${_producto.vendedorFoto}');

    final baseUrl = 'https://mimarketplace-production.up.railway.app';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _buildImageCarousel(),
          ),
          Positioned(
            top: 60,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _producto.nombre,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₡${_producto.precio.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_producto.descripcion != null && _producto.descripcion.isNotEmpty)
                    Text(
                      _producto.descripcion,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.category, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _producto.categoria,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<String>(
                    future: _getUbicacion(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              snapshot.data!,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        print('>>> 1. INICIO - Contactar Vendedor presionado');
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          print('>>> 2. USUARIO NO LOGUEADO');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Debes iniciar sesión')),
                          );
                          return;
                        }
                        print('>>> 2. USUARIO LOGUEADO: ${user.uid}');
                        try {
                          print('>>> 3. PRODUCTO: ${_producto.nombre}');
                          print('>>> 4. IMAGEN URL: ${_producto.imagenUrl}');
                          final convResponse = await http.get(
                            Uri.parse('https://mimarketplace-production.up.railway.app/api/conversaciones/${user.uid}'),
                          );
                          if (convResponse.statusCode == 200) {
                            final List conversaciones = jsonDecode(convResponse.body);
                            final existing = conversaciones.firstWhere(
                              (c) => c['usuario2_id'] == _producto.vendedorId &&
                                  c['producto_id'].toString() == _producto.id.toString(),
                              orElse: () => null,
                            );
                            if (existing != null) {
                              print('>>> Conversación existente encontrada ID: ${existing['id']}');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    conversacionId: existing['id'].toString(),
                                    otroUsuario: _producto.vendedorNombre ?? 'Vendedor',
                                    otroUsuarioId: _producto.vendedorId ?? '',
                                    nombreProducto: _producto.nombre,
                                    productoImagen: _producto.imagenUrl ?? '',
                                    productoId: _producto.id.toString(),
                                    productoPrecio: _producto.precio.toString(),
                                    productoCategoria: _producto.categoria,
                                    productoDescripcion: _producto.descripcion,
                                    productoDireccion: _producto.direccion,
                                    productoImagenDestacada: _producto.imagenDestacada ?? '',
                                    productoImagenesReales: _producto.imagenesReales ?? '',
                                    fotoPerfil: _producto.vendedorFoto ?? '',
                                  ),
                                ),
                              );
                              return;
                            }
                          }
                          print('>>> No existe conversación, creando nueva...');
                          final response = await http.post(
                            Uri.parse('https://mimarketplace-production.up.railway.app/api/conversaciones'),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({
                              'usuario1_id': user.uid,
                              'usuario2_id': _producto.vendedorId ?? '',
                              'producto_id': _producto.id.toString(),
                              'producto_nombre': _producto.nombre,
                              'producto_imagen': _producto.imagenUrl ?? '',
                            }),
                          );
                          print('>>> 5. STATUS CODE: ${response.statusCode}');
                          print('>>> 6. RESPONSE BODY: ${response.body}');
                          if (response.statusCode == 201) {
                            final data = jsonDecode(response.body);
                            print('>>> 7. CONVERSACIÓN CREADA ID: ${data['id']}');
                            print('>>> 8. producto_imagen guardado: ${data['producto_imagen']}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  conversacionId: data['id'].toString(),
                                  otroUsuario: _producto.vendedorNombre ?? 'Vendedor',
                                  otroUsuarioId: _producto.vendedorId ?? '',
                                  nombreProducto: _producto.nombre,
                                  productoImagen: _producto.imagenUrl ?? '',
                                  productoId: _producto.id.toString(),
                                  productoPrecio: _producto.precio.toString(),
                                  productoCategoria: _producto.categoria,
                                  productoDescripcion: _producto.descripcion,
                                  productoDireccion: _producto.direccion,
                                  productoImagenDestacada: _producto.imagenDestacada ?? '',
                                  productoImagenesReales: _producto.imagenesReales ?? '',
                                  fotoPerfil: _producto.vendedorFoto ?? '',
                                ),
                              ),
                            );
                          } else {
                            print('>>> 9. ERROR: Status code ${response.statusCode}');
                            throw Exception('Error al crear conversación');
                          }
                        } catch (e) {
                          print('>>> 10. EXCEPCIÓN: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Contactar Vendedor'),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _mostrarOpcionesVendedor(context);
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey,
                      backgroundImage: _producto.vendedorFoto != null && _producto.vendedorFoto!.isNotEmpty
                          ? NetworkImage('$baseUrl${_producto.vendedorFoto}')
                          : null,
                      child: _producto.vendedorFoto == null || _producto.vendedorFoto!.isEmpty
                          ? const Icon(Icons.person, color: Colors.white, size: 28)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _producto.vendedorNombre ?? 'Vendedor',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isFavorito ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorito ? Colors.redAccent : Colors.white,
                          size: 40,
                        ),
                        onPressed: _toggleFavorito,
                      ),
                      Text(
                        _producto.likes > 1000
                            ? '${(_producto.likes / 1000).toStringAsFixed(1)}K'
                            : '${_producto.likes}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        key: ValueKey(_producto.likes),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _compartirProducto,
                    child: Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}