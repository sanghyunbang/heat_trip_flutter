import 'package:flutter/material.dart';

/// 이용약관 화면 (더미 텍스트)
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const lorem =
        '여기에 이용약관 전문이 들어갑니다. 예시 텍스트...\n\n1. 약관의 목적\n2. 서비스 이용\n3. 금지행위\n...';
    return Scaffold(
      appBar: AppBar(title: const Text('이용약관')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(child: Text(lorem)),
      ),
    );
  }
}
