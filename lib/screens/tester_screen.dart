import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TesterScreen extends StatefulWidget {
  const TesterScreen({super.key});

  @override
  State<TesterScreen> createState() => _TesterScreenState();
}

class _TesterScreenState extends State<TesterScreen> {
  bool _cargando = true;
  bool _esTester = false;
  int _diasConectado = 0;
  List<int> _numerosElegidos = [];
  List<int> _numerosOcupados = [];
  final Set<int> _seleccionados = {};

  int _cupoTotal = 0;
  int _cupoLimite = 20;
  bool _cupoCerrado = false;

  // 🔥 ESTADO GLOBAL
  int _totalTesters = 0;
  int _conectadosHoy = 0;
  int _faltanHoy = 0;
  int _cumplen14Dias = 0;
  int _diasPrueba = 0;
  bool _pruebaCompleta = false;

  static const String _base = 'https://mimarketplace-production.up.railway.app';

  @override
  void initState() {
    super.initState();
    _cargarEstado();
  }

  Future<void> _cargarEstado() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _cargando = false);
        return;
      }
      final token = await user.getIdToken();

      final r = await http.get(
        Uri.parse('$_base/api/tester/mi-info'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final ocupados = await http.get(
        Uri.parse('$_base/api/tester/numeros-ocupados'),
      );
      final cupo = await http.get(
        Uri.parse('$_base/api/tester/cupo'),
      );
      final global = await http.get(
        Uri.parse('$_base/api/tester/estado-global'),
      );

      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        setState(() {
          _esTester = data['es_tester'] == true;
          if (_esTester) {
            _diasConectado = data['dias_conectado'] ?? 0;
            _numerosElegidos = List<int>.from(data['numeros_elegidos'] ?? []);
          }
        });
      }
      if (ocupados.statusCode == 200) {
        final d = jsonDecode(ocupados.body);
        setState(() {
          _numerosOcupados = List<int>.from(d['ocupados'] ?? []);
        });
      }
      if (cupo.statusCode == 200) {
        final c = jsonDecode(cupo.body);
        setState(() {
          _cupoTotal = c['total'] ?? 0;
          _cupoLimite = c['limite'] ?? 20;
          _cupoCerrado = c['cerrado'] == true;
        });
      }
      if (global.statusCode == 200) {
        final g = jsonDecode(global.body);
        setState(() {
          _totalTesters = g['total_testers'] ?? 0;
          _conectadosHoy = g['conectados_hoy'] ?? 0;
          _faltanHoy = g['faltan_hoy'] ?? 0;
          _cumplen14Dias = g['cumplen_14_dias'] ?? 0;
          _diasPrueba = g['dias_prueba'] ?? 0;
          _pruebaCompleta = g['prueba_completa'] == true;
        });
      }
    } catch (e) {
      debugPrint('Error cargando tester: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _mostrarAvisoYRegistrar() async {
    if (_cupoCerrado) return;

    final aceptado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF087FE8)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Antes de registrarte, leé esto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ser tester NO es solo instalar la app. Google exige que la prueba dure MÍNIMO 14 DÍAS CONSECUTIVOS, '
                'con al menos 12 testers activos. Y cada tester debe entrar a la app TODOS LOS DÍAS, '
                'sin saltarse ninguno. Si un día no entrás, el contador puede reiniciarse.',
                style: TextStyle(fontSize: 14, height: 1.45),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.groups, color: Color(0xFF087FE8), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No alcanza con que VOS entres. Si los demás testers no entran todos los días, '
                        'el proceso queda incompleto y la app no puede avanzar a producción. '
                        'Los 14 días se cuentan desde que los 12 testers están activos y conectándose a diario.',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFF97316), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cupo limitado: solo se aceptan $_cupoLimite testers en total. '
                        'Google exige mínimo 12, pero registramos hasta $_cupoLimite por si alguno falla. '
                        'Actualmente hay $_cupoTotal registrados y quedan ${_cupoLimite - _cupoTotal} lugares. '
                        'Una vez lleno, no se aceptan más registros.',
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Text(
                  'RESUMEN DEL COMPROMISO:\n'
                  '• Entrar a la app TODOS LOS DÍAS, sin excepción, durante al menos 14 días.\n'
                  '• Aunque un día no entrés, el proceso puede reiniciarse y hay que empezar de nuevo.\n'
                  '• Si muchos testers fallan, la app no avanza y no se publica en Google Play.\n'
                  '• No se puede abandonar la prueba a mitad de camino.',
                  style: TextStyle(fontSize: 13, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF087FE8),
              foregroundColor: Colors.white,
            ),
            child: const Text('Entendido, continuar'),
          ),
        ],
      ),
    );

    if (aceptado != true) return;

    if (!mounted) return;
    setState(() => _seleccionados.clear());

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Elegí tus 5 números',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Del 1 al 100. Los grises ya están tomados.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 360,
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: List.generate(100, (i) {
                        final n = i + 1;
                        final ocupado = _numerosOcupados.contains(n);
                        final seleccionado = _seleccionados.contains(n);
                        return GestureDetector(
                          onTap: ocupado
                              ? null
                              : () {
                                  setSheetState(() {
                                    if (seleccionado) {
                                      _seleccionados.remove(n);
                                    } else if (_seleccionados.length < 5) {
                                      _seleccionados.add(n);
                                    }
                                  });
                                  setState(() {});
                                },
                          child: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: ocupado
                                  ? Colors.grey.shade300
                                  : seleccionado
                                      ? const Color(0xFF087FE8)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: ocupado
                                    ? Colors.grey.shade400
                                    : seleccionado
                                        ? const Color(0xFF087FE8)
                                        : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              '$n',
                              style: TextStyle(
                                fontSize: 12,
                                color: ocupado
                                    ? Colors.grey.shade500
                                    : seleccionado
                                        ? Colors.white
                                        : Colors.black,
                                fontWeight: seleccionado
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Seleccionados: ${_seleccionados.length}/5',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _seleccionados.length == 5
                        ? () {
                            Navigator.pop(ctx);
                            _registrar();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF087FE8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Confirmar registro'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _registrar() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final token = await user.getIdToken();

      final r = await http.post(
        Uri.parse('$_base/api/tester/registrar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'usuario_id': user.uid,
          'numeros': _seleccionados.toList(),
        }),
      );

      if (r.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Registrado como tester'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarEstado();
      } else {
        final err = jsonDecode(r.body);
        final codigo = err['codigo'] ?? '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              codigo == 'CUPO_LLENO'
                  ? 'El cupo de testers ya está lleno (20 máximo).'
                  : (err['error'] ?? 'Error'),
            ),
            backgroundColor: Colors.red,
          ),
        );
        _cargarEstado();
      }
    } catch (e) {
      debugPrint('Error al registrar tester: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tester'),
        backgroundColor: const Color(0xFF087FE8),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarEstado,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarEstado,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // 🔥 ESTADO DE LA PRUEBA (siempre visible)
                  _buildEstadoPrueba(),
                  const SizedBox(height: 20),
                  // 🔥 CONTENIDO SEGÚN SI ES TESTER O NO
                  if (_esTester)
                    ..._buildPanelTester()
                  else
                    ..._buildPantallaInicial(),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // 📊 ESTADO GLOBAL DE LA PRUEBA (visible para todos)
  // ============================================================
  Widget _buildEstadoPrueba() {
    final Color colorEstado;
    final String tituloEstado;
    final String descripcionEstado;

    if (_pruebaCompleta) {
      colorEstado = const Color(0xFF16A34A);
      tituloEstado = '✅ Prueba completa';
      descripcionEstado = 'Se cumplieron los 14 días con 12+ testers activos.';
    } else if (_totalTesters < 12) {
      colorEstado = const Color(0xFFF59E0B);
      tituloEstado = '⏳ Faltan testers';
      descripcionEstado = 'Google exige mínimo 12 testers activos. Faltan ${12 - _totalTesters}.';
    } else if (_diasPrueba < 14) {
      colorEstado = const Color(0xFF3B82F6);
      tituloEstado = '🔵 Prueba en curso';
      descripcionEstado = 'Día $_diasPrueba de 14. Faltan ${14 - _diasPrueba} días para completar.';
    } else {
      colorEstado = const Color(0xFFF59E0B);
      tituloEstado = '⏳ Aún no se cumplen los requisitos';
      descripcionEstado = 'Se necesitan 14 días consecutivos con 12 testers activos.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorEstado.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorEstado.withValues(alpha: 0.4), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assessment, color: colorEstado, size: 26),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tituloEstado,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: colorEstado,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            descripcionEstado,
            style: TextStyle(
              fontSize: 13,
              color: colorEstado.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 14),
          // BARRA DE PROGRESO DE DÍAS
          _buildBarraProgreso(
            label: 'Días de prueba',
            actual: _diasPrueba,
            total: 14,
            color: colorEstado,
          ),
          const SizedBox(height: 10),
          // BARRA DE PROGRESO DE TESTERS
          _buildBarraProgreso(
            label: 'Testers registrados',
            actual: _totalTesters,
            total: 12,
            color: colorEstado,
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 8),
          // ESTADÍSTICAS DETALLADAS
          Row(
            children: [
              Expanded(
                child: _buildStatMini(
                  icon: Icons.people,
                  label: 'Registrados',
                  valor: '$_totalTesters',
                  color: const Color(0xFF087FE8),
                ),
              ),
              Expanded(
                child: _buildStatMini(
                  icon: Icons.check_circle,
                  label: 'Entraron hoy',
                  valor: '$_conectadosHoy',
                  color: const Color(0xFF16A34A),
                ),
              ),
              Expanded(
                child: _buildStatMini(
                  icon: Icons.warning,
                  label: 'Faltan hoy',
                  valor: '$_faltanHoy',
                  color: _faltanHoy > 0
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatMini(
                  icon: Icons.calendar_month,
                  label: 'Día actual',
                  valor: '$_diasPrueba',
                  color: const Color(0xFF3B82F6),
                ),
              ),
              Expanded(
                child: _buildStatMini(
                  icon: Icons.verified,
                  label: 'Cumplen 14 días',
                  valor: '$_cumplen14Dias',
                  color: _cumplen14Dias >= 12
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFF59E0B),
                ),
              ),
              Expanded(
                child: _buildStatMini(
                  icon: Icons.flag,
                  label: 'Meta',
                  valor: '12 / 14d',
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          if (_faltanHoy > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Color(0xFFDC2626), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$_faltanHoy tester${_faltanHoy == 1 ? '' : 's'} aún no '
                      '${_faltanHoy == 1 ? 'ha' : 'han'} entrado hoy. '
                      'Recordales que deben conectarse todos los días.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBarraProgreso({
    required String label,
    required int actual,
    required int total,
    required Color color,
  }) {
    final pct = (actual / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500)),
            Text('$actual / $total',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _buildStatMini({
    required IconData icon,
    required String label,
    required String valor,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ============================================================
  // 📝 PANTALLA INICIAL (si no es tester)
  // ============================================================
  List<Widget> _buildPantallaInicial() {
    if (_cupoCerrado) {
      return [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: const Column(
            children: [
              Icon(Icons.group_off, size: 64, color: Color(0xFFDC2626)),
              SizedBox(height: 16),
              Text(
                'Cupo de testers lleno',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF991B1B),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Ya se registraron los 20 testers permitidos. '
                'No se aceptan más por ahora.',
                style: TextStyle(fontSize: 14, color: Color(0xFF7F1D1D)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ];
    }

    return [
      const Icon(Icons.bug_report, size: 64, color: Color(0xFF087FE8)),
      const SizedBox(height: 16),
      const Text(
        'Convertite en tester',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        'Quedan ${_cupoLimite - _cupoTotal} lugares de $_cupoLimite.',
        style: const TextStyle(fontSize: 15, color: Colors.grey),
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Color(0xFF087FE8), size: 20),
                SizedBox(width: 8),
                Text(
                  'Compromiso',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF087FE8),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Google exige mínimo 14 días consecutivos con 12 testers activos. '
              'Cada tester debe entrar TODOS LOS DÍAS. Si un día falta, el contador puede reiniciarse. '
              'Al registrarte, aceptás este compromiso.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _mostrarAvisoYRegistrar,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF087FE8),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Quiero ser tester',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    ];
  }

  // ============================================================
  // 🏅 PANEL DEL TESTER (si ya lo es)
  // ============================================================
  List<Widget> _buildPanelTester() {
    return [
      const Icon(Icons.verified_user, size: 64, color: Color(0xFF087FE8)),
      const SizedBox(height: 12),
      const Text(
        '¡Sos tester!',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 24),
      _buildCard(
        icon: Icons.calendar_today,
        titulo: 'Días conectado',
        valor: '$_diasConectado / 14',
      ),
      const SizedBox(height: 12),
      _buildCard(
        icon: Icons.timelapse,
        titulo: 'Días que faltan',
        valor: '${_diasConectado >= 14 ? 0 : 14 - _diasConectado}',
      ),
      const SizedBox(height: 12),
      _buildCard(
        icon: Icons.numbers,
        titulo: 'Tus números',
        valor: _numerosElegidos.join(', '),
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFED7AA)),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Color(0xFFF97316), size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Recordá: si un día no entrás, el contador puede reiniciarse. '
                'Entrá todos los días hasta llegar a 14.',
                style: TextStyle(fontSize: 12.5, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildCard({
    required IconData icon,
    required String titulo,
    required String valor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF087FE8), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(valor,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}