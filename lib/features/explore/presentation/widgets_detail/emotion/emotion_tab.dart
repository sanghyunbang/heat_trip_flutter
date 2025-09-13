/// "감정 경험" 탭
/// - 리뷰 목록/간단 통계/감정 변화 패턴 막대.
/// - EMOTIONS 상수는 UI 레이블/이모지용.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/detail_emotion_vm.dart';
import '../../../domain_detail/emotion_models.dart';

/// UI용 감정 상수(백엔드가 필요 없다면 고정 값 사용)
const EMOTIONS = <EmotionScore>[
  EmotionScore(id:'JOY', name:'기쁨', emoji:'🙂', valence:0.7, arousal:0.5, dominance:0.4),
  EmotionScore(id:'CALM', name:'평온', emoji:'😌', valence:0.4, arousal:-0.4, dominance:0.5),
  EmotionScore(id:'CURIOUS', name:'호기심', emoji:'🤔', valence:0.4, arousal:0.4, dominance:0.1),
  EmotionScore(id:'PROUD', name:'뿌듯함', emoji:'💪', valence:0.5, arousal:0.3, dominance:0.6),
  EmotionScore(id:'ANXIOUS', name:'불안', emoji:'😟', valence:-0.5, arousal:0.6, dominance:-0.5),
  EmotionScore(id:'ANGRY', name:'화남', emoji:'😠', valence:-0.6, arousal:0.7, dominance:0.4),
  EmotionScore(id:'SAD', name:'슬픔', emoji:'😢', valence:-0.7, arousal:-0.4, dominance:-0.6),
  EmotionScore(id:'TIRED', name:'피곤함', emoji:'😴', valence:-0.3, arousal:-0.7, dominance:-0.6),
];

/// ID → EmotionScore 매핑(없으면 첫 원소 반환)
EmotionScore? _byId(String id) =>
    EMOTIONS.firstWhere((e)=>e.id==id, orElse: ()=>EMOTIONS[0]);

class EmotionTab extends StatelessWidget {
  const EmotionTab({super.key});

  // ── 디자인 토큰 (기능 영향 없음) ───────────────────────────────
  static const _brand = Color(0xFFEB9C64);
  static const _cardBorder = Color(0xFFEAEAEA);
  static const _muted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetailEmotionVM>();

    // 로딩 상태 처리
    if (vm.loadingReviews) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
      );
    }

    // 데이터 없음 처리
    if (vm.reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('아직 감정 리뷰가 없어요.'),
      );
    }

    // 간단 통계: |ΔV| 평균 → 0~1 비율로 가정 (그대로)
    final avgImpact =
        vm.reviews.map((r)=>r.dV.abs()).fold(0.0, (a,b)=>a+b) / vm.reviews.length;

    return Column(
      children: [
        /// 상단 요약 카드 (디자인만 변경)
        Card(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('감정 리뷰', vm.reviews.length.toString()),
                _stat('감정 변화도', '${(avgImpact*100).round()}%'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        /// 감정 변화 패턴 바 그래프(단순 막대) — 로직 동일, 스타일만
        Card(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('감정 변화 패턴',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5)),
                const SizedBox(height: 12),
                ...EMOTIONS.map((em){
                  final before = vm.reviews.where((r)=>r.beforeEmotionId==em.id).length;
                  final after  = vm.reviews.where((r)=>r.afterEmotionId==em.id).length;
                  final net = after - before; // 양수면 증가, 음수면 감소
                  final ratio = (net.abs()/vm.reviews.length).clamp(0,1).toDouble();

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      // 왼쪽 라벨(이모지+이름)
                      SizedBox(
                        width: 86,
                        child: Row(
                          children: [
                            Text(em.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                em.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 가운데 막대 (배경/전경색만 변경)
                      Expanded(
                        child: Stack(
                          children: [
                            // 바탕 막대
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            // 변화량 막대(좌/우 정렬)
                            Align(
                              alignment: net>=0?Alignment.centerLeft:Alignment.centerRight,
                              child: Container(
                                height: 8,
                                width: (ratio*100).clamp(0,100) * 2, // 과장표시(2배) — 로직 그대로
                                decoration: BoxDecoration(
                                  color: net>=0 ? Colors.green : Colors.redAccent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 오른쪽 숫자 (+3 / -2)
                      SizedBox(
                        width: 36,
                        child: Text(
                          net>0?'+$net':'$net',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: net>0? Colors.green : (net<0? Colors.redAccent : _muted),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ]),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        /// 리뷰 카드 리스트 (레이아웃/텍스트 톤만 손봄)
        ...vm.reviews.map((r){
          final b = _byId(r.beforeEmotionId);
          final a = _byId(r.afterEmotionId);
          return Card(
            elevation: 0,
            color: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: _cardBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더(작성자)
                  Text(r.author, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  // 감정 변화 요약 (아이콘/간격만 다듬음)
                  Row(
                    children: [
                      Text('${b?.emoji} ${b?.name}', style: const TextStyle(fontSize: 13.5)),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_right_alt, size: 20, color: _muted),
                      const SizedBox(width: 6),
                      Text('${a?.emoji} ${a?.name}', style: const TextStyle(fontSize: 13.5)),
                      const Spacer(),
                      Row(children: [
                        const Icon(Icons.thumb_up_alt_outlined, size:16, color: _muted),
                        Text(' ${r.helpfulCount}', style: const TextStyle(color: _muted)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 본문
                  Text(r.content, style: const TextStyle(height: 1.45)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  /// 통계 카드의 간단한 위젯 (타이포/톤만)
  Widget _stat(String title, String value){
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: _muted)),
      ],
    );
  }
}
