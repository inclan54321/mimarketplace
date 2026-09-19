import 'package:flutter/material.dart';
import 'mapa_entrega_screen.dart';

class SubcategoriasScreen extends StatelessWidget {
  final String categoria;
  final List<String> subcategorias;

  const SubcategoriasScreen({
    super.key,
    required this.categoria,
    required this.subcategorias,
  });

  // Mapa de emojis para subcategorías (genérico)
  String _getEmojiForSubcategoria(String nombre) {
    final Map<String, String> emojis = {
      'Acción': '🔥',
      'Comedia': '😂',
      'Drama': '🎭',
      'Terror': '👻',
      'Ciencia Ficción': '🚀',
      'Animación': '🎨',
      'Guitarras': '🎸',
      'Pianos': '🎹',
      'Baterías': '🥁',
      'Vientos': '🎷',
      'Cuerdas': '🎻',
      'Electrónicos': '💻',
      'Consolas': '🎮',
      'Juegos': '🕹️',
      'PC': '🖥️',
      'Accesorios': '🔌',
      'Monitores': '🖥️',
      'Teclados': '⌨️',
      'Eléctricas': '🔌',
      'Manuales': '🔧',
      'Jardín': '🌿',
      'Medición': '📏',
      'Seguridad': '🛡️',
      'Autos': '🚗',
      'Motocicletas': '🏍️',
      'Bicicletas': '🚲',
      'Repuestos': '🔩',
      'Fútbol': '⚽',
      'Baloncesto': '🏀',
      'Tennis': '🎾',
      'Natación': '🏊',
      'Gimnasio': '🏋️',
      'Ciclismo': '🚴',
      'Novelas': '📖',
      'Ciencia': '🔬',
      'Historia': '📜',
      'Infantiles': '🧒',
      'Técnicos': '⚙️',
      'Televisores': '📺',
      'Audio': '🎵',
      'Cámaras': '📷',
      'Drones': '✈️',
      'Utensilios': '🍴',
      'Electrodomésticos': '🔌',
      'Vajilla': '🍽️',
      'Cuchillos': '🔪',
      'Batidoras': '🥄',
      'Pintura': '🎨',
      'Escultura': '🗿',
      'Costura': '🧵',
      'Papelería': '📎',
      'Bordado': '🪡',
      'Muebles': '🪑',
      'Decoración': '🖼️',
      'Iluminación': '💡',
      'Almacenamiento': '📦',
      'Textiles': '🧶',
      'Camisas': '👔',
      'Pantalones': '👖',
      'Vestidos': '👗',
      'Abrigos': '🧥',
      'Ropa Interior': '🩲',
      'Muñecas': '🎎',
      'Carros': '🚗',
      'Puzzles': '🧩',
      'Juegos de Mesa': '🎲',
      'Figuras': '🗿',
      'Alimentos': '🍖',
      'Juguetes': '🧸',
      'Camas': '🛏️',
      'Correas': '🦮',
      'Acuarios': '🐠',
      'Ropa': '👗',
      'Cunas': '🛏️',
      'Carriolas': '👶',
      'Pañales': '🧷',
      'Maquinaria': '🏗️',
      'Almacén': '📦',
      'Carga': '📦',
      'Mantenimiento': '🔧',
      'Smartphones': '📱',
      'Fundas': '📱',
      'Cargadores': '🔌',
      'Pantallas': '🖥️',
      'Zapatillas': '👟',
      'Botas': '👢',
      'Zapatos': '👞',
      'Sandalias': '🩴',
      'Deportivos': '👟',
    };
    return emojis[nombre] ?? '📦';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoria),
        backgroundColor: const Color(0xFF087FE8),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escoge la subcategoría',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: subcategorias.length,
                itemBuilder: (context, index) {
                  final nombre = subcategorias[index];
                  final emoji = _getEmojiForSubcategoria(nombre);
                  return _buildSubcategoriaCard(context, emoji, nombre);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildSubcategoriaCard(BuildContext context, String icono, String nombre) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapaEntregaScreen(
            categoria: categoria, // ← Cambia widget.categoria por categoria
            subcategoria: nombre,
          ),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icono,
            style: const TextStyle(fontSize: 36),
          ),
          const SizedBox(height: 8),
          Text(
            nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}
}