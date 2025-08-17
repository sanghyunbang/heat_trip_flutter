import 'package:flutter/material.dart';

/// 앱 소개 화면
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const version = '1.0.0';
    return Scaffold(
      appBar: AppBar(title: const Text('소개')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('앱 이름: Heat Trip', style: TextStyle(fontSize: 16)),
            SizedBox(height: 6),
            Text('버전: $version'),
            SizedBox(height: 16),
            Text(
              'Heat Trip은 여행 기록과 감정 큐레이션을 돕는 앱입니다.\n'
                  '여행의 순간을 기록하고 추천 콘텐츠를 받아보세요.',
            ),
          ],
        ),
      ),
    );
  }
}
