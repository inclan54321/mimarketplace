import 'package:flutter/material.dart';

class SwipeAnimationIndicator extends StatefulWidget {
  const SwipeAnimationIndicator({super.key});

  @override
  State<SwipeAnimationIndicator> createState() => _SwipeAnimationIndicatorState();
}

class _SwipeAnimationIndicatorState extends State<SwipeAnimationIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;
        final isForward = _controller.status == AnimationStatus.forward;

        return CustomPaint(
          painter: SwipePainter(
            progress: progress,
            isForward: isForward,
          ),
          size: const Size(200, 80),
        );
      },
    );
  }
}

class SwipePainter extends CustomPainter {
  final double progress;
  final bool isForward;

  SwipePainter({required this.progress, required this.isForward});

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final startX = 20.0;
    final endX = size.width - 20;
    final range = endX - startX;

    final currentX = startX + (progress * range);

    // ===== 1. TRAZO =====
    if (isForward) {
      final opacity = (1 - progress) * 0.5;

      final paint = Paint()
        ..color = Colors.blue.shade400.withValues(alpha: opacity)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(startX, centerY),
        Offset(currentX, centerY),
        paint,
      );
    }

    // ===== 2. MANO (Icons.touch_app) =====
    const icon = Icons.touch_app;
    const iconSize = 36.0;

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: iconSize,
          color: Colors.blue.shade700,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    iconPainter.paint(
      canvas,
      Offset(currentX - iconSize / 2, centerY - iconSize / 2),
    );
  }

  @override
  bool shouldRepaint(covariant SwipePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isForward != isForward;
  }
}