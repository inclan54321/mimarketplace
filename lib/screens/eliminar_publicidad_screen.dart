import 'package:flutter/material.dart';

class EliminarPublicidadScreen extends StatefulWidget {
  const EliminarPublicidadScreen({super.key});

  @override
  State<EliminarPublicidadScreen> createState() =>
      _EliminarPublicidadScreenState();
}

class _EliminarPublicidadScreenState extends State<EliminarPublicidadScreen> {
  String? _planSeleccionado; // 'mensual' o 'semestral'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('Eliminar publicidad'),
        backgroundColor: const Color(0xFF087FE8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 ICONO GRANDE
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF087FE8), Color(0xFF1A56DB)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF087FE8).withValues(alpha: 0.4),
                      blurRadius: 25,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.block,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 🔥 TÍTULO
            const Text(
              'Eliminá los anuncios',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // 🔥 DESCRIPCIÓN
            Text(
              'Pagá un plan y navegá sin publicidad en toda la app. '
              'Sin anuncios, sin interrupciones.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // 🔥 BENEFICIOS
            _buildBeneficio('Sin anuncios en toda la app'),
            _buildBeneficio('Navegación más rápida'),
            _buildBeneficio('Experiencia sin interrupciones'),
            const SizedBox(height: 32),

            const Text(
              'Elegí tu plan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 🔥 PLAN MENSUAL
            _buildPlanCard(
              id: 'mensual',
              titulo: '1 mes',
              precio: '₡1.000',
              subtitulo: 'Sin anuncios por 30 días',
              ahorro: null,
            ),
            const SizedBox(height: 12),

            // 🔥 PLAN SEMESTRAL
            _buildPlanCard(
              id: 'semestral',
              titulo: '6 meses',
              precio: '₡3.000',
              subtitulo: 'Sin anuncios por 180 días',
              ahorro: 'Ahorrás ₡3.000',
            ),
            const SizedBox(height: 32),

            // 🔥 BOTÓN PAGAR
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _planSeleccionado == null
                    ? null
                    : () => _confirmarCompra(_planSeleccionado!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF087FE8),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF087FE8).withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _planSeleccionado == null
                      ? 'Elegí un plan'
                      : 'Pagar ${_planSeleccionado == 'mensual' ? '₡1.000' : '₡3.000'}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔥 AVISO
            Center(
              child: Text(
                'El pago se procesa de forma segura',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeneficio(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF00E676), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String id,
    required String titulo,
    required String precio,
    required String subtitulo,
    String? ahorro,
  }) {
    final seleccionado = _planSeleccionado == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _planSeleccionado = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: seleccionado
              ? const Color(0xFF087FE8).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: seleccionado
                ? const Color(0xFF087FE8)
                : Colors.white.withValues(alpha: 0.1),
            width: seleccionado ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // 🔥 RADIO
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: seleccionado
                      ? const Color(0xFF087FE8)
                      : Colors.white.withValues(alpha: 0.4),
                  width: 2,
                ),
                color: seleccionado
                    ? const Color(0xFF087FE8)
                    : Colors.transparent,
              ),
              child: seleccionado
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 16),

            // 🔥 INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (ahorro != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ahorro,
                            style: const TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // 🔥 PRECIO
            Text(
              precio,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarCompra(String plan) async {
    final precio = plan == 'mensual' ? '₡1.000' : '₡3.000';
    final duracion = plan == 'mensual' ? '1 mes' : '6 meses';

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          'Confirmar compra',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Querés pagar $precio por $duracion sin anuncios?',
          style: const TextStyle(color: Colors.white70),
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
            child: const Text('Pagar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // TODO: integrar pasarela de pago real (Stripe, PayPal, SINPE, etc.)
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🚧 Integración de pago en desarrollo'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}