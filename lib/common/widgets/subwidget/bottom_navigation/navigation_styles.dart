import 'package:flutter/material.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/utils/constants/sizes.dart';

// Navigation styles for consistent theming
class NavigationStyles {
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const EdgeInsets itemPadding = EdgeInsets.symmetric(
    horizontal: FSizes.sm,
    vertical: FSizes.xs,
  );
  static const EdgeInsets containerPadding = EdgeInsets.symmetric(
    horizontal: FSizes.md,
    vertical: FSizes.sm,
  );

  static TextStyle getLabelStyle(bool isSelected) {
    return TextStyle(
      color: isSelected ? FColors.primary : FColors.grey,
      fontSize: FSizes.fontSizeSm,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      fontFamily: 'Poppins',
    );
  }

  static Color getIconColor(bool isSelected) {
    return isSelected ? FColors.primary : FColors.grey;
  }

  static Color getBackgroundColor(bool isSelected) {
    return isSelected
        ? FColors.primary.withValues(alpha: 0.1)
        : Colors.transparent;
  }
}
