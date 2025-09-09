// lib/features/start/start_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Let the logo use at most ~48% of screen height, up to 420px.
    final logoHeight = size.height * 0.48 > 420 ? 420.0 : size.height * 0.48;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E7),

      // Centered logo, no fixed spacers -> no overflow
      body: SafeArea(
        bottom: false, // bottom UI is handled by bottomNavigationBar
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

      // Bottom actions pinned safely above gesture bar
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(24, 0, 24, 16),
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
    );
  }
}
