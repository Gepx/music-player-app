import 'package:flutter/material.dart';

class SlideInWidget extends StatelessWidget {
  final Widget child;
  final Offset beginOffset;
  final Duration duration;
  final Curve curve;

  const SlideInWidget({
    super.key,
    required this.child,
    this.beginOffset = const Offset(0, 0.15),
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: beginOffset, end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: Offset(0, offset.dy * 100),
          child: child,
        );
      },
      child: child,
    );
  }
}

