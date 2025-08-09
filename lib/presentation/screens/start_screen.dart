import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heat_trip_flutter/core/widgets/layout/main_nav_layout.dart';
import 'package:heat_trip_flutter/features/auth/presentation/sign_up_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  static const List<Map<String, dynamic>> feelings = [
    {
      "label": "Happy",
      "icon": Icons.emoji_emotions,
      "color": Color(0xFF90AEBB),
    },
    {"label": "Calm", "icon": Icons.waves, "color": Color(0xDED6A4A4)},
    {"label": "Excited", "icon": Icons.star, "color": Color(0xFFF1A979)},
    {"label": "Sad", "icon": Icons.water_drop, "color": Color(0xFF9881B8)},
    {
      "label": "Tired",
      "icon": Icons.nightlight_round,
      "color": Color(0xFF4A5D6C),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              SvgPicture.asset("assets/sampleLogo.svg", height: 100),
              SizedBox(height: 50),
              const Text(
                'How are you feeling\nright now?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.separated(
                  itemCount: feelings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final feeling = feelings[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        // 클릭했을 때 처리할 동작 작성
                        print("클릭한 감정: ${feeling['label']}");
                      },
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: feeling['color'],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 24),
                            Icon(feeling['icon'], color: Colors.white),
                            const SizedBox(width: 16),
                            Text(
                              feeling['label'],
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        '회원가입',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainNavLayout(),
                          ),
                        );
                      },
                      child: const Text(
                        'Skip',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
