import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart'; // (선택)

import '../../data/curation_local_data_source.dart';
import '../../data/curation_repository_impl.dart';
import '../../data/sub_emotions.dart';
import '../../domain/repositories.dart';
import '../state/curation_state.dart';
import '../widgets/message_box.dart';
import '../widgets/option_grid.dart';
import '../widgets/pad_selection_group.dart';

/// WHAT: HTML 시안을 Flutter로 옮긴 메인 입력 화면
/// - PAD 3축 선택 → 하위 감정 추천(Top8)
/// - 여행 목적/환경 요소 단일 선택
/// - 저장/불러오기/초기화
/// - "여행 큐레이션 받기" 클릭 시 결과 화면으로 이동(go_router)
class CurationScreen extends StatefulWidget {
  const CurationScreen({super.key});

  @override
  State<CurationScreen> createState() => _CurationScreenState();
}

class _CurationScreenState extends State<CurationScreen> {
  late CurationState state; // 상태 보관
  bool showMessage = false; // 메시지 박스 표시 여부
  String messageTitle = '';
  String messageText = '';
  bool messageError = false;

  @override
  void initState() {
    super.initState();
    // WHAT: 간이 DI — 데이터 계층 구현체를 주입
    final repo = CurationRepositoryImpl(CurationLocalDataSource());
    state = CurationState(
      repository: repo,
      subEmotionSource: const BuiltInSubEmotionSource(),
      matcher: SubEmotionMatcher(),
    );
  }

  /// 짧게 토스트처럼 보였다 사라지는 메시지 헬퍼
  void _flash(String title, String text, {bool error = false}) {
    setState(() {
      showMessage = true;
      messageTitle = title;
      messageText = text;
      messageError = error;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => showMessage = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFFDFBF2); // HTML의 오프화이트 배경

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('나의 감정과 공간 선택 🎨'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1) PAD 섹션
                    Text(
                      '1. PAD 감정',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 12),
                    PadSelectionGroup(
                      pleasure: state.pad.pleasure,
                      arousal: state.pad.arousal,
                      dominance: state.pad.dominance,
                      onSelectPleasure: (v) =>
                          setState(() => state.setPad(pleasure: v)),
                      onSelectArousal: (v) =>
                          setState(() => state.setPad(arousal: v)),
                      onSelectDominance: (v) =>
                          setState(() => state.setPad(dominance: v)),
                    ),

                    // 2) 하위 감정 Top8 — PAD가 모두 선택된 경우에만 노출
                    if (state.padComplete) ...[
                      const SizedBox(height: 24),
                      Text(
                        '2. 나를 가장 잘 표현하는 감정은?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'PAD 선택을 완료하면, 가까운 하위 감정들이 나타납니다.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: state.suggestedSubEmotions
                            .map(
                              (e) => _SubEmotionCard(
                                label: e.name,
                                selected:
                                    state.selectedSubEmotionEnglish ==
                                    e.english,
                                onTap: () => setState(
                                  () => state.setSubEmotion(e.english),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),

                    // 3) 여행 목적
                    TravelPurposeGrid(
                      selected: state.travelPurpose,
                      onSelect: (v) =>
                          setState(() => state.setTravelPurpose(v)),
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),

                    // 4) 환경 요소 섹션 + 액션 버튼들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '4. 공간 및 환경 요소',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () async {
                                final ok = await state.load();
                                setState(() {});
                                if (ok) {
                                  _flash('불러오기 완료!', '저장된 데이터를 불러왔습니다.');
                                } else {
                                  _flash('오류!', '저장된 데이터가 없습니다.', error: true);
                                }
                              },
                              child: const Text('저장된 값 불러오기 📋'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () async {
                                await state.reset();
                                setState(() {});
                                _flash('초기화 완료!', '모든 선택이 초기화되었습니다.');
                              },
                              child: const Text('새로 시작 🔄'),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    SpaceGrid(
                      selected: state.environment.space,
                      onSelect: (v) =>
                          setState(() => state.setEnvironment(space: v)),
                    ),
                    const SizedBox(height: 12),
                    SocialityGrid(
                      selected: state.environment.sociality,
                      onSelect: (v) =>
                          setState(() => state.setEnvironment(sociality: v)),
                    ),
                    const SizedBox(height: 12),
                    NoiseGrid(
                      selected: state.environment.noise,
                      onSelect: (v) =>
                          setState(() => state.setEnvironment(noise: v)),
                    ),
                    const SizedBox(height: 12),
                    CongestionGrid(
                      selected: state.environment.congestion,
                      onSelect: (v) =>
                          setState(() => state.setEnvironment(congestion: v)),
                    ),
                    const SizedBox(height: 12),
                    InOutGrid(
                      selected: state.environment.indoorOutdoor,
                      onSelect: (v) => setState(
                        () => state.setEnvironment(indoorOutdoor: v),
                      ),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5A3D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          await state.save();
                          if (!mounted) return;
                          _flash('저장 완료!', '선택 사항이 성공적으로 저장되었습니다.');
                          context.goNamed(
                            'curationResult',
                          ); // go_router로 결과 화면 이동
                        },
                        child: const Text(
                          '여행 큐레이션 받기 ✨',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    if (showMessage) ...[
                      const SizedBox(height: 12),
                      MessageBox(
                        title: messageTitle,
                        text: messageText,
                        isError: messageError,
                      ),
                    ],
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

class _SubEmotionCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SubEmotionCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFA37B5C) : const Color(0xFFF2EDDC);
    final fg = selected ? Colors.white : const Color(0xFF2D2A26);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: fg, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
