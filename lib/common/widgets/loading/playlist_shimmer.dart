import 'package:flutter/material.dart';

import 'shimmer_loader.dart';

class PlaylistShimmer extends StatelessWidget {
  final int itemCount;

  const PlaylistShimmer({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            return SizedBox(
              width: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 160,
                      height: 120,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(height: 14, width: 140, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 12, width: 90, color: Colors.white),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

