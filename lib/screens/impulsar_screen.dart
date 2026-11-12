import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../services/producto_service.dart';
import '../models/producto.dart';

class ImpulsarScreen extends StatefulWidget {
  const ImpulsarScreen({super.key});

  @override
  State<ImpulsarScreen> createState() => _ImpulsarScreenState();
}

class _ImpulsarScreenState extends State<ImpulsarScreen> {
  // 🔥 Estado de la pantalla
  bool _modoSeleccion = false; // false = intro, true = configuración
  Producto? _productoSeleccionado;

  // 🔥 GOOGLE PLAY BILLING
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  final InAppPurchase _iap = InAppPurchase.instance;
  ProductDetails? _productoImpulso;
  bool _cargandoProducto = true;
  bool _procesandoCompra = false;
  final Set<String> _comprasProcesadas = {};

  @override
  void initState() {
    super.initState();
    _inicializarCompras();
  }

  Future<void> _inicializarCompras() async {
    final bool disponible = await _iap.isAvailable();
    if (!disponible) {
      debugPrint('>>> ❌ Google Play Billing no disponible');
      setState(() => _cargandoProducto = false);
      return;
    }

    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (error) => debugPrint('>>> ❌ Error en purchaseStream: $error'),
    );

    // 🔥 Recuperar compras pendientes (por si cerró la app antes de verificar)
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('>>> ⚠️ Error en restorePurchases: $e');
    }

    const Set<String> ids = {'impulso_500'};

    final ProductDetailsResponse respuesta = await _iap.queryProductDetails(ids);
    if (respuesta.error != null) {
      debugPrint('>>> ❌ Error consultando producto: ${respuesta.error}');
    }

    setState(() {
      _productoImpulso = respuesta.productDetails.isNotEmpty
          ? respuesta.productDetails.first
          : null;
      _cargandoProducto = false;
    });

    debugPrint('>>> 🛒 Producto impulso disponible: ${_productoImpulso?.id ?? "NINGUNO"}');
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: Text(_modoSeleccion ? 'Configurar impulso' : 'Impulsar'),
        backgroundColor: const Color(0xFF0D1117),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: _modoSeleccion
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _modoSeleccion = false;
                    _productoSeleccionado = null;
                  });
                },
              )
            : null,
      ),
      body: _modoSeleccion ? _buildConfiguracion() : _buildIntro(),
    );
  }

  // ============================================================
  // 🎬 PANTALLA 1: INTRO
  // ============================================================
  Widget _buildIntro() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFB300).withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.rocket_launch,
                size: 52,
                color: Color(0xFFFFB300),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Impulsar publicación',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Poné tu producto primero',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPunto(
                  '🚀',
                  'Subí al primer lugar',
                  'Tu producto aparece primero en la lista de Productos Destacados del Home.',
                ),
                const SizedBox(height: 18),
                _buildPunto(
                  '👀',
                  'Más visibilidad',
                  'Al estar primero, más personas lo ven y tenés más chances de venderlo rápido.',
                ),
                const SizedBox(height: 18),
                _buildPunto(
                  '⏱️',
                  'Duración limitada',
                  'El impulso dura hasta que otro vendedor pague por subir. Ahí bajás un lugar.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 🔥 BOTÓN PRINCIPAL
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _abrirSelectorProducto,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text(
                'Seleccionar artículo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 🔥 AVISO DE "PRÓXIMAMENTE"
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFB300).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.construction,
                  color: Color(0xFFFFB300),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Próximamente disponible. Estamos habilitando los pagos.',
                    style: TextStyle(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPunto(String emoji, String titulo, String descripcion) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                descripcion,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 🎬 PANTALLA 2: CONFIGURACIÓN DEL IMPULSO
  // ============================================================
  Widget _buildConfiguracion() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 PRODUCTO SELECCIONADO
          const Text(
            'Artículo a impulsar',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildCardProducto(_productoSeleccionado!),
          const SizedBox(height: 24),

          // 🔥 EXPLICACIÓN DEL IMPULSO
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFFFFB300),
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      '¿Cómo funciona?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Al impulsar, tu producto sube al primer lugar del Home. '
                  'Si otro vendedor impulsa su producto, vos bajás un lugar. '
                  'El que pagó más recientemente siempre está primero.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 🔥 BOTÓN IMPULSAR
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_productoImpulso == null ||
                          _cargandoProducto ||
                          _procesandoCompra)
                  ? null
                  : _impulsar,
              icon: (_cargandoProducto || _procesandoCompra)
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.rocket_launch),
              label: Text(
                _procesandoCompra
                    ? 'Procesando...'
                    : (_cargandoProducto
                        ? 'Cargando...'
                        : 'Impulsar ahora'),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300),
                foregroundColor: Colors.black,
                disabledBackgroundColor: const Color(0xFFFFB300).withValues(alpha: 0.4),
                disabledForegroundColor: Colors.black54,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 Card del producto seleccionado
  Widget _buildCardProducto(Producto producto) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty
                ? Image.network(
                    'https://mimarketplace-production.up.railway.app${producto.imagenMiniatura ?? producto.imagenUrl}',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₡${producto.precio.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFF60A5FA),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white54, size: 20),
            onPressed: _abrirSelectorProducto,
            tooltip: 'Cambiar producto',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔧 LÓGICA
  // ============================================================

  // 🔥 Abrir selector de producto (bottom sheet)
  void _abrirSelectorProducto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión')),
      );
      return;
    }

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final productos = await ProductoService().getProductosByVendedor(user.uid);
      if (!mounted) return;
      Navigator.pop(context); // cerrar loading

      if (productos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No tenés productos publicados'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Abrir bottom sheet con la lista
      final seleccionado = await showModalBottomSheet<Producto>(
        context: context,
        backgroundColor: const Color(0xFF161B22),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        isScrollControlled: true,
        builder: (context) => _buildSelectorProducto(productos),
      );

      if (seleccionado != null) {
        setState(() {
          _productoSeleccionado = seleccionado;
          _modoSeleccion = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // 🔥 Bottom sheet con lista de productos
  Widget _buildSelectorProducto(List<Producto> productos) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Elegí un artículo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'El que elijas aparecerá primero en el Home',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF30363D), height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final p = productos[index];
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, p),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1117),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF30363D)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: p.imagenUrl != null &&
                                    p.imagenUrl!.isNotEmpty
                                ? Image.network(
                                    'https://mimarketplace-production.up.railway.app${p.imagenMiniatura ?? p.imagenUrl}',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey.shade800,
                                      child: const Icon(Icons.image,
                                          color: Colors.grey, size: 24),
                                    ),
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey.shade800,
                                    child: const Icon(Icons.image,
                                        color: Colors.grey, size: 24),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.nombre,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₡${p.precio.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Color(0xFF60A5FA),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: Colors.white38),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // 🔥 Impulsar (pago con Google Play)
  Future<void> _impulsar() async {
    if (_productoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero elegí un artículo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión')),
      );
      return;
    }

    if (_productoImpulso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto de impulso no disponible. Revisá tu conexión.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 🔥 Iniciar la compra en Google Play (consumible)
    // autoConsume: false → el backend es quien consume el token
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: _productoImpulso!,
    );
    await _iap.buyConsumable(
      purchaseParam: purchaseParam,
      autoConsume: false,  // 🔥 acá va, no en PurchaseParam
    );
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchase in purchaseDetailsList) {
      // 🔥 Solo procesar compras "purchased", no "restored"
      if (purchase.status == PurchaseStatus.purchased) {
        final pid = purchase.purchaseID ?? '';
        if (pid.isNotEmpty && _comprasProcesadas.contains(pid)) {
          // ya procesada → completar y salir
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
          continue;
        }
        if (pid.isNotEmpty) _comprasProcesadas.add(pid);
        _verificarPagoImpulso(purchase);
      }

      if (purchase.status == PurchaseStatus.error) {
        debugPrint('>>> ❌ Error en compra: ${purchase.error}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${purchase.error?.message ?? 'Desconocido'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _verificarPagoImpulso(PurchaseDetails purchase) async {
    String? token;
    if (purchase is GooglePlayPurchaseDetails) {
      token = purchase.billingClientPurchase.purchaseToken;
    }

    if (token == null) {
      debugPrint('>>> ❌ No se obtuvo purchaseToken');
      return;
    }

    if (_procesandoCompra) {
      debugPrint('>>> ⏭️ Ya hay una compra en proceso, ignorando');
      return;
    }

    if (!mounted) return;
    setState(() => _procesandoCompra = true);

    // Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      final response = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/productos/${_productoSeleccionado!.id}/impulsar'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'usuario_id': user?.uid,
          'purchase_token': token,
        }),
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // cerrar loading

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ "${_productoSeleccionado!.nombre}" está primero en el Home'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        final codigo = data['codigo'];
        String mensaje;
        switch (codigo) {
          case 'PAGO_INVALIDO':
            mensaje = 'El pago no se pudo verificar. Contactá a soporte.';
            break;
          case 'COMPRA_NO_COMPLETADA':
            mensaje = 'La compra quedó pendiente. Intentá de nuevo.';
            break;
          default:
            mensaje = data['error'] ?? 'Error al impulsar';
        }
        throw Exception(mensaje);
      }
    } catch (e) {
      if (!mounted) return;
      // Cerrar loading si sigue abierto
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _procesandoCompra = false);
    }
  }
}