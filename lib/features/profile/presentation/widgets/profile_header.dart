import 'package:flutter/material.dart';

/// 상단 헤더 영역
/// - 로그인됨:  [Edit] [닉네임] [Logout] + (아래) TabBar 노출
/// - 비로그인:  [Login] [게스트라벨] [Sign up] + (아래) TabBar 숨김
class ProfileHeader extends StatelessWidget {
  final Color backgroundColor;        // 헤더 배경색
  final TabController tabController;  // 상단 탭 컨트롤러(로그인 시에만 사용)
  final String avatarUrl;             // 아바타 이미지 URL
  final String nickname;              // 로그인 시 닉네임
  final bool isLoggedIn;              // ✅ 로그인 여부

  // 로그인됨일 때 동작
  final VoidCallback onEdit;          // Edit 클릭 콜백
  final VoidCallback onLogout;        // Logout 클릭 콜백

  // 비로그인일 때 동작(선택)
  final VoidCallback? onLogin;        // Login 클릭 콜백
  final VoidCallback? onSignUp;       // Sign up 클릭 콜백
  final String guestLabel;            // 비로그인 중앙 라벨 텍스트

  const ProfileHeader({
    super.key,
    required this.backgroundColor,
    required this.tabController,
    required this.avatarUrl,
    required this.nickname,
    required this.isLoggedIn,
    required this.onEdit,
    required this.onLogout,
    this.onLogin,
    this.onSignUp,
    this.guestLabel = '게스트',
  });

  @override
  Widget build(BuildContext context) {
    final safeUrl = avatarUrl.trim(); // 공백 방지
    final hasUrl = safeUrl.isNotEmpty;

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Column(
        children: [
          // ===== 상단 행: 좌/중앙/우 액션 =====
          Row(
            children: [
              // 좌측: 로그인됨 → Edit / 비로그인 → Login
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: isLoggedIn
                      ? TextButton(
                    onPressed: onEdit,
                    style: _textBtnStyle(leftAligned: true),
                    child: const Text(
                      'Edit',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  )
                      : TextButton(
                    onPressed: onLogin, // null이면 비활성
                    style: _textBtnStyle(leftAligned: true),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                ),
              ),

              // 중앙: 로그인됨 → 닉네임 / 비로그인 → guestLabel
              Text(
                isLoggedIn ? (nickname.isEmpty ? '' : nickname) : guestLabel,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .2,
                ),
              ),

              // 우측: 로그인됨 → Logout / 비로그인 → Sign up
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: isLoggedIn
                      ? TextButton(
                    onPressed: onLogout,
                    style: _textBtnStyle(),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  )
                      : TextButton(
                    onPressed: onSignUp,
                    style: _textBtnStyle(),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ===== 아바타 (네트워크 이미지 안정 렌더링) =====
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 10,
                )
              ],
            ),
            child: ClipOval(
              child: hasUrl
                  ? Image.network(
                safeUrl,
                key: ValueKey(safeUrl), // URL 바뀌면 강제 리빌드
                width: 108,
                height: 108,
                fit: BoxFit.cover,
                // 네트워크 실패 시 플레이스홀더
                errorBuilder: (_, __, ___) => _fallbackAvatar(),
                // 느린 네트워크에서 로딩 표시
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return SizedBox(
                    width: 108,
                    height: 108,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
              )
                  : _fallbackAvatar(),
            ),
          ),
          const SizedBox(height: 12),

          // ===== 상단 탭바: ✅ 로그인시에만 노출 =====
          if (isLoggedIn)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: tabController,
                labelColor: Color(0xFFDE835F),
                unselectedLabelColor: Colors.black45,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: Color(0xFFDE835F),
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

  /// 텍스트 버튼을 "순수 텍스트처럼" 보이게 하는 공통 스타일
  ButtonStyle _textBtnStyle({bool leftAligned = false}) {
    return TextButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: const Size(0, 0),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      alignment: leftAligned ? Alignment.centerLeft : Alignment.centerRight,
      foregroundColor: Colors.black54,
      overlayColor: Colors.transparent,
    );
  }

  /// 네트워크 실패/URL 없음일 때 보이는 기본 아바타
  Widget _fallbackAvatar() {
    return Container(
      width: 108,
      height: 108,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.person, size: 48, color: Colors.black38),
      ),
    );
  }
}
