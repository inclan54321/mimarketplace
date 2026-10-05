import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'reconocimiento_facial_screen.dart';
import '../widgets/rewarded_ad_prueba.dart';

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  List<Map<String, dynamic>> _alertas = [];
  bool _isLoading = true;

  // 🔥 ALERTA DE PRUEBA DE RECONOCIMIENTO FACIAL
  Map<String, dynamic>? _alertaTestReconocimiento;
  Timer? _timerTestReconocimiento;
  double _distanciaActual = 0;

  @override
  void initState() {
    super.initState();
    _cargarAlertas();
  }

  @override
  void dispose() {
    _timerTestReconocimiento?.cancel();
    super.dispose();
  }

  void _iniciarAlertaTest() async {
    if (_alertaTestReconocimiento != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏳ Ya hay una verificación pendiente'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 🔥 OBTENER UBICACIÓN ACTUAL
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Se necesita permiso de ubicación'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      final posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _distanciaActual = 0;
        _alertaTestReconocimiento = {
          'tipo': 'test_reconocimiento',
          'fecha_inicio': DateTime.now(),
          'segundos_restantes': 20,
          'lista_para_verificar': false,
          'lat_objetivo': posicion.latitude,
          'lng_objetivo': posicion.longitude,
        };
      });

      _timerTestReconocimiento =
          Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (_alertaTestReconocimiento == null) {
          timer.cancel();
          return;
        }

        final segundosRestantes =
            _alertaTestReconocimiento!['segundos_restantes'] as int;

        if (segundosRestantes <= 1) {
          timer.cancel();

          // 🔥 VERIFICAR UBICACIÓN
          final dentro = await _estoyEnLaUbicacion(
            _alertaTestReconocimiento!['lat_objetivo'] as double,
            _alertaTestReconocimiento!['lng_objetivo'] as double,
          );

          if (!mounted) return;

          if (dentro) {
            setState(() {
              _alertaTestReconocimiento!['segundos_restantes'] = 0;
              _alertaTestReconocimiento!['lista_para_verificar'] = true;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🔔 Es hora de verificar tu identidad'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          } else {
            setState(() {
              _alertaTestReconocimiento = null;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ No estás en la ubicación acordada'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          }
        } else {
          setState(() {
            _alertaTestReconocimiento!['segundos_restantes'] =
                segundosRestantes - 1;
          });
        }
      });
    } catch (e) {
      print('Error al obtener ubicación: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener ubicación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🔥 VERIFICAR SI ESTOY EN LA UBICACIÓN
  Future<bool> _estoyEnLaUbicacion(double latObjetivo, double lngObjetivo) async {
    try {
      final posicionActual = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final distancia = Geolocator.distanceBetween(
        posicionActual.latitude,
        posicionActual.longitude,
        latObjetivo,
        lngObjetivo,
      );

      print('>>> Distancia a la ubicación objetivo: ${distancia.toStringAsFixed(1)} metros');

      if (mounted) {
        setState(() {
          _distanciaActual = distancia;
        });
      }

      return distancia <= 100; // 100 metros de radio
    } catch (e) {
      print('Error al verificar ubicación: $e');
      return false;
    }
  }

  void _abrirModalReconocimiento() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.face_retouching_natural,
                    size: 48, color: Colors.red),
              ),
              const SizedBox(height: 16),
              const Text(
                'Verificación de identidad',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Necesitamos verificar tu identidad para continuar con el encuentro.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);

                    final user = FirebaseAuth.instance.currentUser;

                    final resultado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReconocimientoFacialScreen(
                          usuarioId: user?.uid ?? '',
                        ),
                      ),
                    );

                    if (resultado == true) {
                      _finalizarAlertaTest();
                    }
                  },
                  icon: const Icon(Icons.camera_front, size: 20),
                  label: const Text('Hacer reconocimiento facial'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Más tarde',
                    style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _finalizarAlertaTest() {
    _timerTestReconocimiento?.cancel();
    setState(() {
      _alertaTestReconocimiento = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📸 Reconocimiento facial iniciado'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildTarjetaTest() {
    if (_alertaTestReconocimiento == null) return const SizedBox.shrink();

    final segundos = _alertaTestReconocimiento!['segundos_restantes'] as int;
    final lista = _alertaTestReconocimiento!['lista_para_verificar'] as bool;
    final minutos = (segundos / 60).floor();
    final segs = segundos % 60;
    final tiempoFormateado =
        '${minutos.toString().padLeft(2, '0')}:${segs.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: lista ? _abrirModalReconocimiento : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: lista ? Colors.red.shade50 : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: lista ? Colors.red : Colors.orange,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 90,
              decoration: BoxDecoration(
                color: lista ? Colors.red : Colors.orange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      lista ? Icons.face_retouching_natural : Icons.timer,
                      color: lista ? Colors.red : Colors.orange,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lista
                                ? 'Es hora de verificar tu identidad'
                                : 'Verificación de identidad pendiente',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color:
                                  lista ? Colors.red : Colors.orange.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lista
                                ? 'Toca para hacer el reconocimiento facial'
                                : 'Disponible en $tiempoFormateado',
                            style: TextStyle(
                              fontSize: 12,
                              color: lista
                                  ? Colors.red.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Distancia: ${_distanciaActual.toStringAsFixed(1)}m',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (lista)
                      const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

        // 🔥 Marcar todas como leídas en el backend
        await http.put(
          Uri.parse(
              'https://mimarketplace-production.up.railway.app/api/alertas/marcar-leidas/${user.uid}'),
        );
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
            icon: const Icon(Icons.bug_report, color: Colors.yellow),
            onPressed: _iniciarAlertaTest,
            tooltip: 'Test: Reconocimiento facial',
          ),
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
          : ListView(
              children: [
                _buildTarjetaTest(),
                if (_alertas.isEmpty && _alertaTestReconocimiento == null)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'No tienes alertas',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ..._alertas.map((alerta) {
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
                  }),
              ],
            ),
    );
  }
}