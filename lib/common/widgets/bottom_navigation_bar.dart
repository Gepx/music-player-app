import 'package:flutter/material.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/common/widgets/subwidget/bottom_navigation/navigation_item.dart';
import 'package:music_player/common/widgets/subwidget/bottom_navigation/navigation_items.dart';
import 'package:music_player/common/widgets/subwidget/bottom_navigation/navigation_styles.dart';

class FBottomNavigationBar extends StatelessWidget {
  const FBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: FColors.dark,
        border: Border(top: BorderSide(color: FColors.darkerGrey, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: NavigationStyles.containerPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                NavigationItems.items
                    .map(
                      (item) => NavigationItemWidget(
                        item: item,
                        isSelected: currentIndex == item.index,
                        onTap: () => onTap(item.index),
                      ),
                    )
                    .toList(),
          ),
        ),
      ),
    );
  }
}
