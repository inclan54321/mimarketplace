import 'package:flutter/material.dart';
import '../services/producto_service.dart';
import 'productos_screen.dart';
import '../l10n/generated/app_localizations.dart';

class TodasCategoriasScreen extends StatefulWidget {
  final List<String> bloqueados;
  const TodasCategoriasScreen({super.key, required this.bloqueados});

  // Misma lista de categorías que el home
  static const List<String> categorias = [
    'Electrónicos',
    'Deportes',
    'Hogar',
    'Música',
    'Cocina',
    'Películas',
    'Fotografía',
    'Videojuegos',
    'Juegos de Mesa',
    'Juguetes',
    'Figuras',
    'Automóviles',
    'Herramientas',
    'Ropa y Calzado',
  ];

  // Mismos íconos que el home
  static const Map<String, IconData> iconos = {
    'Electrónicos': Icons.memory,
    'Deportes': Icons.directions_run,
    'Hogar': Icons.home,
    'Música': Icons.music_note,
    'Cocina': Icons.restaurant,
    'Películas': Icons.movie,
    'Fotografía': Icons.camera_alt,
    'Videojuegos': Icons.sports_esports,
    'Juegos de Mesa': Icons.casino,
    'Juguetes': Icons.toys,
    'Figuras': Icons.emoji_people,
    'Automóviles': Icons.directions_car,
    'Herramientas': Icons.handyman,
    'Ropa y Calzado': Icons.checkroom,
  };

  // Misma paleta que el home
  static const List<Color> coloresAtardecer = [
    Color(0xFF06B6D4), // Electrónicos
    Color(0xFF22C55E), // Deportes
    Color(0xFFF97316), // Hogar
    Color(0xFFEC4899), // Música
    Color(0xFFEF4444), // Cocina
    Color(0xFFA855F7), // Películas
    Color(0xFF6366F1), // Fotografía
    Color(0xFF14B8A6), // Videojuegos
    Color(0xFFF59E0B), // Juegos de Mesa
    Color(0xFFF472B6), // Juguetes
    Color(0xFF8B5CF6), // Figuras
    Color(0xFF3B82F6), // Automóviles
    Color(0xFFF59E0B), // Herramientas
    Color(0xFFEC4899), // Ropa y Calzado
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

  String _traducirCategoria(String categoria, AppLocalizations l10n) {
    switch (categoria) {
      case 'Electrónicos': return l10n.catElectronicos;
      case 'Deportes': return l10n.catDeportes;
      case 'Hogar': return l10n.catHogar;
      case 'Música': return l10n.catMusica;
      case 'Cocina': return l10n.catCocina;
      case 'Películas': return l10n.catPeliculas;
      case 'Fotografía': return l10n.catFotografia;
      case 'Videojuegos': return l10n.catVideojuegos;
      case 'Juegos de Mesa': return l10n.catJuegosDeMesa;
      case 'Juguetes': return l10n.catJuguetes;
      case 'Figuras': return l10n.catFiguras;
      case 'Automóviles': return l10n.catAutomoviles;
      case 'Herramientas': return l10n.catHerramientas;
      case 'Ropa y Calzado': return l10n.catRopaYCalzado;
      default: return categoria;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // 🔥 Filtrar categorías según lo que el usuario escribió
    final List<String> categoriasFiltradas = TodasCategoriasScreen.categorias
        .where((c) => c.toLowerCase().contains(_filtro.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todasLasCategorias),
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
                      decoration: InputDecoration(
                        hintText: l10n.buscarCategoria,
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
                            l10n.noSeEncontraronCategorias,
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
    final l10n = AppLocalizations.of(context)!;
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
              content: Text(l10n.errorGenerico('$e')),
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
                _traducirCategoria(categoria, l10n),
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