import 'package:flutter/material.dart';
import 'package:music_player/utils/constants/sizes.dart';
import 'package:music_player/common/widgets/subwidget/bottom_navigation/navigation_styles.dart';

class NavigationItemWidget extends StatelessWidget {
  const NavigationItemWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final NavigationItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: NavigationStyles.animationDuration,
        padding: NavigationStyles.itemPadding,
        decoration: BoxDecoration(
          color: NavigationStyles.getBackgroundColor(isSelected),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: NavigationStyles.getIconColor(isSelected),
              size: FSizes.iconMd,
            ),
            const SizedBox(height: FSizes.xs),
            Text(item.label, style: NavigationStyles.getLabelStyle(isSelected)),
          ],
        ),
      ),
    );
  }
}

// Navigation item data class
class NavigationItemData {
  final IconData icon;
  final String label;
  final int index;

  const NavigationItemData({
    required this.icon,
    required this.label,
    required this.index,
  });
}
