import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _ubicacionCargada = false;

  String get _claveUbicacion =>
      'ultima_ubicacion_${widget.categoria}_${widget.subcategoria}';

  @override
  void initState() {
    super.initState();
    _cargarUltimaUbicacion();
  }

  @override
  void dispose() {
    debugPrint('🗺️ [PERF] MapaEntregaScreen dispose');
    _pinActual = null;
    _controller = null;
    super.dispose();
  }

  Future<void> _cargarUltimaUbicacion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('${_claveUbicacion}_lat');
      final lng = prefs.getDouble('${_claveUbicacion}_lng');
      if (lat != null && lng != null && mounted) {
        setState(() {
          selectedPosition = LatLng(lat, lng);
          _ubicacionCargada = true;
        });
        debugPrint('>>> 📍 Última ubicación cargada: $lat, $lng');
      } else {
        if (mounted) {
          setState(() => _ubicacionCargada = true);
        }
        debugPrint('>>> 📍 No hay ubicación guardada, usando default');
      }
    } catch (e) {
      debugPrint('Error al cargar última ubicación: $e');
      if (mounted) {
        setState(() => _ubicacionCargada = true);
      }
    }
  }

  Future<void> _guardarUltimaUbicacion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(
          '${_claveUbicacion}_lat', selectedPosition.latitude);
      await prefs.setDouble(
          '${_claveUbicacion}_lng', selectedPosition.longitude);
      debugPrint(
          '>>> 💾 Ubicación guardada: ${selectedPosition.latitude}, ${selectedPosition.longitude}');
    } catch (e) {
      debugPrint('Error al guardar última ubicación: $e');
    }
  }

  Future<void> _continuarSiguiente() async {
    await _guardarUltimaUbicacion();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ImagenesProductoScreen(
          categoria: widget.categoria,
          subcategoria: widget.subcategoria,
          direccion:
              'Lat: ${selectedPosition.latitude}, Lng: ${selectedPosition.longitude}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona ubicación para: ${widget.subcategoria}'),
        backgroundColor: const Color(0xFF087FE8),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _continuarSiguiente,
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
            child: !_ubicacionCargada
                ? const Center(child: CircularProgressIndicator())
                : RepaintBoundary(
                    child: MapLibreMap(
                      styleString:
                          'https://tiles.openfreemap.org/styles/liberty',
                      initialCameraPosition: CameraPosition(
                        target: selectedPosition,
                        zoom: 14,
                      ),
                      onMapCreated: (controller) {
                        _controller = controller;
                      },
                      onStyleLoadedCallback: () async {
                        try {
                          final Uint8List bytes =
                              await _crearIconoDesdeFlutter(
                            Icons.push_pin,
                            Colors.red,
                          );
                          await _controller?.addImage('chinche', bytes);
                          _imagenCargada = true;
                          debugPrint('>>> Ícono registrado en el mapa');
                        } catch (e) {
                          debugPrint('Error al crear ícono: $e');
                        }

                        await _controller?.animateCamera(
                          CameraUpdate.newLatLngZoom(selectedPosition, 14),
                        );

                        await _dibujarPin(selectedPosition);
                      },
                      onMapClick: (point, coordinates) async {
                        debugPrint(
                            '>>> TAP: ${coordinates.latitude}, ${coordinates.longitude}');
                        if (_imagenCargada) {
                          await _moverPin(coordinates);
                        }
                      },
                    ),
                  ),
          ),
          _UbicacionInfo(position: selectedPosition),
        ],
      ),
    );
  }

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
          iconSize: 0.6,
          iconAnchor: 'bottom',
        ),
      );
    } catch (e) {
      debugPrint('Error al dibujar pin: $e');
    }
  }

  Future<void> _moverPin(LatLng nuevaPosicion) async {
    try {
      if (_pinActual != null) {
        await _controller!.removeSymbol(_pinActual!);
      }
      await _dibujarPin(nuevaPosicion);

      if (mounted) {
        setState(() {
          selectedPosition = nuevaPosicion;
        });
      }

      _guardarUltimaUbicacion();
    } catch (e) {
      debugPrint('Error al mover pin: $e');
    }
  }
}

// ============================================================
// 🧩 WIDGET SEPARADO — coordenadas sin rebuild del mapa
// ============================================================
class _UbicacionInfo extends StatelessWidget {
  final LatLng position;

  const _UbicacionInfo({required this.position});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                'Lat: ${position.latitude.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Lng: ${position.longitude.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}