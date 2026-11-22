import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;

  const ImageViewerScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Imagen a pantalla completa
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: FutureBuilder<String?>(
  future: FirebaseAuth.instance.currentUser?.getIdToken(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const CircularProgressIndicator(
        color: Colors.white,
      );
    }

    return Image.network(
      imageUrl,
      headers: {
        'Authorization': 'Bearer ${snapshot.data}',
      },
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const Icon(
        Icons.broken_image,
        size: 80,
        color: Colors.grey,
      ),
    );
  },
),
            ),
          ),
          // Botón de cerrar
          Positioned(
            top: 40,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}