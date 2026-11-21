import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/producto.dart';
import 'detalle_producto_screen.dart';

class ImagenCompletaScreen extends StatefulWidget {
  final String imagenUrl;
  final String nombreProducto;
  final Producto? producto; // 🔥 NUEVO
  final List<Producto>? productos; // 🔥 lista para hacer scroll entre destacados
  final int indiceInicial;

  const ImagenCompletaScreen({
    super.key,
    required this.imagenUrl,
    required this.nombreProducto,
    this.producto, // 🔥 NUEVO - opcional
    this.productos,
    this.indiceInicial = 0,
  });

  @override
  State<ImagenCompletaScreen> createState() => _ImagenCompletaScreenState();
}

class _ImagenCompletaScreenState extends State<ImagenCompletaScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _audioSonando = false;
  late final PageController _pageController;
  int _indice = 0;

  List<Producto> get _lista =>
      widget.productos ?? (widget.producto != null ? [widget.producto!] : []);

  Producto? get _productoActual {
    final l = _lista;
    if (l.isNotEmpty && _indice >= 0 && _indice < l.length) return l[_indice];
    return widget.producto;
  }

  String _imagenDe(Producto p) {
    final d = p.imagenDestacada ?? '';
    if (d.isNotEmpty) return d;
    return p.imagenUrl ?? '';
  }

  @override
  void initState() {
    super.initState();
    _indice = widget.indiceInicial;
    _pageController = PageController(initialPage: widget.indiceInicial);
    // 🔥 Reproducir el audio del producto (si tiene) al abrir
    final audio = _productoActual?.audioUrl ?? '';
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

  Future<void> _alCambiarPagina(int i) async {
    setState(() {
      _indice = i;
      _audioSonando = false;
    });
    await _audioPlayer.stop();
    final audio = _productoActual?.audioUrl ?? '';
    if (audio.isNotEmpty) _reproducirAudio(audio);
  }

  Future<void> _pausarAudio() async {
    await _audioPlayer.pause();
    if (mounted) setState(() => _audioSonando = false);
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _pageController.dispose();
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
          _productoActual?.nombre ?? widget.nombreProducto,
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
          // 🔥 SCROLL VERTICAL ENTRE DESTACADOS (sin zoom)
          if (_lista.length > 1)
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: _lista.length,
                onPageChanged: _alCambiarPagina,
                itemBuilder: (context, i) {
                  final img = _imagenDe(_lista[i]);
                  return Center(
                    child: img.isEmpty
                        ? const Icon(Icons.image, size: 80, color: Colors.grey)
                        : Image.network(
                            'https://mimarketplace-production.up.railway.app$img',
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                                Icons.broken_image,
                                size: 80,
                                color: Colors.grey),
                          ),
                  );
                },
              ),
            ),

          // 🔥 IMAGEN A PANTALLA COMPLETA (un solo producto: conserva zoom)
          if (_lista.length <= 1)
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
          if ((_productoActual?.audioUrl ?? '').isNotEmpty)
            Positioned(
              top: 100,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  if (_audioSonando) {
                    _pausarAudio();
                  } else {
                    _reproducirAudio(_productoActual!.audioUrl!);
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
          if (_productoActual != null)
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
                        producto: _productoActual!,
                        reproducirAudio: false, // 🔊 ya sonó en la imagen destacada
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