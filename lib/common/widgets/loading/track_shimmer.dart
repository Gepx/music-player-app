import 'package:flutter/material.dart';

import 'shimmer_loader.dart';

class TrackShimmer extends StatelessWidget {
  final int itemCount;
  final double imageSize;

  const TrackShimmer({
    super.key,
    this.itemCount = 6,
    this.imageSize = 56,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: imageSize,
                  height: imageSize,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: double.infinity, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 160, color: Colors.white),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

