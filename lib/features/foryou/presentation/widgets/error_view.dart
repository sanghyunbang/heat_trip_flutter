/// ErrorView  [Widget]
/// 역할: 오류 상태 표시 + 재시도 버튼.
/// 입력: [message] 오류 메세지, [onRetry] 재시도 콜백
/// 사용처: ForYouScreen에서 VM.error != null일 때.
/// 비고: 네트워크/서버 오류 메세지를 그대로 노출하므로 사용자 친화 문구로 래핑해도 좋음.

// lib/features/foryou/presentation/widgets/error_view.dart
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48),
            const SizedBox(height: 12),
            Text('네트워크 오류', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
