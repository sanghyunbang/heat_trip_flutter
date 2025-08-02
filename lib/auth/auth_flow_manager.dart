import 'package:flutter/material.dart';
import 'token_storage.dart';

/// [역할] 인증 플로우를 관리하는 클래스
/// [시점] 앱 시작 시
/// JWT 토큰이 존재하는지 확인하고 (로그인 자체X, 로그인 되어 있는지만 파악)
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

/**[흐름 요약]
 * flowchart TD
  A[앱 시작] --> B{SharedPreferences에 토큰 있음?}
  B -- Yes --> C[HomeScreen으로 이동]
  B -- No --> D[LoginScreen으로 이동]

  D --> E[사용자가 소셜 로그인 버튼 클릭]
  E --> F[SocialLoginService.signIn()]
  F --> G[브라우저 열기 → 소셜 로그인 진행]
  G --> H[앱으로 돌아오기 (딥링크)]
  H --> I[토큰 추출 → TokenStorage.saveToken()]
  I --> J[Login 성공 → HomeScreen으로 이동]
 */
