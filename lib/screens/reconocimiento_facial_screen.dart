import 'package:flutter/material.dart';
import 'package:flutter_face_liveness/flutter_face_liveness.dart';

class ReconocimientoFacialScreen extends StatefulWidget {
  final String usuarioId;

  const ReconocimientoFacialScreen({
    super.key,
    required this.usuarioId,
  });

  @override
  State<ReconocimientoFacialScreen> createState() =>
      _ReconocimientoFacialScreenState();
}

class _ReconocimientoFacialScreenState
    extends State<ReconocimientoFacialScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación facial'),
        backgroundColor: const Color(0xFF087FE8),
        foregroundColor: Colors.white,
      ),
      body: FlutterFaceLiveness(
        actions: const [
          LivenessAction.blink,
          LivenessAction.turnLeft,
          LivenessAction.turnRight,
        ],
        config: LivenessConfig(
          enableFaceId: true,
          faceIdMode: FaceIdMode.verificationOnly,
          faceIdSimilarityThreshold: 0.72,
          enableAntiSpoof: true,
          randomizeActions: true,
          showDebugOverlay: false,
        ),
        onSuccess: (result) {
          print('>>> ✅ VERIFICACIÓN EXITOSA');
          print('>>> faceId: ${result.faceId}');
          print('>>> isFaceIdNew: ${result.isFaceIdNew}');

          if (result.isFaceIdNew == false) {
            Navigator.pop(context, true);
          } else {
            _mostrarError('Las caras no coinciden con el perfil registrado');
          }
        },
        onFailed: (reason) {
          print('>>> ❌ VERIFICACIÓN FALLIDA: $reason');
          _mostrarError('No se pudo verificar tu identidad: $reason');
        },
      ),
    );
  }

  void _mostrarError(String mensaje) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Verificación fallida'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, false);
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
  }
}