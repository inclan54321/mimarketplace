import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerPruebaWidget extends StatefulWidget {
  const BannerPruebaWidget({super.key});

  @override
  State<BannerPruebaWidget> createState() => _BannerPruebaWidgetState();
}

class _BannerPruebaWidgetState extends State<BannerPruebaWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // 🔥 ID de UNIDAD de Banner de PRUEBA de Google (NO genera ingresos)
  final String _adUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _cargarBanner();
  }

  void _cargarBanner() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
          print('>>> ✅ Banner de prueba cargado con éxito');
        },
        onAdFailedToLoad: (ad, error) {
          print('>>> ❌ Error al cargar banner de prueba: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }
}