import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import '../widgets/rewarded_ad_prueba.dart';
import 'pantalla_verificacion_encuentro.dart';
import 'pantalla_verificar_identidad_otro.dart';

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  // 🔥 Caché en memoria: sobrevive mientras la app esté abierta
  static List<Map<String, dynamic>>? _alertasCache;
  static Map<int, Map<String, bool>>? _estadosCache;

  List<Map<String, dynamic>> _alertas = [];
  bool _isLoading = true;
  final Map<int, Map<String, bool>> _estadosVerificacion = {};

  @override
  void initState() {
    super.initState();
    // 🔥 Mostrar caché para no ver pantalla vacía mientras carga
    if (_alertasCache != null) {
      _alertas = List.from(_alertasCache!);
      if (_estadosCache != null) {
        _estadosVerificacion.addAll(_estadosCache!);
      }
      _isLoading = false;
    }
    // 🔥 PERO siempre pedir al backend. Si hay algo nuevo, el setState lo pinta.
    _cargarAlertas();
  }

  Future<void> _cargarAlertas() async {
    print('>>> 🔍 _cargarAlertas INICIADO');
    try {
      final user = FirebaseAuth.instance.currentUser;
      print('>>> 🔍 user.uid: ${user?.uid}');
      if (user == null) return;

      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/alertas/${user.uid}'),
        headers: {
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );

      print('>>> 🔍 STATUS HTTP: ${response.statusCode}');
      print('>>> 🔍 BODY RAW: ${response.body}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final nuevas = data.map((item) => Map<String, dynamic>.from(item)).toList();

        print('>>> 🔍 ALERTAS DEL BACKEND: ${nuevas.length}');
        for (final a in nuevas) {
          print('>>>   id=${a['id']} tipo=${a['tipo']} producto_id=${a['producto_id']} leida=${a['leida']}');
        }

        // 🔥 PRINT 1: cuántas alertas llegaron del backend
        print('>>> 🔍 ALERTAS DEL BACKEND: ${nuevas.length}');
        print('>>> 🔍 DETALLE:');
        for (final a in nuevas) {
          print('>>>   id=${a['id']} tipo=${a['tipo']} producto_id=${a['producto_id']} leida=${a['leida']} mensaje=${a['mensaje']}');
        }

        // 🔥 PRINT 2: cuántas alertas tiene la app ahora
        print('>>> 🔍 ALERTAS EN APP (antes): ${_alertas.length}');

        debugPrint('>>> 🔔 Alertas recibidas: ${nuevas.length} para ${user.uid}');

        // 🔥 Usar la lista NUEVA para cargar los estados de verificación
        // (sin asignar todavía a _alertas, para que el setState detecte el cambio)
        final listaAnterior = _alertas;
        _alertas = nuevas;
        await _cargarEstadosVerificacion(silencioso: true);

        // 🔥 Solo repintar si cambió algo o si estamos cargando
        final cambio = _isLoading ||
            listaAnterior.length != nuevas.length ||
            (nuevas.isNotEmpty &&
                (listaAnterior.isEmpty || listaAnterior.first['id'] != nuevas.first['id']));

        if (mounted && cambio) {
          setState(() {
            _alertas = nuevas;
            _isLoading = false;
          });
        } else if (mounted && !cambio) {
          // Igual actualizar por si acaso el widget no estaba reconstruido
          _alertas = nuevas;
          _isLoading = false;
        }

        _alertasCache = List.from(_alertas);
        _estadosCache = Map.from(_estadosVerificacion);

        // 🔥 Marcar todas como leídas
        final idTokenMarcar = await FirebaseAuth.instance.currentUser?.getIdToken();
        await http.put(
          Uri.parse(
              'https://mimarketplace-production.up.railway.app/api/alertas/marcar-leidas/${user.uid}'),
          headers: {
            if (idTokenMarcar != null) 'Authorization': 'Bearer $idTokenMarcar',
          },
        );
      } else {
        debugPrint('>>> ❌ Alertas status ${response.statusCode}: ${response.body}');
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('>>> ❌ Error cargando alertas: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cargarEstadosVerificacion({bool silencioso = false}) async {
    final idsUnicos = <int>{};
    for (final a in _alertas) {
      final eid = (a['encuentro_id'] ?? 0) as int;
      if (eid > 0) idsUnicos.add(eid);
    }
    if (idsUnicos.isEmpty) return;

    for (final eid in idsUnicos) {
      try {
        final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
        final r = await http.get(
          Uri.parse('https://mimarketplace-production.up.railway.app/api/encuentro/$eid/mi-estado-verificacion'),
          headers: {if (idToken != null) 'Authorization': 'Bearer $idToken'},
        );
        debugPrint('>>> mi-estado-verificacion [$eid] status: ${r.statusCode} body: ${r.body}');
        if (r.statusCode == 200) {
          final data = jsonDecode(r.body) as Map<String, dynamic>;

          bool yoAsist = false;
          bool otroAsist = false;
          bool ambosAsist = false;
          try {
            final rAsist = await http.get(
              Uri.parse('https://mimarketplace-production.up.railway.app/api/encuentro/$eid/asistencia'),
              headers: {if (idToken != null) 'Authorization': 'Bearer $idToken'},
            );
            if (rAsist.statusCode == 200) {
              final a = jsonDecode(rAsist.body) as Map<String, dynamic>;
              yoAsist = a['yo_confirmado'] == true;
              otroAsist = a['otro_confirmado'] == true;
              ambosAsist = a['ambos_confirmaron'] == true;
            }
          } catch (_) {}

          _estadosVerificacion[eid] = {
            'mi_selfie': data['mi_selfie_existe'] == true,
            'otro_selfie': data['otro_selfie_existe'] == true,
            'confirmado': data['mi_confirmacion_cruzada'] == true,
            'rechazado': data['mi_rechazo_cruzado'] == true,
            'yo_asist': yoAsist,
            'otro_asist': otroAsist,
            'ambos_asist': ambosAsist,
          };
        }
      } catch (e) {
        debugPrint('>>> Error cargando estado [$eid]: $e');
      }
    }
    _estadosCache = Map.from(_estadosVerificacion);
    if (mounted && !silencioso) setState(() {});
  }

  Future<void> _confirmarAsistencia(int encuentroId) async {
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final r = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/encuentro/$encuentroId/confirmar-asistencia'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        final ambos = data['ambos_confirmaron'] == true;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ambos
                  ? '✅ Ambos confirmaron. ¡Nos vemos!'
                  : '✅ Confirmaste tu asistencia. Esperando al otro.'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _cargarEstadosVerificacion();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildBotonConfirmarAsistencia({required int encuentroId}) {
    final estado = _estadosVerificacion[encuentroId];
    final yoAsist = estado?['yo_asist'] == true;
    final otroAsist = estado?['otro_asist'] == true;

    if (yoAsist && otroAsist) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check_circle, size: 16, color: Colors.green),
        label: const Text('Ambos confirmaron', style: TextStyle(color: Colors.green)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          textStyle: const TextStyle(fontSize: 12),
        ),
      );
    }

    if (yoAsist && !otroAsist) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.hourglass_top, size: 16, color: Colors.grey),
        label: const Text('Esperando al otro', style: TextStyle(color: Colors.grey)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          textStyle: const TextStyle(fontSize: 12),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _confirmarAsistencia(encuentroId),
      icon: const Icon(Icons.check_circle_outline, size: 16),
      label: const Text('Confirmar encuentro'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0A5BE0),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildBotonVerificacion({required int encuentroId}) {
    final estado = _estadosVerificacion[encuentroId];
    final miSelfie = estado?['mi_selfie'] ?? false;
    final otroSelfie = estado?['otro_selfie'] ?? false;
    final confirmado = estado?['confirmado'] ?? false;
    final rechazado = estado?['rechazado'] ?? false;

    // 1. Yo no me tomé la selfie → "Verificar identidad"
    if (!miSelfie) {
      return ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PantallaVerificacionEncuentro(encuentroId: encuentroId),
            ),
          ).then((_) async {
            await _cargarEstadosVerificacion();
          });
        },
        icon: const Icon(Icons.verified_user, size: 16),
        label: const Text('Verificar identidad'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A5BE0),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          textStyle: const TextStyle(fontSize: 12),
        ),
      );
    }

    // 2. Yo sí, el otro no → "Esperando al otro"
    if (!otroSelfie) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.hourglass_top, size: 16, color: Colors.grey),
        label: const Text('Esperando al otro', style: TextStyle(color: Colors.grey)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          textStyle: const TextStyle(fontSize: 12),
        ),
      );
    }

    // 3. Ambos selfies, no confirmé → "Verificar identidad del otro"
    if (!confirmado && !rechazado) {
      return ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PantallaVerificarIdentidadOtro(encuentroId: encuentroId),
            ),
          ).then((_) async {
            await _cargarEstadosVerificacion();
          });
        },
        icon: const Icon(Icons.face_retouching_natural, size: 16),
        label: const Text('Verificar identidad del otro'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A5BE0),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          textStyle: const TextStyle(fontSize: 12),
        ),
      );
    }

    // 4. Ya rechacé → "Identidad rechazada" (deshabilitado)
    if (rechazado) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.cancel, size: 16, color: Colors.grey),
        label: const Text('Identidad rechazada', style: TextStyle(color: Colors.grey)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          textStyle: const TextStyle(fontSize: 12),
        ),
      );
    }

    // 5. Ya confirmé → "Revisar comparación"
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PantallaVerificarIdentidadOtro(encuentroId: encuentroId),
          ),
        ).then((_) async {
          await _cargarEstadosVerificacion();
        });
      },
      icon: const Icon(Icons.search, size: 16),
      label: const Text('Revisar comparación'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  Future<void> _renovarProducto(Map<String, dynamic> alerta) async {
    final productoId = alerta['producto_id'];
    if (productoId == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (!RewardedAdManager.isAdLoaded) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏳ Cargando anuncio... espera un momento'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      // 🔥 Esperar a que el anuncio realmente termine de cargar
      final cargado = await RewardedAdManager.waitForAdLoaded();

      if (!cargado) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ No se pudo cargar el anuncio. Intentá de nuevo.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    RewardedAdManager.showRewardedAd(
      onRewarded: () async {
        try {
          final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
          final response = await http.post(
            Uri.parse('https://mimarketplace-production.up.railway.app/api/productos/renovar/$productoId'),
            headers: {
              'Content-Type': 'application/json',
              if (idToken != null) 'Authorization': 'Bearer $idToken',
            },
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

  String _limpiarMensaje(String mensaje) {
    final limpio = mensaje
        .replaceAll(
          RegExp(
            r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}\u{FE0F}\u{200D}]',
            unicode: true,
          ),
          '',
        )
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .trim();

    return limpio.isEmpty ? mensaje.trim() : limpio;
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

      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.delete(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/alertas/limpiar/${user.uid}'),
        headers: {
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _alertas.clear();
        });
        _alertasCache = [];
        _estadosCache = {};
        _estadosVerificacion.clear();
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
    print('>>> 🎨 BUILD AlertasScreen: _isLoading=$_isLoading, _alertas.length=${_alertas.length}');
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Alertas',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.3),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A5BE0), Color(0xFF1E9BF0), Color(0xFF0A5BE0)],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              // 🔥 Forzar recarga limpia: descartar caché y pedir fresco
              setState(() {
                _isLoading = true;
              });
              await _cargarAlertas();
            },
            tooltip: 'Recargar',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: _limpiarAlertas,
            tooltip: 'Limpiar todas las alertas',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 📱 Contenido (fondo negro puro)
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _alertas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0F2447),
                          border: Border.all(
                            color: const Color(0xFF00E676).withValues(alpha: 0.7),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E676).withValues(alpha: 0.35),
                              blurRadius: 22,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          size: 46,
                          color: Color(0xFF00E676),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No tienes alertas',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0A3D91),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Aquí aparecerán tus avisos y encuentros.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _alertas.length,
                  itemBuilder: (context, index) {
                    final alerta = _alertas[index];
                    print('>>> 🎨 DIBUJANDO ALERTA $index: id=${alerta['id']} tipo=${alerta['tipo']} producto_id=${alerta['producto_id']}');
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
                    } else if (tipo == 'encuentro') {
                      rayaColor = Colors.blue;
                      icono = Icons.event_available;
                      iconoColor = Colors.blue;
                    } else if (tipo == 'recordatorio_encuentro') {
                      rayaColor = Colors.orange;
                      icono = Icons.alarm;
                      iconoColor = Colors.orange;
                    } else if (tipo == 'recordatorio_10m') {
                      rayaColor = Colors.deepOrange;
                      icono = Icons.face_retouching_natural;
                      iconoColor = Colors.deepOrange;
                    } else if (tipo == 'confirmacion_asistencia') {
                      rayaColor = Colors.green;
                      icono = Icons.check_circle_outline;
                      iconoColor = Colors.green;
                    } else if (tipo == 'esperando_verificacion') {
                      rayaColor = Colors.orange;
                      icono = Icons.hourglass_top;
                      iconoColor = Colors.orange;
                    } else if (tipo == 'verificar_identidad') {
                      rayaColor = const Color(0xFF0A5BE0);
                      icono = Icons.face_retouching_natural;
                      iconoColor = const Color(0xFF0A5BE0);
                    } else if (tipo == 'no_presentado') {
                      rayaColor = Colors.red;
                      icono = Icons.location_off;
                      iconoColor = Colors.red;
                    } else if (tipo == 'trato_cancelado') {
                      rayaColor = Colors.red;
                      icono = Icons.cancel;
                      iconoColor = Colors.red;
                    } else if (tipo == 'chat_desbloqueado') {
                      rayaColor = Colors.green;
                      icono = Icons.lock_open;
                      iconoColor = Colors.green;
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.black,
                            Colors.black,
                          ],
                        ),
                        border: Border.all(
                          color: rayaColor.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: rayaColor.withValues(alpha: 0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            constraints: const BoxConstraints(minHeight: 70),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  rayaColor,
                                  rayaColor.withValues(alpha: 0.55),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: rayaColor.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: iconoColor.withValues(alpha: 0.12),
                                      border: Border.all(
                                        color: iconoColor.withValues(alpha: 0.45),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: iconoColor.withValues(alpha: 0.25),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Icon(icono, color: iconoColor, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _limpiarMensaje(mensaje),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: esLeida ? FontWeight.normal : FontWeight.w600,
                                          ),
                                          maxLines: (tipo == 'encuentro' || tipo == 'recordatorio_encuentro') ? 10 : 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          fecha,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white70,
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
                                        // 🔥 BOTÓN DE CONFIRMAR ASISTENCIA (solo 1h y confirmación)
                                        if ((tipo == 'recordatorio_encuentro' ||
                                                tipo == 'confirmacion_asistencia') &&
                                            (alerta['encuentro_id'] ?? 0) > 0)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: _buildBotonConfirmarAsistencia(
                                              encuentroId: (alerta['encuentro_id'] as num).toInt(),
                                            ),
                                          ),
                                        // 🔥 BOTÓN DE VERIFICACIÓN FACIAL (solo 10min)
                                        if (tipo == 'recordatorio_10m' &&
                                            (alerta['encuentro_id'] ?? 0) > 0)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: _buildBotonVerificacion(
                                              encuentroId: (alerta['encuentro_id'] as num).toInt(),
                                            ),
                                          ),
                                        // 🔥 BOTÓN DE VERIFICACIÓN (para las otras alertas)
                                        if ((tipo == 'encuentro' ||
                                                tipo == 'esperando_verificacion' ||
                                                tipo == 'verificar_identidad') &&
                                            (alerta['encuentro_id'] ?? 0) > 0)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: _buildBotonVerificacion(
                                              encuentroId: (alerta['encuentro_id'] as num).toInt(),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (!esLeida)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00E676),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF00E676).withValues(alpha: 0.7),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
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
        ],
      ),
    );
  }
}

