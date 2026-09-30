import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/producto_service.dart';
import '../models/producto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detalle_producto_screen.dart';
import '../models/calificacion.dart';
import 'editar_producto_screen.dart';
import 'terminos_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'editar_perfil_screen.dart';
import 'privacidad_screen.dart';
import 'soporte_screen.dart';

// ============================================================
// 🎨 ESTILOS VISUALES DEL PERFIL
// ============================================================
enum EstiloPerfil {
  atardecer,  // el actual (montañas + sol + rayos)
  galaxia,    // estrellas + nebulosas
  oceano,     // olas + luna
  volcan,     // lava + humo
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;
  String? _fotoPerfilUrl;
  List<Producto> _misProductos = [];
  List<Producto> _favoritosProductos = [];
  List<Producto> _productosMasVistos = [];
  bool _isLoading = true;
  bool _isLoadingMasVistos = false;
  String? _errorMasVistos;
  static List<Producto> favoritos = [];
  
  // 🔥 NUEVAS VARIABLES PARA CALIFICACIONES 🔥
  double _promedioCalificaciones = 0;
  int _totalCalificaciones = 0;
  List<Calificacion> _calificaciones = [];
  bool _cargandoCalificaciones = false;
  
  // 🎨 Estilo visual actual
  EstiloPerfil _estiloActual = EstiloPerfil.atardecer;

  static void agregarFavorito(Producto producto) {
    favoritos.add(producto);
  }

  static void eliminarFavorito(Producto producto) {
    favoritos.removeWhere((p) => p.nombre == producto.nombre);
  }

 @override
void initState() {
  super.initState();
  _cargarEstiloGuardado();
  _cargarFotoPerfil();
  _cargarMisProductos();
  _cargarFavoritos();
  _cargarCalificaciones();
  _cargarMasVistos();
  _precargarImagenPerfil();
}

// 🎨 Cargar estilo guardado
Future<void> _cargarEstiloGuardado() async {
  final prefs = await SharedPreferences.getInstance();
  final estiloStr = prefs.getString('estilo_perfil') ?? 'atardecer';
  final estilo = EstiloPerfil.values.firstWhere(
    (e) => e.name == estiloStr,
    orElse: () => EstiloPerfil.atardecer,
  );
  if (mounted) {
    setState(() {
      _estiloActual = estilo;
    });
  }
}

// 🎨 Guardar estilo elegido
Future<void> _guardarEstilo(EstiloPerfil estilo) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('estilo_perfil', estilo.name);
}

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _cargarMisProductos();
  _cargarFavoritos();
}

 // ============ 🔥 CARGAR PRODUCTOS MÁS VISTOS ============
