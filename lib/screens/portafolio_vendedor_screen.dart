import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/producto.dart';
import 'productos_screen.dart';

class PortafolioVendedorScreen extends StatefulWidget {
  final String vendedorId;
  final String vendedorNombre;
  final String? vendedorFoto;

  const PortafolioVendedorScreen({
    super.key,
    required this.vendedorId,
    required this.vendedorNombre,
    this.vendedorFoto,
  });

  @override
  State<PortafolioVendedorScreen> createState() =>
      _PortafolioVendedorScreenState();
}

class _PortafolioVendedorScreenState extends State<PortafolioVendedorScreen> {
  bool _isLoading = true;
  List<Producto> _productos = [];
  Map<String, List<Producto>> _porCategoria = {};

  // 🔥 Mismos iconos que el home
  static const Map<String, IconData> iconos = {
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

  // 🔥 Misma paleta que el home
  static const Map<String, Color> colores = {
    'Electrónicos': Color(0xFF5EEAD4),
    'Ropa': Color(0xFF4ADE80),
    'Libros': Color(0xFFFCD34D),
    'Hogar': Color(0xFFFB923C),
    'Juegos': Color(0xFFF97316),
    'Herramientas': Color(0xFFEF4444),
    'Música': Color(0xFFF87171),
    'Deportes': Color(0xFF2DD4BF),
    'Automóviles': Color(0xFFA78BFA),
    'Jardín': Color(0xFF60A5FA),
  };

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/productos/vendedor/${widget.vendedorId}'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final productos =
            data.map((json) => Producto.fromJson(json)).toList();

        // 🔥 AGRUPAR POR CATEGORÍA
        final Map<String, List<Producto>> agrupado = {};
        for (final p in productos) {
          final cat = p.categoria.trim().isEmpty
              ? 'Sin categoría'
              : p.categoria.trim();
          if (!agrupado.containsKey(cat)) {
            agrupado[cat] = [];
          }
          agrupado[cat]!.add(p);
        }

        if (mounted) {
          setState(() {
            _productos = productos;
            _porCategoria = agrupado;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('Error al cargar portafolio: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF087FE8),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portafolio de ${widget.vendedorNombre}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_productos.length} producto${_productos.length == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _productos.isEmpty
              ? _buildVacio()
              : _buildPortafolio(),
    );
  }

  Widget _buildVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Este vendedor aún no tiene productos',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPortafolio() {
    final categorias = _porCategoria.keys.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 HEADER DEL VENDEDOR
          _buildHeaderVendedor(),
          const SizedBox(height: 20),

          // 🔥 TÍTULO CATEGORÍAS
          const Text(
            'Categorías',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // 🔥 GRID DE CATEGORÍAS (estilo "Ver todas")
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              final cat = categorias[index];
              final cantidad = _porCategoria[cat]!.length;
              return _buildCategoriaCard(context, cat, cantidad);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderVendedor() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // FOTO PERFIL
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFF60A5FA)],
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: widget.vendedorFoto != null &&
                        widget.vendedorFoto!.isNotEmpty
                    ? Image.network(
                        'https://mimarketplace-production.up.railway.app${widget.vendedorFoto}',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person,
                          size: 32,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 32,
                        color: Colors.grey,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // NOMBRE Y STATS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.vendedorNombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.inventory_2,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${_productos.length} producto${_productos.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.category,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${_porCategoria.length} categoría${_porCategoria.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaCard(
      BuildContext context, String categoria, int cantidad) {
    final colorBase = colores[categoria] ?? const Color(0xFF087FE8);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductosScreen(
              categoria: categoria,
              productos: _porCategoria[categoria]!,
            ),
          ),
        );
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
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: colorBase.withValues(alpha: 0.4),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 🔥 BADGE CON CANTIDAD ARRIBA A LA DERECHA
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$cantidad',
                  style: TextStyle(
                    color: colorBase,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // 🔥 CONTENIDO CENTRAL
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: Icon(
                    iconos[categoria] ?? Icons.category,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    categoria,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}