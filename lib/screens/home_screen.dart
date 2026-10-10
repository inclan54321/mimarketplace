import 'package:flutter/material.dart';
import '../widgets/swipe_indicator.dart';
import '../services/producto_service.dart';
import 'productos_screen.dart';
import '../models/producto.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detalle_producto_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'imagen_completa_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'todas_categorias_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showSwipeIndicator = true;
  final ScrollController _scrollController = ScrollController();
  
  bool _modoBusqueda = false;
  List<Producto> _resultadosBusqueda = [];
  String _busqueda = '';
  List<String> _bloqueados = [];
  List<Producto> _productosDestacados = []; // 🔥 NUEVA VARIABLE
  
  // 🔥 NUEVO: FAVORITOS VISUALES (solo en memoria)
  final Set<int> _favoritosVisuales = {};
  
final TextEditingController _busquedaController = TextEditingController();

  // 🔥 FILTROS FUNCIONALES
  String _filtroCanton = 'Todos';
  double? _filtroPrecioMin;
  double? _filtroPrecioMax;
  bool _filtrosActivos = false;
  final List<String> categorias = [
    'Electrónicos',
    'Ropa',
    'Libros',
    'Hogar',
    'Juegos',
    'Herramientas',
    'Música',
    'Deportes',
    'Automóviles',
    'Jardín',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 0 && _showSwipeIndicator) {
        setState(() {
          _showSwipeIndicator = false;
        });
      }
    });
    _cargarBloqueados();
    _cargarProductosDestacados(); // 🔥 NUEVO
    _cargarFavoritos(); // 🔥 NUEVO
  }

  Future<List<String>> _obtenerBloqueados() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isEmpty) return [];

      final response = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/bloquear/$uid'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => e['usuario_bloqueado'].toString()).toList();
      }
      return [];
    } catch (e) {
      print('Error al obtener bloqueados: $e');
      return [];
    }
  }

  Future<void> _cargarBloqueados() async {
    final nuevos = await _obtenerBloqueados();
    setState(() {
      _bloqueados = nuevos;
    });
    print('>>> BLOQUEADOS ACTUALIZADOS: $_bloqueados');
  }
