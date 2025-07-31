import 'package:flutter/material.dart';
import 'token_storage.dart';

/// 인증 플로우를 관리하는 클래스
/// 앱 시작 시, JWT 토큰이 존재하는지 확인하고
/// 홈 화면 또는 로그인 화면으로 이동시키는 초기 진입 로직을 담당

class AuthFlowManager extends StatelessWidget {
  final Widget homeScreen;
  final Widget loginScreen;

  const AuthFlowManager({
    Key? key,
    required this.homeScreen,
    required this.loginScreen,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: TokenStorage.getToken(),
      builder: (context, snapshot) {
        // 로딩 중일 때 화면 로딩 표시
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 토큰이 존재하면 홈 화면으로 이동, 없으면 로그인 화면으로
        if (snapshot.data != null) {
          return homeScreen; // 토큰이 존재하면 홈 화면
        } else {
          return loginScreen; // 토큰이 없으면 로그인 화면
        }
      },
    );
  }
}
