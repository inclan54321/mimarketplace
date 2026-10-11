import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'imagenes_producto_screen.dart';
class MapaEntregaScreen extends StatefulWidget {
  final String categoria;
  final String subcategoria;

  const MapaEntregaScreen({
    super.key,
    required this.categoria,
    required this.subcategoria,
  });

  @override
  State<MapaEntregaScreen> createState() => _MapaEntregaScreenState();
}

class _MapaEntregaScreenState extends State<MapaEntregaScreen> {
  MapLibreMapController? _controller;
  LatLng selectedPosition = const LatLng(9.9281, -84.0907);
  Symbol? _pinActual;
  bool _imagenCargada = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona ubicación para: ${widget.subcategoria}'),
        backgroundColor: const Color(0xFF087FE8),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
           onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ImagenesProductoScreen(
        categoria: widget.categoria,
        subcategoria: widget.subcategoria,
        direccion: 'Lat: ${selectedPosition.latitude}, Lng: ${selectedPosition.longitude}',
      ),
    ),
  );
},
            child: const Text(
              'Siguiente',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
  children: [
    const Padding(
      padding: EdgeInsets.all(12),
      child: Text(
        'Toca en el mapa para seleccionar la ubicación',
        style: TextStyle(fontSize: 14),
      ),
    ),
    Expanded(
      child: MapLibreMap(
        styleString: 'https://tiles.openfreemap.org/styles/liberty',
        initialCameraPosition: CameraPosition(
          target: selectedPosition,
          zoom: 14,
        ),
        onMapCreated: (controller) {
          _controller = controller;
        },
        onStyleLoadedCallback: () async {
          try {
            final Uint8List bytes = await _crearIconoDesdeFlutter(
              Icons.push_pin,
              Colors.red,
            );
            await _controller?.addImage('chinche', bytes);
            _imagenCargada = true;
            debugPrint('>>> Ícono registrado en el mapa');
          } catch (e) {
            debugPrint('Error al crear ícono: $e');
          }

          await _dibujarPin(selectedPosition);
        },
        onMapClick: (point, coordinates) async {
          debugPrint('>>> TAP: ${coordinates.latitude}, ${coordinates.longitude}');
          if (_imagenCargada) {
            await _moverPin(coordinates);
          }
        },
      ),
    ),
    // ===== UBICACIÓN SELECCIONADA =====
    Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ubicación seleccionada:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Lat: ${selectedPosition.latitude.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Lng: ${selectedPosition.longitude.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    ),
  ],
),
    );
  }

  // 🔥 CONVERTIR UN IconData DE FLUTTER EN PNG
  Future<Uint8List> _crearIconoDesdeFlutter(
    IconData icono,
    Color color, {
    double size = 128,
  }) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final TextPainter painter = TextPainter(textDirection: TextDirection.ltr);

    painter.text = TextSpan(
      text: String.fromCharCode(icono.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: icono.fontFamily,
        package: icono.fontPackage,
        color: color,
        shadows: const [
          Shadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );

    painter.layout();
    painter.paint(
      canvas,
      Offset((size - painter.width) / 2, (size - painter.height) / 2),
    );

    final ui.Image image = await recorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
        );
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _dibujarPin(LatLng posicion) async {
    try {
      _pinActual = await _controller!.addSymbol(
        SymbolOptions(
          geometry: posicion,
          iconImage: 'chinche',
          iconSize: 0.35,
          iconAnchor: 'bottom',
        ),
      );
    } catch (e) {
      debugPrint('Error al dibujar pin: $e');
    }
  }

  Future<void> _moverPin(LatLng nuevaPosicion) async {
    try {
      setState(() {
        selectedPosition = nuevaPosicion;
      });

      if (_pinActual != null) {
        await _controller!.removeSymbol(_pinActual!);
      }
      await _dibujarPin(nuevaPosicion);
    } catch (e) {
      debugPrint('Error al mover pin: $e');
    }
  }
}