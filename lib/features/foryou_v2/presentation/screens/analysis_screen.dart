import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/foryou_v2/presentation/screens/result_screen.dart';
import '../../state/foryou_vm.dart';
import '../../domain/models.dart';

// ─────────────────────────────────────────────────────────────
// Brand palette (화이트 기반 + 기존 오렌지/레드)
// ─────────────────────────────────────────────────────────────
const _brandRed = Color(0xFFE11D48);
const _brandOrange = Color(0xFFF97316);
const _ink = Color(0xFF121212); // 본문 잉크색
const _inkSubtle = Color(0xFF2A2A2A); // 보조 텍스트
const _borderSoft = Color(0xFFFFE3D0); // 오렌지 톤 소프트 보더
const _surface = Colors.white;
const _surfaceAlt = Color(0xFFFFF6F0); // 연한 오렌지 톤 섹션 배경 (카테고리 내부 유지)
const _chipFill = Color(0xFFFFF1E7);
const _chipStroke = Color(0xFFFFD6B6);

// ── Warm Blossom (base) ──
const _rose500 = Color(0xFFFB7185); // 포인트
const _peach300 = Color(0xFFFEC6A1);
const _blushWash = Color(0xFFFEF7FB); // 아주 옅은 분홍 워시
const _glowPink = Color(0x22FF9CB3); // ↓ 글로우 강도/불투명도 낮춤
const _glowPeach = Color(0x22FFC9A7);

// ── Calm Bloom (차분한 CTA/배지용 뮤트 팔레트) ──
// 더 낮은 채도 & 한 톤 다운된 분홍/코랄/살구
const _calmPink = Color(0xFFF45C84); // muted rose
const _calmFuchsia = Color(0xFFF27BAF); // soft fuchsia
const _calmPeach = Color(0xFFF49A76); // soft peach
const _calmGlow1 = Color(0x1AFF6CA4); // 글로우 알파 낮춤
const _calmGlow2 = Color(0x14FF9BCD);

// 활동 카드 바깥 보더(차분한 로즈 테두리)
const _softRoseBorder = Color(0xFFF7C9D6);

