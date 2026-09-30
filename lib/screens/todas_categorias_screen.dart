import 'package:flutter/material.dart';
import '../services/producto_service.dart';
import 'productos_screen.dart';

class TodasCategoriasScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas las Categorías'),
        backgroundColor: const Color(0xFF087FE8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
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
            return _buildCategoryCard(context, categorias[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, String categoria, int index) {
    final colorBase = coloresAtardecer[index % coloresAtardecer.length];

    return GestureDetector(
      onTap: () async {
        try {
          final productos = await ProductoService().getProductosByCategoria(
            categoria,
            bloqueados: bloqueados,
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
      ),
    );
  }
}