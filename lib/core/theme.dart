import 'package:flutter/material.dart';

import 'constants/app_colors.dart';

ThemeData buildFolkTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.maroon).copyWith(
    primary: AppColors.maroon,
    secondary: AppColors.saffron,
    surface: AppColors.cream,
    onSurface: AppColors.brown,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  const gold = Color(0xFFD9A441);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.grass,
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.brown,
      displayColor: AppColors.maroon,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.maroon, width: 3),
      ),
      titleTextStyle: const TextStyle(
          color: AppColors.maroon, fontSize: 20, fontWeight: FontWeight.w800),
      contentTextStyle:
          const TextStyle(color: AppColors.brown, fontSize: 15, height: 1.35),
      iconColor: AppColors.maroon,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFFFF8E7),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: gold, width: 1.5),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.parchment,
      dragHandleColor: AppColors.maroon,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        side: BorderSide(color: AppColors.maroon, width: 3),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.leaf,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.maroon,
        side: const BorderSide(color: AppColors.maroon, width: 1.5),
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.maroon),
    ),
    listTileTheme: const ListTileThemeData(iconColor: AppColors.maroon),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.leaf,
      linearTrackColor: Color(0x33000000),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.maroon,
      contentTextStyle: const TextStyle(color: AppColors.cream),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
