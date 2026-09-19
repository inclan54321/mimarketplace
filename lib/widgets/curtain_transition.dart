import 'package:flutter/material.dart';

class CurtainTransition extends StatefulWidget {
  final Widget child;
  final bool forward; // true = sube, false = baja

  const CurtainTransition({
    super.key,
    required this.child,
    this.forward = true,
  });

  @override
  State<CurtainTransition> createState() => _CurtainTransitionState();
}

class _CurtainTransitionState extends State<CurtainTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    if (widget.forward) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant CurtainTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.forward != oldWidget.forward) {
      if (widget.forward) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: _animation.value,
        child: widget.child,
      ),
    );
  }
}