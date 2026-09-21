import 'package:flutter/material.dart';
import '../models/producto.dart';
import 'detalle_producto_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

final Map<String, Color> coloresProvincias = {
  'San José': const Color.fromARGB(255, 171, 15, 182),
  'Alajuela': const Color.fromARGB(255, 223, 15, 15),
  'Cartago': const Color.fromARGB(255, 8, 16, 229),
  'Heredia': const Color.fromARGB(187, 245, 208, 0),
  'Guanacaste': const Color.fromARGB(255, 54, 244, 114),
  'Puntarenas': const Color.fromARGB(255, 0, 150, 130),
  'Limón': const Color.fromARGB(255, 57, 255, 7),
};

class ProductosScreen extends StatelessWidget {
  final String categoria;
  final List<Producto> productos;
  final VoidCallback? onBloqueoCambiado;

  const ProductosScreen({
    super.key,
    required this.categoria,
    required this.productos,
    this.onBloqueoCambiado,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoria),
        backgroundColor: const Color(0xFF087FE8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: productos.isEmpty
          ? const Center(
              child: Text(
                'No hay productos en esta categoría',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final producto = productos[index];
                  print('>>> Producto: ${producto.nombre}, provincia: ${producto.provincia}');
                  print('>>> imagenUrl en productos: ${producto.imagenUrl}');
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleProductoScreen(
                            producto: producto,
                            onBloqueoCambiado: onBloqueoCambiado, // 🔥 CORREGIDO: SIN widget.
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
                           height: 113,
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
                                   imageUrl: (() {
                                     final url = producto.imagenMiniatura != null && producto.imagenMiniatura!.isNotEmpty
                                         ? 'https://mimarketplace-production.up.railway.app${producto.imagenMiniatura}'
                                         : 'https://mimarketplace-production.up.railway.app${producto.imagenUrl}';
                                     print('>>> 🖼️ CARGANDO IMAGEN PARA ${producto.nombre}: $url');
                                     return url;
                                   })(),
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
                                const SizedBox(height: 0),
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
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: coloresProvincias[producto.provincia] ?? Colors.grey,
                                      fontWeight: FontWeight.w500,
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
    );
  }
}