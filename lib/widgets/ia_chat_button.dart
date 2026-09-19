import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/rewarded_ad_prueba.dart';

class IaChatButton extends StatefulWidget {
  final bool isActive;
  final VoidCallback onToggle;
  final VoidCallback onAdCompleted;

  const IaChatButton({
    super.key,
    required this.isActive,
    required this.onToggle,
    required this.onAdCompleted,
  });

  @override
  State<IaChatButton> createState() => _IaChatButtonState();
}

class _IaChatButtonState extends State<IaChatButton> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    RewardedAdManager.loadRewardedAd();
  }

  void _handleToggle() async {
    if (widget.isActive) {
      widget.onToggle();
      return;
    }

    setState(() => _isLoading = true);

    if (!RewardedAdManager.isAdLoaded) {
      RewardedAdManager.loadRewardedAd();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏳ Cargando anuncio... espera un momento'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    RewardedAdManager.showRewardedAd(
      onRewarded: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ IA activada correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        widget.onToggle();
        widget.onAdCompleted();
        setState(() => _isLoading = false);
      },
      onDismissed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Debes ver el anuncio completo para activar la IA'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() => _isLoading = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _handleToggle,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: widget.isActive 
              ? Colors.green.withValues(alpha: 0.15) 
              : Colors.grey.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isActive ? Colors.green : Colors.grey,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blue,
                ),
              )
            else
              Icon(
                widget.isActive ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                color: widget.isActive ? Colors.green : Colors.grey,
                size: 20,
              ),
            const SizedBox(width: 4),
            Text(
              _isLoading 
                  ? 'Cargando...' 
                  : widget.isActive 
                      ? 'IA Activa' 
                      : 'Activar IA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: widget.isActive ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}