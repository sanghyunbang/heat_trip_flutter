import 'package:flutter/material.dart';
import '../../state/foryou_vm.dart';
import '../../domain/models.dart';
import 'input_screen.dart';
import 'loading_screen.dart';
import 'analysis_screen.dart';

/// 홈: 랜딩/처리/완료 스위처
class ForYouHomeScreen extends StatelessWidget {
  final ForYouVM vm;
  const ForYouHomeScreen({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    // 👇 ChangeNotifier(vm)을 직접 구독해 상태 변경 시 자동 리빌드
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        Widget body;
        switch (vm.phase) {
          case ForYouPhase.collecting:
            body = _Landing(
              onNext: () async {
                final updated = await Navigator.of(context).push<RankRequest>(
                  MaterialPageRoute(
                    builder: (_) => InputScreen(initial: vm.request),
                  ),
                );
                if (updated != null) await vm.submit(updated);
              },
            );
            break;
          case ForYouPhase.processing:
            body = const LoadingScreen(); // VM이 최소 로딩시간 보장
            break;
          case ForYouPhase.error:
            body = Center(child: Text(vm.error ?? '문제가 발생했어요.'));
            break;
          case ForYouPhase.ready:
            body = AnalysisScreen(vm: vm);
            break;
        }

        return Scaffold(
          appBar: AppBar(
            elevation: 0.6,
            title: const Text('For You'),
            actions: [
              IconButton(
                tooltip: '입력 수정',
                icon: const Icon(Icons.tune),
                onPressed: () async {
                  final updated = await Navigator.of(context).push<RankRequest>(
                    MaterialPageRoute(
                      builder: (_) => InputScreen(initial: vm.request),
                    ),
                  );
                  if (updated != null) await vm.submit(updated);
                },
              ),
            ],
          ),
          body: body,
        );
      },
    );
  }
}

/// 그라데이션 랜딩 (React Screen1_Home 느낌)
class _Landing extends StatelessWidget {
  final VoidCallback onNext;
  const _Landing({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF7B42), Color(0xFFFF5670)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: Colors.white, size: 96),
            const SizedBox(height: 16),
            const Text(
              '나를 위한 여행',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '당신의 감정을 분석하고 여행 테마를 추천해드려요',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.white),
              onPressed: onNext,
              child: const Text(
                '시작하기',
                style: TextStyle(color: Color(0xFFFB6A3E)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
