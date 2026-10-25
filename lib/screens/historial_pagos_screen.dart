import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HistorialPagosScreen extends StatefulWidget {
  const HistorialPagosScreen({super.key});

  @override
  State<HistorialPagosScreen> createState() => _HistorialPagosScreenState();
}

class _HistorialPagosScreenState extends State<HistorialPagosScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _pagos = [];

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _error = 'Debés iniciar sesión';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final idToken = await user.getIdToken();
      final response = await http.get(
        Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/pagos/historial/${user.uid}'),
        headers: {
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _pagos = data.map((e) => Map<String, dynamic>.from(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Error al cargar el historial (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  String _formatearMonto(dynamic monto) {
    if (monto == null) return '₡0';
    final n = double.tryParse(monto.toString()) ?? 0;
    return '₡${NumberFormat('#,##0', 'es_CR').format(n)}';
  }

  String _formatearFecha(String? fecha) {
    if (fecha == null) return '';
    try {
      final dt = DateTime.parse(fecha).toLocal();
      return DateFormat('dd/MM/yyyy · h:mm a', 'es_CR').format(dt);
    } catch (_) {
      return fecha;
    }
  }

  Color _colorEstado(String? estado) {
    switch (estado) {
      case 'completado':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'fallido':
      case 'rechazado':
        return Colors.red;
      case 'reembolsado':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _iconoEstado(String? estado) {
    switch (estado) {
      case 'completado':
        return Icons.check_circle;
      case 'pendiente':
        return Icons.hourglass_top;
      case 'fallido':
      case 'rechazado':
        return Icons.cancel;
      case 'reembolsado':
        return Icons.replay;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('Historial de pagos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _cargarHistorial,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : _pagos.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long,
                                color: Colors.white.withValues(alpha: 0.3),
                                size: 72),
                            const SizedBox(height: 16),
                            const Text(
                              'No tenés pagos registrados todavía',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _cargarHistorial,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _pagos.length,
                        itemBuilder: (context, index) {
                          final pago = _pagos[index];
                          final estado = pago['estado']?.toString();
                          final colorEstado = _colorEstado(estado);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161B22),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF30363D),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            colorEstado.withValues(alpha: 0.15),
                                      ),
                                      child: Icon(
                                        _iconoEstado(estado),
                                        color: colorEstado,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pago['concepto']?.toString() ??
                                                'Pago',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _formatearFecha(
                                                pago['fecha']?.toString()),
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.55),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      _formatearMonto(pago['monto']),
                                      style: TextStyle(
                                        color: colorEstado,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                if ((pago['metodo_pago'] ?? '')
                                    .toString()
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(Icons.credit_card,
                                          color: Colors.white
                                              .withValues(alpha: 0.5),
                                          size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        pago['metodo_pago'].toString(),
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.6),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        (estado ?? '').toUpperCase(),
                                        style: TextStyle(
                                          color: colorEstado,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}