// ============================================================
// 🎨 GEOMETRIC BACKGROUND PAINTER (copiado de SellScreen)
// ============================================================
class _GeometricBackgroundPainter extends CustomPainter {
  const _GeometricBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    _drawHexagon(
      canvas,
      center: Offset(width * 0.75, height * 0.35),
      radius: width * 0.6,
      color: const Color(0xFF3B82F6),
      alpha: 0.9,
    );

    _drawHexagon(
      canvas,
      center: Offset(width * 0.15, height * 0.2),
      radius: width * 0.45,
      color: const Color(0xFF06B6D4),
      alpha: 0.7,
    );

    _drawHexagon(
      canvas,
      center: Offset(width * 0.5, height * 0.85),
      radius: width * 0.55,
      color: const Color(0xFF8B5CF6),
      alpha: 0.6,
    );

    _drawTriangle(
      canvas,
      center: Offset(width * 0.5, height * 0.1),
      radius: width * 0.4,
      color: const Color(0xFF60A5FA),
      alpha: 0.5,
    );

    _drawDiamond(
      canvas,
      center: Offset(width * 0.9, height * 0.75),
      radius: width * 0.35,
      color: const Color(0xFF0891B2),
      alpha: 0.6,
    );
  }

  void _drawHexagon(Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
    required double alpha,
  }) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * (math.pi / 180);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, paint);
  }

  void _drawTriangle(Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
    required double alpha,
  }) {
    final path = Path();
    for (int i = 0; i < 3; i++) {
      final angle = (i * 120 - 90) * (math.pi / 180);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
    required double alpha,
  }) {
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx + radius, center.dy);
    path.lineTo(center.dx, center.dy + radius);
    path.lineTo(center.dx - radius, center.dy);
    path.close();

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}