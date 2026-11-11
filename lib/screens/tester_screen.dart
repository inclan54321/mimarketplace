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
    } catch (e) {
      debugPrint('Error cargando tester: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _registrar() async {
    if (_seleccionados.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elegí exactamente 5 números')),
      );
      return;
    }
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err['error'] ?? 'Error'),
            backgroundColor: Colors.red,
          ),
        );
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
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _esTester
              ? _buildPanelTester()
              : _buildFormularioRegistro(),
    );
  }

  Widget _buildPanelTester() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            valor: '$_diasConectado',
          ),
          const SizedBox(height: 12),
          _buildCard(
            icon: Icons.numbers,
            titulo: 'Tus números',
            valor: _numerosElegidos.join(', '),
          ),
        ],
      ),
    );
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

  Widget _buildFormularioRegistro() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registrate como tester',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Elegí 5 números entre 1 y 100. Quedan reservados para vos.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Wrap(
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
                        setState(() {
                          if (seleccionado) {
                            _seleccionados.remove(n);
                          } else if (_seleccionados.length < 5) {
                            _seleccionados.add(n);
                          }
                        });
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
          const SizedBox(height: 20),
          Text(
            'Seleccionados: ${_seleccionados.length}/5',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _seleccionados.length == 5 ? _registrar : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF087FE8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Registrarme como tester'),
            ),
          ),
        ],
      ),
    );
  }
}