Future<void> _cargarProductosDestacados() async {
  try {
    print('>>> 1. INICIANDO CARGA DE DESTACADOS');
    final response = await http.get(
      Uri.parse('https://mimarketplace-production.up.railway.app/api/productos'),
    );
    print('>>> 2. STATUS CODE: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print('>>> 3. TOTAL PRODUCTOS: ${data.length}');
      
      // FILTRAR SOLO PRODUCTOS CON IMAGEN DESTACADA
      final destacados = data.where((p) {
        final imgDestacada = p['imagen_destacada'] ?? '';
        return imgDestacada.isNotEmpty;
      }).toList();
      print('>>> 4. PRODUCTOS CON IMAGEN DESTACADA: ${destacados.length}');
      
      // Mostrar los nombres de los destacados
      for (var p in destacados) {
        print('>>> DESTACADO: ${p['nombre']} - imagen: ${p['imagen_destacada']}');
      }
      
      // FILTRAR BLOQUEADOS
      print('>>> 5. BLOQUEADOS ACTUALES: $_bloqueados');
      final filtrados = destacados.where((p) {
        final vendedorId = p['vendedor_id']?.toString() ?? '';
        final estaBloqueado = _bloqueados.contains(vendedorId);
        print('>>> PRODUCTO: ${p['nombre']} - VENDEDOR: $vendedorId - BLOQUEADO: $estaBloqueado');
        return !estaBloqueado;
      }).toList();
      print('>>> 6. DESTACADOS FINALES: ${filtrados.length}');
      
      setState(() {
        _productosDestacados = filtrados.map((json) => Producto.fromJson(json)).toList();
      });
    }
  } catch (e) {
    print('Error al cargar productos destacados: $e');
  }
}
  // ============ 🔥 NUEVO: CARGAR FAVORITOS DEL USUARIO ============
  Future<void> _cargarFavoritos() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final response = await http.get(
        Uri.parse(
          'https://mimarketplace-production.up.railway.app/api/favoritos/${user.uid}',
        ),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _favoritosVisuales.clear();
          for (var item in data) {
            final id = int.tryParse(item['id']?.toString() ?? '0');
            if (id != null) {
              _favoritosVisuales.add(id);
            }
          }
        });
        print('>>> ✅ Favoritos cargados: ${_favoritosVisuales.length}');
      }
    } catch (e) {
      print('Error al cargar favoritos: $e');
    }
  }

  // ============ 🔥 NUEVO: TOGGLE FAVORITO (BACKEND) ============
  Future<void> _toggleFavorito(Producto producto) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final esFavorito = _favoritosVisuales.contains(producto.id);

    // 🔥 ACTUALIZACIÓN OPTIMISTA (cambia el icono YA)
    setState(() {
      if (esFavorito) {
        _favoritosVisuales.remove(producto.id);
      } else {
        _favoritosVisuales.add(producto.id);
      }
    });

    try {
      if (esFavorito) {
        // QUITAR DE FAVORITOS
        final response = await http.delete(
          Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/favoritos',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'usuario_id': user.uid,
            'producto_id': producto.id.toString(),
          }),
        );
        if (response.statusCode != 200) {
          throw Exception('Error al quitar: ${response.statusCode}');
        }
      } else {
        // AGREGAR A FAVORITOS
        final response = await http.post(
          Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/favoritos',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'usuario_id': user.uid,
            'producto_id': producto.id.toString(),
          }),
        );
        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Error al agregar: ${response.statusCode}');
        }
      }
    } catch (e) {
      // 🔥 REVERTIR SI FALLA
      setState(() {
        if (esFavorito) {
          _favoritosVisuales.add(producto.id);
        } else {
          _favoritosVisuales.remove(producto.id);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _hideIndicator() {
    if (_showSwipeIndicator) {
      setState(() {
        _showSwipeIndicator = false;
      });
    }
  }

  // 🔥 GETTER DE FILTROS
  bool get _hayFiltros =>
      _filtroCanton != 'Todos' ||
      _filtroPrecioMin != null ||
      _filtroPrecioMax != null;

  // 🔥 APLICAR FILTROS A UNA LISTA
  List<Producto> _aplicarFiltros(List<Producto> lista) {
    if (!_hayFiltros) return lista;

    return lista.where((p) {
      // Filtro por cantón
      if (_filtroCanton != 'Todos') {
        final cantonProducto = (p.canton ?? '').toString().trim();
        if (cantonProducto.toLowerCase() != _filtroCanton.toLowerCase()) {
          return false;
        }
      }

      // Filtro por precio mínimo
      if (_filtroPrecioMin != null && p.precio < _filtroPrecioMin!) {
        return false;
      }

      // Filtro por precio máximo
      if (_filtroPrecioMax != null && p.precio > _filtroPrecioMax!) {
        return false;
      }

      return true;
    }).toList();
  }

  // 🔥 LIMPIAR FILTROS
  void _limpiarFiltros() {
    setState(() {
      _filtroCanton = 'Todos';
      _filtroPrecioMin = null;
      _filtroPrecioMax = null;
      _filtrosActivos = false;
    });
  }

  // ============ 🔥 NUEVO: MOSTRAR FILTROS (SOLO UI) ============
   void _mostrarFiltros() {
    final TextEditingController precioMinCtrl = TextEditingController(
      text: _filtroPrecioMin?.toStringAsFixed(0) ?? '',
    );
    final TextEditingController precioMaxCtrl = TextEditingController(
      text: _filtroPrecioMax?.toStringAsFixed(0) ?? '',
    );
    String cantonTemp = _filtroCanton;

    final List<String> cantones = [
      'Todos',
      'Abangares', 'Acosta', 'Alajuela', 'Alajuelita', 'Alvarado', 'Aserrí',
      'Atenas', 'Bagaces', 'Barva', 'Belén', 'Buenos Aires', 'Cañas', 'Carrillo',
      'Cartago', 'Corredores', 'Coto Brus', 'Curridabat', 'Desamparados', 'Dota',
      'El Guarco', 'Escazú', 'Esparza', 'Flores', 'Garabito', 'Goicoechea',
      'Golfito', 'Grecia', 'Guácimo', 'Guatuso', 'Heredia', 'Hojancha', 'Jiménez',
      'La Cruz', 'La Unión', 'León Cortés', 'Liberia', 'Limón', 'Los Chiles',
      'Matina', 'Monteverde', 'Montes de Oca', 'Montes de Oro', 'Mora', 'Moravia',
      'Nandayure', 'Naranjo', 'Nicoya', 'Oreamuno', 'Orotina', 'Osa', 'Palmares',
      'Paraíso', 'Parrita', 'Pérez Zeledón', 'Pococí', 'Poás', 'Puntarenas',
      'Puriscal', 'Quepos', 'Río Cuarto', 'San Carlos', 'San Isidro', 'San José',
      'San Mateo', 'San Pablo', 'San Rafael', 'San Ramón', 'Santa Ana',
      'Santa Bárbara', 'Santa Cruz', 'Santo Domingo', 'Sarapiquí', 'Sarchí',
      'Siquirres', 'Talamanca', 'Tarrazú', 'Tibás', 'Tilarán', 'Turrialba',
      'Turrubares', 'Upala', 'Vásquez de Coronado', 'Zarcero',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(Icons.filter_list, color: Color(0xFF087FE8)),
                          SizedBox(width: 8),
                          Text(
                            'Filtrar productos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // CANTÓN
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '📍 Cantón',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: cantonTemp,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            menuMaxHeight: 350,
                            items: cantones.map((c) {
                              return DropdownMenuItem<String>(
                                value: c,
                                child: Text(c),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setStateModal(() {
                                cantonTemp = value ?? 'Todos';
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // PRECIO
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '💰 Rango de precio (₡)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: precioMinCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Mín',
                                prefixText: '₡ ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: precioMaxCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Máx',
                                prefixText: '₡ ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // BOTONES
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setStateModal(() {
                                  cantonTemp = 'Todos';
                                  precioMinCtrl.clear();
                                  precioMaxCtrl.clear();
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Limpiar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                final min = double.tryParse(
                                    precioMinCtrl.text.trim());
                                final max = double.tryParse(
                                    precioMaxCtrl.text.trim());

                                setState(() {
                                  _filtroCanton = cantonTemp;
                                  _filtroPrecioMin = min;
                                  _filtroPrecioMax = max;
                                  _filtrosActivos = _hayFiltros;
                                });

                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _hayFiltros
                                          ? '✅ Filtros aplicados'
                                          : 'Sin filtros aplicados',
                                    ),
                                    backgroundColor: _hayFiltros
                                        ? Colors.green
                                        : Colors.grey,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF087FE8),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Aplicar filtros',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).viewPadding.bottom + 40,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: ClipPath(
          clipper: BottomBevelledClipper(),
          child: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: 130,
            centerTitle: false,
            automaticallyImplyLeading: false,
            flexibleSpace: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E3A8A),
                        Color(0xFF1A56DB),
                        Color(0xFF2563EB),
                        Color(0xFF3B82F6),
                      ],
                      stops: [0.0, 0.4, 0.7, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: -50,
                  right: -80,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3BA6F5).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(200),
                        topLeft: Radius.circular(200),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  left: -60,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xFF053B6E).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(250),
                        bottomRight: Radius.circular(250),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  left: -40,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7CC5FA).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(150),
                        topRight: Radius.circular(150),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'MiMarketplaceCR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                  children: [
                                    TextSpan(
                                      text: 'Compra',
                                      style: TextStyle(color: Color(0xFFFFB74D)),
                                    ),
                                    TextSpan(
                                      text: '. ',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    TextSpan(
                                      text: 'Vende',
                                      style: TextStyle(color: Color(0xFF4CAF50)),
                                    ),
                                    TextSpan(
                                      text: '. ',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    TextSpan(
                                      text: 'Encuentra',
                                      style: TextStyle(color: Color(0xFFE57373)),
                                    ),
                                    TextSpan(
                                      text: '.',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            '🇨🇷',
                            style: TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Color.fromARGB(255, 0, 0, 0), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _busquedaController,
                                style: const TextStyle(color: Colors.black87),
                                decoration: const InputDecoration(
                                  hintText: 'Buscar productos...',
                                  hintStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                              onChanged: (value) async {
  setState(() {
    _busqueda = value;
    _modoBusqueda = value.isNotEmpty;
  });

  // 🔥 GUARDAR BÚSQUEDA (solo si tiene 3+ caracteres)
  if (value.length >= 3) {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isNotEmpty) {
        final guardarResponse = await http.post(
          Uri.parse('https://mimarketplace-production.up.railway.app/api/busquedas-app'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'usuario_id': uid,
            'termino': value,
          }),
        );
        
        if (guardarResponse.statusCode == 201) {
          print('>>> ✅ Búsqueda guardada: $value');
        } else if (guardarResponse.statusCode == 403) {
          print('>>> ⛔ No se guardó búsqueda: usuario sin consentimiento');
        } else {
          print('>>> Error al guardar búsqueda: ${guardarResponse.statusCode}');
        }
      }
    } catch (e) {
      print('Error al guardar búsqueda: $e');
    }
  }

  // 🔥 BUSCAR PRODUCTOS
  if (value.length >= 2) {
    try {
      final response = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/productos/buscar?q=${Uri.encodeComponent(value)}'),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print('>>> PRODUCTOS ANTES DE FILTRAR: ${data.length}');
        
        // 🔥 FILTRO AQUÍ 🔥
        final filtrados = data.where((p) {
          final vendedorId = p['vendedor_id']?.toString() ?? '';
          final bool estaBloqueado = _bloqueados.contains(vendedorId);
          if (estaBloqueado) {
            print('>>> PRODUCTO BLOQUEADO: ${p['nombre']}');
          }
          return !estaBloqueado;
        }).toList();
        
        print('>>> PRODUCTOS DESPUÉS DE FILTRAR: ${filtrados.length}');
        
        setState(() {
          _resultadosBusqueda = filtrados.map((json) => Producto.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error al buscar: $e');
    }
  } else {
    setState(() {
      _resultadosBusqueda = [];
    });
  }
},
                              ),
                            ),
                            if (_busqueda.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                                onPressed: () {
                                  _busquedaController.clear();
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    _busqueda = '';
                                    _modoBusqueda = false;
                                    _resultadosBusqueda = [];
                                  });
                                },
                              ),
                            const SizedBox(width: 4),
                            Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.filter_list,
                                    color: Colors.black54,
                                    size: 24,
                                  ),
                                  onPressed: _mostrarFiltros,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: 'Filtrar',
                                ),
                                // 🔥 PUNTITO INDICADOR SI HAY FILTROS "APLICADOS"
                                if (_filtrosActivos)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF9FAFB),
        ),
        child: Stack(
          children: [
            // 🔥 BURBUJAS DE FONDO
            Positioned(
              top: 50,
              left: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 200,
              right: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 300,
              right: -10,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 400,
              left: 30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              right: 40,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // 🔥 CONTENIDO PRINCIPAL
            _modoBusqueda
                ? _resultadosBusqueda.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay resultados',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : Builder(
                        builder: (context) {
                          final filtrados = _aplicarFiltros(_resultadosBusqueda);
                          if (filtrados.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                                    const SizedBox(height: 12),
                                    Text(
                                      _hayFiltros
                                          ? 'No hay productos con esos filtros'
                                          : 'No hay resultados',
                                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (_hayFiltros) ...[
                                      const SizedBox(height: 16),
                                      OutlinedButton.icon(
                                        onPressed: _limpiarFiltros,
                                        icon: const Icon(Icons.clear),
                                        label: const Text('Quitar filtros'),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: [
                              if (_hayFiltros)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            if (_filtroCanton != 'Todos')
                                              Chip(
                                                label: Text('📍 $_filtroCanton', style: const TextStyle(fontSize: 11)),
                                                backgroundColor: const Color(0xFF087FE8).withValues(alpha: 0.15),
                                                deleteIcon: const Icon(Icons.close, size: 14),
                                                onDeleted: () {
                                                  setState(() {
                                                    _filtroCanton = 'Todos';
                                                    _filtrosActivos = _hayFiltros;
                                                  });
                                                },
                                              ),
                                            if (_filtroPrecioMin != null || _filtroPrecioMax != null)
                                              Chip(
                                                label: Text(
                                                  '💰 ${_filtroPrecioMin?.toStringAsFixed(0) ?? '0'} - ${_filtroPrecioMax?.toStringAsFixed(0) ?? '∞'}',
                                                  style: const TextStyle(fontSize: 11),
                                                ),
                                                backgroundColor: Colors.green.shade100,
                                                deleteIcon: const Icon(Icons.close, size: 14),
                                                onDeleted: () {
                                                  setState(() {
                                                    _filtroPrecioMin = null;
                                                    _filtroPrecioMax = null;
                                                    _filtrosActivos = _hayFiltros;
                                                  });
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _limpiarFiltros,
                                        child: const Text('Limpiar', style: TextStyle(fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${filtrados.length} resultado${filtrados.length == 1 ? '' : 's'}',
                                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GridView.builder(
                                  padding: const EdgeInsets.all(12),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.9,
                                  ),
                                  itemCount: filtrados.length,
                                  itemBuilder: (context, index) {
                                    final producto = filtrados[index];
                          return GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetalleProductoScreen(
                                    producto: producto,
                                    onBloqueoCambiado: _cargarBloqueados,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 90,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: producto.imagenUrl != null
                                        ? CachedNetworkImage(
                                            imageUrl: producto.imagenMiniatura != null && producto.imagenMiniatura!.isNotEmpty
                                                ? 'https://mimarketplace-production.up.railway.app${producto.imagenMiniatura}'
                                                : 'https://mimarketplace-production.up.railway.app${producto.imagenUrl}',
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                            ),
                                          )
                                        : Container(
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          producto.nombre,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₡${producto.precio.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade700,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (producto.provincia != null && producto.provincia!.isNotEmpty)
                                          Text(
                                            producto.provincia!,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Categorías',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TodasCategoriasScreen(
                                        bloqueados: _bloqueados,
                                      ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  foregroundColor: const Color(0xFF087FE8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Ver todas',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward_ios, size: 14),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _hideIndicator,
                          onVerticalDragStart: (_) => _hideIndicator(),
                          onHorizontalDragStart: (_) => _hideIndicator(),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              SizedBox(
                                height: 65,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  scrollDirection: Axis.horizontal,
                                  reverse: true,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  itemCount: categorias.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 1),
                                      child: SizedBox(
                                        width: 55,
                                        height: 55,
                                        child: _buildCategoryCard(categorias[index]),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (_showSwipeIndicator)
                                Positioned(
                                  right: 16,
                                  top: 10,
                                  child: const SwipeAnimationIndicator(),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Productos Destacados',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _productosDestacados.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Text(
                                      'No hay productos destacados',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemCount: _productosDestacados.length,
                                  itemBuilder: (context, index) {
                                    final producto = _productosDestacados[index];
                                    final bool esFav = _favoritosVisuales.contains(producto.id);

                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withValues(alpha: 0.15),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // 🔥 IMAGEN (con overlay de nombre y corazón)
                                            Expanded(
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  // Imagen
                                                  GestureDetector(
                                                    onTap: () {
                                                      // 🔥 ABRIR IMAGEN COMPLETA AL TOCAR LA IMAGEN
                                                      String imagen = producto.imagenDestacada ??
                                                          producto.imagenUrl ??
                                                          '';
                                                      if (imagen.isEmpty) {
                                                        ScaffoldMessenger.of(context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                              content: Text(
                                                                  'Este producto no tiene imagen')),
                                                        );
                                                        return;
                                                      }
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ImagenCompletaScreen(
                                                            imagenUrl: imagen,
                                                            nombreProducto:
                                                                producto.nombre,
                                                            producto: producto, // 🔥 NUEVO: pasar el producto completo
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: producto.imagenDestacada != null &&
                                                            producto.imagenDestacada!
                                                                .isNotEmpty
                                                        ? Image.network(
                                                            'https://mimarketplace-production.up.railway.app${producto.imagenDestacada}',
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (_, _, _) =>
                                                                    Container(
                                                              color: Colors
                                                                  .grey.shade200,
                                                              child: const Icon(
                                                                  Icons.image,
                                                                  size: 40,
                                                                  color: Colors
                                                                      .grey),
                                                            ),
                                                          )
                                                        : (producto.imagenUrl != null &&
                                                                producto.imagenUrl!
                                                                    .isNotEmpty
                                                            ? Image.network(
                                                                'https://mimarketplace-production.up.railway.app${producto.imagenUrl}',
                                                                fit: BoxFit.cover,
                                                                errorBuilder:
                                                                    (_, _, _) =>
                                                                        Container(
                                                                  color: Colors
                                                                      .grey.shade200,
                                                                  child: const Icon(
                                                                      Icons.image,
                                                                      size: 40,
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                              )
                                                            : Container(
                                                                color: Colors
                                                                    .grey.shade200,
                                                                child: const Icon(
                                                                    Icons.image,
                                                                    size: 40,
                                                                    color: Colors
                                                                        .grey),
                                                              )),
                                                  ),
                                                  // 🔥 CORAZÓN ARRIBA A LA DERECHA
                                                  Positioned(
                                                    top: 6,
                                                    right: 6,
                                                    child: GestureDetector(
                                                      onTap: () =>
                                                          _toggleFavorito(producto),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(6),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white
                                                              .withValues(alpha: 0.9),
                                                          shape: BoxShape.circle,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.black
                                                                  .withValues(alpha: 0.1),
                                                              blurRadius: 4,
                                                              offset: const Offset(
                                                                  0, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Icon(
                                                          esFav
                                                              ? Icons.favorite
                                                              : Icons.favorite_border,
                                                          color: esFav
                                                              ? Colors.red
                                                              : Colors.grey.shade600,
                                                          size: 22,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // 🔥 OVERLAY CON NOMBRE
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          begin: Alignment.topCenter,
                                                          end: Alignment.bottomCenter,
                                                          colors: [
                                                            Colors.transparent,
                                                            Colors.black.withValues(
                                                                alpha: 0.6),
                                                          ],
                                                        ),
                                                      ),
                                                      child: Text(
                                                        producto.nombre,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

   Widget _buildCategoryCard(String categoria) {
    final Map<String, IconData> iconos = {
      'Electrónicos': Icons.phone_android,
      'Ropa': Icons.checkroom,
      'Libros': Icons.library_books,
      'Hogar': Icons.weekend,
      'Juegos': Icons.sports_esports,
      'Herramientas': Icons.handyman,
      'Música': Icons.music_note,
      'Deportes': Icons.sports_soccer,
      'Automóviles': Icons.directions_car,
      'Jardín': Icons.grass,
    };

    // 🔥 PALETA FLAT (mapeada al orden de categorías)
    final List<Color> coloresAtardecer = [
      const Color(0xFF5EEAD4), // Electrónicos - turquesa
      const Color(0xFF4ADE80), // Ropa         - verde
      const Color(0xFFFCD34D), // Libros       - amarillo
      const Color(0xFFFB923C), // Hogar        - naranja claro
      const Color(0xFFF97316), // Juegos       - naranja
      const Color(0xFFEF4444), // Herramientas - rojo
      const Color(0xFFF87171), // Música       - rojo suave/rosa
      const Color(0xFF2DD4BF), // Deportes     - turquesa oscuro
      const Color(0xFFA78BFA), // Automóviles  - violeta
      const Color(0xFF60A5FA), // Jardín       - azul claro
    ];

    // Obtener el índice de la categoría
    final index = categorias.indexOf(categoria);
    final colorBase = coloresAtardecer[index % coloresAtardecer.length];

    return GestureDetector(
      onTap: () async {
        try {
          final productos = await ProductoService().getProductosByCategoria(
            categoria,
            bloqueados: _bloqueados,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductosScreen(
                categoria: categoria,
                productos: productos,
              ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar productos: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorBase,
              colorBase.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: colorBase.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconos[categoria] ?? Icons.category,
              size: 34,
              color: Colors.white,
            ),
            Text(
              categoria,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
void dispose() {     // ← ❌ ESTÁ FUERA DE LA CLASE
  _busquedaController.dispose();
  super.dispose();
  }
  
}

class BottomBevelledClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final height = size.height;
    final width = size.width;

    final horizontal = 30.0;
    final vertical = 3.0;

    path.moveTo(0, 0);
    path.lineTo(width, 0);
    path.lineTo(width, height - vertical);
    path.lineTo(width - horizontal, height);
    path.lineTo(horizontal, height);
    path.lineTo(0, height - vertical);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}