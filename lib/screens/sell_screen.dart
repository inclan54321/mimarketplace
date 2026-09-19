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
          height: MediaQuery.of(context).size.height,
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
                left: 20,    // ← Cambia esto para moverlo horizontalmente
                right: 20,   // ← Si usas right, no uses left
                top:430,// Cambia esto para subir/bajar el botón
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

              // ===== IMAGEN 1 (Electrónicos) =====
              Positioned(
                left: 20,
                top: 150,
                child: _buildImage(context, categorias[0]),
              ),
              // ===== IMAGEN 2 (Deportes) =====
              Positioned(
                right: 20,
                top: 150,
                child: _buildImage(context, categorias[1]),
              ),
              // ===== IMAGEN 3 (Hogar) =====
              Positioned(
                left: 20,
                bottom: 400,
                child: _buildImage(context, categorias[2]),
              ),
              // ===== IMAGEN 4 (Música) =====
              Positioned(
                right: 20,
                bottom: 400,
                child: _buildImage(context, categorias[3]),
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