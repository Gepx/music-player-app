import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/common/widgets/subwidget/bottom_navigation/navigation_item.dart';

class NavigationItems {
  static const List<NavigationItemData> items = [
    NavigationItemData(icon: Iconsax.home, label: 'Home', index: 0),
    NavigationItemData(icon: Iconsax.radio, label: 'Radio', index: 1),
    NavigationItemData(
      icon: Iconsax.music_library_2,
      label: 'Library',
      index: 2,
    ),
    NavigationItemData(icon: Iconsax.search_normal, label: 'Search', index: 3),
  ];
}
