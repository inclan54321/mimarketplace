import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdManager {
  static RewardedAd? _rewardedAd;
  static bool _isAdLoaded = false;

  // 🔥 ID de UNIDAD de Recompensado de PRUEBA (NO genera ingresos)
  static const String _adUnitId = 'ca-app-pub-3940256099942544/5224354917';

  static void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
          print('>>> ✅ Rewarded Ad de prueba cargado');
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          print('>>> ❌ Error al cargar Rewarded Ad: $error');
        },
      ),
    );
  }

  static Future<bool> showRewardedAd({
    required VoidCallback onRewarded,
    required VoidCallback onDismissed,
  }) async {
    if (_rewardedAd == null || !_isAdLoaded) {
      loadRewardedAd();
      return false;
    }

    bool rewarded = false;

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewarded = true;
        onRewarded();
        // 🔥 Cerrar el anuncio automáticamente después de la recompensa
        Future.delayed(const Duration(milliseconds: 500), () {
          ad.dispose();
          _rewardedAd = null;
          _isAdLoaded = false;
          loadRewardedAd();
        });
      },
    );

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('>>> Anuncio mostrado');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('>>> Anuncio cerrado por el usuario');
        onDismissed();
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('>>> Error al mostrar anuncio: $error');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        loadRewardedAd();
      },
    );

    return rewarded;
  }

  static bool get isAdLoaded => _isAdLoaded;
}