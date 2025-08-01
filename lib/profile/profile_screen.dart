/* 메인 화면에서 하단 메뉴 profile 클릭 시 보여지는 화면 */
import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/home/start_screen.dart';
import 'package:heat_trip_flutter/profile/expense_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String realName = '본명';
    final String nickname = '닉네임';
    final String profileImageUrl =
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSnRCDEVIMXXel2QFByCN48ls28VRkE7GneTg&s';

    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 프로필
            const SizedBox(height: 60),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(profileImageUrl),
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        realName,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 100,
                        height: 1,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            nickname,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              print('프로필 편집 클릭됨');
                            },
                            icon: const Icon(Icons.edit, size: 14),
                            label: const Text(
                              '프로필 편집',
                              style: TextStyle(fontSize: 10),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              side: const BorderSide(width: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 내 활동 요약
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem('게시물', '23'),
                _buildSummaryItem('좋아요', '87'),
                _buildSummaryItem('팔로워', '9'),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            // 내 활동
            const Text('📌 내 활동', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            _buildMenuTile('내가 작성한 게시물 통계보기', Icons.article, () {}),
            _buildMenuTile('좋아요 누른 게시물', Icons.favorite_border, () {}),
            _buildMenuTile('여행 지출 내역', Icons.receipt_long, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExpenseHistoryScreen(),
                ),
              );
            }),

            const SizedBox(height: 20),
            const Text('👥 소셜 / 커뮤니티', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            _buildMenuTile('숨김/차단 관리', Icons.visibility_off, () {}),

            const SizedBox(height: 20),
            const Text('⚙️ 계정 설정', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            _buildMenuTile('로그아웃', Icons.logout, () {
              // 로그아웃 로직 실행 후 StartScreen으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const StartScreen()),
              );
            }),

            _buildMenuTile('회원 탈퇴', Icons.delete_forever, () {
              // 예: 탈퇴 로직
              print('회원 탈퇴 클릭됨');
            }),
          ],
        ),
      ),
    );
  }

  // 활동 요약 박스
  Widget _buildSummaryItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  // 리스트 타일 스타일 메뉴
  Widget _buildMenuTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, color: Colors.black54),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
