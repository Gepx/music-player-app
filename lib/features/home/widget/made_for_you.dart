import 'package:flutter/material.dart';

class MadeForYouList extends StatelessWidget {
  const MadeForYouList({super.key});

  @override
  Widget build(BuildContext context) {
    final madeForYou = [
      {'title': 'Daily Mix 1', 'subtitle': 'Made for you', 'image': '🎵'},
      {'title': 'Discover Weekly', 'subtitle': 'Made for you', 'image': '🔍'},
      {'title': 'Release Radar', 'subtitle': 'Made for you', 'image': '📡'},
      {'title': 'Time Capsule', 'subtitle': 'Made for you', 'image': '⏰'},
    ];

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: madeForYou.length,
        itemBuilder: (context, index) {
          final item = madeForYou[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF8B5CF6),
                        const Color(0xFF7C3AED),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item['image'] as String,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['subtitle'] as String,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
