import 'package:flutter/material.dart';
import '../widgets/rewarded_ad_prueba.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../l10n/generated/app_localizations.dart';

// ============================================================
// 🎨 CONSTANTES DE COLOR
// ============================================================
class _AppColors {
  static const bg = Color(0xFF0A1628);
  static const primary = Color(0xFF3B82F6);
  static const primaryDark = Color(0xFF1A56DB);
  static const primaryLight = Color(0xFF60A5FA);
  static const surface = Color(0xFF0F2447);

  static final white70 = Colors.white.withValues(alpha: 0.7);
  static final white60 = Colors.white.withValues(alpha: 0.6);
  static final white50 = Colors.white.withValues(alpha: 0.5);
  static final white35 = Colors.white.withValues(alpha: 0.35);
  static final white20 = Colors.white.withValues(alpha: 0.2);
  static final white10 = Colors.white.withValues(alpha: 0.1);
  static final white05 = Colors.white.withValues(alpha: 0.05);
  static final primary15 = primary.withValues(alpha: 0.15);
  static final primary18 = primary.withValues(alpha: 0.18);
  static final primary35 = primary.withValues(alpha: 0.35);
  static final primary40 = primary.withValues(alpha: 0.4);
  static final primary50 = primary.withValues(alpha: 0.5);
  static final primary60 = primary.withValues(alpha: 0.6);
}

class ProductoFormScreen extends StatefulWidget {
  final String categoria;
  final String direccion;
  final XFile? imagenDestacada;
  final List<XFile> imagenesReales;

  const ProductoFormScreen({
    super.key,
    required this.categoria,
    required this.direccion,
    this.imagenDestacada,
    this.imagenesReales = const [],
  });

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _publicandoNotifier = ValueNotifier<bool>(false);
  final _scrollController = ScrollController();

