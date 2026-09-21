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
  final int _selectedTab = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
    _cargarAgenda();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ===== CARGAR DATOS RÁPIDO =====
  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _cargarConversaciones(),
      _cargarBloqueados(),
    ]);
    setState(() => _isLoading = false);
  }

  // ===== CARGAR CONVERSACIONES =====
  Future<void> _cargarConversaciones() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final response = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/conversaciones/${user.uid}'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final todas = data.map((item) => Map<String, dynamic>.from(item)).toList();

        final conversacionesFiltradas = todas.where((chat) {
          final otroId = chat['usuario1_id'] == user.uid
              ? chat['usuario2_id']
              : chat['usuario1_id'];
          return !_bloqueados.contains(otroId);
        }).toList();

        setState(() {
          _conversaciones = conversacionesFiltradas;
        });
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
        Uri.parse('https://mimarketplace-production.up.railway.app/api/bloquear/${user.uid}'),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _bloqueados = data.map((e) => e['usuario_bloqueado'].toString()).toList();
        });
      }
    } catch (e) {
      print('Error al cargar bloqueados: $e');
    }
  }

  // ===== CARGAR AGENDA =====
  Future<void> _cargarAgenda() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final agendaString = prefs.getString('agenda_mensajes');
      if (agendaString != null && agendaString.isNotEmpty) {
        final List data = jsonDecode(agendaString);
        setState(() {
          _agenda = data.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      }
    } catch (e) {
      print('Error al cargar agenda: $e');
    }
  }

  // ===== GUARDAR EN AGENDA =====
  Future<void> _guardarEnAgenda(Map<String, dynamic> chat) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final nuevoItem = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'fecha': DateTime.now().toIso8601String(),
        'otroUsuario': chat['otroUsuario'] ?? 'Usuario',
        'productoNombre': chat['productoNombre'] ?? 'Producto',
        'ultimoMensaje': chat['ultimoMensaje'] ?? 'Sin mensajes',
        'productoImagen': chat['productoImagen'] ?? '',
        'productoImagenMiniatura': chat['productoImagenMiniatura'] ?? '',
        'conversacionId': chat['conversacionId'] ?? '',
      };

      setState(() {
        _agenda.insert(0, nuevoItem);
      });

      final agendaString = jsonEncode(_agenda);
      await prefs.setString('agenda_mensajes', agendaString);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Guardado en agenda'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ===== ELIMINAR DE AGENDA =====
  Future<void> _eliminarDeAgenda(String id) async {
    try {
      setState(() {
        _agenda.removeWhere((item) => item['id'] == id);
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('agenda_mensajes', jsonEncode(_agenda));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ Eliminado'),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 1),
        ),
      );
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
        content: Text('¿Eliminar la conversación con $nombreUsuario?'),
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
        final response = await http.delete(
          Uri.parse('https://mimarketplace-production.up.railway.app/api/conversaciones/$conversacionId'),
        );

        if (response.statusCode == 200) {
          setState(() {
            _conversaciones.removeWhere((c) => c['id'].toString() == conversacionId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat eliminado'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
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
           appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          title: null,
          backgroundColor: const Color(0xFF0D1B3E),
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.red.shade700,
            indicatorWeight: 3,
            labelColor: Colors.red.shade700,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            tabs: const [
              Tab(text: 'CHATS'),
              Tab(text: 'AGENDA'),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // ===== TAB 1: CHATS =====
                _conversaciones.isEmpty
                    ? const Center(
                        child: Text(
                          'No tienes conversaciones',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
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

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      conversacionId: conversacionId,
                                      otroUsuario: otroUsuario,
                                      otroUsuarioId: otroUsuarioId,
                                      nombreProducto: productoNombre,
                                      productoImagen: chat['producto_imagen'] ?? '',
                                      productoId: chat['producto_id']?.toString() ?? '',
                                      productoPrecio: chat['producto_precio']?.toString() ?? '0',
                                      productoCategoria: chat['productoCategoria'] ?? '',
                                      productoDescripcion: chat['productoDescripcion'] ?? '',
                                      productoDireccion: chat['productoDireccion'] ?? '',
                                      fotoPerfil: chat['usuario1_id'] == user?.uid
                                          ? chat['foto_perfil2'] ?? ''
                                          : chat['foto_perfil1'] ?? '',
                                      productoImagenesReales: chat['producto_imagenes_reales'] ?? '',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                                    // Avatar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: chat['producto_imagen'] != null &&
                                              chat['producto_imagen'].toString().isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: chat['producto_imagen_miniatura'] != null &&
                                                      chat['producto_imagen_miniatura'].toString().isNotEmpty
                                                  ? 'https://mimarketplace-production.up.railway.app${chat['producto_imagen_miniatura']}'
                                                  : 'https://mimarketplace-production.up.railway.app${chat['producto_imagen']}',
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(
                                                width: 50,
                                                height: 50,
                                                color: Colors.grey.shade200,
                                                child: const Icon(Icons.image, color: Colors.grey),
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                width: 50,
                                                height: 50,
                                                color: Colors.grey.shade200,
                                                child: const Icon(Icons.broken_image, color: Colors.grey),
                                              ),
                                            )
                                          : Container(
                                              width: 50,
                                              height: 50,
                                              decoration: const BoxDecoration(
                                                color: Colors.grey,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.person, color: Colors.white, size: 28),
                                            ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            otroUsuario,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            productoNombre,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.red.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            ultimoMensaje,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // 🔥 BOTONES EN COLUMNA (dentro del recuadro)
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.bookmark_add,
                                            color: Colors.red.shade700,
                                            size: 28,
                                          ),
                                          onPressed: () {
                                            _guardarEnAgenda({
                                              'otroUsuario': otroUsuario,
                                              'productoNombre': productoNombre,
                                              'ultimoMensaje': ultimoMensaje,
                                              'productoImagen': chat['producto_imagen'] ?? '',
                                              'productoImagenMiniatura': chat['producto_imagen_miniatura'] ?? '',
                                              'conversacionId': conversacionId,
                                            });
                                          },
                                          tooltip: 'Guardar en agenda',
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: 22,
                                          ),
                                          onPressed: () {
                                            _eliminarChat(conversacionId, otroUsuario);
                                          },
                                          tooltip: 'Eliminar chat',
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                // ===== TAB 2: AGENDA =====
                _agenda.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No hay mensajes guardados',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Toca el botón rojo en un chat para guardarlo',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _agenda.length,
                        itemBuilder: (context, index) {
                          final item = _agenda[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  // Avatar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: item['productoImagen'] != null &&
                                            item['productoImagen'].toString().isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: item['productoImagenMiniatura'] != null &&
                                                    item['productoImagenMiniatura'].toString().isNotEmpty
                                                ? 'https://mimarketplace-production.up.railway.app${item['productoImagenMiniatura']}'
                                                : 'https://mimarketplace-production.up.railway.app${item['productoImagen']}',
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              width: 50,
                                              height: 50,
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.image, color: Colors.grey),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              width: 50,
                                              height: 50,
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.broken_image, color: Colors.grey),
                                            ),
                                          )
                                        : Container(
                                            width: 50,
                                            height: 50,
                                            decoration: const BoxDecoration(
                                              color: Colors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.person, color: Colors.white, size: 28),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item['otroUsuario'] ?? 'Usuario',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item['productoNombre'] ?? 'Producto',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.red.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item['ultimoMensaje'] ?? 'Sin mensajes',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          _formatearFecha(item['fecha']),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                                    onPressed: () {
                                      _eliminarDeAgenda(item['id']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
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