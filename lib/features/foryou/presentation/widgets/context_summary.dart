// lib/features/foryou/presentation/widgets/context_summary.dart

/// ContextSummary  [Widget]
/// 역할: 현재 추천 컨텍스트(PAD, 사교/소음/혼잡, 위치)를 칩 형태로 요약 표시.
/// 입력: [ctx] dom.Context
/// 사용처: ForYouScreen 상단 요약 박스.
/// 주의: 값 범위(PAD: -2/-1/1/2, 선호: -1/1)가 UI 문구에 반영됨.

// lib/features/foryou/presentation/widgets/context_summary.dart
import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/foryou/domain/entities/context.dart'
    as dom;

class _Pal {
  static const primary100 = Color(0xFFEB9C64); // #eb9c64 (orange)
  static const primary200 = Color(0xFFFF8789); // #ff8789 (pink)
  static const primary300 = Color(0xFF554E4F);
  static const accent100 = Color(0xFF8FBF9F);
  static const accent200 = Color(0xFF346145);
  static const text100 = Color(0xFF353535);
  static const text200 = Color(0xFF000000);
  static const bg100 = Color(0xFFF5ECD7);
  static const bg200 = Color(0xFFEBE2CD);
  static const bg300 = Color(0xFFC2BAA6);
}

class ContextSummary extends StatelessWidget {
  final dom.Context ctx;
  const ContextSummary({super.key, required this.ctx});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    // 숫자 대신 이모지 + 짧은 코멘트
    final p = _pleasure(ctx.P);
    final a = _arousal(ctx.A);
    final d = _dominance(ctx.D);
    final social = ctx.sociality == 1 ? '🧑‍🤝‍🧑 사교적' : '🧘 혼자 선호';
    final noise = ctx.noise == 1 ? '🔊 활기' : '🔈 조용';
    final crowd = ctx.crowdedness == 1 ? '👥 북적' : '🌿 한적';
    final locale = '📍 ${ctx.location.toUpperCase()}';

    // 칩(아주 작게, 눈에 안 거슬리게)
    const pillBgOpacity = 0.42; // 더 연하게 하려면 0.30~0.35 권장
    Widget pill(String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _Pal.bg200.withOpacity(pillBgOpacity),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _Pal.bg300.withOpacity(0.55), width: 0.6),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12, // 작게
            height: 1.0,
            fontWeight: FontWeight.w600,
            color: _Pal.text100,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: const BoxDecoration(
              // 스크린샷 느낌: 좌상단→우하단으로 부드러운 오렌지→핑크
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_Pal.primary100, _Pal.primary200],
              ),
            ),
            child: InkWell(
              // 박스 전체에만 리플(칩에는 퍼지지 않음)
              splashColor: Colors.white24,
              highlightColor: Colors.transparent,
              onTap: () {}, // 필요시 요약 설명 등 액션
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Wrap(
                  spacing: 6, // 칩 간 간격도 살짝 줄임
                  runSpacing: 6,
                  children: [
                    pill(p),
                    pill(a),
                    pill(d),
                    pill(social),
                    pill(noise),
                    pill(crowd),
                    pill(locale),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== 감정 매핑: {-2, -1, 1, 2} 가정 =====
  String _pleasure(int v) {
    switch (v) {
      case -2:
        return '😞 기분 다운';
      case -1:
        return '🙁 낮은 기분';
      case 1:
        return '🙂 좋은 기분';
      case 2:
        return '😄 매우 좋음';
      default:
        return '🙂 기분';
    }
  }

  String _arousal(int v) {
    switch (v) {
      case -2:
        return '😪 매우 졸림';
      case -1:
        return '😌 차분함';
      case 1:
        return '⚡ 에너지 업';
      case 2:
        return '🤩 매우 들뜸';
      default:
        return '⚡ 각성';
    }
  }

  String _dominance(int v) {
    switch (v) {
      case -2:
        return '😣 부담 큼';
      case -1:
        return '😕 자신감 낮음';
      case 1:
        return '💪 자신감';
      case 2:
        return '🦾 완전 주도';
      default:
        return '💪 주도성';
    }
  }
}
