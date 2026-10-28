import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
class RewardedAdManager {
  static RewardedAd? _rewardedAd;
  static bool _isAdLoaded = false;

  // 🔥 Completer para saber cuándo termina la carga
  static Completer<bool>? _loadCompleter;

  // 🔥 ID de UNIDAD de Recompensado de PRUEBA (NO genera ingresos)
  static const String _adUnitId = 'ca-app-pub-3940256099942544/5224354917';

  static void loadRewardedAd() {
    // 🔥 Si ya hay una carga en curso, no lanzar otra
    if (_loadCompleter != null && !_loadCompleter!.isCompleted) {
      return;
    }

    _loadCompleter = Completer<bool>();

    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
          print('>>> ✅ Rewarded Ad de prueba cargado');
          if (_loadCompleter != null && !_loadCompleter!.isCompleted) {
            _loadCompleter!.complete(true);
          }
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          print('>>> ❌ Error al cargar Rewarded Ad: $error');
          if (_loadCompleter != null && !_loadCompleter!.isCompleted) {
            _loadCompleter!.complete(false);
          }
        },
      ),
    );
  }

  // 🔥 Esperar a que el anuncio esté cargado (o falle)
  static Future<bool> waitForAdLoaded({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_isAdLoaded) return true;

    loadRewardedAd();

    if (_loadCompleter == null) {
      return false;
    }

    try {
      return await _loadCompleter!.future.timeout(timeout);
    } catch (_) {
      return false;
    }
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