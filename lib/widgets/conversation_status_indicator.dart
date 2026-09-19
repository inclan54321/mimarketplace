import 'package:flutter/material.dart';
import 'package:animated_emoji/animated_emoji.dart';
import 'dart:async';

enum ConversationStatus {
  neutral,    // ⚪ Gris - Sin suficiente información
  good,       // 🟢 Verde - Todo bien
  warning,    // 🟡 Amarillo - Precaución
  danger,     // 🔴 Rojo - Peligro inminente
}

class ConversationStatusIndicator extends StatefulWidget {
  final ConversationStatus status;
  final double size;
  final VoidCallback? onTap;
  final bool showAnimation;

  const ConversationStatusIndicator({
    super.key,
    this.status = ConversationStatus.neutral,
    this.size = 50,
    this.onTap,
    this.showAnimation = true,
  });

  @override
  State<ConversationStatusIndicator> createState() => _ConversationStatusIndicatorState();
}

class _ConversationStatusIndicatorState extends State<ConversationStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  
  // Lista de emojis para animar (SOLO los que existen)
  final List<AnimatedEmoji> _emojis = [
    const AnimatedEmoji(AnimatedEmojis.smile, size: 30, repeat: true),
    const AnimatedEmoji(AnimatedEmojis.joy, size: 30, repeat: true),
    const AnimatedEmoji(AnimatedEmojis.heartEyes, size: 30, repeat: true),
    const AnimatedEmoji(AnimatedEmojis.wink, size: 30, repeat: true),
    const AnimatedEmoji(AnimatedEmojis.sad, size: 30, repeat: true),
    const AnimatedEmoji(AnimatedEmojis.angry, size: 30, repeat: true),
  ];
  
  int _currentEmojiIndex = 0;
  Timer? _emojiTimer;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.showAnimation) {
      _emojiTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
        if (mounted) {
          setState(() {
            _currentEmojiIndex = (_currentEmojiIndex + 1) % _emojis.length;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _emojiTimer?.cancel();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case ConversationStatus.good:
        return Colors.green;
      case ConversationStatus.warning:
        return Colors.amber;
      case ConversationStatus.danger:
        return Colors.red;
      case ConversationStatus.neutral:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = 0.9 + (0.1 * _pulseAnimation.value);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getStatusColor().withValues(alpha: 0.2),
                border: Border.all(
                  color: _getStatusColor(),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor().withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: _emojis[_currentEmojiIndex],
              ),
            ),
          );
        },
      ),
    );
  }
}