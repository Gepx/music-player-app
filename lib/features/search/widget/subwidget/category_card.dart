import 'package:flutter/material.dart';
import 'package:music_player/utils/constants/colors.dart';

class CategoryItem {
  final String name;
  final Color color;
  final IconData icon;

  CategoryItem(this.name, this.color, this.icon);
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category, required this.onTap});

  final CategoryItem category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            category.color.withValues(alpha: 0.9),
            category.color.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    color: FColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Transform.rotate(
                    angle: 0.2,
                    child: Icon(
                      category.icon,
                      color: FColors.textWhite.withValues(alpha: 0.8),
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
