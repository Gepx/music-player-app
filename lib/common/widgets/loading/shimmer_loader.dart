import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:music_player/utils/constants/colors.dart';

class ShimmerLoader extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const ShimmerLoader({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Shimmer.fromColors(
      baseColor: FColors.darkerGrey,
      highlightColor: FColors.darkGrey.withValues(alpha: 0.65),
      child: child,
    );
  }
}

