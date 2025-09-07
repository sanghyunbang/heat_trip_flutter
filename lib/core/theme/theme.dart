import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

AppBarTheme appBarTheme() {
  return AppBarTheme(
    centerTitle: false,
    backgroundColor: Colors.white,
    elevation: 0.0,
    scrolledUnderElevation: 0,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: GoogleFonts.nanumGothic(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  );
}

BottomNavigationBarThemeData bottomNavigationTheme() {
  return const BottomNavigationBarThemeData(
    selectedItemColor: Color(0xFFEB9C64),
    unselectedItemColor: Colors.grey,
    showUnselectedLabels: true,
  );
}

ThemeData theme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    shadowColor: Colors.transparent,

    appBarTheme: appBarTheme(),
    bottomNavigationBarTheme: bottomNavigationTheme(),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: const WidgetStatePropertyAll(0),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    ),

    cardTheme: const CardThemeData(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    dialogTheme: const DialogThemeData(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    // 전역 스낵바: floating + 하단 여백 + 둥근 모서리
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      insetPadding: EdgeInsets.fromLTRB(12, 0, 12,5),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
    ),
    chipTheme: const ChipThemeData(
      elevation: 0,
      pressElevation: 0,
      shadowColor: Colors.transparent,
      selectedShadowColor: Colors.transparent,
    ),

    bottomAppBarTheme: const BottomAppBarTheme(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
    ),
  );
}
