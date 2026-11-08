import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class SeleccionarLugarMapaScreen extends StatefulWidget {
  final LatLng? inicial;

  const SeleccionarLugarMapaScreen({super.key, this.inicial});

  @override
  State<SeleccionarLugarMapaScreen> createState() =>
      _SeleccionarLugarMapaScreenState();
}

class _SeleccionarLugarMapaScreenState
    extends State<SeleccionarLugarMapaScreen> {
  MapLibreMapController? _controller;
  late LatLng _posicion;
  Symbol? _pin;
  bool _imagenCargada = false;

  @override
  void initState() {
    super.initState();
    _posicion = widget.inicial ?? const LatLng(9.9281, -84.0907);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegí el lugar del encuentro'),
        backgroundColor: const Color(0xFF0A5BE0),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'lat': _posicion.latitude,
                'lng': _posicion.longitude,
              });
            },
            child: const Text(
              'Confirmar',
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
              'Tocá en el mapa para marcar el punto exacto del encuentro.\nElegí un lugar público y concurrido.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            child: MapLibreMap(
              styleString: 'https://tiles.openfreemap.org/styles/liberty',
              initialCameraPosition: CameraPosition(
                target: _posicion,
                zoom: 14,
              ),
              onMapCreated: (c) => _controller = c,
              onStyleLoadedCallback: () async {
                try {
                  final Uint8List bytes =
                      await _crearIconoDesdeFlutter(Icons.place, Colors.red);
                  await _controller?.addImage('pin_lugar', bytes);
                  _imagenCargada = true;
                } catch (e) {
                  debugPrint('Error ícono: $e');
                }
                await _controller?.animateCamera(
                  CameraUpdate.newLatLngZoom(_posicion, 14),
                );
                await _dibujarPin(_posicion);
              },
              onMapClick: (point, coords) async {
                if (_imagenCargada) await _moverPin(coords);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                const Icon(Icons.place, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lat: ${_posicion.latitude.toStringAsFixed(6)}\n'
                    'Lng: ${_posicion.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Future<void> _dibujarPin(LatLng pos) async {
    try {
      _pin = await _controller!.addSymbol(
        SymbolOptions(
          geometry: pos,
          iconImage: 'pin_lugar',
          iconSize: 0.6,
          iconAnchor: 'bottom',
        ),
      );
    } catch (e) {
      debugPrint('Error pin: $e');
    }
  }

  Future<void> _moverPin(LatLng nueva) async {
    setState(() => _posicion = nueva);
    if (_pin != null) await _controller!.removeSymbol(_pin!);
    await _dibujarPin(nueva);
  }
}