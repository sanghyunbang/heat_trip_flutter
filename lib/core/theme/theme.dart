import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

AppBarTheme appBarTheme() {
  return AppBarTheme(
    centerTitle: false,
    backgroundColor: Colors.white, // ← color 대신 backgroundColor 권장
    elevation: 0.0,
    scrolledUnderElevation: 0, // ← 스크롤 시 생기는 음영 제거
    shadowColor: Colors.transparent, // ← AppBar 전용 쉐도우 제거
    surfaceTintColor: Colors.transparent, // ← M3 틴트 제거(흰 막 올라오는 느낌 방지)
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
    // BottomNavigationBar 자체는 보통 그림자 속성이 없지만
    // 상단에 얇은 음영처럼 보이면 Scaffold 쪽 BottomAppBarTheme로 elevation=0을 추가하세요.
  );
}

ThemeData theme() {
  return ThemeData(
    useMaterial3: true, // 사용 중이면 유지
    scaffoldBackgroundColor: Colors.white,

    // 전역 Shadow 색상 자체를 끄기
    shadowColor: Colors.transparent,

    appBarTheme: appBarTheme(),
    bottomNavigationBarTheme: bottomNavigationTheme(),

    // ElevatedButton 전역 그림자 제거(눌림/포커스 포함)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: const WidgetStatePropertyAll(0),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    ),

    // Card류(및 M3 틴트) 평면화
    cardTheme: const CardThemeData(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    // Dialog/BottomSheet도 평면화
    dialogTheme: const DialogThemeData(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    // SnackBar·FAB·Chip 등 잔여 그림자 제거
    snackBarTheme: const SnackBarThemeData(elevation: 0),
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

    // (선택) BottomAppBar를 쓰는 화면의 하단 음영 제거
    bottomAppBarTheme: const BottomAppBarTheme(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
    ),
  );
}
