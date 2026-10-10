import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:animated_emoji/animated_emoji.dart';
import 'conversation_status_indicator.dart';
import 'rewarded_ad_prueba.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    // _timerEmoji?.cancel(); // 🔥 Ya no se usa
    _ondasController.dispose();
    _destellosController.dispose();
    _vibracionController.dispose();
    super.dispose();
  }

  // 🔥 MODAL DE ANUNCIO - ESTILO UBER CON 3 PASOS
  void _mostrarModalAnuncio() {
    final PageController pageController = PageController();
    int paginaActual = 0;
    bool noMostrarMas = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  height: 620,
                  color: Colors.white,
                  child: Stack(
                    children: [
                      // 🔥 CONTENIDO
                      Column(
                        children: [
                          // 🔥 CONTENIDO PAGINADO
                          Expanded(
                            child: PageView(
                              controller: pageController,
                              onPageChanged: (index) {
                                setDialogState(() {
                                  paginaActual = index;
                                });
                              },
                              children: [
                                _buildPaso(
                                  imagen: 'assets/images/escudo/paso1.jpg',
                                  titulo: 'Bloqueo de enlaces y teléfonos',
                                  descripcion:
                                      'Detectamos y bloqueamos automáticamente números de teléfono y enlaces externos en los mensajes. Así evitamos que compartas datos de contacto fuera de la app y reduces el riesgo de fraudes o estafas.',
                                ),
                                _buildPaso(
                                  imagen: 'assets/images/escudo/paso2.jpg',
                                  titulo: 'Seguimiento GPS',
                                  descripcion:
                                      'El día del encuentro activamos el GPS para confirmar que ambos llegaron al lugar acordado. Si alguien llega tarde o no aparece, queda registrado y puede ser sancionado según las reglas de MiMarketplace.',
                                ),
                                _buildPaso(
                                  imagen: 'assets/images/escudo/paso3.jpg',
                                  titulo: 'Reconocimiento facial',
                                  descripcion:
                                      'Antes de abrir el chat del encuentro, verificamos tu identidad con reconocimiento facial. Así confirmamos que sos vos y evitamos que alguien más use tu cuenta.',
                                ),
                              ],
                            ),
                          ),

                          // 🔥 INDICADOR DE PÁGINA
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (i) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: paginaActual == i ? 20 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: paginaActual == i
                                        ? Colors.black
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              }),
                            ),
                          ),

                          // 🔥 CHECKBOX "NO MOSTRAR MÁS"
                          if (paginaActual == 2)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: noMostrarMas,
                                      onChanged: (value) {
                                        setDialogState(() {
                                          noMostrarMas = value ?? false;
                                        });
                                      },
                                      activeColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'No mostrar más',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // 🔥 BOTÓN PRINCIPAL
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (paginaActual < 2) {
                                    pageController.nextPage(
                                      duration: const Duration(
                                          milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  } else {
                                    if (noMostrarMas) {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setBool(
                                          'escudo_no_mostrar_mas', true);
                                    }
                                    if (dialogContext.mounted) {
                                      Navigator.pop(dialogContext);
                                    }
                                    _verAnuncioYActivar();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  paginaActual < 2
                                      ? 'Siguiente'
                                      : 'Ver video',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 🔥 BOTÓN X FLOTANDO ARRIBA A LA DERECHA
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(dialogContext),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 🔥 PÁGINA DEL PASO ESTILO UBER CON IMAGEN
  Widget _buildPaso({
    required String imagen,
    required String titulo,
    required String descripcion,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 🔥 IMAGEN FULL WIDTH ARRIBA
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
          child: Image.asset(
            imagen,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey.shade200,
              child: Icon(
                Icons.image_not_supported,
                size: 48,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // 🔥 TÍTULO ESTILO UBER
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        // 🔥 DESCRIPCIÓN ESTILO UBER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            descripcion,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
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

  // 🔥 ARO DISCONTINUO GIRANDO (3 ARCOS IGUALES)
  Widget _buildDestellos(Color color) {
    return AnimatedBuilder(
      animation: _destellosController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _destellosController.value * 2 * math.pi,
          child: CustomPaint(
            size: const Size(64, 64),
            painter: _AroDiscontinuoPainter(color: color),
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
          offset: const Offset(20, -4),
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

                  // 🔥 BOTÓN DE INFORMACIÓN CON ARO LUMINOSO
                  Positioned(
                    top: 18,
                    child: GestureDetector(
                    onTap: widget.onInfoTap,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.3),
                        border: Border.all(
                          color: widget.isActive
                              ? colorCarita
                              : Colors.grey.shade600,
                          width: 2,
                        ),
                        boxShadow: widget.isActive
                            ? [
                                BoxShadow(
                                  color: colorCarita.withValues(alpha: 0.6),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                                BoxShadow(
                                  color: colorCarita.withValues(alpha: 0.3),
                                  blurRadius: 22,
                                  spreadRadius: 4,
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: widget.isActive
                            ? colorCarita
                            : Colors.grey.shade500,
                        size: 20,
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
          onTap: () async {
            if (!_videoVisto) {
              final prefs = await SharedPreferences.getInstance();
              final noMostrar = prefs.getBool('escudo_no_mostrar_mas') ?? false;
              if (noMostrar) {
                // 🔥 Ya marcó "no mostrar más", ir directo al anuncio
                _verAnuncioYActivar();
              } else {
                _mostrarModalAnuncio();
              }
            } else {
              widget.onToggle();
            }
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0F2447),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _videoVisto
                    ? const Color(0xFF00E676)
                    : Colors.grey.shade600,
                width: 1.5,
              ),
              boxShadow: _videoVisto
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00E676).withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user,
                  color: _videoVisto
                      ? const Color(0xFF00E676)
                      : Colors.grey.shade400,
                  size: 22,
                ),
                Text(
                  _videoVisto ? 'ON' : 'PLUS',
                  style: TextStyle(
                    color: _videoVisto
                        ? const Color(0xFF00E676)
                        : Colors.white,
                    fontSize: 8,
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
// 🔥 PAINTER PARA EL ARO DISCONTINUO (3 ARCOS IGUALES GIRANDO)
class _AroDiscontinuoPainter extends CustomPainter {
  final Color color;

  _AroDiscontinuoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // 🔥 3 ARCOS IGUALES. Cada arco ocupa 1/3 de la circunferencia.
    // 2π / 3 = 120 grados = 2.0944 radianes por arco.
    const int cantidadArcos = 3;
    final double arcoCompleto = 2 * math.pi / cantidadArcos;
    // 🔥 El arco visible ocupa el 60% del espacio (40% es el "hueco").
    final double longitudArco = arcoCompleto * 0.6;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // 🔥 CAPA 1: Glow exterior
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    for (int i = 0; i < cantidadArcos; i++) {
      final double inicio = i * arcoCompleto;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        inicio,
        longitudArco,
        false,
        glowPaint,
      );
    }

    // 🔥 CAPA 2: Arco sólido encima
    for (int i = 0; i < cantidadArcos; i++) {
      final double inicio = i * arcoCompleto;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        inicio,
        longitudArco,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AroDiscontinuoPainter oldDelegate) =>
      oldDelegate.color != color;
}
