import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class CalificacionWidget extends StatefulWidget {
  final String vendedorId;
  final String vendedorNombre;
  final String productoId;
  final String nombreProducto;
  final Function onCalificacionEnviada;

  const CalificacionWidget({
    super.key,
    required this.vendedorId,
    required this.vendedorNombre,
    required this.productoId,
    required this.nombreProducto,
    required this.onCalificacionEnviada,
  });

  @override
  State<CalificacionWidget> createState() => _CalificacionWidgetState();
}

class _CalificacionWidgetState extends State<CalificacionWidget> {
  int _puntuacion = 0;
  final TextEditingController _comentarioController = TextEditingController();
  bool _enviando = false;

  Future<void> _enviarCalificacion() async {
    if (_puntuacion == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una calificación'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _enviando = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes iniciar sesión'), backgroundColor: Colors.red),
        );
        setState(() => _enviando = false);
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.100.248:3000/api/calificaciones'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'calificado_id': widget.vendedorId,
          'calificador_id': user.uid,
          'producto_id': widget.productoId,
          'puntuacion': _puntuacion,
          'comentario': _comentarioController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Calificación enviada. ¡Gracias!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onCalificacionEnviada(); // 🔥 NOTIFICAR AL CHAT
        Navigator.pop(context); // 🔥 CERRAR EL WIDGET
      } else {
        throw Exception('Error al calificar');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        children: [
          Text(
            '⭐ Califica a ${widget.vendedorNombre}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text('¿Cómo fue tu experiencia?', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          // 🔥 ESTRELLAS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _puntuacion ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _puntuacion = index + 1;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            _puntuacion > 0 ? '$_puntuacion estrella${_puntuacion > 1 ? 's' : ''}' : 'Toca una estrella',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (_puntuacion > 0) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _comentarioController,
              decoration: const InputDecoration(
                labelText: 'Comentario (opcional)',
                border: OutlineInputBorder(),
                hintText: '¿Qué te pareció la experiencia?',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _enviando ? null : _enviarCalificacion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _enviando
                    ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    : const Text('Enviar Calificación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}