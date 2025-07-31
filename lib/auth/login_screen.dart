import 'package:flutter/material.dart';
import 'social_login_service.dart';
import '../home/recommendation_screen.dart';

/// 로그인 버튼 UI를 포함한 화면
/// 로그인 성공 시 홈 화면으로 이동

class LoginScreen extends StatelessWidget {
  // SocialLoginService 클래스는 브라우저를 열고 토큰을 받아오는 역할
  final loginService = SocialLoginService();

  LoginScreen({super.key}); // 생성자. key는 위젯의 고유 식별자 역할

  /// 로그인 버튼 눌렀을 때 실행
  /// [provider]는 'google', 'kakao', 'naver' 중 하나, 해당 플랫폼으로 로그인 시도
  /// 로그인 성공 시 홈화면

  Future<void> _handleLogin(BuildContext context, String provider) async {
    final success = await SocialLoginService.signIn(provider); //

    // context.mounted는 위젯이 여전히 유효한지를 확인 (비동기 작업 후 안전하게 화면 이동 가능 여부를 판단)
    if (success && context.mounted) {
      // 로그인 성공하면 홈 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RecommendationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _handleLogin(context, 'google'),
              child: const Text('Google로 로그인'),
            ),
            ElevatedButton(
              onPressed: () => _handleLogin(context, 'kakao'),
              child: const Text('Kakao로 로그인'),
            ),
            ElevatedButton(
              onPressed: () => _handleLogin(context, 'naver'),
              child: const Text('Naver로 로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
