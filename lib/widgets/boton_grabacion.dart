import 'package:flutter/material.dart';

class BotonGrabacion extends StatefulWidget {
  final bool isRecording;
  final String recordingTime;
  final bool mostrarMensajeCancelar;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onCancel;
  final void Function(bool mostrar) onDragChange;
  final GlobalKey? buttonKey;

  const BotonGrabacion({
    super.key,
    required this.isRecording,
    required this.recordingTime,
    required this.mostrarMensajeCancelar,
    required this.onStart,
    required this.onStop,
    required this.onCancel,
    required this.onDragChange,
    this.buttonKey,
  });

  @override
  State<BotonGrabacion> createState() => _BotonGrabacionState();
}

class _BotonGrabacionState extends State<BotonGrabacion>
    with SingleTickerProviderStateMixin {
  Offset _startPosition = Offset.zero;
  late AnimationController _giroController;

  @override
  void initState() {
    super.initState();
    _giroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 🔥 SI YA ESTABA GRABANDO AL MONTAR, NO HACER NADA
    // 🔥 SI CAMBIA DE GRABANDO A NO GRABANDO, DISPARAR EL GIRO
    if (!widget.isRecording) {
      _giroController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant BotonGrabacion oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔥 CUANDO SE SUELTA (isRecording: true → false), DISPARAR GIRO
    if (oldWidget.isRecording && !widget.isRecording) {
      _giroController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _giroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      key: widget.buttonKey,
      onPointerDown: (event) {
        widget.onStart();
        _startPosition = event.position;
      },
      onPointerUp: (event) {
        if (!widget.isRecording) return;
        final distance = (event.position - _startPosition).distance;
        if (distance > 80) {
          widget.onCancel();
        } else {
          widget.onStop();
        }
      },
      onPointerCancel: (event) {
        if (widget.isRecording) widget.onCancel();
      },
      onPointerMove: (event) {
        if (!widget.isRecording) return;
        final distance = (event.position - _startPosition).distance;
        widget.onDragChange(distance > 80);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: widget.isRecording
            ? const SizedBox(width: 28, height: 28)
            : RotationTransition(
                turns: Tween<double>(begin: 0.0, end: 1.0)
                    .animate(_giroController),
                child: Icon(
                  Icons.mic,
                  color: Colors.grey.shade600,
                  size: 28,
                ),
              ),
      ),
    );
  }
}