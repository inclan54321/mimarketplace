import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../l10n/generated/app_localizations.dart';
import '../main.dart' show currencyClient;

class EliminarPublicidadScreen extends StatefulWidget {
  const EliminarPublicidadScreen({super.key});

  @override
  State<EliminarPublicidadScreen> createState() =>
      _EliminarPublicidadScreenState();
}

class _EliminarPublicidadScreenState extends State<EliminarPublicidadScreen> {
  String? _planSeleccionado; // 'mensual' o 'semestral'

  double? _precioMensualConvertido;
  double? _precioSemestralConvertido;
  String _monedaDestino = 'CRC';
  bool _cargandoPrecios = true;

  // 🔥 GOOGLE PLAY BILLING
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  final InAppPurchase _iap = InAppPurchase.instance;
  List<ProductDetails> _productosDisponibles = [];
  bool _cargandoProductos = true;

  @override
  void initState() {
    super.initState();
    _convertirPrecios();
    _inicializarCompras();
  }

  Future<void> _inicializarCompras() async {
    final bool disponible = await _iap.isAvailable();
    if (!disponible) {
      debugPrint('>>> ❌ Google Play Billing no disponible');
      setState(() => _cargandoProductos = false);
      return;
    }

    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (error) => debugPrint('>>> ❌ Error en purchaseStream: $error'),
    );

    const Set<String> ids = {
      'plan_mensual_sin_anuncios',
      'plan_semestral_sin_anuncios',
    };

    final ProductDetailsResponse respuesta = await _iap.queryProductDetails(ids);
    if (respuesta.error != null) {
      debugPrint('>>> ❌ Error consultando productos: ${respuesta.error}');
    }

    setState(() {
      _productosDisponibles = respuesta.productDetails;
      _cargandoProductos = false;
    });

    debugPrint('>>> 🛒 Productos disponibles: ${_productosDisponibles.map((p) => p.id).toList()}');
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  Future<void> _convertirPrecios() async {
    final locale = ui.PlatformDispatcher.instance.locale;
    debugPrint('>>> 🌍 locale del sistema: ${locale.languageCode}');
    debugPrint('>>> 🌍 locale completo: $locale');

    String destino = 'CRC';
    if (locale.languageCode == 'en') destino = 'USD';
    if (locale.languageCode == 'de') destino = 'EUR';
    debugPrint('>>> 🌍 moneda destino: $destino');

    if (destino == 'CRC') {
      setState(() {
        _precioMensualConvertido = 1000.0;
        _precioSemestralConvertido = 3000.0;
        _monedaDestino = 'CRC';
        _cargandoPrecios = false;
      });
      return;
    }

    try {
      final mensual = await currencyClient.convert(
        amount: 1000.0,
        from: 'CRC',
        to: destino,
      );
      final semestral = await currencyClient.convert(
        amount: 3000.0,
        from: 'CRC',
        to: destino,
      );

      if (!mounted) return;
      setState(() {
        _precioMensualConvertido = mensual;
        _precioSemestralConvertido = semestral;
        _monedaDestino = destino;
        _cargandoPrecios = false;
      });
    } catch (e) {
      debugPrint('>>> ❌ Error convirtiendo moneda: $e');
      if (!mounted) return;
      setState(() {
        _precioMensualConvertido = 1000.0;
        _precioSemestralConvertido = 3000.0;
        _monedaDestino = 'CRC';
        _cargandoPrecios = false;
      });
    }
  }

  String _formatearPrecio(double monto) {
    final locale = _monedaDestino == 'USD'
        ? 'en_US'
        : _monedaDestino == 'EUR'
            ? 'de_DE'
            : 'es_CR';
    return NumberFormat.simpleCurrency(locale: locale, name: _monedaDestino)
        .format(monto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.eliminarPublicidadTitulo),
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
            Text(
              AppLocalizations.of(context)!.eliminaLosAnuncios,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // 🔥 DESCRIPCIÓN
            Text(
              AppLocalizations.of(context)!.descripcionEliminarPublicidad,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // 🔥 BENEFICIOS
            _buildBeneficio(AppLocalizations.of(context)!.beneficioSinAnuncios),
            _buildBeneficio(
                AppLocalizations.of(context)!.beneficioNavegacionRapida),
            _buildBeneficio(
                AppLocalizations.of(context)!.beneficioSinInterrupciones),
            const SizedBox(height: 32),

            Text(
              AppLocalizations.of(context)!.elegiTuPlan,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 🔥 PLAN MENSUAL
            _buildPlanCard(
              id: 'mensual',
              titulo: AppLocalizations.of(context)!.plan1Mes,
              precio: _cargandoPrecios
                  ? '...'
                  : _formatearPrecio(_precioMensualConvertido ?? 1000.0),
              subtitulo: AppLocalizations.of(context)!.sinAnunciosPor30Dias,
              ahorro: null,
            ),
            const SizedBox(height: 12),

            // 🔥 PLAN SEMESTRAL
            _buildPlanCard(
              id: 'semestral',
              titulo: AppLocalizations.of(context)!.plan6Meses,
              precio: _cargandoPrecios
                  ? '...'
                  : _formatearPrecio(_precioSemestralConvertido ?? 3000.0),
              subtitulo: AppLocalizations.of(context)!.sinAnunciosPor180Dias,
              ahorro: _cargandoPrecios
                  ? null
                  : AppLocalizations.of(context)!
                      .ahorrasMonto(_formatearPrecio(3000.0)),
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
                      ? AppLocalizations.of(context)!.elegiUnPlan
                      : AppLocalizations.of(context)!.pagarMonto(
                          _planSeleccionado == 'mensual'
                              ? _formatearPrecio(
                                  _precioMensualConvertido ?? 1000.0)
                              : _formatearPrecio(
                                  _precioSemestralConvertido ?? 3000.0)),
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
                AppLocalizations.of(context)!.pagoSeguro,
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
                      Flexible(
                        child: Text(
                          titulo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (ahorro != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
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
                              overflow: TextOverflow.ellipsis,
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
            Flexible(
              child: Text(
                precio,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarCompra(String plan) async {
    final String productId = plan == 'mensual'
        ? 'plan_mensual_sin_anuncios'
        : 'plan_semestral_sin_anuncios';

    final ProductDetails? producto = _productosDisponibles
        .where((p) => p.id == productId)
        .firstOrNull;

    if (producto == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto no disponible. Revisa tu conexión.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: producto);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _verificarCompraEnBackend(purchase);
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

  Future<void> _verificarCompraEnBackend(PurchaseDetails purchase) async {
    debugPrint('>>> ✅ Compra recibida: ${purchase.productID}');
    String? token;
    if (purchase is GooglePlayPurchaseDetails) {
      token = purchase.billingClientPurchase.purchaseToken;
    }
    debugPrint('>>> 🔑 PurchaseToken: $token');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Compra exitosa. Los anuncios se quitarán pronto.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}