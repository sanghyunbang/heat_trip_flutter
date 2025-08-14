import 'package:flutter/material.dart';

/// 상단 헤더 영역
/// - 좌: Edit(텍스트 버튼 모양 유지) / 중앙: 닉네임 / 우: Logout(텍스트 버튼 모양 유지)
/// - 중앙 아래: 아바타 / 그 아래: TabBar
class ProfileHeader extends StatelessWidget {
  final Color backgroundColor;
  final TabController tabController;
  final String avatarUrl;
  final String nickname;
  final VoidCallback onEdit;
  final VoidCallback onLogout;

  const ProfileHeader({
    super.key,
    required this.backgroundColor,
    required this.tabController,
    required this.avatarUrl,
    required this.nickname,
    required this.onEdit,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Column(
        children: [
          // ===== 상단 행: Edit / Nickname / Logout =====
          Row(
            children: [
              // Edit (디자인 변화 없이 클릭만 되도록 스타일링)
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: onEdit,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerLeft,
                      foregroundColor: Colors.black54,
                      overlayColor: Colors.transparent,
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                ),
              ),

              // 닉네임 (중앙)
              Text(
                nickname,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .2,
                ),
              ),

              // Logout (디자인 변화 없이 클릭만 되도록 스타일링)
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onLogout,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerRight,
                      foregroundColor: Colors.black54,
                      overlayColor: Colors.transparent,
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 아바타 (흰색 테두리+그림자)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 10),
              ],
            ),
            child: CircleAvatar(
              radius: 54,
              backgroundImage: NetworkImage(avatarUrl),
            ),
          ),
          const SizedBox(height: 12),

          // 상단 탭바 (statics / bookmark)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.black45,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
                insets: const EdgeInsets.symmetric(horizontal: 48, vertical: 6),
              ),
              tabs: const [
                Tab(text: 'statics'),
                Tab(text: 'bookmark'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
