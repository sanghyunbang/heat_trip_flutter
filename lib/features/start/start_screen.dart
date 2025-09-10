// lib/features/start/start_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // 로고는 화면 높이의 ~48%까지만, 최대 420px
    final logoHeight = size.height * 0.48 > 420 ? 420.0 : size.height * 0.48;

    // 회원가입/skip 버튼 아래 추가 여백
    const extraLift = 24.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E7),

      // 가운데 로고 — SafeArea로 상단 노치/스테이터스바 피해서 표시
      body: SafeArea(
        bottom: false, // 하단은 bottomNavigationBar에서 처리
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              height: logoHeight,
              child: Image.asset(
                "assets/Logo4.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),

      // 하단 액션 — SafeArea로 제스처 바 피하고, Padding으로 살짝 위로
      bottomNavigationBar: SafeArea(
        top: false,
        // SafeArea로 기본 하단 인셋을 챙기고, Padding으로 '추가로' 위쪽으로 올림
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, extraLift),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => context.goNamed('signUp'),
                child: const Text(
                  '회원가입',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/explore'),
                child: const Text(
                  'Skip',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
