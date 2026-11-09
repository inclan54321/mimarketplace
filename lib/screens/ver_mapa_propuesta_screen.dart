import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class VerMapaPropuestaScreen extends StatefulWidget {
  final double lat;
  final double lng;
  final String titulo;

  const VerMapaPropuestaScreen({
    super.key,
    required this.lat,
    required this.lng,
    this.titulo = 'Ubicación del encuentro',
  });

  @override
  State<VerMapaPropuestaScreen> createState() => _VerMapaPropuestaScreenState();
}

class _VerMapaPropuestaScreenState extends State<VerMapaPropuestaScreen> {
  MapLibreMapController? _controller;
  Symbol? _pin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: const Color(0xFF0A5BE0),
        foregroundColor: Colors.white,
      ),
      body: MapLibreMap(
        styleString: 'https://tiles.openfreemap.org/styles/liberty',
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.lat, widget.lng),
          zoom: 16,
        ),
        onMapCreated: (c) => _controller = c,
        onStyleLoadedCallback: () async {
          try {
            // 🔥 Crear el ícono del pin desde Flutter
            final bytes = await _crearIconoDesdeFlutter(Icons.place, Colors.red);
            await _controller?.addImage('pin_rojo', bytes);
          } catch (e) {
            debugPrint('Error creando pin: $e');
          }
          await _controller?.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(widget.lat, widget.lng), 16),
          );
          _pin = await _controller?.addSymbol(
            SymbolOptions(
              geometry: LatLng(widget.lat, widget.lng),
              iconImage: 'pin_rojo',
              iconSize: 0.8,
              iconAnchor: 'bottom',
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A5BE0),
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.close, color: Colors.white),
      ),
    );
  }

  Future<Uint8List> _crearIconoDesdeFlutter(
    IconData icono,
    Color color, {
    double size = 128,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: String.fromCharCode(icono.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: icono.fontFamily,
        package: icono.fontPackage,
        color: color,
        shadows: const [
          Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset((size - painter.width) / 2, (size - painter.height) / 2),
    );
    final image =
        await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}