  bool _verificandoPublicacion = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🟢 [PERF] ProductoFormScreen initState');
    _inicializarPublicidad();
  }

  // ============================================================
  // 👑 CONSULTAR ESTADO PREMIUM
  // ============================================================
  Future<bool> _consultarEstadoPremium() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return false;

      final idToken = await user.getIdToken();

      if (idToken == null) return false;

      final respuesta = await http.get(
        Uri.parse(
          'https://mimarketplace-production.up.railway.app/api/suscripciones/estado/${user.uid}',
        ),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      ).timeout(const Duration(seconds: 10));

      if (!mounted ||
          FirebaseAuth.instance.currentUser?.uid != user.uid) {
        return false;
      }

      final premium = respuesta.statusCode == 200 &&
          jsonDecode(respuesta.body)['premium'] == true;

      debugPrint(
        '>>> 👑 [PUBLICAR PRODUCTO] Estado premium: $premium',
      );

      return premium;
    } catch (e) {
      debugPrint(
        '>>> ⚠️ [PUBLICAR PRODUCTO] Error consultando premium: $e',
      );

      return false;
    }
  }

  // ============================================================
  // 🔥 CARGAR PUBLICIDAD SOLO PARA USUARIOS NORMALES
  // ============================================================
  Future<void> _inicializarPublicidad() async {
    final premium = await _consultarEstadoPremium();

    if (!mounted) return;

    if (premium) {
      debugPrint(
        '>>> 👑 [PUBLICAR PRODUCTO] Usuario premium: no se carga publicidad',
      );
      return;
    }

    RewardedAdManager.loadRewardedAd();
  }

  // ============================================================
  // 🔥 PUBLICAR CON O SIN PUBLICIDAD
  // ============================================================
  Future<void> _mostrarPopupAnuncioPublicar() async {
    if (_verificandoPublicacion ||
        _publicandoNotifier.value) return;

    if (!_formKey.currentState!.validate()) return;

    _verificandoPublicacion = true;

    try {
      final premium = await _consultarEstadoPremium();

      if (!mounted) return;

      // 👑 PUBLICAR DIRECTAMENTE SIN ANUNCIO
      if (premium) {
        debugPrint(
          '>>> 👑 [PUBLICAR PRODUCTO] Publicando directamente sin anuncio',
        );

        await _publicarProducto();
        return;
      }

      // 🔥 USUARIO NORMAL: CONSERVAR FLUJO DE PUBLICIDAD
      if (!RewardedAdManager.isAdLoaded) {
        RewardedAdManager.loadRewardedAd();
      }

      final confirmar = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _PopupAnuncioDialog(),
      );

      if (!mounted) return;

      if (confirmar == true) {
        _verAnuncioYPublicar();
      }
    } finally {
      _verificandoPublicacion = false;
    }
  }

  void _verAnuncioYPublicar() {
    final l10n = AppLocalizations.of(context)!;
    if (!RewardedAdManager.isAdLoaded) {
      RewardedAdManager.loadRewardedAd();
      _snack(l10n.cargandoAnuncio, Colors.orange);
      return;
    }

    RewardedAdManager.showRewardedAd(
      onRewarded: () {
        _snack(l10n.anuncioCompletado, Colors.green);
        _publicarProducto();
      },
      onDismissed: () {
        _snack(l10n.debesVerAnuncioParaPublicar, Colors.red);
      },
    );
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  Future<void> _publicarProducto() async {
    final l10n = AppLocalizations.of(context)!;
    if (_publicandoNotifier.value) return;
    _publicandoNotifier.value = true;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://mimarketplace-production.up.railway.app/api/productos'),
      );

      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken != null) {
        request.headers['Authorization'] = 'Bearer $idToken';
      }

      request.fields['nombre'] = _nombreController.text;
      request.fields['precio'] = _precioController.text;
      request.fields['descripcion'] = _descripcionController.text;
      request.fields['categoria'] = widget.categoria;
      request.fields['subcategoria'] = '';
      request.fields['vendedor_id'] =
          FirebaseAuth.instance.currentUser?.uid ?? '';
      request.fields['direccion'] = widget.direccion;

      if (widget.imagenDestacada != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'imagen_destacada',
          widget.imagenDestacada!.path,
        ));
      }

      for (final imagen in widget.imagenesReales) {
        request.files.add(await http.MultipartFile.fromPath(
          'imagenes_reales[]',
          imagen.path,
        ));
      }

      final response = await request.send();
      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(await response.stream.bytesToString());
        debugPrint('>>> ✅ Producto enviado: ${data['mensaje']}');
        _snack(
          l10n.productoEnviadoRevision,
          Colors.orange,
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        final errBody = await response.stream.bytesToString();
        debugPrint('>>> ❌ Error body: $errBody');
        throw Exception('Error al publicar (${response.statusCode})');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _snack(l10n.errorAlPublicar('$e'), Colors.red);
    } finally {
      _publicandoNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    debugPrint('🔁 [PERF] ProductoFormScreen build');
    return Scaffold(
      backgroundColor: _AppColors.bg,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(140),
        child: _ProductoAppBar(),
      ),
      body: RepaintBoundary(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 160,
            bottom: 32,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InfoCard(
                  icono: Icons.grid_view_rounded,
                  label: l10n.categoria,
                  valor: widget.categoria,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icono: Icons.location_on_outlined,
                  label: l10n.direccion,
                  valor: widget.direccion,
                ),
                const SizedBox(height: 12),
                RepaintBoundary(
                  child: _InputCard(
                    icono: Icons.inventory_2_outlined,
                    label: l10n.nombreDelProducto,
                  hint: l10n.ejemploNombreProducto,
                    controller: _nombreController,
                    maxLength: 80,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return l10n.ingresaNombreProducto;
                      }
                      if (v.trim().length < 3) {
                        return l10n.nombreMinimoCaracteres;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 12),
                RepaintBoundary(
                  child: _InputCard(
                    icono: Icons.monetization_on_outlined,
                    label: l10n.precio,
                    hint: l10n.ingresePrecioProducto,
                    controller: _precioController,
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.ingresaPrecio;
                      final precio = double.tryParse(v);
                      if (precio == null) return l10n.ingresaPrecioValido;
                      if (precio <= 0) return l10n.precioMayorCero;
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 12),
                RepaintBoundary(
                  child: _InputCard(
                    icono: Icons.description_outlined,
                    label: l10n.descripcion,
                    hint: l10n.escribeDescripcionDetallada,
                    controller: _descripcionController,
                    maxLines: 4,
                    maxLength: 1000,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? l10n.ingresaDescripcion : null,
                  ),
                ),
                const SizedBox(height: 28),
                _BotonPublicar(
                  publicando: _publicandoNotifier,
                  onPressed: _mostrarPopupAnuncioPublicar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('🔴 [PERF] ProductoFormScreen dispose');
    _nombreController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    _publicandoNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// ============================================================
// 🎨 APPBAR
// ============================================================
class _ProductoAppBar extends StatelessWidget {
  const _ProductoAppBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RepaintBoundary(
      child: ClipPath(
        clipper: const _BottomWaveClipper(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A3A6B), Color(0xFF0F2A47), Color(0xFF0A1929)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _AppColors.white10,
                        border: Border.all(color: _AppColors.white20),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [_AppColors.primary, _AppColors.primaryDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _AppColors.primary60,
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.inventory_2,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.publicarProducto,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          l10n.compartaProductoComunidad,
                          style: TextStyle(
                              fontSize: 12, color: _AppColors.white60),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 🧩 INFO CARD
// ============================================================
class _InfoCard extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;

  const _InfoCard({
    required this.icono,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _AppColors.white05,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _AppColors.primary35, width: 1.3),
        boxShadow: [
          BoxShadow(
            color: _AppColors.primary15,
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _AppColors.primary18,
              border: Border.all(color: _AppColors.primary40, width: 1.2),
            ),
            child: Icon(icono, color: _AppColors.primaryLight, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: _AppColors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: _AppColors.white50, size: 24),
        ],
      ),
    );
  }
}

// ============================================================
// 🧩 INPUT CARD — SIN boxShadow (lag al escribir teclado)
// ============================================================
class _InputCard extends StatelessWidget {
  final IconData icono;
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;

  const _InputCard({
    required this.icono,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _AppColors.white05,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _AppColors.primary35, width: 1.3),
        // ⚠️ boxShadow REMOVIDO: repintar sombra con el teclado = lag
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _AppColors.primary18,
                border: Border.all(color: _AppColors.primary40, width: 1.2),
              ),
              child: Icon(icono, color: _AppColors.primaryLight, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: _AppColors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  maxLength: maxLength,
                  validator: validator,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  cursorColor: _AppColors.primaryLight,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: _AppColors.white35,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    errorStyle: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 11,
                    ),
                    counterText: '', // 👈 oculta el "0/80"
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 🧩 BOTÓN PUBLICAR
// ============================================================
class _BotonPublicar extends StatelessWidget {
  final ValueNotifier<bool> publicando;
  final VoidCallback onPressed;

  const _BotonPublicar({required this.publicando, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [_AppColors.primary, _AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: _AppColors.primary60,
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: publicando,
        builder: (context, isLoading, _) => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      l10n.publicarProducto,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ============================================================
// 🧩 POPUP ANUNCIO
// ============================================================
class _PopupAnuncioDialog extends StatelessWidget {
  const _PopupAnuncioDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: _AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: _AppColors.primary50, width: 1.5),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [_AppColors.primary, _AppColors.primaryDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _AppColors.primary50,
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Icon(Icons.storefront, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.publicarProducto,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.paraPublicarNecesitasVerAnuncio,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _AppColors.white70),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      l10n.cancelar,
                      style: TextStyle(fontSize: 14, color: _AppColors.white60),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_circle_filled, size: 18),
                        const SizedBox(width: 6),
                        Text(l10n.verAnuncio, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 🎨 WAVE CLIPPER
// ============================================================
class _BottomWaveClipper extends CustomClipper<Path> {
  const _BottomWaveClipper();

  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 20)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height + 20,
        size.width,
        size.height - 20,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}