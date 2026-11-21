import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/generated/app_localizations.dart';

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
                            AppLocalizations.of(context)!.escudoActivoPor(widget.nombreQuienActivo!),
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
                      children: [
                        _PasoEscudo(
                          imagen: 'assets/images/escudo/paso0.jpg',
                          imagenAltura: 340,
                          imagenFit: BoxFit.cover,
                          titulo: AppLocalizations.of(context)!.escudoPaso0Titulo,
                          descripcion: AppLocalizations.of(context)!.escudoPaso0Desc,
                        ),
                        _PasoEscudo(
                          imagen: 'assets/images/escudo/paso1.jpg',
                          titulo: AppLocalizations.of(context)!.escudoPaso1Titulo,
                          descripcion: AppLocalizations.of(context)!.escudoPaso1Desc,
                        ),
                        _PasoEscudo(
                          imagen: 'assets/images/escudo/paso6.jpg',
                          titulo: AppLocalizations.of(context)!.escudoPaso2Titulo,
                          descripcion: AppLocalizations.of(context)!.escudoPaso2Desc,
                        ),
                        _PasoEscudo(
                          imagen: 'assets/images/escudo/paso7.jpeg',
                          titulo: AppLocalizations.of(context)!.escudoPaso3Titulo,
                          descripcion: AppLocalizations.of(context)!.escudoPaso3Desc,
                        ),
                        _PasoEscudo(
                          imagen: 'assets/images/escudo/paso2.jpg',
                          titulo: AppLocalizations.of(context)!.escudoPaso4Titulo,
                          descripcion: AppLocalizations.of(context)!.escudoPaso4Desc,
                        ),
                        _PasoEscudo(
                          imagen: 'assets/images/escudo/paso3.jpg',
                          titulo: AppLocalizations.of(context)!.escudoPaso5Titulo,
                          descripcion: AppLocalizations.of(context)!.escudoPaso5Desc,
                        ),
                        _PasoEscudo(
                          imagen: 'assets/icon/icon.png',
                          imagenFit: BoxFit.contain,
                          titulo: AppLocalizations.of(context)!.escudoPaso6Titulo,
                          descripcion: AppLocalizations.of(context)!.escudoPaso6Desc,
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
                    child: (_esModoAceptar && _paginaActual >= 6)
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
                                  child: Text(
                                    AppLocalizations.of(context)!.noAceptar,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
                                  child: Text(
                                    AppLocalizations.of(context)!.aceptar,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
                                if (_paginaActual < 6) {
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
                                    ? AppLocalizations.of(context)!.cerrar
                                    : (_paginaActual < 6
                                        ? AppLocalizations.of(context)!.siguiente
                                        : (FirebaseAuth.instance.currentUser?.email?.trim().toLowerCase() == 'universo3dcr@gmail.com'
                                            ? AppLocalizations.of(context)!.iniciar
                                            : AppLocalizations.of(context)!.verVideo)),
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