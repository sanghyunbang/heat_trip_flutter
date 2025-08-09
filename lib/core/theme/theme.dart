import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/* 동일하거나 고정되어야 하는 기능의 스타일을 정의 */
// text나 icon도 추가할 수 있음

AppBarTheme appBarTheme() {
  return AppBarTheme(
    centerTitle: false,
    color: Colors.white,
    elevation: 0.0,
    titleTextStyle: GoogleFonts.nanumGothic(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  );
}

BottomNavigationBarThemeData bottomNavigationTheme() {
  return BottomNavigationBarThemeData(
    selectedItemColor: Color(0xFF003F8F),
    unselectedItemColor: Colors.grey,
    showUnselectedLabels: true,
  );
}

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: appBarTheme(),
    bottomNavigationBarTheme: bottomNavigationTheme(),
  );
}
