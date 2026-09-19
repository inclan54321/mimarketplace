import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class CalificarScreen extends StatefulWidget {
  final String vendedorId;
  final String vendedorNombre;
  final int productoId;
  final String productoNombre;

  const CalificarScreen({
    super.key,
    required this.vendedorId,
    required this.vendedorNombre,
    required this.productoId,
    required this.productoNombre,
  });

  @override
  State<CalificarScreen> createState() => _CalificarScreenState();
}

class _CalificarScreenState extends State<CalificarScreen> {
  int _puntuacion = 0;
  final TextEditingController _comentarioController = TextEditingController();
  bool _isLoading = false;
  bool _mostrarComentario = false; // 🔥 NUEVO: Controla si muestra el comentario

  Future<void> _guardarCalificacion() async {
    if (_puntuacion == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una puntuación'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_comentarioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, escribe un comentario'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.100.248:3000/api/calificaciones'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'calificado_id': widget.vendedorId,
          'calificador_id': user.uid,
          'producto_id': widget.productoId.toString(),
          'puntuacion': _puntuacion,
          'comentario': _comentarioController.text.trim(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Calificación guardada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Error al guardar calificación');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calificar Vendedor'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'Califica a ${widget.vendedorNombre}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Producto: ${widget.productoNombre}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            
            // 🔥 ESTRELLAS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _puntuacion = index + 1;
                      _mostrarComentario = true; // 🔥 MUESTRA EL COMENTARIO AL SELECCIONAR
                    });
                  },
                  child: Icon(
                    index < _puntuacion ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 48,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _puntuacion > 0 ? '${_puntuacion} estrella${_puntuacion > 1 ? 's' : ''}' : 'Selecciona una calificación',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            
            // 🔥 CAMPO DE COMENTARIO - SOLO APARECE DESPUÉS DE SELECCIONAR UNA ESTRELLA
            if (_mostrarComentario) ...[
              TextField(
                controller: _comentarioController,
                decoration: const InputDecoration(
                  labelText: 'Comentario (obligatorio)',
                  border: OutlineInputBorder(),
                  hintText: '¿Qué te pareció la experiencia?',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 30),
              
              // 🔥 BOTÓN GUARDAR
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarCalificacion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        )
                      : const Text(
                          'Guardar Calificación',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ] else ...[
              // 🔥 MENSAJE PARA QUE SELECCIONE UNA ESTRELLA PRIMERO
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Selecciona una calificación con las estrellas para poder escribir un comentario',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}