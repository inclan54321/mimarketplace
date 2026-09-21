import 'package:flutter/material.dart';
import 'subcategorias_screen.dart';

class SellScreen extends StatelessWidget {
  const SellScreen({super.key});

  final Map<String, Map<String, dynamic>> categoriasConSubcategorias = const {
    'Electrónicos': {
      'imagen': 'electronica.png',
      'subcategorias': ['Televisores', 'Audio', 'Cámaras', 'Drones', 'Accesorios'],
    },
    'Deportes': {
      'imagen': 'deportes.png',
      'subcategorias': ['Fútbol', 'Baloncesto', 'Tennis', 'Natación', 'Gimnasio'],
    },
    'Hogar': {
      'imagen': 'hogar.png',
      'subcategorias': ['Muebles', 'Decoración', 'Iluminación', 'Almacenamiento', 'Textiles'],
    },
    'Música': {
      'imagen': 'musica.png',
      'subcategorias': ['Guitarras', 'Pianos', 'Baterías', 'Vientos', 'Cuerdas'],
    },

    'Cocina': {
      'imagen': 'cocina.png',
      'subcategorias': ['Ollas', 'Sartenes', 'Utensilios', 'Electrodomésticos', 'Vajilla'],
    },
    'Películas': {
      'imagen': 'peliculas.png',
      'subcategorias': ['Acción', 'Comedia', 'Drama', 'Terror', 'Ciencia Ficción'],
    },
    'Fotografía': {
      'imagen': 'fotografia.png',
      'subcategorias': ['Cámaras', 'Lentes', 'Trípodes', 'Iluminación', 'Accesorios'],
    },
    'Videojuegos': {
      'imagen': 'videojuegos.png',
      'subcategorias': ['Consolas', 'Juegos', 'Controles', 'Accesorios', 'Realidad Virtual'],
    },
    'Juegos de Mesa': {
      'imagen': 'juegosdemesa.png',
      'subcategorias': ['Cartas', 'Tableros', 'Estrategia', 'Familiares', 'Rol'],
    },
    'Juguetes': {
      'imagen': 'juguetes.png',
      'subcategorias': ['Peluches', 'Bloques', 'Muñecas', 'Carros', 'Didácticos'],
    },
    'Figuras': {
      'imagen': 'figuras.png',
      'subcategorias': ['Acción', 'Coleccionables', 'Anime', 'Estatua', 'Miniaturas'],
    },
  };

  @override
  Widget build(BuildContext context) {
    final List<String> categorias = categoriasConSubcategorias.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vender'),
        backgroundColor: const Color(0xFF087FE8),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SizedBox(
                    height: 950,   // ← más alto para la fila 6 + botón
          child: Stack(
            children: [
              // ===== LÍNEA 1: Título =====
              Positioned(
                left: 0,
                right: 155,
                top: 15,
                child: const Text(
                  '¿Qué vas a vender?',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    height: 24 / 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // ===== LÍNEA 2: Subtítulo =====
              Positioned(
                left: 0,
                right: 50,
                top: 40,
                child: const Text(
                  'Selecciona la categoría que mejor describe tu artículo',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                    height: 20 / 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // ===== BUSCADOR =====
              Positioned(
                left: 30,
                right: 30,
                top: 80,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Escribe el nombre de tu producto y te ayudaremos a encontrar la mejor categoría',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      const Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
                    ],
                  ),
                ),
              ),

              // ===== BOTÓN "TODAS LAS CATEGORÍAS" (MOVIBLE) =====
                                       Positioned(
                left: 20,
                right: 20,
                top: 820,   // ← debajo de la nueva fila 6
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      print('Mostrar todas las categorías');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF087FE8),
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      ),
                    ),
                    child: const Text(
                      'Todas las categorías',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // ===== FILA 1 =====
              // IMAGEN 1 (Electrónicos)
              Positioned(
                left: 20,
                top: 150,
                child: _buildImage(context, categorias[0]),
              ),
              // IMAGEN 2 (Deportes)
              Positioned(
                right: 20,
                top: 150,
                child: _buildImage(context, categorias[1]),
              ),

              // ===== FILA 2 =====
              // IMAGEN 3 (Hogar)
              Positioned(
                left: 20,
                top: 245,
                child: _buildImage(context, categorias[2]),
              ),
              // IMAGEN 4 (Música)
              Positioned(
                right: 20,
                top: 245,
                child: _buildImage(context, categorias[3]),
              ),

              // ===== FILA 3 =====
              // IMAGEN 5 (Cocina)
              Positioned(
                left: 20,
                top: 340,
                child: _buildImage(context, categorias[4]),
              ),
              // IMAGEN 6 (Películas)
              Positioned(
                right: 20,
                top: 340,
                child: _buildImage(context, categorias[5]),
              ),

              // ===== FILA 4 =====
              // IMAGEN 7 (Fotografía)
              Positioned(
                left: 20,
                top: 435,
                child: _buildImage(context, categorias[6]),
              ),
              // IMAGEN 8 (Videojuegos)
              Positioned(
                right: 20,
                top: 435,
                child: _buildImage(context, categorias[7]),
              ),

              // ===== FILA 5 =====
              // IMAGEN 9 (Juegos de Mesa)
              Positioned(
                left: 20,
                top: 530,
                child: _buildImage(context, categorias[8]),
              ),
              // IMAGEN 10 (Juguetes)
              Positioned(
                right: 20,
                top: 530,
                child: _buildImage(context, categorias[9]),
              ),

              // ===== FILA 6 =====
              // IMAGEN 11 (Figuras)
              Positioned(
                left: 20,
                top: 625,
                child: _buildImage(context, categorias[10]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, String categoria) {
    final data = categoriasConSubcategorias[categoria]!;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubcategoriasScreen(
              categoria: categoria,
              subcategorias: data['subcategorias'] as List<String>,
            ),
          ),
        );
      },
      child: SizedBox(
        width: 180,
        height: 180,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/categorias/${data['imagen']}',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}