import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/rewarded_ad_prueba.dart';

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  List<Map<String, dynamic>> _alertas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarAlertas();
  }

  Future<void> _cargarAlertas() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final response = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/alertas/${user.uid}'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _alertas = data.map((item) => Map<String, dynamic>.from(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _renovarProducto(Map<String, dynamic> alerta) async {
    final productoId = alerta['producto_id'];
    if (productoId == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (!RewardedAdManager.isAdLoaded) {
      RewardedAdManager.loadRewardedAd();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏳ Cargando anuncio... espera un momento'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    RewardedAdManager.showRewardedAd(
      onRewarded: () async {
        try {
          final response = await http.post(
            Uri.parse('https://mimarketplace-production.up.railway.app/api/productos/renovar/$productoId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'usuario_id': user.uid}),
          );

          if (response.statusCode == 200) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Producto renovado por 30 días más'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            await _cargarAlertas();
          } else {
            throw Exception('Error al renovar');
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al renovar: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      onDismissed: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Debes ver el anuncio completo para renovar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Future<void> _limpiarAlertas() async {
    if (_alertas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay alertas para limpiar'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🗑️ Limpiar alertas'),
          content: const Text(
            '¿Estás seguro de que quieres eliminar todas las alertas?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar todo'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final response = await http.delete(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/alertas/limpiar/${user.uid}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _alertas.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Todas las alertas han sido eliminadas'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Error al limpiar alertas');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al limpiar alertas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        backgroundColor: const Color(0xFF087FE8),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarAlertas,
            tooltip: 'Recargar',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            onPressed: _limpiarAlertas,
            tooltip: 'Limpiar todas las alertas',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alertas.isEmpty
              ? const Center(
                  child: Text(
                    'No tienes alertas',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _alertas.length,
                  itemBuilder: (context, index) {
                    final alerta = _alertas[index];
                    final esLeida = alerta['leida'] ?? false;
                    final tipo = alerta['tipo'] ?? 'info';
                    final mensaje = alerta['mensaje'] ?? '';
                    final fecha = alerta['fecha'] != null
                        ? DateTime.parse(alerta['fecha']).toString().substring(0, 16)
                        : '';
                    final productoId = alerta['producto_id'];

                    Color rayaColor = Colors.grey;
                    IconData icono = Icons.info;
                    Color iconoColor = Colors.grey;

                    if (tipo == 'exito') {
                      rayaColor = Colors.green;
                      icono = Icons.check_circle;
                      iconoColor = Colors.green;
                    } else if (tipo == 'error') {
                      rayaColor = Colors.red;
                      icono = Icons.error;
                      iconoColor = Colors.red;
                    } else if (tipo == 'pendiente') {
                      rayaColor = Colors.orange;
                      icono = Icons.hourglass_top;
                      iconoColor = Colors.orange;
                    } else if (tipo == 'caducado') {
                      rayaColor = Colors.red;
                      icono = Icons.timer_off;
                      iconoColor = Colors.red;
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: tipo == 'caducado' ? 100 : 70,
                            decoration: BoxDecoration(
                              color: rayaColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    icono,
                                    color: iconoColor,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          mensaje.replaceAll(RegExp(r'[✅❌📝🔔⏰]'), '').trim(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: esLeida ? Colors.grey : Colors.black87,
                                            fontWeight: esLeida ? FontWeight.normal : FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          fecha,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        if (tipo == 'caducado' && productoId != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: ElevatedButton.icon(
                                              onPressed: () => _renovarProducto(alerta),
                                              icon: const Icon(Icons.refresh, size: 16),
                                              label: const Text('Renovar por 30 días'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 4,
                                                ),
                                                textStyle: const TextStyle(fontSize: 12),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (!esLeida)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}