/// "공간 특성" 탭
/// - 백엔드에서 가져온 6개 특성을 진행바로 표시.
/// - 상위 3개 특성으로 '추천 이유' 문장 생성.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/detail_emotion_vm.dart';
import '../../../domain_detail/emotion_models.dart';

class FeaturesTab extends StatelessWidget {
  const FeaturesTab({super.key});

  // ── 디자인 토큰(기능 영향 없음) ───────────────────────────────
  static const _brand = Color(0xFFEB9C64);
  static const _muted = Color(0xFF6B7280);
  static const _cardBorder = Color(0xFFEAEAEA);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetailEmotionVM>();

    // 로딩 피드백 (그대로)
    if (vm.loadingFeatures) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
      );
    }

    // 실패/데이터없음 처리 (그대로)
    final f = vm.features;
    if (f == null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('공간 특성을 불러오지 못했어요.'),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: vm.loadFeatures, child: const Text('다시 시도')),
        ]),
      );
    }

    // UI에 표시할 행 리스트 구성(라벨, 값, 아이콘) — 로직 동일
    List<_FeatureRow> rows = [
      _FeatureRow('사교성', f.sociality, Icons.groups),
      _FeatureRow('영적 체험', f.spirituality, Icons.auto_awesome),
      _FeatureRow('모험성', f.adventure, Icons.explore),
      _FeatureRow('문화성', f.culture, Icons.museum),
      _FeatureRow('자연치유', f.natureHealing, Icons.park),
      _FeatureRow('고요함', f.quiet, Icons.terrain),
    ];

    // 값 내림차순 정렬 → 상위 3개 Reason에 사용 (그대로)
    rows.sort((a,b)=>b.value.compareTo(a.value));

    return Column(
      children: [
        /// 진행바 리스트 (스타일만 개선)
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
              children: rows.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(r.icon, size: 20),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 86,
                      child: Text(
                        r.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 진행바
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: r.value.clamp(0, 1).toDouble(),
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(_brand),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 44,
                      child: Text(
                        '${(r.value * 100).round()}%',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ),

        const SizedBox(height: 12),

        /// 추천 이유(Top3) — 텍스트 톤/여백만 정리
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('추천 이유', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5)),
              const SizedBox(height: 8),
              ...rows.take(3).map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 6),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _reason(r.label),
                        style: const TextStyle(height: 1.45, color: _muted),
                      ),
                    ),
                  ],
                ),
              )),
            ]),
          ),
        ),
      ],
    );
  }
}

/// 진행바 한 줄 표현용 내부 모델
class _FeatureRow {
  final String label; final double value; final IconData icon;
  _FeatureRow(this.label, this.value, this.icon);
}

/// 특성 라벨 → 추천 문장 (로직 동일)
String _reason(String label){
  switch(label){
    case '사교성':   return '사람들과 어울리는 활동을 좋아하는 분께 잘 맞아요.';
    case '영적 체험': return '내면의 평화를 찾는 분께 적합해요.';
    case '모험성':   return '새로운 도전과 체험을 원하는 분께 좋아요.';
    case '문화성':   return '문화·학습 경험을 중시하는 분께 추천해요.';
    case '자연치유':  return '자연 속 힐링을 원하는 분께 적합해요.';
    case '고요함':   return '조용한 시간을 원하는 분께 잘 맞아요.';
    default: return '';
  }
}
