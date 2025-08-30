// lib/features/foryou/presentation/widgets/context_summary.dart
import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/foryou/domain/entities/context.dart'
    as dom;

/// ─────────────────────────────────────────────────────────────────
/// 1) 칩 색상 스킴: 파일 최상단(클래스 밖, 전역 영역)에 둡니다.
/// ─────────────────────────────────────────────────────────────────
class _ChipScheme {
  final Color bg1; // gradient start
  final Color bg2; // gradient end
  final Color border;
  final Color fg; // text color
  const _ChipScheme({
    required this.bg1,
    required this.bg2,
    required this.border,
    required this.fg,
  });
}

// 파스텔 팔레트
const _SCHEME_PLEASURE = _ChipScheme(
  bg1: Color(0xFFFFF0DD),
  bg2: Color(0xFFFFE6D4),
  border: Color(0xFFFFD6B8),
  fg: Color(0xFF6B4E3D),
); // 좋은 기분: 살구
const _SCHEME_CALM = _ChipScheme(
  bg1: Color(0xFFE8F2FF),
  bg2: Color(0xFFDDEBFF),
  border: Color(0xFFCDE0FF),
  fg: Color(0xFF244C7A),
); // 차분/졸림: 라이트블루
const _SCHEME_DOMINANCE = _ChipScheme(
  bg1: Color(0xFFF2E8FF),
  bg2: Color(0xFFEDE1FF),
  border: Color(0xFFDECCFF),
  fg: Color(0xFF5A3E8E),
); // 주도/자신감: 라일락
const _SCHEME_SOCIAL = _ChipScheme(
  bg1: Color(0xFFE6FAF2),
  bg2: Color(0xFFDDF7ED),
  border: Color(0xFFC6F0E1),
  fg: Color(0xFF256D57),
); // 사교: 민트
const _SCHEME_QUIET = _ChipScheme(
  bg1: Color(0xFFF6F1FF),
  bg2: Color(0xFFF3ECFF),
  border: Color(0xFFE7DBFF),
  fg: Color(0xFF5C4C86),
); // 조용: 연보라
const _SCHEME_ENERGETIC = _ChipScheme(
  bg1: Color(0xFFFFF5D9),
  bg2: Color(0xFFFFF0C7),
  border: Color(0xFFFFE3A3),
  fg: Color(0xFF7A5A12),
); // 활기/에너지/들뜸: 라이트옐로
const _SCHEME_SERENE = _ChipScheme(
  bg1: Color(0xFFEFF9F0),
  bg2: Color(0xFFE8F6E9),
  border: Color(0xFFD4EED6),
  fg: Color(0xFF2E5E30),
); // 한적: 라이트그린
const _SCHEME_DEFAULT = _ChipScheme(
  bg1: Colors.white,
  bg2: Colors.white,
  border: Color(0xFFE6E1D6),
  fg: Color(0xFF374151),
);

// 라벨 문자열로 색상 스킴 선택
_ChipScheme schemeForLabel(String text) {
  if (text.contains('기분') || text.contains('🙂') || text.contains('😄'))
    return _SCHEME_PLEASURE;
  if (text.contains('차분') ||
      text.contains('😌') ||
      text.contains('졸림') ||
      text.contains('😪'))
    return _SCHEME_CALM;
  if (text.contains('주도') ||
      text.contains('자신감') ||
      text.contains('💪') ||
      text.contains('🦾'))
    return _SCHEME_DOMINANCE;
  if (text.contains('사교') || text.contains('🧑‍🤝‍🧑')) return _SCHEME_SOCIAL;
  if (text.contains('조용') || text.contains('🔈')) return _SCHEME_QUIET;
  if (text.contains('활기') ||
      text.contains('에너지') ||
      text.contains('⚡') ||
      text.contains('🔊') ||
      text.contains('들뜸'))
    return _SCHEME_ENERGETIC;
  if (text.contains('한적') || text.contains('🌿')) return _SCHEME_SERENE;
  return _SCHEME_DEFAULT;
}

/// ─────────────────────────────────────────────────────────────────
/// 2) 요약 위젯 본문
/// ─────────────────────────────────────────────────────────────────
class ContextSummary extends StatelessWidget {
  const ContextSummary({super.key, required this.ctx});
  final dom.Context ctx;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    // 라벨(이모지 + 텍스트)
    final p = _pleasure(ctx.P);
    final a = _arousal(ctx.A);
    final d = _dominance(ctx.D);
    final social = ctx.sociality == 1 ? '🧑‍🤝‍🧑 사교적' : '💗 IN';
    final noise = ctx.noise == 1 ? '🔊 활기' : '🔈 조용';
    final crowd = ctx.crowdedness == 1 ? '👥 북적' : '🌿 한적';
    final locale = '📍 ${ctx.location.toUpperCase()}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF4E6), Color(0xFFFFEEF3)], // 크림 → 옅은 핑크
          ),
          border: Border.all(color: const Color(0xFFECE7DB), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(p),
              _pill(a),
              _pill(d),
              _pill(social),
              _pill(noise),
              _pill(crowd),
              _pill(locale),
            ],
          ),
        ),
      ),
    );
  }

  // 칩(그라디언트 + 얇은 테두리)
  Widget _pill(String text) {
    final sc = schemeForLabel(text); // ← 전역 함수 호출
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [sc.bg1, sc.bg2],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: sc.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          height: 1.0,
          fontWeight: FontWeight.w700,
          color: sc.fg,
          letterSpacing: .1,
        ),
      ),
    );
  }

  // 라벨 매핑
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
