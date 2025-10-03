import 'package:flutter/material.dart';
import 'package:music_player/utils/constants/sizes.dart';

class FSpacingStyle {
  static const EdgeInsetsGeometry paddingWithAppBarHeight = EdgeInsets.only(
    top: FSizes.appBarHeight,
    left: FSizes.defaultSpace,
    bottom: FSizes.defaultSpace,
    right: FSizes.defaultSpace,
  );
}
