import 'package:flutter/material.dart';
import 'token_storage.dart';

// 로그아웃 처리를 담당하는 함수
// 저장된 JWT 토큰을 삭제하고, 로그인 화면으로 이동

Future<void> logout(BuildContext context, Widget loginScreen) async {
  // 1. SharedPreferences에서 JWT 토큰 삭제
  await TokenStorage.clearToken();

  // 2. 로그아웃 후 로그인 화면으로 이동
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => loginScreen),
    (route) => false, // 모든 이전 화면 제거)
  );
}
