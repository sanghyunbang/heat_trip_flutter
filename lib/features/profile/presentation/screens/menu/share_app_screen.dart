import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 앱 추천 화면
/// - 앱 스토어 링크/초대 링크 등을 복사/공유하도록 구성
class ShareAppScreen extends StatelessWidget {
  const ShareAppScreen({super.key});

  static const String _dummyLink = 'https://example.com/app';

  void _copyLink(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _dummyLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('링크가 클립보드에 복사되었어요!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('앱추천')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('친구에게 앱을 추천해 보세요!'),
            const SizedBox(height: 12),
            SelectableText(
              _dummyLink,
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _copyLink(context),
              icon: const Icon(Icons.copy),
              label: const Text('링크 복사'),
            ),
          ],
        ),
      ),
    );
  }
}
