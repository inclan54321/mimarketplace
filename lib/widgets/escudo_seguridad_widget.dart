import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:animated_emoji/animated_emoji.dart';
import 'conversation_status_indicator.dart';
import 'rewarded_ad_prueba.dart';

class EscudoSeguridadWidget extends StatefulWidget {
  final ConversationStatus? emojiDesdeEstado; // 🔥 NUEVO
  final ConversationStatus estado;
  final bool isActive;
  final bool videoVistoInicial; // 🔥 NUEVO
  final VoidCallback onToggle;
  final VoidCallback onAdCompleted;
  final VoidCallback onInfoTap;

  const EscudoSeguridadWidget({
    this.emojiDesdeEstado, // 🔥 NUEVO
    super.key,
    required this.estado,
    required this.isActive,
    this.videoVistoInicial = false, // 🔥 NUEVO
    required this.onToggle,
    required this.onAdCompleted,
    required this.onInfoTap,
  });

  @override
  State<EscudoSeguridadWidget> createState() => _EscudoSeguridadWidgetState();
}

class _EscudoSeguridadWidgetState extends State<EscudoSeguridadWidget>
    with TickerProviderStateMixin {
  final List<AnimatedEmoji> _emojis = const [
    AnimatedEmoji(AnimatedEmojis.joy, size: 42, repeat: true),          // 0: good
    AnimatedEmoji(AnimatedEmojis.smile, size: 42, repeat: true),        // 1: neutral
    AnimatedEmoji(AnimatedEmojis.heartEyes, size: 42, repeat: true),    // 2: (sin uso)
    AnimatedEmoji(AnimatedEmojis.sad, size: 42, repeat: true),          // 3: warning
    AnimatedEmoji(AnimatedEmojis.angry, size: 42, repeat: true),        // 4: danger
    AnimatedEmoji(AnimatedEmojis.dottedLineFace, size: 42, repeat: true), // 5: apagado
  ];

  // int _indiceEmoji = 0; // 🔥 Ya no se usa
  Timer? _timerEmoji;
  bool _emojiVisible = true;
  int _contadorCiclo = 0;      // 🔥 Cuenta cuántos "toggles" van
  bool _enEspera = false;      // 🔥 Si está en los 15 segundos de espera
  int _contadorEspera = 0;     // 🔥 Cuenta los 15 segundos

  // 🔥 EMOJI ESTÁTICO (para cuando no está animado)
  // Lo generamos con el mismo emoji pero sin animación
  // (usaremos Opacity para "pausar" visualmente)

  // 🔥 EL EMOJI DEPENDE DEL ESTADO QUE VIENE DEL PADRE
  int get _indiceEmojiSegunEstado {
    switch (widget.emojiDesdeEstado ?? widget.estado) {
      case ConversationStatus.good:
        return 0; // 😂 joy
      case ConversationStatus.warning:
        return 3; // 😢 sad (precaución)
      case ConversationStatus.danger:
        return 4; // 😡 angry (peligro)
      case ConversationStatus.neutral:
      default:
        return 1; // 🙂 smile
    }
  }

  late bool _videoVisto;

  // 🔥 Controllers para los efectos
  late AnimationController _ondasController;
  late AnimationController _destellosController;
  late AnimationController _vibracionController;

  @override
  void initState() {
    super.initState();
    // 🔥 NUEVO: Leer el estado inicial
    _videoVisto = widget.videoVistoInicial;
    print('>>> 🛡️ Escudo initState - videoVistoInicial: ${widget.videoVistoInicial}');
    // 🔥 CICLO: 4s animado → 4s pausa → 4s animado → 4s pausa → 15s espera → repetir
    _timerEmoji = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_enEspera) {
        // 🔥 ESTAMOS EN LOS 15 SEGUNDOS DE ESPERA
        _contadorEspera++;
        if (_contadorEspera >= 15) {
          setState(() {
            _enEspera = false;
            _contadorEspera = 0;
            _contadorCiclo = 0;
            _emojiVisible = true;
          });
        }
      } else {
        // 🔥 ESTAMOS EN EL CICLO DE 4s + 4s
        // Cada 4 segundos, alternar
        if (timer.tick % 4 == 0) {
          _contadorCiclo++;
          setState(() {
            _emojiVisible = !_emojiVisible;
          });

          // Después de 4 alternancias (16 segundos), pasar a espera
          if (_contadorCiclo >= 4) {
            setState(() {
              _enEspera = true;
              _contadorEspera = 0;
              _emojiVisible = false; // Ocultar emoji durante la espera
            });
          }
        }
      }
    });

    RewardedAdManager.loadRewardedAd();

    // Controladores para efectos
    _ondasController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _destellosController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _vibracionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant EscudoSeguridadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('>>> 🛡️ didUpdateWidget - old: ${oldWidget.videoVistoInicial}, new: ${widget.videoVistoInicial}');
    // 🔥 Si el estado del video cambió desde el padre, actualizar
    if (widget.videoVistoInicial != oldWidget.videoVistoInicial) {
      setState(() {
        _videoVisto = widget.videoVistoInicial;
      });
      print('>>> 🛡️ _videoVisto actualizado a: $_videoVisto');
    }
  }

  @override
  void dispose() {
    _timerEmoji?.cancel(); // 🔥 Ahora sí se usa
    _ondasController.dispose();
    _destellosController.dispose();
    _vibracionController.dispose();
    super.dispose();
  }

  // 🔥 MODAL DE ANUNCIO
  void _mostrarModalAnuncio() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield,
                    size: 40,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '🛡️ Escudo de Seguridad',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Protege tus conversaciones y encuentros en MiMarketplace.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFuncionItem(
                        Icons.block,
                        'Bloquea números de teléfono',
                        'Evita compartir datos de contacto.',
                        Colors.red,
                      ),
                      const SizedBox(height: 6),
                      _buildFuncionItem(
                        Icons.link_off,
                        'Bloquea enlaces externos',
                        'Detecta intentos de salir de la app.',
                        Colors.orange,
                      ),
                      const SizedBox(height: 6),
                      _buildFuncionItem(
                        Icons.location_on,
                        'Sugiere lugares seguros',
                        'Recomienda puntos públicos.',
                        Colors.green,
                      ),
                      const SizedBox(height: 6),
                      _buildFuncionItem(
                        Icons.face,
                        'Verificación facial',
                        'Confirma tu identidad.',
                        Colors.blue,
                      ),
                      const SizedBox(height: 6),
                      _buildFuncionItem(
                        Icons.gps_fixed,
                        'Seguimiento GPS',
                        'Trackea tu ubicación.',
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.play_circle_filled,
                          color: Colors.amber.shade800, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Para activarlo, mira un anuncio corto.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _verAnuncioYActivar();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_circle_filled, size: 18),
                              SizedBox(width: 6),
                              Text('Ver anuncio 🎬'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFuncionItem(
    IconData icono,
    String titulo,
    String descripcion,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
              Text(descripcion,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }

  void _verAnuncioYActivar() {
    if (!RewardedAdManager.isAdLoaded) {
      RewardedAdManager.loadRewardedAd();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏳ Cargando anuncio... espera un momento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    RewardedAdManager.showRewardedAd(
      onRewarded: () {
        setState(() {
          _videoVisto = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Escudo activado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onAdCompleted();
      },
      onDismissed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Debes ver el anuncio completo para activar el Escudo'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  // 🔥 CONSTRUIR EL EFECTO SEGÚN EL EMOJI ACTUAL
  Widget _buildEfectoAura(Color color) {
    switch (_indiceEmojiSegunEstado) {
      case 0: // joy → Destellos girando
        return _buildDestellos(color);
      case 1: // smile → Ondas expansivas
        return _buildOndas(color);
      case 3: // sad → Ondas expansivas
        return _buildOndas(color);
      case 4: // angry → Destellos girando (más agresivo)
        return _buildDestellos(color);
      default:
        return _buildOndas(color);
    }
  }

  // 🔥 ONDAS EXPANSIVAS
  Widget _buildOndas(Color color) {
    return AnimatedBuilder(
      animation: _ondasController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            _buildOnda(progreso: _ondasController.value, color: color),
            _buildOnda(
              progreso: (_ondasController.value + 0.5) % 1.0,
              color: color,
            ),
          ],
        );
      },
    );
  }

  Widget _buildOnda({required double progreso, required Color color}) {
    final double tamano = 64 + (88 - 64) * progreso;
    final double opacidad = (1.0 - progreso) * 0.6;
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: opacidad),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacidad * 0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  // 🔥 DESTELLOS GIRANDO
  Widget _buildDestellos(Color color) {
    return AnimatedBuilder(
      animation: _destellosController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _destellosController.value * 2 * math.pi,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(6, (i) {
              final angle = (i * math.pi * 2) / 6;
              return Transform.translate(
                offset: Offset(
                  math.cos(angle) * 38,
                  math.sin(angle) * 38,
                ),
                child: Icon(
                  Icons.star,
                  color: color.withValues(alpha: 0.7),
                  size: 12,
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // 🔥 CORAZONES FLOTANDO
  Widget _buildCorazones(Color color) {
    return AnimatedBuilder(
      animation: _destellosController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(4, (i) {
            final progreso = (_destellosController.value + i * 0.25) % 1.0;
            final y = -30 * (1 - progreso);
            final opacidad = math.sin(progreso * math.pi);
            final x = math.sin(progreso * math.pi * 2 + i) * 15;
            return Transform.translate(
              offset: Offset(x, y),
              child: Icon(
                Icons.favorite,
                color: Colors.pinkAccent.withValues(alpha: opacidad),
                size: 14,
              ),
            );
          }),
        );
      },
    );
  }

  // 🔥 ZZZ FLOTANDO
  Widget _buildZzz(Color color) {
    return AnimatedBuilder(
      animation: _destellosController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (i) {
            final progreso = (_destellosController.value + i * 0.33) % 1.0;
            final y = -40 * progreso;
            final x = 20 * progreso;
            final opacidad = (1 - progreso) * 0.8;
            return Transform.translate(
              offset: Offset(x, y),
              child: Text(
                'Z',
                style: TextStyle(
                  color: Colors.lightBlueAccent.withValues(alpha: opacidad),
                  fontSize: 16 + i * 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // 🔥 EMOJI ESTÁTICO SEGÚN EL ESTADO
  String _emojiEstatico(int indice) {
    switch (indice) {
      case 0:
        return '😂'; // good
      case 3:
        return '😢'; // warning
      case 4:
        return '😡'; // danger
      case 1:
      default:
        return '🙂'; // neutral
    }
  }

  @override
  Widget build(BuildContext context) {
    Color colorCarita;
    switch (widget.estado) {
      case ConversationStatus.good:
        colorCarita = Colors.greenAccent;
        break;
      case ConversationStatus.warning:
        colorCarita = Colors.orangeAccent;
        break;
      case ConversationStatus.danger:
        colorCarita = Colors.redAccent;
        break;
      default:
        colorCarita = Colors.white;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.translate(
          offset: const Offset(0, -4),
          child: SizedBox(
            width: 100,
            height: 100,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // 🔥 EFECTO SEGÚN EL EMOJI ACTUAL (solo si el Escudo está activo)
                  if (widget.isActive && _indiceEmojiSegunEstado != 3)
                    _buildEfectoAura(colorCarita),

                  // 🔥 CÍRCULO CENTRAL CON EL SMILEY
                  widget.isActive
                      ? Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorCarita.withValues(alpha: 0.2),
                            border: Border.all(
                              color: colorCarita,
                              width: 2.5,
                            ),
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                key: ValueKey('${_indiceEmojiSegunEstado}_$_emojiVisible'),
                                child: _enEspera
                                    ? Text(
                                        _emojiEstatico(_indiceEmojiSegunEstado),
                                        style: const TextStyle(fontSize: 42),
                                      )
                                    : _emojiVisible
                                        ? _emojis[_indiceEmojiSegunEstado]
                                        : Text(
                                            _emojiEstatico(_indiceEmojiSegunEstado),
                                            style: const TextStyle(fontSize: 42),
                                          ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          // 🔥 ESCUDO APAGADO: círculo con borde punteado
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200.withValues(alpha: 0.2),
                          ),
                          child: CustomPaint(
                            painter: _CirculoPunteadoPainter(),
                            child: const Center(
                              child: Text(
                                '🫥', // 🔥 Cara punteada
                                style: TextStyle(fontSize: 42),
                              ),
                            ),
                          ),
                        ),

                  // 🔥 BOTÓN "i"
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: widget.onInfoTap,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF087FE8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),

                  // 🔥 BADGE ROJO
                  if (widget.isActive &&
                      widget.estado == ConversationStatus.danger)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () {
            if (!_videoVisto) {
              _mostrarModalAnuncio();
            } else {
              widget.onToggle();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _videoVisto
                    ? [const Color(0xFF4ADE80), const Color(0xFF22C55E)]
                    : [
                        const Color(0xFF60A5FA),
                        const Color(0xFF3B82F6),
                        const Color(0xFF1E40AF),
                      ],
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _videoVisto
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF1E3A8A),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_videoVisto
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF3B82F6))
                      .withValues(alpha: 0.5),
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(height: 1),
                Text(
                  _videoVisto ? 'ACTIVADO' : 'PLUS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// 🔥 PAINTER PARA EL CÍRCULO PUNTEADO (ESCUDO APAGADO)
class _CirculoPunteadoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final paint = Paint()
      ..color = Colors.grey.shade500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const dashCount = 16;
    const dashAngle = 2 * math.pi / dashCount;
    final dashLength = dashAngle * 0.55;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final endAngle = startAngle + dashLength;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
    }

    final fillPaint = Paint()
      ..color = Colors.grey.shade200.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 2, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}