import 'package:flutter/material.dart';

// 🔥 MODAL DEL ESCUDO ESTILO UBER
// 🔥 Se usa en dos casos:
//   1. Cuando el usuario va a activar el escudo por primera vez (botón "Ver video").
//   2. Cuando el otro usuario ya activó el escudo y este debe aceptar o rechazar.
//   3. Cuando el escudo ya está activo y el usuario quiere ver las instrucciones (solo "Cerrar").
class ModalEscudoUber extends StatefulWidget {
  final String? nombreQuienActivo; // Si es null, modo "activar". Si tiene valor, modo "aceptar/rechazar".
  final VoidCallback? onVerVideo;   // Modo activar: qué hacer al tocar "Ver video".
  final VoidCallback? onAceptar;    // Modo aceptar: qué hacer al tocar "Aceptar".
  final VoidCallback? onRechazar;   // Modo aceptar: qué hacer al tocar "No aceptar".

  const ModalEscudoUber({
    super.key,
    this.nombreQuienActivo,
    this.onVerVideo,
    this.onAceptar,
    this.onRechazar,
  });

  // 🔥 Helper para mostrarlo como dialog
  static Future<void> mostrar(
    BuildContext context, {
    String? nombreQuienActivo,
    VoidCallback? onVerVideo,
    VoidCallback? onAceptar,
    VoidCallback? onRechazar,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (dialogContext) => ModalEscudoUber(
        nombreQuienActivo: nombreQuienActivo,
        onVerVideo: onVerVideo == null ? null : () {
          Navigator.pop(dialogContext);
          onVerVideo();
        },
        onAceptar: onAceptar == null ? null : () {
          Navigator.pop(dialogContext);
          onAceptar();
        },
        onRechazar: onRechazar == null ? null : () {
          Navigator.pop(dialogContext);
          onRechazar();
        },
      ),
    );
  }

  @override
  State<ModalEscudoUber> createState() => _ModalEscudoUberState();
}

