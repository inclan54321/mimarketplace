import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  late LatLng selectedPosition;
  late MapController mapController;

  @override
  void initState() {
    super.initState();
    selectedPosition = LatLng(9.9281, -84.0907);
    mapController = MapController();
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
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: selectedPosition,
          initialZoom: 14,
          onTap: (_, LatLng position) {
            setState(() {
              selectedPosition = position;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.mimarketplace',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: selectedPosition,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
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
}