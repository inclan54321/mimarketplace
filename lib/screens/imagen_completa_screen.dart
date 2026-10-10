import 'package:flutter/material.dart';
import '../models/producto.dart';
import 'detalle_producto_screen.dart';

class ImagenCompletaScreen extends StatelessWidget {
  final String imagenUrl;
  final String nombreProducto;
  final Producto? producto; // 🔥 NUEVO

  const ImagenCompletaScreen({
    super.key,
    required this.imagenUrl,
    required this.nombreProducto,
    this.producto, // 🔥 NUEVO - opcional
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          nombreProducto,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 🔥 IMAGEN A PANTALLA COMPLETA
          Positioned.fill(
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Hero(
                  tag: imagenUrl,
                  child: Image.network(
                    'https://mimarketplace-production.up.railway.app$imagenUrl',
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(Icons.broken_image,
                          size: 80, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 🔥 BOTÓN "VER PRODUCTO" ABAJO
          if (producto != null)
            Positioned(
              bottom: 60,
              left: 24,
              right: 24,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleProductoScreen(
                        producto: producto!,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                label: const Text(
                  'Ver producto',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF087FE8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFF087FE8).withValues(alpha: 0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}