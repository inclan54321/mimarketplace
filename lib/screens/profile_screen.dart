import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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

  static void agregarFavorito(Producto producto) {
    favoritos.add(producto);
  }

  static void eliminarFavorito(Producto producto) {
    favoritos.removeWhere((p) => p.nombre == producto.nombre);
  }

 @override
void initState() {
  super.initState();
  _cargarFotoPerfil();
  _cargarMisProductos();
  _cargarFavoritos();
  _cargarCalificaciones();
  _cargarMasVistos();
  _precargarImagenPerfil();
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
      Uri.parse('http://192.168.100.248:3000/api/estadisticas/usuario/${user.uid}/ranking'),
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
        Uri.parse('http://192.168.100.248:3000/api/perfil/foto'),
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
        Uri.parse('http://192.168.100.248:3000/api/favoritos/${user.uid}'),
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
        Uri.parse('http://192.168.100.248:3000/api/calificaciones/resumen/${user.uid}'),
      );
      if (resumenResponse.statusCode == 200) {
        final data = jsonDecode(resumenResponse.body);
        setState(() {
          _totalCalificaciones = data['total'] ?? 0;
          _promedioCalificaciones = (data['promedio'] ?? 0).toDouble();
        });
      }

      final califResponse = await http.get(
        Uri.parse('http://192.168.100.248:3000/api/calificaciones/${user.uid}'),
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
        Uri.parse('http://192.168.100.248:3000/api/productos/${producto.id}'),
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
      ? CachedNetworkImageProvider('http://192.168.100.248:3000${calif.calificadorFoto}')
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
      Uri.parse('http://192.168.100.248:3000/api/perfil/foto/${user.uid}'),
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
        CachedNetworkImageProvider('http://192.168.100.248:3000$_fotoPerfilUrl'),
        context,
      );
    } catch (e) {
      print('Error precargando imagen: $e');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    print('>>> BUILD - _fotoPerfilUrl: $_fotoPerfilUrl');
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
                            ? CachedNetworkImageProvider('http://192.168.100.248:3000$_fotoPerfilUrl')
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.blue.shade100,
                   backgroundImage: _fotoPerfilUrl != null && _fotoPerfilUrl!.isNotEmpty
    ? CachedNetworkImageProvider('http://192.168.100.248:3000$_fotoPerfilUrl')
    : null,
                    child: _fotoPerfilUrl == null || _fotoPerfilUrl!.isEmpty
                        ? Text(
                            user?.displayName?.isNotEmpty == true
                                ? user!.displayName![0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _seleccionarFotoPerfil,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 24,
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
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              user?.email ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),

            // 🔥 CALIFICACIONES 🔥
            GestureDetector(
              onTap: _mostrarDetalleCalificaciones,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(width: 6),
                    Text(
                      _promedioCalificaciones.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($_totalCalificaciones ${_totalCalificaciones == 1 ? 'calificación' : 'calificaciones'})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey.shade600,
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
        itemCount: _misProductos.length,
        itemBuilder: (context, index) {
          final producto = _misProductos[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: producto.imagenMiniatura != null && producto.imagenMiniatura!.isNotEmpty
                            ? 'http://192.168.100.248:3000${producto.imagenMiniatura}'
                            : 'http://192.168.100.248:3000${producto.imagenUrl}',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, size: 30, color: Colors.grey),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 40),
                      ),
                    )
                  : const Icon(Icons.inventory_2, color: Colors.blue, size: 40),
              title: Text(producto.nombre),
              subtitle: Text('₡${producto.precio} - ${producto.categoria}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blue),
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
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () async {
                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditarProductoScreen(
                            producto: producto,
                          ),
                        ),
                      );
                      if (resultado == true) {
                        await _invalidarCacheMisProductos();
                        _cargarMisProductos();
                      }
                    },
                    tooltip: 'Editar producto',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _eliminarProducto(producto);
                    },
                    tooltip: 'Eliminar producto',
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
        itemCount: _favoritosProductos.length,
        itemBuilder: (context, index) {
          final producto = _favoritosProductos[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: producto.imagenMiniatura != null && producto.imagenMiniatura!.isNotEmpty
                            ? 'http://192.168.100.248:3000${producto.imagenMiniatura}'
                            : 'http://192.168.100.248:3000${producto.imagenUrl}',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, size: 30, color: Colors.grey),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 40),
                      ),
                    )
                  : const Icon(Icons.inventory_2, color: Colors.blue, size: 40),
              title: Text(producto.nombre),
              subtitle: Text('₡${producto.precio} - ${producto.categoria}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blue),
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
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () async {
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;

                        final response = await http.delete(
                          Uri.parse('http://192.168.100.248:3000/api/favoritos'),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============ 🔥 CONSTRUIR MÁS VISTOS CON BARRAS HORIZONTALES ============
   // ============ 🔥 CONSTRUIR MÁS VISTOS CON BARRAS HORIZONTALES ============
  Widget _buildMasVistos() {
    if (_isLoadingMasVistos) {
      return const Center(child: CircularProgressIndicator());
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

    // 🔥 ORDENAR DE MÁS VISTO A MENOS VISTO
    final productosOrdenados = List<Producto>.from(_productosMasVistos)
      ..sort((a, b) => (b.vistas ?? 0).compareTo(a.vistas ?? 0));

    final maxVistas = productosOrdenados.isNotEmpty
        ? (productosOrdenados.first.vistas ?? 1)
        : 1;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: productosOrdenados.length,
      itemBuilder: (context, index) {
        final producto = productosOrdenados[index];
        final vistas = producto.vistas ?? 0;
        final porcentaje = maxVistas > 0 ? vistas / maxVistas : 0.0;

        // Colores para las barras según posición
        final Color barColor;
        if (index == 0) {
          barColor = Colors.amber.shade700;
        } else if (index == 1) {
          barColor = Colors.grey.shade600;
        } else if (index == 2) {
          barColor = Colors.brown.shade500;
        } else {
          barColor = Colors.blue.shade400;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: InkWell(
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
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                // 🔥 NÚMERO DE VISTAS A LA IZQUIERDA
                SizedBox(
                  width: 50,
                  child: Text(
                    '$vistas',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 8),
                // 🔥 BARRA HORIZONTAL
                Expanded(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Stack(
                      children: [
                        // Barra de progreso
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.6 * porcentaje,
                            height: 30,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  barColor.withOpacity(0.7),
                                  barColor,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        // Nombre del producto dentro de la barra
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              // Posición (medalla o número)
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: index < 3 ? Colors.white : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    index == 0 ? '🥇' : index == 1 ? '🥈' : index == 2 ? '🥉' : '${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  producto.nombre,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: porcentaje > 0.3 ? Colors.white : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
            ),
          ),
        );
      },
    );
  }
}