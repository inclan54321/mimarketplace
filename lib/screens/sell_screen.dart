import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'mapa_entrega_screen.dart';

class SellScreen extends StatelessWidget {
  const SellScreen({super.key});

  final Map<String, Map<String, dynamic>> categoriasConSubcategorias = const {
    'Electrónicos': {
      'imagen': 'electronica.jpg',
      'subcategorias': ['Televisores', 'Audio', 'Cámaras', 'Drones', 'Accesorios'],
      'icono': Icons.memory,
      'subtitulo': 'Móviles, Laptops, Audio',
      'colorInicio': Color(0xFF06B6D4),
      'colorFin': Color(0xFF3B82F6),
    },
    'Deportes': {
      'imagen': 'deportes.jpg',
      'subcategorias': ['Fútbol', 'Baloncesto', 'Tennis', 'Natación', 'Gimnasio'],
      'icono': Icons.directions_run,
      'subtitulo': 'Fútbol, Tenis, Running',
      'colorInicio': Color(0xFF22C55E),
      'colorFin': Color(0xFF10B981),
    },
    'Hogar': {
      'imagen': 'hogar.png',
      'subcategorias': ['Muebles', 'Decoración', 'Iluminación', 'Almacenamiento', 'Textiles'],
      'icono': Icons.home,
      'subtitulo': 'Muebles, Decoración, Cocina',
      'colorInicio': Color(0xFFF97316),
      'colorFin': Color(0xFFF59E0B),
    },
    'Música': {
      'imagen': 'musica.png',
      'subcategorias': ['Guitarras', 'Pianos', 'Baterías', 'Vientos', 'Cuerdas'],
      'icono': Icons.music_note,
      'subtitulo': 'Guitarras, Pianos, Audio',
      'colorInicio': Color(0xFFEC4899),
      'colorFin': Color(0xFFF472B6),
    },
    'Cocina': {
      'imagen': 'cocina.png',
      'subcategorias': ['Ollas', 'Sartenes', 'Utensilios', 'Electrodomésticos', 'Vajilla'],
      'icono': Icons.restaurant,
      'subtitulo': 'Ollas, Utensilios, Vajilla',
      'colorInicio': Color(0xFFEF4444),
      'colorFin': Color(0xFFF97316),
    },
    'Películas': {
      'imagen': 'peliculas.jpg',
      'subcategorias': ['Acción', 'Comedia', 'Drama', 'Terror', 'Ciencia Ficción'],
      'icono': Icons.movie,
      'subtitulo': 'Acción, Comedia, Drama',
      'colorInicio': Color(0xFFA855F7),
      'colorFin': Color(0xFF8B5CF6),
    },
    'Fotografía': {
      'imagen': 'fotografia.jpg',
      'subcategorias': ['Cámaras', 'Lentes', 'Trípodes', 'Iluminación', 'Accesorios'],
      'icono': Icons.camera_alt,
      'subtitulo': 'Cámaras, Lentes, Accesorios',
      'colorInicio': Color(0xFF6366F1),
      'colorFin': Color(0xFF8B5CF6),
    },
    'Videojuegos': {
      'imagen': 'videojuegos.png',
      'subcategorias': ['Consolas', 'Juegos', 'Controles', 'Accesorios', 'Realidad Virtual'],
      'icono': Icons.sports_esports,
      'subtitulo': 'Consolas, Juegos, Controles',
      'colorInicio': Color(0xFF14B8A6),
      'colorFin': Color(0xFF06B6D4),
    },
    'Juegos de Mesa': {
      'imagen': 'juegosdemesa.png',
      'subcategorias': ['Cartas', 'Tableros', 'Estrategia', 'Familiares', 'Rol'],
      'icono': Icons.casino,
      'subtitulo': 'Cartas, Tableros, Estrategia',
      'colorInicio': Color(0xFFF59E0B),
      'colorFin': Color(0xFFEF4444),
    },
    'Juguetes': {
      'imagen': 'juguetes.png',
      'subcategorias': ['Peluches', 'Bloques', 'Muñecas', 'Carros', 'Didácticos'],
      'icono': Icons.toys,
      'subtitulo': 'Peluches, Bloques, Carros',
      'colorInicio': Color(0xFFF472B6),
      'colorFin': Color(0xFFEC4899),
    },
    'Figuras': {
      'imagen': 'figuras.png',
      'subcategorias': ['Acción', 'Coleccionables', 'Anime', 'Estatua', 'Miniaturas'],
      'icono': Icons.emoji_people,
      'subtitulo': 'Acción, Coleccionables, Anime',
      'colorInicio': Color(0xFF8B5CF6),
      'colorFin': Color(0xFF6366F1),
    },
  };

