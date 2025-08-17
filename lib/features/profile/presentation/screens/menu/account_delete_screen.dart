import 'package:flutter/material.dart';

/// 회원탈퇴 화면(확인 다이얼로그만 포함)
/// - 실제 탈퇴 API 호출/세션 제거/라우팅은 앱 로직에 맞게 연결
class AccountDeleteScreen extends StatelessWidget {
  const AccountDeleteScreen({super.key});

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('회원탈퇴'),
        content: const Text('정말 탈퇴하시겠어요? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('탈퇴', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('탈퇴 처리가 완료되었습니다(데모).')),
      );
      Navigator.of(context).pop(); // 이전 화면으로
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원탈퇴')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('주의', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => _confirmDelete(context),
                child: const Text('정말로 탈퇴하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
