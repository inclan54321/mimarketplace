import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _conversaciones = [];
  List<Map<String, dynamic>> _agenda = [];
  bool _isLoading = true;
  List<String> _bloqueados = [];
  late TabController _tabController;

  // 🔍 Búsqueda en agenda
  final TextEditingController _busquedaAgendaController =
      TextEditingController();
  String _busquedaAgenda = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.animation!.addListener(() {
      if (mounted) setState(() {});
    });
    _cargarDatos();
    _cargarAgenda();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _busquedaAgendaController.dispose();
    super.dispose();
  }

  // ===== CARGAR DATOS =====
  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _cargarConversaciones(),
      _cargarBloqueados(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  // ===== CARGAR CONVERSACIONES =====
  Future<void> _cargarConversaciones() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final response = await http.get(
        Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/conversaciones/${user.uid}'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final todas =
            data.map((item) => Map<String, dynamic>.from(item)).toList();

        final conversacionesFiltradas = todas.where((chat) {
          final otroId = chat['usuario1_id'] == user.uid
              ? chat['usuario2_id']
              : chat['usuario1_id'];
          return !_bloqueados.contains(otroId);
        }).toList();

        if (mounted) {
          setState(() {
            _conversaciones = conversacionesFiltradas;
          });
        }
      }
    } catch (e) {
      print('Error al cargar conversaciones: $e');
    }
  }

  // ===== CARGAR BLOQUEADOS =====
  Future<void> _cargarBloqueados() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final response = await http.get(
        Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/bloquear/${user.uid}'),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _bloqueados =
                data.map((e) => e['usuario_bloqueado'].toString()).toList();
          });
        }
      }
    } catch (e) {
      print('Error al cargar bloqueados: $e');
    }
  }

  // ===== CARGAR AGENDA DESDE EL BACKEND =====
  Future<void> _cargarAgenda() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final response = await http.get(
        Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/agenda/${user.uid}'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _agenda = data
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
          });
        }
        print('>>> ✅ Agenda cargada: ${data.length} items');
        // 🔥 DEBUG: ver la estructura completa
        if (data.isNotEmpty) {
          final item = Map<String, dynamic>.from(data[0]);
          print('>>> 🔥 CAMPOS DEL ITEM: ${item.keys.toList()}');
          print('>>> 🔥 productos? ${item["productos"]}');
          print('>>> 🔥 productos_lista? ${item["productos_lista"]}');
          print('>>> 🔥 cantidad_productos? ${item["cantidad_productos"]}');
          print('>>> 🔥 producto_nombre? ${item["producto_nombre"]}');
        }
      }
    } catch (e) {
      print('Error al cargar agenda: $e');
    }
  }

  // ===== GUARDAR EN AGENDA (BACKEND) =====
  Future<void> _guardarEnAgenda(Map<String, dynamic> chat) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final otroUsuarioId = chat['otroUsuarioId']?.toString() ?? '';
      if (otroUsuarioId.isEmpty) return;

      // 🔥 Buscar TODAS las conversaciones con este vendedor
      final chatsDelVendedor = _conversaciones.where((c) {
        final usuario1 = c['usuario1_id'] ?? '';
        final usuario2 = c['usuario2_id'] ?? '';
        final otroId = usuario1 == user.uid ? usuario2 : usuario1;
        return otroId == otroUsuarioId;
      }).toList();

      // 🔥 Construir lista de productos sin duplicados
      final List<Map<String, dynamic>> productos = [];
      final Set<String> idsVistos = {};
      for (final c in chatsDelVendedor) {
        final productoId = c['producto_id']?.toString() ?? '';
        if (productoId.isEmpty || idsVistos.contains(productoId)) continue;
        idsVistos.add(productoId);

        productos.add({
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
        });
      }

      // 🔥 DEBUG: ver qué estamos enviando
      print('>>> 🔥 DATOS A ENVIAR:');
      print('>>> chat completo: $chat');
      print('>>> productos encontrados: $productos');
      print('>>> otroUsuarioId: $otroUsuarioId');
      print('>>> chatsDelVendedor.length: ${chatsDelVendedor.length}');

      // 🔥 Enviar al backend CON TODOS LOS PRODUCTOS
      final response = await http.post(
        Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/agenda'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': user.uid,
          'otro_usuario': chat['otroUsuario'] ?? 'Usuario',
          'producto_nombre': productos.isNotEmpty
              ? productos.map((p) => p['productoNombre']).join(', ')
              : 'Producto',
          'ultimo_mensaje': chat['ultimoMensaje'] ?? 'Sin mensajes',
          'producto_imagen': productos.isNotEmpty
              ? productos.first['productoImagen'] ?? ''
              : '',
          'conversacion_id': chat['conversacionId'] ?? '',
          'productos_lista': productos,              // 🔥 NUEVO
          'foto_perfil': chat['fotoPerfil'] ?? '',    // 🔥 NUEVO
        }),
      );

      print('>>> 🔥 STATUS: ${response.statusCode}');
      print('>>> 🔥 BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Recargar agenda desde el backend
        await _cargarAgenda();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Guardado (${productos.length} productos)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ===== ELIMINAR DE AGENDA (BACKEND) =====
  Future<void> _eliminarDeAgenda(dynamic id) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/agenda/$id'),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _agenda.removeWhere((item) => item['id'].toString() == id.toString());
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🗑️ Eliminado'),
              backgroundColor: Colors.grey,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      print('Error al eliminar: $e');
    }
  }

  // ===== ELIMINAR CHAT =====
  Future<void> _eliminarChat(String conversacionId, String nombreUsuario) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar chat'),
        content: Text('¿Estás seguro de borrar la conversación con $nombreUsuario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final response = await http.post(
          Uri.parse(
              'https://mimarketplace-production.up.railway.app/api/conversaciones/$conversacionId/ocultar'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'usuario_id': user.uid}),
        );

        if (response.statusCode == 200) {
          if (!mounted) return;
          setState(() {
            _conversaciones
                .removeWhere((c) => c['id'].toString() == conversacionId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('👁️ Chat oculto'),
                backgroundColor: Colors.grey),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: ClipPath(
          clipper: _BottomWaveClipper(),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F2A47),
                  Color(0xFF0A1929),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF3B82F6),
                                Color(0xFF1A56DB)
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6)
                                    .withValues(alpha: 0.6),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Mensajes',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Chatea con compradores y vendedores',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildTabChip('CHATS', 0),
                        const SizedBox(width: 6),
                        _buildTabChip('AGENDA', 1),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo_montanas.jpg',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.35),
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC0A1628),
                    Color(0xAA0F2447),
                    Color(0xEE0A1628),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 140),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabChats(user),
                      _buildTabAgenda(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ===== TAB CHIP =====
  Widget _buildTabChip(String label, int index) {
    final animValue = _tabController.animation?.value ?? 0.0;
    final isActive = animValue.round() == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1A56DB)],
                )
              : null,
          color: isActive ? null : Colors.transparent,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.6),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ===== TAB CHATS =====
  Widget _buildTabChats(User? user) {
    if (_conversaciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 80, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'No tienes conversaciones',
              style: TextStyle(
                  fontSize: 16, color: Colors.white.withValues(alpha: 0.6)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _conversaciones.length,
      itemBuilder: (context, index) {
        final chat = _conversaciones[index];
        final otroUsuario = chat['usuario1_id'] == user?.uid
            ? chat['nombre2'] ?? 'Usuario'
            : chat['nombre1'] ?? 'Usuario';
        final otroUsuarioId = chat['usuario1_id'] == user?.uid
            ? chat['usuario2_id'] ?? ''
            : chat['usuario1_id'] ?? '';
        final productoNombre = chat['producto_nombre'] ?? 'Producto';
        final ultimoMensaje = chat['ultimo_mensaje'] ?? 'Sin mensajes';
        final conversacionId = chat['id'].toString();

        // 🔥 DETECTAR SI HAY MENSAJES NUEVOS
        bool hayMensajesNuevos = false;
        try {
          final ultimaFechaStr = chat['ultima_fecha']?.toString();
          final miUltimoLeidoStr = chat['mi_ultimo_leido']?.toString();

          if (ultimaFechaStr != null && miUltimoLeidoStr != null) {
            final ultimaFecha = DateTime.parse(ultimaFechaStr);
            final miUltimoLeido = DateTime.parse(miUltimoLeidoStr);

            // 🔥 Hay mensajes nuevos si el último mensaje es más reciente que mi última lectura
            // Y el último mensaje NO es mío
            final ultimoMensajeEsMio = chat['ultimo_mensaje_usuario_id'] == user?.uid;
            hayMensajesNuevos = ultimaFecha.isAfter(miUltimoLeido) && !ultimoMensajeEsMio;
          }
        } catch (e) {
          print('Error al calcular mensajes nuevos: $e');
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    conversacionId: conversacionId,
                    otroUsuario: otroUsuario,
                    otroUsuarioId: otroUsuarioId,
                    nombreProducto: productoNombre,
                    productoImagen: chat['producto_imagen'] ?? '',
                    productoId: chat['producto_id']?.toString() ?? '',
                    productoPrecio:
                        chat['producto_precio']?.toString() ?? '0',
                    productoCategoria: chat['productoCategoria'] ?? '',
                    productoDescripcion: chat['productoDescripcion'] ?? '',
                    productoDireccion: chat['productoDireccion'] ?? '',
                    fotoPerfil: chat['usuario1_id'] == user?.uid
                        ? chat['foto_perfil2'] ?? ''
                        : chat['foto_perfil1'] ?? '',
                    productoImagenesReales:
                        chat['producto_imagenes_reales'] ?? '',
                  ),
                ),
              );

              // 🔥 AL VOLVER DEL CHAT, RECARGAR CONVERSACIONES
              if (mounted) {
                await _cargarConversaciones();
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                // 🔥 COLOR CAMBIA SI HAY MENSAJES NUEVOS
                color: hayMensajesNuevos
                    ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: hayMensajesNuevos
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF3B82F6).withValues(alpha: 0.4),
                  width: hayMensajesNuevos ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: hayMensajesNuevos
                        ? const Color(0xFF3B82F6).withValues(alpha: 0.6)
                        : const Color(0xFF3B82F6).withValues(alpha: 0.2),
                    blurRadius: hayMensajesNuevos ? 25 : 15,
                    spreadRadius: hayMensajesNuevos ? 3 : 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hayMensajesNuevos)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3B82F6)
                                      .withValues(alpha: 0.7),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Text(
                              'NUEVO MENSAJE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF60A5FA),
                              Color(0xFF3B82F6),
                              Color(0xFF1A56DB),
                            ],
                          ),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF0A1628),
                          ),
                          child: ClipOval(
                            child: chat['producto_imagen'] != null &&
                                    chat['producto_imagen']
                                        .toString()
                                        .isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: chat[
                                                    'producto_imagen_miniatura'] !=
                                                null &&
                                            chat['producto_imagen_miniatura']
                                                .toString()
                                                .isNotEmpty
                                        ? 'https://mimarketplace-production.up.railway.app${chat['producto_imagen_miniatura']}'
                                        : 'https://mimarketplace-production.up.railway.app${chat['producto_imagen']}',
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey.shade800,
                                      child: const Icon(Icons.image,
                                          color: Colors.grey),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.grey.shade800,
                                      child: const Icon(Icons.broken_image,
                                          color: Colors.grey),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey.shade800,
                                    child: const Icon(Icons.person,
                                        color: Colors.white, size: 28),
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0A1628),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF22C55E)
                                    .withValues(alpha: 0.7),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          otroUsuario,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          productoNombre,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ultimoMensaje,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            final fotoVendedor =
                                chat['usuario1_id'] == user?.uid
                                    ? chat['foto_perfil2'] ?? ''
                                    : chat['foto_perfil1'] ?? '';
                            _guardarEnAgenda({
                              'otroUsuario': otroUsuario,
                              'otroUsuarioId': otroUsuarioId,
                              'productoNombre': productoNombre,
                              'ultimoMensaje': ultimoMensaje,
                              'productoImagen':
                                  chat['producto_imagen'] ?? '',
                              'productoImagenMiniatura':
                                  chat['producto_imagen_miniatura'] ?? '',
                              'conversacionId': conversacionId,
                              'fotoPerfil': fotoVendedor,
                            });
                          },
                          child: const Icon(
                            Icons.bookmark_add,
                            color: Color(0xFF60A5FA),
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            _eliminarChat(conversacionId, otroUsuario);
                          },
                          child: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFEF4444),
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white54,
                    size: 22,
                  ),
                ],
              ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===== TAB AGENDA =====
  Widget _buildTabAgenda() {
    final agendaFiltrada = _busquedaAgenda.isEmpty
        ? _agenda
        : _agenda.where((item) {
            final nombre =
                (item['otroUsuario'] ?? '').toString().toLowerCase();
            final productos = (item['productos'] as List?) ?? [];
            final nombresProductos = productos
                .map((p) =>
                    (p['productoNombre'] ?? '').toString().toLowerCase())
                .join(' ');
            return nombre.contains(_busquedaAgenda.toLowerCase()) ||
                nombresProductos.contains(_busquedaAgenda.toLowerCase());
          }).toList();

    return Column(
      children: [
        // 🔍 Barra de búsqueda
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                width: 1.5,
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
              children: [
                Icon(
                  Icons.search,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _busquedaAgendaController,
                    onChanged: (value) {
                      setState(() {
                        _busquedaAgenda = value;
                      });
                    },
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Buscar contactos o productos...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_busquedaAgenda.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _busquedaAgendaController.clear();
                      setState(() {
                        _busquedaAgenda = '';
                      });
                    },
                    child: Icon(
                      Icons.clear,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // 📋 Lista
        Expanded(
          child: agendaFiltrada.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _busquedaAgenda.isEmpty
                            ? Icons.bookmark_border
                            : Icons.search_off,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _busquedaAgenda.isEmpty
                            ? 'No hay contactos guardados'
                            : 'No hay resultados para "$_busquedaAgenda"',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_busquedaAgenda.isEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Toca el botón en un chat para guardar el contacto en tu agenda',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  itemCount: agendaFiltrada.length,
                  itemBuilder: (context, index) {
                    final item = agendaFiltrada[index];
                    
                    // 🔥 LEER CAMPOS CON SNAKE_CASE (como los devuelve el backend)
                    final otroUsuario = item['otro_usuario'] ?? 'Usuario';
                    final ultimoMensaje = item['ultimo_mensaje'] ?? 'Sin mensajes';
                    final fotoPerfil = item['foto_perfil'] ?? '';
                    final conversacionId = item['conversacion_id']?.toString() ?? '';
                    final fechaGuardado = item['fecha_guardado']?.toString();
                    
                    // 🔥 productos viene como array del backend
                    final productos = (item['productos'] as List?) ?? [];
                    final primerProducto = productos.isNotEmpty
                        ? Map<String, dynamic>.from(productos.first)
                        : <String, dynamic>{};

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                conversacionId: conversacionId,
                                otroUsuario: otroUsuario,
                                otroUsuarioId: '', // 🔥 no está en la respuesta
                                nombreProducto: primerProducto[
                                        'productoNombre'] ??
                                    'Producto',
                                productoImagen:
                                    primerProducto['productoImagen'] ?? '',
                                productoId: primerProducto['productoId']
                                        ?.toString() ??
                                    '',
                                productoPrecio: primerProducto[
                                        'productoPrecio']
                                        ?.toString() ??
                                    '0',
                                productoCategoria: primerProducto[
                                        'productoCategoria'] ??
                                    '',
                                productoDescripcion: primerProducto[
                                        'productoDescripcion'] ??
                                    '',
                                productoDireccion: primerProducto[
                                        'productoDireccion'] ??
                                    '',
                                productoImagenesReales: primerProducto[
                                        'productoImagenesReales'] ??
                                    '',
                                fotoPerfil: fotoPerfil,
                              ),
                            ),
                          );

                          // 🔥 AL VOLVER, RECARGAR
                          if (mounted) {
                            await _cargarConversaciones();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF3B82F6)
                                  .withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6)
                                    .withValues(alpha: 0.2),
                                blurRadius: 15,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF60A5FA),
                                      Color(0xFF3B82F6),
                                      Color(0xFF1A56DB),
                                    ],
                                  ),
                                ),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF0A1628),
                                  ),
                                  child: ClipOval(
                                    child: fotoPerfil.toString().isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl:
                                                'https://mimarketplace-production.up.railway.app$fotoPerfil',
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) => Container(
                                              color: Colors.grey.shade800,
                                              child: const Icon(
                                                  Icons.person,
                                                  color: Colors.grey),
                                            ),
                                            errorWidget: (_, __, ___) =>
                                                Container(
                                              color: Colors.grey.shade800,
                                              child: const Icon(
                                                  Icons.person,
                                                  color: Colors.grey),
                                            ),
                                          )
                                        : Container(
                                            color: Colors.grey.shade800,
                                            child: const Icon(Icons.person,
                                                color: Colors.white,
                                                size: 28),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      otroUsuario,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.shopping_bag,
                                            size: 14,
                                            color: Color(0xFF60A5FA)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            productos
                                                .map((p) =>
                                                    p['productoNombre'] ??
                                                    'Producto')
                                                .join(' · '),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF60A5FA),
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      ultimoMensaje,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white
                                            .withValues(alpha: 0.5),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      _formatearFecha(fechaGuardado),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white
                                        .withValues(alpha: 0.15),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    _eliminarDeAgenda(item['id']);
                                  },
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Color(0xFFEF4444),
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatearFecha(String? fecha) {
    if (fecha == null) return 'Fecha desconocida';
    try {
      final date = DateTime.parse(fecha);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays > 0) {
        return 'hace ${diff.inDays} días';
      } else if (diff.inHours > 0) {
        return 'hace ${diff.inHours} horas';
      } else if (diff.inMinutes > 0) {
        return 'hace ${diff.inMinutes} minutos';
      } else {
        return 'hace unos segundos';
      }
    } catch (e) {
      return 'Fecha desconocida';
    }
  }
}

// ============================================================
// 🎨 WAVE CLIPPER
// ============================================================
class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 15,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}