Future<void> _cargarMasVistos() async {
  setState(() => _isLoadingMasVistos = true);
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoadingMasVistos = false;
        _errorMasVistos = 'Debes iniciar sesión';
      });
      return;
    }

    final response = await http.get(
      Uri.parse('https://mimarketplace-production.up.railway.app/api/estadisticas/usuario/${user.uid}/ranking'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        _productosMasVistos = data.map((item) => Producto(
          id: int.tryParse(item['id']?.toString() ?? '0') ?? 0,
          nombre: item['nombre'] ?? 'Sin nombre',
          categoria: '',
          precio: double.tryParse(item['precio']?.toString() ?? '0') ?? 0.0,
          imagenUrl: item['imagen_url'] ?? '',
          descripcion: '',
          direccion: '',
          vendedorNombre: item['vendedor_nombre'] ?? '',
          vendedorFoto: '',
          vendedorId: '',
          provincia: '',
          imagenDestacada: '',
          imagenesReales: '',
          likes: 0,
          vistas: int.tryParse(item['total_vistas']?.toString() ?? '0') ?? 0,
        )).toList();
        _isLoadingMasVistos = false;
        _errorMasVistos = null;
      });
    } else {
      setState(() {
        _errorMasVistos = 'Error al cargar los datos (${response.statusCode})';
        _isLoadingMasVistos = false;
      });
    }
  } catch (e) {
    setState(() {
      _errorMasVistos = 'Error: $e';
      _isLoadingMasVistos = false;
    });
  }
}

  Future<void> _seleccionarFotoPerfil() async {
    print('>>> Seleccionando foto de perfil');
    final picker = ImagePicker();
    final imagen = await picker.pickImage(
  source: ImageSource.gallery,
  maxWidth: 200,   // ✅ REDUCIR TAMAÑO
  maxHeight: 200,  // ✅ REDUCIR TAMAÑO
  imageQuality: 75, // ✅ COMPRIMIR
);
    if (imagen == null) {
      print('>>> No se seleccionó imagen');
      return;
    }

    print('>>> Imagen seleccionada: ${imagen.path}');
    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://mimarketplace-production.up.railway.app/api/perfil/foto'),
      );
      
      request.fields['uid'] = FirebaseAuth.instance.currentUser!.uid;
      request.files.add(await http.MultipartFile.fromPath('foto', imagen.path));
      
      print('>>> Enviando petición...');
      final response = await request.send();
      print('>>> Status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        final json = jsonDecode(data);
        
        // Guardar en caché local
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('foto_perfil', json['fotoUrl']);
        
        setState(() {
          _fotoPerfilUrl = json['fotoUrl'];
          _isLoading = false;
        });
      } else {
        throw Exception('Error al subir foto: ${response.statusCode}');
      }
    } catch (e) {
      print('>>> EXCEPCIÓN: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ============ 🔥 CARGAR MIS PRODUCTOS CON CACHÉ ============
  Future<void> _cargarMisProductos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'mis_productos_${user.uid}';

    // ✅ 1. MOSTRAR CACHÉ PRIMERO (RÁPIDO)
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        final List data = jsonDecode(cached);
        setState(() {
          _misProductos = data.map((json) => Producto.fromJson(json)).toList();
          _isLoading = false;
        });
        print('>>> PRODUCTOS CARGADOS DESDE CACHÉ: ${_misProductos.length}');
      } catch (e) {
        print('Error al leer caché: $e');
      }
    }

    // ✅ 2. CARGAR DEL SERVIDOR EN SEGUNDO PLANO (ACTUALIZAR)
    try {
      print('>>> CARGANDO PRODUCTOS DEL VENDEDOR: ${user.uid}');
      final productos = await ProductoService().getProductosByVendedor(user.uid);
      print('>>> PRODUCTOS ENCONTRADOS: ${productos.length}');
      
      // Guardar en caché
      final productosJson = jsonEncode(productos.map((p) => p.toJson()).toList());
      await prefs.setString(cacheKey, productosJson);
      
      setState(() {
        _misProductos = productos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar productos: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ============ 🔥 CARGAR FAVORITOS CON CACHÉ ============
  Future<void> _cargarFavoritos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'favoritos_${user.uid}';

    // ✅ 1. MOSTRAR CACHÉ PRIMERO (RÁPIDO)
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        final List data = jsonDecode(cached);
        setState(() {
          _favoritosProductos = data.map((json) => Producto.fromJson(json)).toList();
        });
        print('>>> FAVORITOS CARGADOS DESDE CACHÉ: ${_favoritosProductos.length}');
      } catch (e) {
        print('Error al leer caché de favoritos: $e');
      }
    }

    // ✅ 2. CARGAR DEL SERVIDOR EN SEGUNDO PLANO (ACTUALIZAR)
    try {
      final response = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/favoritos/${user.uid}'),
      );
      print('Status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print('Cantidad de favoritos: ${data.length}');
        
        // Guardar en caché
        await prefs.setString(cacheKey, response.body);
        
        setState(() {
          _favoritosProductos = data.map((json) => Producto.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error al cargar favoritos: $e');
    }
  }

  // ============ 🔥 INVALIDAR CACHÉ AL EDITAR ============
  Future<void> _invalidarCacheMisProductos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mis_productos_${user.uid}');
    print('>>> CACHÉ DE MIS PRODUCTOS INVALIDADO');
  }

  // ============ 🔥 INVALIDAR CACHÉ DE FAVORITOS ============
  Future<void> _invalidarCacheFavoritos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('favoritos_${user.uid}');
    print('>>> CACHÉ DE FAVORITOS INVALIDADO');
  }

  Future<void> _cargarCalificaciones() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _cargandoCalificaciones = true);

    try {
      final resumenResponse = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/calificaciones/resumen/${user.uid}'),
      );
      if (resumenResponse.statusCode == 200) {
        final data = jsonDecode(resumenResponse.body);
        setState(() {
          _totalCalificaciones = data['total'] ?? 0;
          _promedioCalificaciones = (data['promedio'] ?? 0).toDouble();
        });
      }

      final califResponse = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/calificaciones/${user.uid}'),
      );
      if (califResponse.statusCode == 200) {
        final List data = jsonDecode(califResponse.body);
        setState(() {
          _calificaciones = data.map((json) => Calificacion.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error al cargar calificaciones: $e');
    } finally {
      setState(() => _cargandoCalificaciones = false);
    }
  }

  // ============ 🔥 ELIMINAR PRODUCTO ============
  Future<void> _eliminarProducto(Producto producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⚠️ Eliminar producto'),
          content: Text(
            '¿Estás seguro de que quieres eliminar "${producto.nombre}"?\n\nEsta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      print('>>> ID DEL PRODUCTO A ELIMINAR: ${producto.id}');
      final response = await http.delete(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/productos/${producto.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'vendedor_id': user.uid,
        }),
      );

      if (response.statusCode == 200) {
        // ✅ INVALIDAR CACHÉ AL ELIMINAR
        await _invalidarCacheMisProductos();
        
        setState(() {
          _misProductos.removeWhere((p) => p.id == producto.id);
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ "${producto.nombre}" eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Error al eliminar producto');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarDetalleCalificaciones() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        _promedioCalificaciones.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($_totalCalificaciones ${_totalCalificaciones == 1 ? 'calificación' : 'calificaciones'})',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  Expanded(
                    child: _calificaciones.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay calificaciones aún',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _calificaciones.length,
                            itemBuilder: (context, index) {
                              final calif = _calificaciones[index];
                              return ListTile(
                               leading: CircleAvatar(
  backgroundColor: Colors.blue.shade100,
  backgroundImage: calif.calificadorFoto != null && calif.calificadorFoto!.isNotEmpty
      ? CachedNetworkImageProvider('https://mimarketplace-production.up.railway.app${calif.calificadorFoto}')
      : null,
  child: calif.calificadorFoto == null || calif.calificadorFoto!.isEmpty
      ? Text(calif.calificadorNombre?.isNotEmpty == true ? calif.calificadorNombre![0].toUpperCase() : '?')
      : null,
),
                                title: Text(calif.calificadorNombre ?? 'Usuario'),
                                subtitle: Text(calif.comentario.isNotEmpty ? calif.comentario : 'Sin comentario'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < calif.puntuacion ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

Future<void> _cargarFotoPerfil() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final prefs = await SharedPreferences.getInstance();
  final cachedFoto = prefs.getString('foto_perfil');
  
  if (cachedFoto != null && cachedFoto.isNotEmpty) {
    setState(() {
      _fotoPerfilUrl = cachedFoto;
    });
    return;
  }

  try {
    final response = await http.get(
      Uri.parse('https://mimarketplace-production.up.railway.app/api/perfil/foto/${user.uid}'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['foto_perfil'] != null && data['foto_perfil'].isNotEmpty) {
        await prefs.setString('foto_perfil', data['foto_perfil']);
        setState(() {
          _fotoPerfilUrl = data['foto_perfil'];
        });
      }
    }
  } catch (e) {}
}

Future<void> _precargarImagenPerfil() async {
  if (_fotoPerfilUrl != null && _fotoPerfilUrl!.isNotEmpty) {
    try {
      await precacheImage(
        CachedNetworkImageProvider('https://mimarketplace-production.up.railway.app$_fotoPerfilUrl'),
        context,
      );
    } catch (e) {
      print('Error precargando imagen: $e');
    }
  }
}

  // ============================================================
  // 🎨 SELECTOR DE ESTILO VISUAL (BOTTOM SHEET)
  // ============================================================
  void _mostrarSelectorEstilo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F2447),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '🎨 Estilo visual del perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Elige el fondo que más te guste',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              // Opciones
              _buildOpcionEstilo(
                EstiloPerfil.atardecer,
                'Atardecer',
                'Sol y montañas con rayos',
                Icons.wb_twilight,
                const Color(0xFFFFB347),
              ),
              _buildOpcionEstilo(
                EstiloPerfil.galaxia,
                'Galaxia',
                'Estrellas y nebulosas',
                Icons.auto_awesome,
                const Color(0xFF8B5CF6),
              ),
              _buildOpcionEstilo(
                EstiloPerfil.oceano,
                'Océano',
                'Olas y luna llena',
                Icons.water,
                const Color(0xFF3B82F6),
              ),
              _buildOpcionEstilo(
                EstiloPerfil.volcan,
                'Volcán',
                'Lava y humo ardiente',
                Icons.local_fire_department,
                const Color(0xFFEF4444),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOpcionEstilo(
    EstiloPerfil estilo,
    String titulo,
    String subtitulo,
    IconData icono,
    Color color,
  ) {
    final isActive = _estiloActual == estilo;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () async {
          setState(() {
            _estiloActual = estilo;
          });
          await _guardarEstilo(estilo);
          if (!mounted) return;
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isActive
                ? color.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isActive
                  ? color
                  : Colors.white.withValues(alpha: 0.1),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.2),
                  border: Border.all(
                    color: color.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Icon(icono, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 Devuelve el painter según el estilo elegido
  CustomPainter _getPainterSegunEstilo() {
    switch (_estiloActual) {
      case EstiloPerfil.atardecer:
        return _MountainsPainter();
      case EstiloPerfil.galaxia:
        return _GalaxiaPainter();
      case EstiloPerfil.oceano:
        return _OceanoPainter();
      case EstiloPerfil.volcan:
        return _VolcanPainter();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('>>> BUILD - _fotoPerfilUrl: $_fotoPerfilUrl');
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F2447),
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Cambiar estilo visual',
            onPressed: _mostrarSelectorEstilo,
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage: _fotoPerfilUrl != null && _fotoPerfilUrl!.isNotEmpty
                            ? CachedNetworkImageProvider('https://mimarketplace-production.up.railway.app$_fotoPerfilUrl')
                            : null,
                        child: _fotoPerfilUrl == null || _fotoPerfilUrl!.isEmpty
                            ? Text(
                                user?.displayName?.isNotEmpty == true
                                    ? user!.displayName![0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user?.displayName ?? 'Usuario',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              user?.email ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar Perfil'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditarPerfilScreen(),
                  ),
                );
                if (result == true) {
                  // Recargar datos del perfil después de editar
                  _cargarFotoPerfil();
                  _cargarMisProductos();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('foto_perfil');
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sesión cerrada')),
                );
              },
            ),
            const Divider(),
            ListTile(
  leading: const Icon(Icons.lock),
  title: const Text('Privacidad y Seguridad'),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivacidadScreen(),
      ),
    );
  },
),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Soporte'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SoporteScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Términos de Servicio'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TerminosScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 🌄 CAPA 1: Fondo según el estilo elegido
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: ClipPath(
              clipper: _HeaderWaveClipper(),
              child: CustomPaint(
                painter: _getPainterSegunEstilo(),
                size: Size.infinite,
              ),
            ),
          ),
          
          // 📱 CAPA 2: Contenido principal (con scroll)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                  
                  // Avatar con doble borde (glow cyan + blanco interior)
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        // Glow cyan exterior
                        BoxShadow(
                          color: const Color(0xFF5EEAD4).withValues(alpha: 0.6),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF5EEAD4),
                            Color(0xFF3B82F6),
                            Color(0xFF1A56DB),
                          ],
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0F2447),
                        ),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: const Color(0xFF1E3A8A),
                          backgroundImage: _fotoPerfilUrl != null && _fotoPerfilUrl!.isNotEmpty
                              ? CachedNetworkImageProvider('https://mimarketplace-production.up.railway.app$_fotoPerfilUrl')
                              : null,
                          child: _fotoPerfilUrl == null || _fotoPerfilUrl!.isEmpty
                              ? Text(
                                  user?.displayName?.isNotEmpty == true
                                      ? user!.displayName![0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: _seleccionarFotoPerfil,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF3B82F6),
                              Color(0xFF1A56DB),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.displayName ?? 'Usuario',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              user?.email ?? '',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),

            // 🔥 CALIFICACIONES 🔥
            GestureDetector(
              onTap: _mostrarDetalleCalificaciones,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        final valor = _promedioCalificaciones;
                        if (index < valor.floor()) {
                          return const Icon(Icons.star, color: Colors.amber, size: 18);
                        } else if (index < valor.ceil() && valor % 1 != 0) {
                          return const Icon(Icons.star_half, color: Colors.amber, size: 18);
                        } else {
                          return const Icon(Icons.star_border, color: Colors.amber, size: 18);
                        }
                      }),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _promedioCalificaciones.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '($_totalCalificaciones ${_totalCalificaciones == 1 ? 'calificación' : 'calificaciones'})',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Divider(
              color: Colors.white.withValues(alpha: 0.15),
              thickness: 1,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabButton('Mis artículos', 0),
                _buildTabButton('Más vistos', 1),
                _buildTabButton('Favoritos', 2, onTap: () {
                  setState(() {
                    _selectedTab = 2;
                  });
                  _cargarFavoritos();
                }),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedTab == 0
                      ? _buildMisArticulos()
                      : _selectedTab == 1
                          ? _buildMasVistos()
                          : _selectedTab == 2
                              ? _buildFavoritos()
                              : Center(
                                  child: Text(
                                    _getTabContent(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
            ),
          ],
        ),
            ),
        ],
      ),
    );
  }

  // 🎨 Color principal según el estilo actual
  Color get _colorEstiloActual {
    switch (_estiloActual) {
      case EstiloPerfil.atardecer:
        return const Color(0xFFFFB347);
      case EstiloPerfil.galaxia:
        return const Color(0xFF8B5CF6);
      case EstiloPerfil.oceano:
        return const Color(0xFF3B82F6);
      case EstiloPerfil.volcan:
        return const Color(0xFFEF4444);
    }
  }

  // 🎨 Card con gradiente + borde + glow
  Widget _buildCardEstilizada({
    required Widget child,
    required EdgeInsets margin,
  }) {
    final color = _colorEstiloActual;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E3A6B).withValues(alpha: 0.9),
            const Color(0xFF0F2447).withValues(alpha: 0.95),
          ],
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTabButton(String title, int index, {VoidCallback? onTap}) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: onTap ?? () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  String _getTabContent() {
    switch (_selectedTab) {
      case 0:
        return 'Aquí aparecerán tus artículos publicados';
      case 1:
        return 'Aquí aparecerán los artículos más vistos';
      case 2:
        return 'Aquí aparecerán los artículos más valorados';
      default:
        return '';
    }
  }

  Widget _buildMisArticulos() {
    if (_misProductos.isEmpty) {
      return const Center(
        child: Text(
          'No has publicado ningún artículo',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _cargarMisProductos,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 20),
        itemCount: _misProductos.length,
        itemBuilder: (context, index) {
          final producto = _misProductos[index];
          return _buildCardEstilizada(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Imagen
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: producto.imagenUrl != null &&
                            producto.imagenUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: producto.imagenMiniatura != null &&
                                    producto.imagenMiniatura!.isNotEmpty
                                ? 'https://mimarketplace-production.up.railway.app${producto.imagenMiniatura}'
                                : 'https://mimarketplace-production.up.railway.app${producto.imagenUrl}',
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.image,
                                  size: 30, color: Colors.grey),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.broken_image,
                                  size: 30, color: Colors.grey),
                            ),
                          )
                        : Container(
                            width: 55,
                            height: 55,
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.inventory_2,
                                color: Colors.white54, size: 30),
                          ),
                  ),
                  const SizedBox(width: 14),

                  // Textos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          producto.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₡${producto.precio} • ${producto.categoria}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Botones
                  IconButton(
                    icon: Icon(Icons.visibility, color: _colorEstiloActual, size: 22),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleProductoScreen(
                            producto: producto,
                            onBloqueoCambiado: () {},
                          ),
                        ),
                      );
                    },
                    tooltip: 'Ver producto',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit,
                        color: Color(0xFFFFA726), size: 22),
                    onPressed: () async {
                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditarProductoScreen(producto: producto),
                        ),
                      );
                      if (resultado == true) {
                        await _invalidarCacheMisProductos();
                        _cargarMisProductos();
                      }
                    },
                    tooltip: 'Editar producto',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete,
                        color: Color(0xFFEF5350), size: 22),
                    onPressed: () {
                      _eliminarProducto(producto);
                    },
                    tooltip: 'Eliminar producto',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

   Widget _buildFavoritos() {
    if (_favoritosProductos.isEmpty) {
      return const Center(
        child: Text(
          'No tienes productos favoritos',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _cargarFavoritos,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 20),
        itemCount: _favoritosProductos.length,
        itemBuilder: (context, index) {
          final producto = _favoritosProductos[index];
          return _buildCardEstilizada(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Imagen
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: producto.imagenUrl != null &&
                            producto.imagenUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: producto.imagenMiniatura != null &&
                                    producto.imagenMiniatura!.isNotEmpty
                                ? 'https://mimarketplace-production.up.railway.app${producto.imagenMiniatura}'
                                : 'https://mimarketplace-production.up.railway.app${producto.imagenUrl}',
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.image,
                                  size: 30, color: Colors.grey),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.broken_image,
                                  size: 30, color: Colors.grey),
                            ),
                          )
                        : Container(
                            width: 55,
                            height: 55,
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.inventory_2,
                                color: Colors.white54, size: 30),
                          ),
                  ),
                  const SizedBox(width: 14),

                  // Textos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          producto.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₡${producto.precio} • ${producto.categoria}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Botones
                  IconButton(
                    icon: Icon(Icons.visibility, color: _colorEstiloActual, size: 22),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleProductoScreen(
                            producto: producto,
                          ),
                        ),
                      );
                    },
                    tooltip: 'Ver producto',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.favorite,
                        color: Color(0xFFEF5350), size: 22),
                    onPressed: () async {
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;

                        final response = await http.delete(
                          Uri.parse(
                              'https://mimarketplace-production.up.railway.app/api/favoritos'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'usuario_id': user.uid,
                            'producto_id': producto.id.toString(),
                          }),
                        );

                        if (response.statusCode == 200) {
                          await _invalidarCacheFavoritos();
                          setState(() {
                            _favoritosProductos.remove(producto);
                          });
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Eliminado de favoritos'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } else {
                          throw Exception('Error al eliminar favorito');
                        }
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

    // ============ 🔥 MÁS VISTOS - GRÁFICA DE BARRAS VERTICALES ============
  Widget _buildMasVistos() {
    if (_isLoadingMasVistos) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMasVistos != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMasVistos!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarMasVistos,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_productosMasVistos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No tienes productos publicados o no tienen vistas aún',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // 🔥 ORDENAR Y TOMAR TOP 5
    final productosOrdenados = List<Producto>.from(_productosMasVistos)
      ..sort((a, b) => (b.vistas ?? 0).compareTo(a.vistas ?? 0));
    final top5 = productosOrdenados.take(5).toList();

    final maxVistas = top5.isNotEmpty ? (top5.first.vistas ?? 1) : 1;

    // 🎨 Colores de las barras
    final List<List<Color>> coloresBarras = [
      [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
      [const Color(0xFF06B6D4), const Color(0xFF22D3EE)],
      [const Color(0xFF14B8A6), const Color(0xFF2DD4BF)],
      [const Color(0xFF10B981), const Color(0xFF34D399)],
      [const Color(0xFFFFD700), const Color(0xFFFFA500)],
    ];

    final List<String> medallas = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];

    // 🔥 ALTURA FIJA de las barras (independiente del espacio del padre)
    const double alturaMaxBarra = 160.0;
    const double alturaMinBarra = 60.0;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A6B),
            Color(0xFF0F2447),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(top5.length, (index) {
          final producto = top5[index];
          final vistas = producto.vistas ?? 0;
          final porcentaje = maxVistas > 0 ? vistas / maxVistas : 0.0;
          final alturaBarra = alturaMinBarra +
              (porcentaje * (alturaMaxBarra - alturaMinBarra));

          final List<Color> gradienteBarra = coloresBarras[
              (coloresBarras.length - top5.length + index)
                  .clamp(0, coloresBarras.length - 1)];

          return Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleProductoScreen(
                      producto: producto,
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 🏅 Medalla
                  Text(
                    medallas[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),

                  // 📊 Barra con altura FIJA en píxeles
                  Container(
                    width: 44,
                    height: alturaBarra,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: gradienteBarra,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                        bottom: Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gradienteBarra[0].withValues(alpha: 0.5),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatearVistas(vistas),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'vistas',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 📝 Nombre del producto
                  SizedBox(
                    height: 26,
                    child: Text(
                      producto.nombre,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // 🔢 Formatear vistas (1000 → 1K)
  String _formatearVistas(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}K';
    }
    return '$n';
  }
}
// ============================================================
// 🎨 WAVE CLIPPER - Curva inferior del header
// ============================================================
class _HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 30,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ============================================================
// 🏔️ MOUNTAINS PAINTER - Dibuja el cielo y las montañas
// ============================================================
class _MountainsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // ===== 1. CIELO CON GRADIENTE =====
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1E3A8A), // azul más oscuro arriba
          Color(0xFF3B82F6), // azul medio
          Color(0xFF60A5FA), // azul claro
          Color(0xFF93C5FD), // azul muy claro (cerca del horizonte)
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      skyPaint,
    );

    // ===== 2. MONTAÑAS LEJANAS (más claras, con neblina) =====
    _drawMountainRange(
      canvas,
      size,
      mountainCount: 4,
      baseHeight: height * 0.55,
      peakHeight: height * 0.35,
      color: const Color(0xFF93C5FD).withValues(alpha: 0.5),
      seed: 1,
    );

    // ===== 3. MONTAÑAS MEDIAS =====
    _drawMountainRange(
      canvas,
      size,
      mountainCount: 3,
      baseHeight: height * 0.68,
      peakHeight: height * 0.45,
      color: const Color(0xFF3B82F6).withValues(alpha: 0.7),
      seed: 2,
    );

    // ===== 4. MONTAÑAS CERCANAS (más oscuras) =====
    _drawMountainRange(
      canvas,
      size,
      mountainCount: 3,
      baseHeight: height * 0.82,
      peakHeight: height * 0.6,
      color: const Color(0xFF1E3A8A),
      seed: 3,
    );

    // ===== 5. CAPA FINAL QUE SE FUNDE CON EL FONDO OSCURO =====
    final bottomFadePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0F1A2E).withValues(alpha: 0),
          const Color(0xFF0F1A2E).withValues(alpha: 0.7),
          const Color(0xFF0F1A2E),
        ],
        stops: const [0.7, 0.9, 1.0],
      ).createShader(Rect.fromLTWH(0, height * 0.7, width, height * 0.3));

    canvas.drawRect(
      Rect.fromLTWH(0, height * 0.7, width, height * 0.3),
      bottomFadePaint,
    );

    // ===== 6. SOL CON RAYOS ELÉCTRICOS =====
    _drawElectricSun(canvas, size);

    // ===== 7. GLOW VERDE NEÓN EN EL PERÍMETRO DE LAS MONTAÑAS =====
    _drawNeonGlow(canvas, size);
  }

  // ===== Dibuja el sol con rayos eléctricos cayendo =====
  void _drawElectricSun(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 🌞 Posición del sol (esquina superior derecha)
    final sunCenter = Offset(width * 0.78, height * 0.18);
    final sunRadius = 25.0;

    // 🔥 RESPLANDOR EXTERIOR DEL SOL (halo suave grande)
    final outerGlow = Paint()
      ..color = const Color(0xFFFFB347).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(sunCenter, sunRadius * 2.2, outerGlow);

    // 🔥 RESPLANDOR INTERMEDIO
    final midGlow = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(sunCenter, sunRadius * 1.5, midGlow);

    // 🔥 CÍRCULO DEL SOL (con gradiente radial)
    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFFFFF0), // blanco cálido centro
          Color(0xFFFFD700), // dorado
          Color(0xFFFFA500), // naranja
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: sunRadius));

    canvas.drawCircle(sunCenter, sunRadius, sunPaint);

    // 🔥 RAYOS ELÉCTRICOS (varios cayendo hacia las montañas)
    _drawElectricBolt(
      canvas,
      size,
      start: sunCenter + Offset(-5, sunRadius - 5),
      end: Offset(width * 0.45, height * 0.75),
      seed: 100,
      intensity: 1.0,
    );

    _drawElectricBolt(
      canvas,
      size,
      start: sunCenter + Offset(5, sunRadius),
      end: Offset(width * 0.72, height * 0.7),
      seed: 200,
      intensity: 0.85,
    );

    _drawElectricBolt(
      canvas,
      size,
      start: sunCenter + Offset(-15, sunRadius - 10),
      end: Offset(width * 0.15, height * 0.72),
      seed: 300,
      intensity: 0.7,
    );

    _drawElectricBolt(
      canvas,
      size,
      start: sunCenter + Offset(15, sunRadius - 5),
      end: Offset(width * 0.95, height * 0.68),
      seed: 400,
      intensity: 0.75,
    );
  }

  // ===== Dibuja un rayo eléctrico tipo relámpago =====
  void _drawElectricBolt(
    Canvas canvas,
    Size size, {
    required Offset start,
    required Offset end,
    required int seed,
    required double intensity,
  }) {
    final random = _SeededRandom(seed);
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // 🔥 Puntos del rayo (zigzag)
    const segments = 14; // más segmentos = más zigzag
    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final baseX = start.dx + (end.dx - start.dx) * t;
      final baseY = start.dy + (end.dy - start.dy) * t;

      // 🔥 Desplazamiento perpendicular (zigzag)
      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      final length = math.sqrt(dx * dx + dy * dy); // sqrt del vector
      final perpX = -dy / length;
      final perpY = dx / length;

      // Amplitud del zigzag (más grande en el medio)
      final amplitude = (1 - (t - 0.5).abs() * 2) * 25 * intensity;
      final offset = (random.nextDouble() - 0.5) * 2 * amplitude;

      final x = baseX + perpX * offset;
      final y = baseY + perpY * offset;

      // 🔥 A veces hacemos un ángulo brusco (más realista)
      if (random.nextDouble() > 0.5) {
        // Punto normal
        path.lineTo(x, y);
      } else {
        // Punto con ángulo recto (más eléctrico)
        if ((i % 2) == 0) {
          path.lineTo(x, baseY);
          path.lineTo(x, y);
        } else {
          path.lineTo(baseX, y);
          path.lineTo(x, y);
        }
      }
    }

    // 🔥 CAPA 1: Glow exterior (naranja eléctrico, muy difuso)
    final glowOuter = Paint()
      ..color = const Color(0xFFFF6600).withValues(alpha: 0.7 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawPath(path, glowOuter);

    // 🔥 CAPA 2: Glow intermedio (amarillo, blur menor)
    final glowMid = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.9 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(path, glowMid);

    // 🔥 CAPA 3: Línea central brillante (blanco amarillento, sin blur)
    final core = Paint()
      ..color = const Color(0xFFFFFFF0).withValues(alpha: intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, core);
  }

  // ===== Dibuja el glow verde neón alrededor de las montañas =====
  void _drawNeonGlow(Canvas canvas, Size size) {
    // 🔥 Glow para las 4 capas de montañas
    _drawNeonGlowForRange(
      canvas,
      size,
      mountainCount: 4,
      baseHeight: 0.55,
      peakHeight: 0.35,
      seed: 1,
      alpha: 0.5, // Capa lejana: más sutil
      strokeWidth: 6,
      blurRadius: 8,
    );

    _drawNeonGlowForRange(
      canvas,
      size,
      mountainCount: 3,
      baseHeight: 0.68,
      peakHeight: 0.45,
      seed: 2,
      alpha: 0.7, // Capa media: intermedia
      strokeWidth: 8,
      blurRadius: 10,
    );

    _drawNeonGlowForRange(
      canvas,
      size,
      mountainCount: 3,
      baseHeight: 0.82,
      peakHeight: 0.6,
      seed: 3,
      alpha: 1.0, // Capa cercana: más intensa
      strokeWidth: 12,
      blurRadius: 15,
    );
  }

  // ===== Helper: dibuja glow para un rango de montañas =====
  void _drawNeonGlowForRange(
    Canvas canvas,
    Size size, {
    required int mountainCount,
    required double baseHeight,
    required double peakHeight,
    required int seed,
    required double alpha,
    required double strokeWidth,
    required double blurRadius,
  }) {
    final width = size.width;
    final height = size.height;
    final glowPath = Path();
    final random = _SeededRandom(seed);

    glowPath.moveTo(0, height * baseHeight);
    final segmentWidth = width / mountainCount;

    for (int i = 0; i < mountainCount; i++) {
      final startX = i * segmentWidth;
      final peakX = startX + segmentWidth * 0.5;
      final endX = startX + segmentWidth;
      final variation = random.nextDouble() * 0.15 - 0.075;
      final thisPeak = height * (peakHeight + peakHeight * variation);
      final thisBase = height * baseHeight;

      glowPath.quadraticBezierTo(
        startX + segmentWidth * 0.3,
        thisBase - (thisBase - thisPeak) * 0.6,
        peakX,
        thisPeak,
      );
      glowPath.quadraticBezierTo(
        peakX + segmentWidth * 0.2,
        thisBase - (thisBase - thisPeak) * 0.4,
        endX,
        thisBase - 5,
      );
    }

    // 🔥 CAPA 1: Resplandor difuso (blur grande)
    final glowPaint = Paint()
      ..color = const Color(0xFF39FF14).withValues(alpha: alpha * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);

    canvas.drawPath(glowPath, glowPaint);

    // 🔥 CAPA 2: Resplandor medio (blur pequeño)
    final glowPaint2 = Paint()
      ..color = const Color(0xFF39FF14).withValues(alpha: alpha * 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius * 0.3);

    canvas.drawPath(glowPath, glowPaint2);

    // 🔥 CAPA 3: Línea central brillante (sin blur)
    final corePaint = Paint()
      ..color = const Color(0xFF7FFFAA).withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(glowPath, corePaint);
  }

  // ===== Dibuja una "cordillera" de montañas =====
  void _drawMountainRange(
    Canvas canvas,
    Size size, {
    required int mountainCount,
    required double baseHeight,
    required double peakHeight,
    required Color color,
    required int seed,
  }) {
    final width = size.width;
    final path = Path();
    final random = _SeededRandom(seed);

    path.moveTo(0, size.height);
    path.lineTo(0, baseHeight);

    final segmentWidth = width / mountainCount;

    for (int i = 0; i < mountainCount; i++) {
      final startX = i * segmentWidth;
      final peakX = startX + segmentWidth * 0.5;
      final endX = startX + segmentWidth;
      
      // Variación aleatoria en la altura de cada pico
      final variation = random.nextDouble() * 0.15 - 0.075;
      final thisPeak = peakHeight + (peakHeight * variation);

      // Subida al pico
      path.quadraticBezierTo(
        startX + segmentWidth * 0.3,
        baseHeight - (baseHeight - thisPeak) * 0.6,
        peakX,
        thisPeak,
      );

      // Bajada del pico
      path.quadraticBezierTo(
        peakX + segmentWidth * 0.2,
        baseHeight - (baseHeight - thisPeak) * 0.4,
        endX,
        baseHeight - 5,
      );
    }

    path.lineTo(width, size.height);
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ===== Random con semilla para que las montañas no cambien en cada repintado =====
class _SeededRandom {
  int _seed;
  _SeededRandom(this._seed);

  double nextDouble() {
    _seed = (_seed * 9301 + 49297) % 233280;
    return _seed / 233280;
  }
}

// ============================================================
// 🌌 GALAXIA PAINTER - Estrellas + Nebulosas
// ============================================================
class _GalaxiaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 1. FONDO OSCURO ESPACIAL
    final fondo = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0A0520),
          Color(0xFF1A0B3E),
          Color(0xFF2D1B69),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), fondo);

    // 2. NEBULOSAS
    _drawNebulosa(canvas, Offset(width * 0.3, height * 0.25),
        width * 0.5, const Color(0xFF8B5CF6), 0.5);
    _drawNebulosa(canvas, Offset(width * 0.75, height * 0.4),
        width * 0.45, const Color(0xFFEC4899), 0.4);
    _drawNebulosa(canvas, Offset(width * 0.5, height * 0.7),
        width * 0.6, const Color(0xFF3B82F6), 0.3);

    // 3. ESTRELLAS
    final random = _SeededRandom(42);
    for (int i = 0; i < 150; i++) {
      final x = random.nextDouble() * width;
      final y = random.nextDouble() * height * 0.8;
      final radius = random.nextDouble() * 1.8 + 0.3;
      final opacity = random.nextDouble() * 0.7 + 0.3;

      final estrella = Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
      canvas.drawCircle(Offset(x, y), radius, estrella);
    }

    // 4. ESTRELLAS GRANDES CON GLOW
    final randomGlow = _SeededRandom(99);
    for (int i = 0; i < 8; i++) {
      final x = randomGlow.nextDouble() * width;
      final y = randomGlow.nextDouble() * height * 0.7;

      final glow = Paint()
        ..color = const Color(0xFF60A5FA).withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawCircle(Offset(x, y), 6, glow);

      final core = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(x, y), 2.5, core);
    }

    // 5. PLANETA PEQUEÑO
    final planetaCentro = Offset(width * 0.82, height * 0.15);
    final planetaPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFEC4899),
          Color(0xFF8B5CF6),
          Color(0xFF1A0B3E),
        ],
        stops: [0.0, 0.6, 1.0],
      ).createShader(
          Rect.fromCircle(center: planetaCentro, radius: 35));
    canvas.drawCircle(planetaCentro, 35, planetaPaint);

    final anillo = Paint()
      ..color = const Color(0xFFF472B6).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
      Rect.fromCenter(center: planetaCentro, width: 90, height: 20),
      anillo,
    );

    // 6. FADE FINAL
    final fade = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0F1A2E).withValues(alpha: 0),
          const Color(0xFF0F1A2E),
        ],
      ).createShader(
          Rect.fromLTWH(0, height * 0.7, width, height * 0.3));
    canvas.drawRect(
      Rect.fromLTWH(0, height * 0.7, width, height * 0.3),
      fade,
    );
  }

  void _drawNebulosa(Canvas canvas, Offset center, double radius,
      Color color, double alpha) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ============================================================