  @override
  Widget build(BuildContext context) {
    final List<String> categorias = categoriasConSubcategorias.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      appBar: AppBar(
        title: const Text('Vender'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F2A47),
                Color(0xFF0A1929),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 🌄 Capa 1: Formas geométricas difusas
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: const CustomPaint(
                painter: _GeometricBackgroundPainter(),
                size: Size.infinite,
              ),
            ),
          ),

          // 🌑 Capa 2: Gradiente oscuro encima
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.5),
                  radius: 1.5,
                  colors: [
                    Color(0x990A1929),
                    Color(0xCC0F2447),
                    Color(0xFF0A1929),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 📱 Capa 3: Contenido real
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ===== TÍTULO =====
                const Text(
                  '¿Qué vas a vender?',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                // ===== SUBTÍTULO =====
                Text(
                  'Selecciona la categoría que mejor describe tu artículo',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // ===== BUSCADOR =====
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
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
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Escribe el nombre de tu producto...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                      const Icon(Icons.auto_awesome, color: Color(0xFF60A5FA), size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ===== CARDS DE CATEGORÍAS =====
                for (int i = 0; i < categorias.length; i++) ...[
                  _buildImageFullWidth(context, categorias[i]),
                  if (i < categorias.length - 1) const SizedBox(height: 14),
                ],

                const SizedBox(height: 24),

                // ===== BOTÓN "TODAS LAS CATEGORÍAS" =====
                Center(
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== CARD DE CATEGORÍA CON ESTILO PREMIUM =====
  Widget _buildImageFullWidth(BuildContext context, String categoria) {
    final data = categoriasConSubcategorias[categoria]!;
    final colorInicio = data['colorInicio'] as Color;
    final colorFin = data['colorFin'] as Color;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapaEntregaScreen(
              categoria: categoria,
              subcategoria: categoria, // 🔥 Se usa la categoría como subcategoría
            ),
          ),
        );
      },
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorInicio.withValues(alpha: 0.4),
              blurRadius: 25,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 🖼️ Imagen de fondo (agrandada y centrada)
              Transform.scale(
                scale: 1.4,
                child: Image.asset(
                  'assets/images/categorias/${data['imagen']}',
                  fit: BoxFit.cover,
                ),
              ),

              // 🌑 Overlay oscuro para que el texto se lea
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),

              // 🎨 Borde sutil del color de la categoría
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorInicio.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
              ),

              // 📦 Contenido
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🔵 Ícono circular arriba izquierda
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colorInicio, colorFin],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorInicio.withValues(alpha: 0.6),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        data['icono'] as IconData,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    // 📝 Título + subtítulo
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          categoria,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data['subtitulo'] as String,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 🎯 Botón "Seleccionar →" abajo derecha
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [colorInicio, colorFin],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorFin.withValues(alpha: 0.6),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Seleccionar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 🎨 GEOMETRIC BACKGROUND PAINTER
// ============================================================
class _GeometricBackgroundPainter extends CustomPainter {
  const _GeometricBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    _drawHexagon(
      canvas,
      center: Offset(width * 0.75, height * 0.35),
      radius: width * 0.6,
      color: const Color(0xFF3B82F6),
      alpha: 0.9,
    );

    _drawHexagon(
      canvas,
      center: Offset(width * 0.15, height * 0.2),
      radius: width * 0.45,
      color: const Color(0xFF06B6D4),
      alpha: 0.7,
    );

    _drawHexagon(
      canvas,
      center: Offset(width * 0.5, height * 0.85),
      radius: width * 0.55,
      color: const Color(0xFF8B5CF6),
      alpha: 0.6,
    );

    _drawTriangle(
      canvas,
      center: Offset(width * 0.5, height * 0.1),
      radius: width * 0.4,
      color: const Color(0xFF60A5FA),
      alpha: 0.5,
    );

    _drawDiamond(
      canvas,
      center: Offset(width * 0.9, height * 0.75),
      radius: width * 0.35,
      color: const Color(0xFF0891B2),
      alpha: 0.6,
    );
  }

  void _drawHexagon(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
    required double alpha,
  }) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * (math.pi / 180);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, paint);
  }

  void _drawTriangle(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
    required double alpha,
  }) {
    final path = Path();
    for (int i = 0; i < 3; i++) {
      final angle = (i * 120 - 90) * (math.pi / 180);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, paint);
  }

  void _drawDiamond(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
    required double alpha,
  }) {
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx + radius, center.dy);
    path.lineTo(center.dx, center.dy + radius);
    path.lineTo(center.dx - radius, center.dy);
    path.close();

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}