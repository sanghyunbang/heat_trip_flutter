// lib/features/start/start_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

/// StartScreen (온보딩 첫 화면)
/// WHY:
///  - 탭 쉘 밖의 독립 라우트(/start)로 두어 뒤로가기/URL 동작을 단순화.
///  - 버튼 클릭 시 go_router의 go/goNamed를 사용해 명시적 라우팅.
///  - "Skip"은 탭 쉘로 진입(/explore), "회원가입"은 /auth/sign-up.
///  - 감정 선택 클릭은 바로 큐레이션 탭(/curation)으로 이동.
///    * 선택한 감정을 넘기고 싶다면 query(또는 extra)로 전달 가능(아래 주석 참고).
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
      // WHAT: HTML 시안 톤에 맞춘 배경 유지
      backgroundColor: const Color(0xFFF8F2E7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 130),
              // WHAT: 앱 로고
              // SvgPicture.asset("assets/sampleLogo.svg", height: 100),
              Image.asset("assets/Logo4.png", height: 500, fit: BoxFit.contain),
              const SizedBox(height: 80),

              // // WHAT: 타이틀 텍스트
              // const Text(
              //   'How are you feeling\nright now?',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     fontSize: 26,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.black87,
              //   ),
              // ),
              // const SizedBox(height: 30),

              // // WHAT: 감정 리스트 (InkWell 카드)
              // // WHY: 클릭 시 go_router로 큐레이션 탭(/curation)으로 이동.
              // //      필요 시 선택값을 query/extra로 전달하여 초기 PAD/서브감정 프리셋 가능.
              // Expanded(
              //   child: ListView.separated(
              //     itemCount: feelings.length,
              //     separatorBuilder: (_, __) => const SizedBox(height: 16),
              //     itemBuilder: (context, index) {
              //       final feeling = feelings[index];
              //       return InkWell(
              //         borderRadius: BorderRadius.circular(30),
              //         onTap: () {
              //           final label = feeling['label'] as String;
              //           // A) 단순히 큐레이션 탭으로 이동:
              //           context.go('/curation');

              //           // B) 선택한 감정을 쿼리로 넘기고 싶다면 (선택):
              //           // context.go(Uri(path: '/curation', queryParameters: {'feeling': label}).toString());

              //           // C) extra로 넘기는 방법 (타입 안전하지만 URL에는 안 보임):
              //           // context.go('/curation', extra: {'feeling': label});
              //         },
              //         child: Container(
              //           height: 60,
              //           decoration: BoxDecoration(
              //             color: feeling['color'] as Color,
              //             borderRadius: BorderRadius.circular(30),
              //           ),
              //           child: Row(
              //             children: [
              //               const SizedBox(width: 24),
              //               Icon(
              //                 feeling['icon'] as IconData,
              //                 color: Colors.white,
              //               ),
              //               const SizedBox(width: 16),
              //               Text(
              //                 feeling['label'] as String,
              //                 style: const TextStyle(
              //                   fontSize: 18,
              //                   color: Colors.white,
              //                   fontWeight: FontWeight.w600,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),

              // WHAT: 우측 하단 액션들(회원가입 / Skip)
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 회원가입 → go_router 이름 기반 이동
                    TextButton(
                      onPressed: () {
                        // WHY: Navigator.push 대신 go_router를 통해 명시적 라우팅
                        context.goNamed('signUp'); // '/auth/sign-up'
                      },
                      child: const Text(
                        '회원가입',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),

                    // Skip → 탭 쉘로 진입(탐색 탭)
                    TextButton(
                      onPressed: () {
                        // WHY: pushReplacement 대신 go로 탭 루트로 이동하면
                        //      뒤로가기도 URL/딥링크와 일관됩니다.
                        context.go('/explore');
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
