import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/calificacion.dart';

class PerfilVendedorScreen extends StatefulWidget {
  final String vendedorId;
  final String vendedorNombre;
  final String? vendedorFoto;

  const PerfilVendedorScreen({
    super.key,
    required this.vendedorId,
    required this.vendedorNombre,
    this.vendedorFoto,
  });

  @override
  State<PerfilVendedorScreen> createState() => _PerfilVendedorScreenState();
}

class _PerfilVendedorScreenState extends State<PerfilVendedorScreen> {
  bool _isLoading = true;
  double _promedioCalificaciones = 0;
  int _totalCalificaciones = 0;
  List<Calificacion> _calificaciones = [];
  String? _email;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    try {
      // 1. OBTENER CALIFICACIONES
      final califResponse = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/calificaciones/${widget.vendedorId}'),
      );
      if (califResponse.statusCode == 200) {
        final List data = jsonDecode(califResponse.body);
        setState(() {
          _calificaciones = data.map((json) => Calificacion.fromJson(json)).toList();
        });
      }

      // 2. OBTENER RESUMEN DE CALIFICACIONES
      final resumenResponse = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/calificaciones/resumen/${widget.vendedorId}'),
      );
      if (resumenResponse.statusCode == 200) {
        final data = jsonDecode(resumenResponse.body);
        setState(() {
          _totalCalificaciones = data['total'] ?? 0;
          _promedioCalificaciones = (data['promedio'] ?? 0).toDouble();
        });
      }

      // 3. OBTENER EMAIL DEL VENDEDOR
      final emailResponse = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/perfil/email/${widget.vendedorId}'),
      );
      if (emailResponse.statusCode == 200) {
        final data = jsonDecode(emailResponse.body);
        setState(() {
          _email = data['email'] ?? '';
        });
      }
    } catch (e) {
      print('Error al cargar datos del vendedor: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = 'https://mimarketplace-production.up.railway.app';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Vendedor'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ===== CABECERA =====
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.shade700,
                          Colors.blue.shade300,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: widget.vendedorFoto != null && widget.vendedorFoto!.isNotEmpty
                              ? NetworkImage('$baseUrl${widget.vendedorFoto}')
                              : null,
                          child: widget.vendedorFoto == null || widget.vendedorFoto!.isEmpty
                              ? Text(
                                  widget.vendedorNombre.isNotEmpty
                                      ? widget.vendedorNombre[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.vendedorNombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_email != null && _email!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _email!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        // ===== ESTRELLAS =====
                        GestureDetector(
                          onTap: () {
                            _mostrarDetalleCalificaciones();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: List.generate(5, (index) {
                                    final valor = _promedioCalificaciones;
                                    if (index < valor.floor()) {
                                      return const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 20,
                                      );
                                    } else if (index < valor.ceil() && valor % 1 != 0) {
                                      return const Icon(
                                        Icons.star_half,
                                        color: Colors.amber,
                                        size: 20,
                                      );
                                    } else {
                                      return const Icon(
                                        Icons.star_border,
                                        color: Colors.amber,
                                        size: 20,
                                      );
                                    }
                                  }),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _promedioCalificaciones.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '($_totalCalificaciones ${_totalCalificaciones == 1 ? 'calificación' : 'calificaciones'})',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ===== LISTA DE CALIFICACIONES =====
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Opiniones de los compradores',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_calificaciones.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'No hay opiniones aún',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _calificaciones.length > 5 ? 5 : _calificaciones.length,
                            itemBuilder: (context, index) {
                              final calif = _calificaciones[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue.shade100,
                                    child: Text(
                                      calif.calificadorNombre?.isNotEmpty == true
                                          ? calif.calificadorNombre![0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(calif.calificadorNombre ?? 'Usuario'),
                                  subtitle: Text(
                                    calif.comentario.isNotEmpty
                                        ? calif.comentario
                                        : 'Sin comentario',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        i < calif.puntuacion
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    }),
                                  ),
                                ),
                              );
                            },
                          ),
                        if (_calificaciones.length > 5)
                          TextButton(
                            onPressed: _mostrarDetalleCalificaciones,
                            child: Text(
                              'Ver todas (${_calificaciones.length})',
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _mostrarDetalleCalificaciones() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        _promedioCalificaciones.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($_totalCalificaciones ${_totalCalificaciones == 1 ? 'calificación' : 'calificaciones'})',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  Expanded(
                    child: _calificaciones.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay calificaciones aún',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _calificaciones.length,
                            itemBuilder: (context, index) {
                              final calif = _calificaciones[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: Text(
                                    calif.calificadorNombre?.isNotEmpty == true
                                        ? calif.calificadorNombre![0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(calif.calificadorNombre ?? 'Usuario'),
                                subtitle: Text(
                                  calif.comentario.isNotEmpty
                                      ? calif.comentario
                                      : 'Sin comentario',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < calif.puntuacion
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}