class AnalysisScreen extends StatefulWidget {
  final ForYouVM vm;
  const AnalysisScreen({super.key, required this.vm});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String? expandedGroup;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).viewPadding;
    final LlmMeta? llm = widget.vm.llm;

    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header: 분석 완료 + 감정 분석 결과
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_brandRed, _brandOrange],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        '분석 완료',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '감정 분석 결과',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          llm?.emotionDiagnosis ?? '감정 분석 요약이 없습니다.',
                          style: const TextStyle(
                            color: Colors.white,
                            height: 1.45,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: (llm?.keywords ?? const []).map((k) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.16), // 더 차분
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.white24),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 8, // ↓
                                    offset: Offset(0, 3),
                                    color: _glowPink,
                                  ),
                                ],
                              ),
                              child: Text(
                                k,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + pad.bottom),
                children: [
                  // 추천 여행 테마
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: _borderSoft, width: 1),
                    ),
                    elevation: 0,
                    color: _surface,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.explore, color: _brandRed, size: 18),
                              SizedBox(width: 8),
                              Text(
                                '추천 여행 테마',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5,
                                  color: _ink,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: '✨ ',
                                  style: TextStyle(fontSize: 13),
                                ),
                                TextSpan(
                                  text: llm?.themeName ?? '테마 미정',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: _ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            llm?.themeDescription ?? '테마 설명이 제공되지 않았어요.',
                            style: const TextStyle(
                              color: _inkSubtle,
                              height: 1.5,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 당신에게 보내는 편지 (카드 클릭 → 다이얼로그)
                  _ComfortLetterCard(letter: llm?.comfortLetter),

                  const SizedBox(height: 10),

                  // 카테고리 그룹
                  if ((llm?.categoryGroups ?? []).isNotEmpty) ...[
                    Row(
                      children: const [
                        Icon(Icons.tag, color: _ink, size: 18),
                        SizedBox(width: 6),
                        Text(
                          '여행 카테고리',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: _ink,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...llm!.categoryGroups.map((g) {
                      final isExpanded = expandedGroup == g.groupName;
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: _borderSoft, width: 1),
                        ),
                        elevation: 0,
                        color: _surface,
                        child: Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() {
                                  expandedGroup = isExpanded
                                      ? null
                                      : g.groupName;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFE8D6),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: _borderSoft),
                                      ),
                                      child: const Icon(
                                        Icons.map,
                                        color: _brandOrange,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            g.groupName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14.5,
                                              color: _ink,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${g.categories.length}개 카테고리',
                                            style: const TextStyle(
                                              color: _inkSubtle,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: _inkSubtle,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isExpanded)
                              const Divider(height: 1, color: _borderSoft),
                            if (isExpanded)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  10,
                                  12,
                                  12,
                                ),
                                color: _surfaceAlt, // 카테고리 내부는 기존 톤 유지
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: g.categories
                                      .map(
                                        (c) => Chip(
                                          label: Text(
                                            c,
                                            style: const TextStyle(
                                              color: _ink,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          backgroundColor: _chipFill,
                                          side: const BorderSide(
                                            color: _chipStroke,
                                            width: 1,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 10),

                  // 활동 추천 (차분 팔레트 + 은은한 글로우 + 그라데이션 배지)
                  if ((llm?.activities ?? []).isNotEmpty)
                    Card(
                      color: _blushWash,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                          color: _softRoseBorder,
                          width: 1,
                        ),
                      ),
                      elevation: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Colors.white, _blushWash],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 14, // ↓
                              offset: Offset(0, 6),
                              color: _glowPink, // 투명도 낮춘 버전
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.auto_awesome,
                                  color: _rose500,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '추천 활동',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.5,
                                    color: _ink,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...llm!.activities.asMap().entries.map((e) {
                              final idx = e.key + 1;
                              final a = e.value;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: _softRoseBorder),
                                  color: _surface,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: const [
                                    BoxShadow(
                                      blurRadius: 10, // ↓
                                      offset: Offset(0, 5),
                                      color: _glowPeach,
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  // 동그라미 인덱스 배지 (뮤트 그라데이션)
                                  leading: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [_calmPink, _calmPeach],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          blurRadius: 9,
                                          offset: Offset(0, 4),
                                          color: _calmGlow1,
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$idx',
                                        style: const TextStyle(
                                          color: _ink,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    a.title,
                                    style: const TextStyle(
                                      color: _ink,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    a.description,
                                    style: const TextStyle(
                                      color: _inkSubtle,
                                      fontSize: 13,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // CTA: 여행지 둘러보기 (차분 3-stop 그라데이션 + 은은한 글로시/글로우)
            Container(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + pad.bottom),
              color: _surface,
              child: SizedBox(
                width: double.infinity,
                child: Stack(
                  children: [
                    // Calm vivid gradient background
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_calmPink, _calmFuchsia, _calmPeach],
                          stops: [0.0, 0.6, 1.0],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 18, // ↓
                            offset: Offset(0, 8),
                            color: _calmGlow1,
                          ),
                          BoxShadow(
                            blurRadius: 22, // ↓
                            offset: Offset(0, 5),
                            color: _calmGlow2,
                          ),
                        ],
                      ),
                    ),
                    // subtle glossy highlight (top sheen)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.16), // ↓
                                Colors.white.withOpacity(0.04),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.25, 0.6],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // transparent button to keep ripple & semantics
                    Positioned.fill(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Colors.white24,
                              width: 0.8,
                            ),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ResultsScreen(vm: widget.vm),
                            ),
                          );
                        },
                        child: const Text(
                          '여행지 둘러보기',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0.35, // 살짝 다운
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComfortLetterCard extends StatelessWidget {
  final String? letter;
  const _ComfortLetterCard({this.letter});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF2F4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFFFD9E1), width: 1),
      ),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (dialogCtx) => AlertDialog(
              backgroundColor: _surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: _borderSoft, width: 1),
              ),
              title: Row(
                children: const [
                  Icon(Icons.mail, color: _brandRed, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '당신에게 보내는 편지',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Text(
                  (letter ?? '편지가 제공되지 않았어요.').replaceAll('\\n', '\n'),
                  style: const TextStyle(
                    height: 1.55,
                    fontSize: 13.5,
                    color: _inkSubtle,
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text(
                    '닫기',
                    style: TextStyle(
                      color: _brandOrange,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.mail, color: _brandRed, size: 18),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '당신에게 보내는 편지',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: Color(0xFF7F1D1D),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFFFB7185),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
