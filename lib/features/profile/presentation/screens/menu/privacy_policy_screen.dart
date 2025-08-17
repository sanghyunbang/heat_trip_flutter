import 'package:flutter/material.dart';

/// 개인정보처리방침 화면 (더미 텍스트)
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const lorem =
        '여기에 개인정보처리방침 전문이 들어갑니다. 예시 텍스트...\n\n1. 수집 항목\n2. 이용 목적\n3. 보관 및 파기\n...';
    return Scaffold(
      appBar: AppBar(title: const Text('개인정보처리방침')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(child: Text(lorem)),
      ),
    );
  }
}
