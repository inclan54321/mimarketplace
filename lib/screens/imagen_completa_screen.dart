import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/producto.dart';
import 'detalle_producto_screen.dart';

class ImagenCompletaScreen extends StatefulWidget {
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
  State<ImagenCompletaScreen> createState() => _ImagenCompletaScreenState();
}

class _ImagenCompletaScreenState extends State<ImagenCompletaScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _audioSonando = false;

  @override
  void initState() {
    super.initState();
    // 🔥 Reproducir el audio del producto (si tiene) al abrir
    final audio = widget.producto?.audioUrl ?? '';
    if (audio.isNotEmpty) {
      _reproducirAudio(audio);
    }
  }

  Future<void> _reproducirAudio(String audioUrl) async {
    try {
      final urlCompleta = audioUrl.startsWith('http')
          ? audioUrl
          : 'https://mimarketplace-production.up.railway.app$audioUrl';
      await _audioPlayer.play(UrlSource(urlCompleta));
      if (mounted) setState(() => _audioSonando = true);
    } catch (e) {
      debugPrint('>>> ❌ Error al reproducir audio: $e');
    }
  }

  Future<void> _pausarAudio() async {
    await _audioPlayer.pause();
    if (mounted) setState(() => _audioSonando = false);
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('>>> IMAGEN COMPLETA - build');
    print('>>> producto?.id: ${widget.producto?.id}');
    print('>>> producto?.vendedorId: ${widget.producto?.vendedorId}');
    print('>>> producto?.vendedorNombre: ${widget.producto?.vendedorNombre}');
    print('>>> producto?.vendedorFoto: ${widget.producto?.vendedorFoto}');
    print('>>> imagenUrl: ${widget.imagenUrl}');
    print('>>> nombreProducto: ${widget.nombreProducto}');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          widget.nombreProducto,
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
                  tag: widget.imagenUrl,
                  child: Image.network(
                    'https://mimarketplace-production.up.railway.app${widget.imagenUrl}',
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

          // 🔥 BOTÓN DE PLAY/PAUSA DEL AUDIO
          if ((widget.producto?.audioUrl ?? '').isNotEmpty)
            Positioned(
              top: 100,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  if (_audioSonando) {
                    _pausarAudio();
                  } else {
                    _reproducirAudio(widget.producto!.audioUrl!);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _audioSonando ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),

          // 🔥 BOTÓN "VER PRODUCTO" ABAJO
          if (widget.producto != null)
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
                        producto: widget.producto!,
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