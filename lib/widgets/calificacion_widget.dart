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
        Uri.parse('https://mimarketplace-production.up.railway.app/api/calificaciones'),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          foregroundPainter: _HumoDoradoPainter(),
          child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // 🔥 FONDO OSCURO
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1F2E),
            Color(0xFF0F1420),
            Color(0xFF1A1F2E),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        // 🔥 BORDE DORADO
        border: Border.all(
          color: const Color(0xFFFFD700),
          width: 2,
        ),
        boxShadow: [
          // 🔥 BRILLO EXTERIOR DORADO
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          // 🔥 BRILLO INTERNO
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '⭐ Califica a ${widget.vendedorNombre}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¿Cómo fue tu experiencia?',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          // 🔥 ESTRELLAS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _puntuacion ? Icons.star : Icons.star_border,
                  color: const Color(0xFFFFD700),
                  size: 36,
                  shadows: [
                    Shadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ],
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
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          if (_puntuacion > 0) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _comentarioController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Comentario (opcional)',
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                hintText: '¿Qué te pareció la experiencia?',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFD700)),
                ),
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
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: const Color(0xFFFFD700).withValues(alpha: 0.6),
                  elevation: 8,
                ),
                child: _enviando
                    ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    : const Text('Enviar Calificación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
          ),
        ),
      ),
    );
  }
}

// 🔥 PAINTER DE HUMO DORADO
class _HumoDoradoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 🔥 HUMO EN ESQUINA INFERIOR DERECHA
    final humoPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(1.0, 1.0),
        radius: 1.2,
        colors: [
          const Color(0xFFFFD700).withValues(alpha: 0.35),
          const Color(0xFFFFA500).withValues(alpha: 0.18),
          const Color(0xFFFFD700).withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    // 🔥 FORMA DE HUMO
    final humoPath = Path()
      ..moveTo(w, h * 0.3)
      ..quadraticBezierTo(w * 0.7, h * 0.5, w * 0.75, h * 0.7)
      ..quadraticBezierTo(w * 0.8, h * 0.95, w, h)
      ..lineTo(w, h)
      ..lineTo(w, h * 0.3)
      ..close();

    canvas.drawPath(humoPath, humoPaint);

    // 🔥 SEGUNDA CAPA DE HUMO
    final humoPaint2 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(1.0, 1.0),
        radius: 1.5,
        colors: [
          const Color(0xFFFFA500).withValues(alpha: 0.25),
          Colors.transparent,
        ],
        stops: const [0.0, 0.8],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    final humoPath2 = Path()
      ..moveTo(w, h * 0.5)
      ..quadraticBezierTo(w * 0.6, h * 0.7, w * 0.7, h * 0.9)
      ..quadraticBezierTo(w * 0.75, h * 0.98, w, h)
      ..lineTo(w, h)
      ..lineTo(w, h * 0.5)
      ..close();

    canvas.drawPath(humoPath2, humoPaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}