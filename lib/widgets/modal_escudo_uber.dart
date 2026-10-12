import 'package:flutter/material.dart';

// 🔥 MODAL DEL ESCUDO ESTILO UBER
// 🔥 Se usa en dos casos:
//   1. Cuando el usuario va a activar el escudo por primera vez (botón "Ver video").
//   2. Cuando el OTRO usuario ya activó el escudo y este debe aceptar o rechazar.
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
          height: 620,
          color: Colors.white,
          child: Stack(
            children: [
              Column(
                children: [
                  // 🔥 CABECERA: "X activó el Escudo" (solo en modo aceptar)
                  if (_esModoAceptar)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFF0F2447),
                      child: Column(
                        children: [
                          const Icon(Icons.verified_user, color: Color(0xFF00E676), size: 32),
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
                          imagen: 'assets/images/escudo/paso1.jpg',
                          titulo: 'Bloqueo de enlaces y teléfonos',
                          descripcion:
                              'Detectamos y bloqueamos automáticamente números de teléfono y enlaces externos en los mensajes. Así evitamos que compartas datos de contacto fuera de la app y reduces el riesgo de fraudes o estafas.',
                        ),
                        _PasoEscudo(
                          imagen: 'assets/images/escudo/paso2.jpg',
                          titulo: 'Seguimiento GPS',
                          descripcion:
                              'El día del encuentro activamos el GPS para confirmar que ambos llegaron al lugar acordado. Si alguien llega tarde o no aparece, queda registrado y puede ser sancionado según las reglas de MiMarketplace.',
                        ),
                        _PasoEscudo(
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
                                // 🔥 En modo "activar", si todavía no está en la última página, avanzar.
                                if (_paginaActual < 2) {
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
                                _paginaActual < 2 ? 'Siguiente' : 'Ver video',
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

              // 🔥 BOTÓN X (solo en modo activar, para poder cerrar sin activar)
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

  const _PasoEscudo({
    required this.imagen,
    required this.titulo,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 🔥 IMAGEN FULL WIDTH ARRIBA
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
}