// 🔥 VOLCÁN PAINTER - Lava + Humo + Rayos rojos
// ============================================================
class _VolcanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 1. CIELO OSCURO CON TINTE ROJO
    final cielo = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1A0505),
          Color(0xFF2D0A0A),
          Color(0xFF4A1010),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), cielo);

    // 2. HUMO
    _drawHumo(canvas, Offset(width * 0.3, height * 0.15),
        width * 0.5, const Color(0xFF1A0505).withValues(alpha: 0.7));
    _drawHumo(canvas, Offset(width * 0.7, height * 0.2),
        width * 0.4, const Color(0xFF2D0A0A).withValues(alpha: 0.6));

    // 3. RESPLANDOR DE LAVA
    final lavaGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF6600).withValues(alpha: 0.6),
          const Color(0xFFFF6600).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(width * 0.5, height * 0.55),
          radius: width * 0.7));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), lavaGlow);

    // 4. MONTAÑAS VOLCÁNICAS
    _drawVolcan(canvas, size,
        baseY: 0.65,
        color: const Color(0xFF1A0505),
        peakHeight: 0.4,
        seed: 1);
    _drawVolcan(canvas, size,
        baseY: 0.82,
        color: const Color(0xFF0A0202),
        peakHeight: 0.6,
        seed: 2);

    // 5. LAVA CAYENDO
    _drawLava(canvas, size,
        startX: 0.5, startY: 0.42, endX: 0.3, endY: 0.85, seed: 10);
    _drawLava(canvas, size,
        startX: 0.52, startY: 0.45, endX: 0.68, endY: 0.88, seed: 20);
    _drawLava(canvas, size,
        startX: 0.48, startY: 0.48, endX: 0.5, endY: 0.9, seed: 30);

    // 6. CHISPAS DE LAVA
    final random = _SeededRandom(77);
    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * width;
      final y =
          height * 0.5 + random.nextDouble() * height * 0.45;
      final radius = random.nextDouble() * 2 + 0.5;

      final chispa = Paint()
        ..color = const Color(0xFFFFAA00).withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(x, y), radius, chispa);
    }

    // 7. FADE FINAL
    final fade = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0F1A2E).withValues(alpha: 0),
          const Color(0xFF0F1A2E),
        ],
      ).createShader(
          Rect.fromLTWH(0, height * 0.75, width, height * 0.25));
    canvas.drawRect(
      Rect.fromLTWH(0, height * 0.75, width, height * 0.25),
      fade,
    );
  }

  void _drawHumo(
      Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color,
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  void _drawVolcan(Canvas canvas, Size size,
      {required double baseY,
      required Color color,
      required double peakHeight,
      required int seed}) {
    final width = size.width;
    final height = size.height;
    final path = Path();
    final random = _SeededRandom(seed);

    path.moveTo(0, height);
    path.lineTo(0, height * baseY);
    final segmentWidth = width / 5;
    for (int i = 0; i < 5; i++) {
      final startX = i * segmentWidth;
      final endX = startX + segmentWidth;
      final variation = random.nextDouble() * 0.15 - 0.075;
      final peak = height * (peakHeight + peakHeight * variation);
      path.quadraticBezierTo(
          (startX + endX) / 2, peak, endX, height * baseY);
    }
    path.lineTo(width, height);
    path.close();

    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);
  }

  void _drawLava(Canvas canvas, Size size,
      {required double startX,
      required double startY,
      required double endX,
      required double endY,
      required int seed}) {
    final width = size.width;
    final height = size.height;
    final random = _SeededRandom(seed);

    final path = Path();
    path.moveTo(width * startX, height * startY);

    const segments = 8;
    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final x = width * (startX + (endX - startX) * t);
      final y = height * (startY + (endY - startY) * t);
      final offset = (random.nextDouble() - 0.5) * 15;
      path.lineTo(x + offset, y);
    }

    final glow = Paint()
      ..color = const Color(0xFFFF4400).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(path, glow);

    final core = Paint()
      ..color = const Color(0xFFFFCC00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, core);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ============================================================
