// lib/features/profile/presentation/account_delete_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';

class AccountDeleteScreen extends StatelessWidget {
  const AccountDeleteScreen({super.key});

  static const kDanger = Colors.red;

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54, // 배경 딤 처리
      builder: (_) => const _DeleteConfirmDialog(),
    );

    if (ok != true || !context.mounted) return;

    final repo = AuthRepositoryImpl();
    final token = await TokenStorage.getToken();

    if (token == null) {
      await TokenStorage.clearToken();
      if (context.mounted) context.goNamed('login');
      return;
    }

    final success = await repo.deleteMyAccount(token);

    if (!context.mounted) return;

    if (success) {
      await TokenStorage.clearToken();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('탈퇴가 완료되었습니다.')),
      );
      context.goNamed('start');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('탈퇴에 실패했습니다. 잠시 후 다시 시도해주세요.')),
      );
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDanger,
                  foregroundColor: Colors.white, // 텍스트/아이콘 흰색
                ),
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

/// ===== 커스텀 탈퇴 확인 다이얼로그 =====
class _DeleteConfirmDialog extends StatelessWidget {
  const _DeleteConfirmDialog();

  static const Color kDanger = Colors.red;
  static const Color kStroke = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 경고 아이콘
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0x1AF44336), // 연한 레드 배경
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_rounded, color: kDanger, size: 36),
            ),
            const SizedBox(height: 14),

            const Text(
              '정말 탈퇴하시겠어요?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),

            const Text(
              '탈퇴 후에는 계정과 모든 데이터가 삭제되며\n복구할 수 없습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 20),

            const Divider(height: 1, color: kStroke),
            const SizedBox(height: 12),

            Row(
              children: [
                // 취소(외곽)
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kStroke),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 10),
                // 탈퇴(위험)
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDanger,
                      foregroundColor: Colors.white, // 텍스트/아이콘 흰색
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('탈퇴하기'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