class _ModalEscudoUberState extends State<ModalEscudoUber> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;

  // 🔥 Modo "aceptar/rechazar" si viene nombreQuienActivo
  bool get _esModoAceptar => widget.nombreQuienActivo != null;

  // 🔥 Modo "solo instrucciones" si NO hay onVerVideo y NO hay nombreQuienActivo
  bool get _esModoInstrucciones => !_esModoAceptar && widget.onVerVideo == null;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 760,
          color: Colors.white,
          child: Stack(
            children: [
              Column(
                children: [
                  // 🔥 CABECERA: "X activó el Escudo" + instrucciones (solo en modo aceptar)
                  if (_esModoAceptar)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFF0F2447),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/escudo/logoescudo.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.verified_user,
                              color: Color(0xFF00E676),
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${widget.nombreQuienActivo} activó el Escudo de Seguridad',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),

                  // 🔥 CONTENIDO PAGINADO (3 pasos)
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _paginaActual = index);
                      },
                      children: const [
                        _PasoEscudo(
                          imagen: 'assets/images/escudo/paso0.jpg',
                          imagenAltura: 340,
                          imagenFit: BoxFit.cover,
                          titulo: '¿Qué es el Escudo de Seguridad?',
                          descripcion:
                              'Es un conjunto de medidas de protección que se activan cuando ambos usuarios de un trato lo aceptan. Su objetivo es prevenir fraudes y garantizar que el encuentro sea seguro.\n\n¿Quién debe activarlo?\nAmbos usuarios del trato deben aceptar el Escudo. Si uno lo activa, el otro recibirá una notificación para aceptarlo o rechazarlo. Si el segundo usuario lo rechaza, el chat se cerrará para ambos.',
                        ),
                        _PasoEscudo(
                          imagen: 'assets/images/escudo/paso1.jpg',
                          titulo: '¿Qué ocurre cuando el Escudo está activo?',
                          descripcion:
                              '3.1. Bloqueo de enlaces y teléfonos: La app detecta y bloquea automáticamente números de teléfono y enlaces externos en los mensajes. Esto evita compartir datos de contacto fuera de la plataforma y reduce el riesgo de estafas.',
                        ),
                        _PasoEscudo(
                          imagen: 'assets/images/escudo/paso6.jpg',
                          titulo: 'Cómo cerrar el trato',
                          descripcion:
                              'Para cerrar el trato, primero proponé un encuentro: tocá el escudo en la barra superior del chat y elegí "Proponer encuentro". Ahí seleccionás provincia, cantón, distrito, un lugar seguro y la fecha con hora. Enviás la propuesta y el otro usuario la recibe como tarjeta en el chat. Cuando la acepta, el encuentro queda agendado pero el chat sigue abierto: pueden seguir hablando. Para cerrar el trato, tocá el escudo otra vez y elegí "Cerrar trato". Se abre un cartel para confirmar. Cuando ambos confirman, el chat se bloquea y las protecciones se activan.',
                        ),
                        _PasoEscudo(
                          imagen: 'assets/images/escudo/paso7.jpeg',
                          titulo: 'Confirmación de asistencia',
                          descripcion:
                              'Una hora antes del encuentro, ambos usuarios recibirán una notificación para confirmar su asistencia. Si alguno de los dos no confirma dentro de los 15 minutos posteriores a la notificación, el otro usuario podrá cancelar el encuentro hasta 15 minutos antes de la hora pactada.',
                        ),
                        _PasoEscudo(
                          imagen: 'assets/images/escudo/paso2.jpg',
                          titulo: 'Seguimiento GPS',
                          descripcion:
                              '3.3. Seguimiento GPS el día del encuentro: El día acordado, 15 minutos antes de la hora del encuentro, ambos usuarios deben estar en el lugar y activar el GPS para verificar su ubicación. Si faltando 5 minutos para la hora acordada el usuario no activó el GPS y no verificó su identidad, se considerará que llegó tarde. Si 15 minutos después de la hora acordada el usuario no lo hizo, se considerará que no llegó. En ambos casos, queda registrado y puede ser sancionado según las normas de MiMarketplace.',
                        ),
                        _PasoEscudo(
                          imagen: 'assets/images/escudo/paso3.jpg',
                          titulo: 'Verificación facial',
                          descripcion:
                              '3.4. Verificación de identidad antes del chat: Para liberar el chat del encuentro, ambos usuarios deben confirmar que son quienes dicen ser. Esto se habilita 15 minutos antes de la hora acordada y es un requisito obligatorio para poder abrir el chat. El sistema le pedirá a cada uno que se tome una foto en el momento. Luego, el otro usuario deberá comparar esa foto con la foto de perfil para confirmar que coinciden. Es importante estar atento, porque la verificación se habilita cuando el otro usuario la activa, y hay que seguir las instrucciones que aparecen en pantalla. Así se evita que alguien más use la cuenta.',
                        ),
                        _PasoEscudo(
                          imagen: 'assets/icon/icon.png',
                          imagenFit: BoxFit.contain,
                          titulo: 'Consideraciones adicionales',
                          descripcion:
                              '4.1. Cancelación voluntaria: Cualquier usuario puede cancelar su asistencia al encuentro siempre y cuando falte más de una hora para la hora acordada. Una vez que falte menos de una hora, la cancelación ya no estará disponible.\n\n¿Cómo cancelar? Entrá al chat del artículo, tocá el botón del escudo en la barra superior y elegí "Cancelar trato". Se va a abrir un cartel que te muestra la fecha del encuentro y te indica si todavía podés cancelar o si ya falta menos de una hora. Si se puede, confirmás y el encuentro se anula para los dos.\n\nRevisá siempre la sección de Alertas. Ahí llegan los recordatorios del encuentro, la confirmación de asistencia, la verificación de identidad y cualquier cambio de estado. Tenés que revisarlas seguido para no perderte nada importante.',
                        ),
                      ],
                    ),
                  ),

                  // 🔥 INDICADOR DE PÁGINA
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(7, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _paginaActual == i ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _paginaActual == i ? Colors.black : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),

                  // 🔥 BOTONES (según modo)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: _esModoAceptar
                        ? Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: widget.onRechazar,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'No aceptar',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: widget.onAceptar,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00E676),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Aceptar',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                // 🔥 Modo instrucciones: "Cerrar" desde el primer paso
                                if (_esModoInstrucciones) {
                                  Navigator.pop(context);
                                  return;
                                }
                                // 🔥 Modo activar: "Siguiente" hasta el último paso, luego "Ver video"
                                if (_paginaActual < 5) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                } else {
                                  widget.onVerVideo?.call();
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
                                _esModoInstrucciones
                                    ? 'Cerrar'
                                    : (_paginaActual < 6 ? 'Siguiente' : 'Ver video'),
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

              // 🔥 BOTÓN X (en modo activar y en modo instrucciones, para poder cerrar)
              if (!_esModoAceptar)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
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
  }
}

// 🔥 PÁGINA DEL PASO (imagen + título + descripción)
class _PasoEscudo extends StatelessWidget {
  final String imagen;
  final String titulo;
  final String descripcion;
  final double imagenAltura;
  final BoxFit imagenFit;

  const _PasoEscudo({
    required this.imagen,
    required this.titulo,
    required this.descripcion,
    this.imagenAltura = 260,
    this.imagenFit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔥 IMAGEN FULL WIDTH ARRIBA
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              imagen,
              width: double.infinity,
              height: imagenAltura,
              fit: imagenFit,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: imagenAltura,
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              descripcion,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// 🔥 FILA DE INSTRUCCIÓN (ícono + título + texto)
class _InstruccionEscudo extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String titulo;
  final String texto;

  const _InstruccionEscudo({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                texto,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}