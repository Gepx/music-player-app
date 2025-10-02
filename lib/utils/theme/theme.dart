import 'package:flutter/material.dart';

import 'package:music_player/utils/theme/custom_themes/appbar_theme.dart';
import 'package:music_player/utils/theme/custom_themes/button_sheet_theme.dart';
import 'package:music_player/utils/theme/custom_themes/checkbox_theme.dart';
import 'package:music_player/utils/theme/custom_themes/chip_theme.dart';
import 'package:music_player/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:music_player/utils/theme/custom_themes/outlined_button_theme.dart';
import 'package:music_player/utils/theme/custom_themes/text_field_theme.dart';
import 'package:music_player/utils/theme/custom_themes/text_theme.dart';

class FAppTheme {
  FAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    textTheme: FTextTheme.lightTextTheme,
    chipTheme: FChipTheme.lightChipTheme,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: FAppBarTheme.lightAppBarTheme,
    checkboxTheme: FCheckboxTheme.lightCheckboxTheme,
    bottomSheetTheme: FBottomSheetTheme.lightBottomSheetTheme,
    elevatedButtonTheme: FElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: FOutlinedButtonTheme.lightOutlineButtonTheme,
    inputDecorationTheme: FTextFormFieldTheme.lightInputDecorationTheme,
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    textTheme: FTextTheme.darkTextTheme,
    chipTheme: FChipTheme.darkChipTheme,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: FAppBarTheme.darkAppBarTheme,
    checkboxTheme: FCheckboxTheme.darkCheckboxTheme,
    bottomSheetTheme: FBottomSheetTheme.darkBottomSheetTheme,
    elevatedButtonTheme: FElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: FOutlinedButtonTheme.darkOutlineButtonTheme,
    inputDecorationTheme: FTextFormFieldTheme.darkInputDecorationTheme,
  );
}
