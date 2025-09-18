import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/common/goal_labels.dart';
import '../../../domain/entities.dart';
import '../cards/card_shell.dart' show ElevatedCardShell;
import '../ui/chip.dart';

/// EmotionInsightCard
/// - Energy: -1→1 bar, 0→2 bars, 1→3 bars
/// - Social: label icon + overlapped people indicator (size/opacity contrast)
/// - Clear "수정" button styling; mood chip stays as a non-interactive pill
class EmotionInsightCard extends StatelessWidget {
  const EmotionInsightCard({
    super.key,
    required this.req,
    required this.onRecord,
  });

  final RankRequest req;
  final VoidCallback onRecord;

  // 키 → 이모지(보조용)
  static const Map<String, String> _keyToEmoji = {
    '기쁨': '😊',
    '흥분': '🤩',
    '평온': '😌',
    '만족': '😇',
    '불안': '😰',
    '우울': '😞',
    '분노': '😠',
    '무기력': '😴',
  };

  // PAD 기반 간단 최근접(백업용)
  String _fallbackEmojiByPad(Pad pad) {
    const moods = {
      '기쁨': {'p': 2.0, 'a': 1.0, 'd': 1.0, 'e': '😊'},
      '흥분': {'p': 2.0, 'a': 2.0, 'd': 1.0, 'e': '🤩'},
      '평온': {'p': 1.0, 'a': -1.0, 'd': 1.0, 'e': '😌'},
      '만족': {'p': 2.0, 'a': 0.0, 'd': 2.0, 'e': '😇'},
      '불안': {'p': -2.0, 'a': 2.0, 'd': -2.0, 'e': '😰'},
      '우울': {'p': -2.0, 'a': -1.0, 'd': -2.0, 'e': '😞'},
      '분노': {'p': -2.0, 'a': 2.0, 'd': 1.0, 'e': '😠'},
      '무기력': {'p': -1.5, 'a': -2.0, 'd': -2.0, 'e': '😴'},
    };
    var best = '😊';
    var min = double.infinity;
    moods.forEach((_, v) {
      final dp = pad.pleasure - (v['p']! as double);
      final da = pad.arousal - (v['a']! as double);
      final dd = pad.dominance - (v['d']! as double);
      final dist = dp * dp + da * da + dd * dd;
      if (dist < min) {
        min = dist;
        best = v['e']! as String;
      }
    });
    return best;
  }

  // 공용 세로 구분선
  Widget _vDivider([double height = 16, double alpha = 0.2]) {
    const purple = Color(0xFF6B5BFF);
    return Container(
      width: 1,
      height: height,
      color: purple.withValues(alpha: alpha),
    );
  }

  // 에너지 인디케이터: -1→1칸, 0→2칸, 1→3칸
  Widget _buildEnergyIndicator(int energy) {
    const purple = Color(0xFF6B5BFF);
    final bars = (energy.clamp(-1, 1)) + 2; // -1→1, 0→2, 1→3

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < bars;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: 4,
          height: 8 + (i * 2),
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: filled
                ? purple.withValues(alpha: 0.85)
                : purple.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  // 소셜 인디케이터: 겹친 사람(앞: 큼/진함, 뒤: 작음/연함)
  Widget _buildSocialIndicator(int socialNeed) {
    const purple = Color(0xFF6B5BFF);
    if (socialNeed <= -1) {
      return Icon(
        Icons.home_rounded,
        size: 14,
        color: purple.withValues(alpha: 0.85),
      );
    }
    if (socialNeed == 0) {
      return Icon(
        Icons.person_rounded,
        size: 14,
        color: purple.withValues(alpha: 0.85),
      );
    }
    return SizedBox(
      width: 24,
      height: 16,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 6,
            top: -2,
            child: Icon(
              Icons.person_rounded,
              size: 12,
              color: purple.withValues(alpha: socialNeed >= 2 ? 0.45 : 0.35),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Icon(
              Icons.person_rounded,
              size: 16,
              color: purple.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6B5BFF);
    const lightPurple = Color(0xFFF5F3FF);

    // 선택 이모지 우선, 없으면 PAD로 추정
    final emoji =
        req.moodEmoji ??
        (req.moodKey != null
            ? (_keyToEmoji[req.moodKey!] ?? '🙂')
            : _fallbackEmojiByPad(req.pad));

    return ElevatedCardShell(
      color: lightPurple,
      radius: 16,
      padding: const EdgeInsets.all(16),
      borderColor: purple.withValues(alpha: 0.15),
      borderWidth: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: purple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.psychology_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '감정 인사이트',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF2D1B69),
                    ),
                  ),
                ],
              ),
              // 수정 버튼
              Semantics(
                button: true,
                label: '감정 인사이트 수정',
                child: FilledButton.icon(
                  onPressed: onRecord,
                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text(
                    '수정',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 메인 정보(이모지/키 + 메트릭들)
          Row(
            children: [
              // 감정 상태
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 6),
                  if (req.moodKey != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: purple.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        req.moodKey!,
                        style: TextStyle(
                          color: purple,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 16),
              _vDivider(20, 0.2),
              const SizedBox(width: 16),

              // 메트릭(에너지 & 소셜)
              Expanded(
                child: Row(
                  children: [
                    // Energy
                    Semantics(
                      label: '에너지 레벨',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flash_on_rounded,
                            size: 14,
                            color: purple.withValues(alpha: 0.75),
                          ),
                          const SizedBox(width: 4),
                          _buildEnergyIndicator(req.energy),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),
                    _vDivider(16, 0.22),
                    const SizedBox(width: 12),

                    // Social
                    Semantics(
                      label: '사회적 욕구',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.groups_rounded,
                            size: 14,
                            color: purple.withValues(alpha: 0.75),
                          ),
                          const SizedBox(width: 4),
                          _buildSocialIndicator(req.socialNeed.toInt()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 추천 목표
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: purple.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.flag_rounded,
                  size: 12,
                  color: purple.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  '목표: ',
                  style: TextStyle(
                    color: purple.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: Text(
                    // ✅ SSOT 사용
                    goalLabelFromKeys(req.goals),
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
