import 'package:flutter/material.dart';
import '../services/producto_service.dart';
import 'productos_screen.dart';

class TodasCategoriasScreen extends StatefulWidget {
  final List<String> bloqueados;
  const TodasCategoriasScreen({super.key, required this.bloqueados});

  // Misma lista de categorías que el home
  static const List<String> categorias = [
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

  // Mismos íconos que el home
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

  // Misma paleta que el home
  static const List<Color> coloresAtardecer = [
    Color(0xFF5EEAD4), // Electrónicos - turquesa
    Color(0xFF4ADE80), // Ropa         - verde
    Color(0xFFFCD34D), // Libros       - amarillo
    Color(0xFFFB923C), // Hogar        - naranja claro
    Color(0xFFF97316), // Juegos       - naranja
    Color(0xFFEF4444), // Herramientas - rojo
    Color(0xFFF87171), // Música       - rojo suave/rosa
    Color(0xFF2DD4BF), // Deportes     - turquesa oscuro
    Color(0xFFA78BFA), // Automóviles  - violeta
    Color(0xFF60A5FA), // Jardín       - azul claro
  ];

  @override
  State<TodasCategoriasScreen> createState() => _TodasCategoriasScreenState();
}

class _TodasCategoriasScreenState extends State<TodasCategoriasScreen> {
  final TextEditingController _busquedaController = TextEditingController();
  String _filtro = '';

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Filtrar categorías según lo que el usuario escribió
    final List<String> categoriasFiltradas = TodasCategoriasScreen.categorias
        .where((c) => c.toLowerCase().contains(_filtro.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas las Categorías'),
        backgroundColor: const Color(0xFF087FE8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔥 BUSCADOR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _busquedaController,
                      onChanged: (value) {
                        setState(() {
                          _filtro = value.trim();
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Buscar categoría...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  if (_filtro.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear,
                          color: Colors.grey.shade600, size: 20),
                      onPressed: () {
                        _busquedaController.clear();
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _filtro = '';
                        });
                      },
                    ),
                ],
              ),
            ),
          ),

          // 🔥 RESULTADOS
          Expanded(
            child: categoriasFiltradas.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'No se encontraron categorías',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: categoriasFiltradas.length,
                      itemBuilder: (context, index) {
                        return _buildCategoryCard(
                          context,
                          categoriasFiltradas[index],
                          index,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, String categoria, int index) {
    final colorBase = TodasCategoriasScreen.coloresAtardecer[
        index % TodasCategoriasScreen.coloresAtardecer.length];

    return GestureDetector(
      onTap: () async {
        try {
          final productos = await ProductoService().getProductosByCategoria(
            categoria,
            bloqueados: widget.bloqueados,
          );
          if (!context.mounted) return;
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
          if (!context.mounted) return;
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              child: Icon(
                TodasCategoriasScreen.iconos[categoria] ?? Icons.category,
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
      ),
    );
  }
}