// 🌊 OCÉANO PAINTER - Olas + Luna + Reflejo
// ============================================================
class _OceanoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 1. CIELO NOCTURNO
    final cielo = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0A1A3A),
          Color(0xFF1A3A6B),
          Color(0xFF2A5A8F),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), cielo);

    // 2. LUNA
    final lunaCentro = Offset(width * 0.82, height * 0.18);
    final lunaGlow = Paint()
      ..color = const Color(0xFFE0E7FF).withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(lunaCentro, 60, lunaGlow);

    final lunaPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFE0E7FF),
          Color(0xFFC7D2FE),
        ],
      ).createShader(Rect.fromCircle(center: lunaCentro, radius: 30));
    canvas.drawCircle(lunaCentro, 30, lunaPaint);

    // 3. OLAS
    _drawOla(canvas, size,
        baseY: 0.55,
        amplitude: 20,
        color: const Color(0xFF1E40AF).withValues(alpha: 0.6),
        seed: 1);
    _drawOla(canvas, size,
        baseY: 0.68,
        amplitude: 25,
        color: const Color(0xFF1E3A8A).withValues(alpha: 0.8),
        seed: 2);
    _drawOla(canvas, size,
        baseY: 0.82,
        amplitude: 30,
        color: const Color(0xFF0F2557),
        seed: 3);

    // 4. REFLEJO DE LUNA
    final reflejo = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFE0E7FF).withValues(alpha: 0.4),
          const Color(0xFFE0E7FF).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(
          lunaCentro.dx - 40, height * 0.55, 80, height * 0.4));
    canvas.drawRect(
      Rect.fromLTWH(
          lunaCentro.dx - 40, height * 0.55, 80, height * 0.4),
      reflejo,
    );

    // 5. FADE FINAL
    final fade = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0F1A2E).withValues(alpha: 0),
          const Color(0xFF0F1A2E),
        ],
      ).createShader(
          Rect.fromLTWH(0, height * 0.75, width, height * 0.25));
    canvas.drawRect(
      Rect.fromLTWH(0, height * 0.75, width, height * 0.25),
      fade,
    );
  }

  void _drawOla(Canvas canvas, Size size,
      {required double baseY,
      required double amplitude,
      required Color color,
      required int seed}) {
    final width = size.width;
    final height = size.height;
    final path = Path();
    final random = _SeededRandom(seed);

    path.moveTo(0, height * baseY);
    final segmentWidth = width / 6;
    for (int i = 0; i < 6; i++) {
      final startX = i * segmentWidth;
      final endX = startX + segmentWidth;
      final peak =
          height * baseY + (random.nextDouble() - 0.5) * amplitude;
      path.quadraticBezierTo(
          (startX + endX) / 2, peak, endX, height * baseY);
    }
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}