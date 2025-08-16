import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/curation_local_data_source.dart';
import '../../data/curation_repository_impl.dart';
import '../../data/sub_emotions.dart';
import '../../domain/repositories.dart';
import '../state/curation_state.dart';
import '../widgets/message_box.dart';
import '../widgets/option_grid.dart';
import '../widgets/pad_selection_group.dart';

/// WHAT: 다단계 위저드 화면
/// 1) PAD 선택 → 2) 하위 감정 → 3) 여행 목적 → 4) 환경 요소 → 완료
class CurationScreen extends StatefulWidget {
  const CurationScreen({super.key});
  @override
  State<CurationScreen> createState() => _CurationScreenState();
}

class _CurationScreenState extends State<CurationScreen> {
  late CurationState state;

  // Wizard
  final _page = PageController();
  int _step = 0;
  static const _totalSteps = 4;

  // 메시지 박스
  bool showMessage = false;
  String messageTitle = '';
  String messageText = '';
  bool messageError = false;

  @override
  void initState() {
    super.initState();
    // 간이 DI
    final repo = CurationRepositoryImpl(CurationLocalDataSource());
    state = CurationState(
      repository: repo,
      subEmotionSource: const BuiltInSubEmotionSource(),
      matcher: SubEmotionMatcher(),
    );
  }

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

  bool get _canNext {
    switch (_step) {
      case 0:
        return state.padComplete; // PAD 완료 여부
      case 1:
        return state.selectedSubEmotionEnglish != null;
      case 2:
        return state.travelPurpose != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  Future<void> _goNext() async {
    if (!_canNext) {
      _flash('선택 필요', '이 단계를 먼저 완료해 주세요.');
      return;
    }
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      await _page.animateToPage(
        _step,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      await state.save();
      // 결과 화면을 push (뒤로 오면 Future 완료)
      await context.pushNamed('curationResult');

      // 돌아온 직후 리셋
      if (!mounted) return;
      await state.reset();
      setState(() => _step = 0);
      _page.jumpToPage(0);
    }
  }

  /** 백으로 보내고 나면, 이걸 쓸 예정 [앞에 내용들 리셋]
   * Future<void> _goNext() async {
      if (!_canNext) { _flash('선택 필요', '이 단계를 먼저 완료해 주세요.'); return; }

      if (_step < _totalSteps - 1) {
        setState(() => _step++);
        await _page.animateToPage(_step,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic);
      } else {
        // 1) 결과생성용으로 저장
        await state.save();

        // 2) 위저드 상태 초기화(UI 값들)
        await state.reset();               // ← 이미 쓰던 초기화 메서드
        if (mounted) {
          setState(() {
            _step = 0;
          });
          _page.jumpToPage(0);             // 페이지도 첫 단계로
        }

        // 3) 결과 화면으로 이동
        if (!mounted) return;
        context.goNamed('curationResult');
      }
    }

   */

  void _goBack() {
    if (_step == 0) return;
    setState(() => _step--);
    _page.animateToPage(
      _step,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFFDFBF2);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('나의 감정과 공간 선택 🎨'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 진행도 바
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (_step + 1) / _totalSteps,
                minHeight: 6,
                backgroundColor: Colors.black12,
              ),
            ),
          ),

          // 페이지 영역
          Expanded(
            child: PageView(
              controller: _page,
              physics: const NeverScrollableScrollPhysics(), // 스와이프 잠금
              children: [
                _buildStepPad(context),
                _buildStepSubEmotion(context),
                _buildStepPurpose(context),
                _buildStepEnvironment(context),
              ],
            ),
          ),

          // 하단 컨트롤 + 메시지
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showMessage) ...[
                    MessageBox(
                      title: messageTitle,
                      text: messageText,
                      isError: messageError,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _step == 0 ? null : _goBack,
                        icon: const Icon(Icons.chevron_left),
                        label: const Text('이전'),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: _goNext,
                        icon: Icon(
                          _step == _totalSteps - 1
                              ? Icons.check
                              : Icons.chevron_right,
                        ),
                        label: Text(_step == _totalSteps - 1 ? '완료' : '다음'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 공통 카드 쉘
  Widget _cardShell(BuildContext context, {required Widget child}) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
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
          child: child,
        ),
      ),
    );
  }

  // STEP 1: PAD
  Widget _buildStepPad(BuildContext context) {
    return _cardShell(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('나의 상태 진단하기', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 12),
          PadSelectionGroup(
            pleasure: state.pad.pleasure,
            arousal: state.pad.arousal,
            dominance: state.pad.dominance,
            onSelectPleasure: (v) => setState(() => state.setPad(pleasure: v)),
            onSelectArousal: (v) => setState(() => state.setPad(arousal: v)),
            onSelectDominance: (v) =>
                setState(() => state.setPad(dominance: v)),
          ),
        ],
      ),
    );
  }

  // STEP 2: 하위 감정
  Widget _buildStepSubEmotion(BuildContext context) {
    return _cardShell(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '나를 가장 잘 표현하는 감정은?',
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
            childAspectRatio: 1.9,
            children: state.suggestedSubEmotions.map((e) {
              return _SubEmotionCard(
                label: e.name,
                selected: state.selectedSubEmotionEnglish == e.english,
                onTap: () => setState(() => state.setSubEmotion(e.english)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // STEP 3: 여행 목적 (3열)
  Widget _buildStepPurpose(BuildContext context) {
    return _cardShell(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('여행 목적', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TravelPurposeGrid(
            selected: state.travelPurpose,
            onSelect: (v) => setState(() => state.setTravelPurpose(v)),
          ),
        ],
      ),
    );
  }

  // STEP 4: 환경 요소
  Widget _buildStepEnvironment(BuildContext context) {
    return _cardShell(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('공간 및 환경 요소', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SpaceGrid(
            selected: state.environment.space,
            onSelect: (v) => setState(() => state.setEnvironment(space: v)),
          ),
          const SizedBox(height: 12),
          SocialityGrid(
            selected: state.environment.sociality,
            onSelect: (v) => setState(() => state.setEnvironment(sociality: v)),
          ),
          const SizedBox(height: 12),
          NoiseGrid(
            selected: state.environment.noise,
            onSelect: (v) => setState(() => state.setEnvironment(noise: v)),
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
            onSelect: (v) =>
                setState(() => state.setEnvironment(indoorOutdoor: v)),
          ),
        ],
      ),
    );
  }
}

// === 하위 감정 카드 ===
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
