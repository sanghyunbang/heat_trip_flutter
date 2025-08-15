// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ✅ go_router 네비게이션
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';

// 🔽 슬라이드 메뉴 패널(우측에서 열리는 패널) — 실제 위치에 맞게 경로 수정하세요.
import 'package:heat_trip_flutter/features/profile/presentation/widgets/right_side_menu_panel.dart';

/// ProfileScreen
/// - JWT가 있으면 사용자 정보(이름/닉네임)를 조회해 상단 영역에 표시
/// - "여행 지출 내역" 등 목록형 메뉴 제공
/// - AppBar 우측의 햄버거 버튼으로 RightSideMenuPanel 열기
/// - 로그아웃 시 SharedPreferences에서 토큰 삭제 후 `go_router`로 로그인 화면으로 이동
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // === 의존성 ===
  final authRepository = AuthRepositoryImpl();

  // === 상태 ===
  String realName = '';
  String nickname = '';
  String profileImageUrl =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSnRCDEVIMXXel2QFByCN48ls28VRkE7GneTg&s';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // 앱 진입 시 사용자 정보 로딩
  }

  /// ✅ SharedPreferences에 저장된 JWT로 사용자 정보를 불러오는 로직
  /// - 토큰 없으면 게스트 상태로 렌더링
  /// - 토큰 있으면 /public/getuser 호출 → 이름/닉네임 표시
  Future<void> _loadUserProfile() async {
    final token = await TokenStorage.getToken();
    if (!mounted) return;

    if (token == null) {
      // 토큰이 없으면 게스트 상태로 렌더링(스피너 해제)
      setState(() => isLoading = false);
      return;
    }

    try {
      final userInfo = await authRepository.getMyProfile(token);
      if (!mounted) return;

      if (userInfo != null) {
        setState(() {
          realName = userInfo['name'] ?? '';
          nickname = userInfo['nickname'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  /// ✅ 우측 슬라이드 메뉴 열기
  /// showGeneralDialog + SlideTransition을 사용해 오른쪽에서 부드럽게 등장
  void _openRightMenuSheet() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Profile Menu',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: Align(
            alignment: Alignment.centerRight,
            // 닫기는 다이얼로그 컨텍스트(ctx)로 pop → 현재 페이지가 pop되지 않도록 주의
            child: RightSideMenuPanel(onClose: () => Navigator.of(ctx).pop()),
          ),
        );
      },
    );
  }

  /// ✅ 로그아웃: 토큰 삭제 → go_router로 로그인 화면으로
  /// - push/pop 사용하지 않고 goNamed로 현재 라우트를 교체 → 스택 정리
  Future<void> _logout() async {
    await TokenStorage.clearToken();
    if (!mounted) return;
    context.goNamed('login'); // 라우터에 '/auth/login'이 등록되어 있어야 함
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          // ✅ 우측 햄버거(메뉴) 버튼
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _openRightMenuSheet,
            tooltip: 'Menu',
          ),
        ],
      ),

      // ===== 본문 =====
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // ===== 상단 프로필 영역 =====
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 아바타
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(profileImageUrl),
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(width: 16),

                      // 이름/닉네임/편집버튼
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 실명(혹은 백엔드가 내려주는 다른 표기)
                            Text(
                              realName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              height: 1,
                              width: 100,
                              color: Colors.grey.withOpacity(.3),
                            ),
                            const SizedBox(height: 2),

                            // 닉네임 + 프로필 편집
                            Row(
                              children: [
                                Text(
                                  nickname.isEmpty ? '이름없음' : nickname,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    // TODO: 프로필 편집 화면으로 push
                                    // ex) context.pushNamed('profileEdit');
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
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
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

                  // ===== 요약 수치(예시) =====
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

                  // ===== 메뉴 그룹 1: 활동 =====
                  const Text('📌 내 활동', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  _buildMenuTile('내가 작성한 게시물 통계보기', Icons.article, () {
                    // TODO: 추후 라우팅
                    // ex) context.pushNamed('myPostStats');
                  }),
                  _buildMenuTile('좋아요 누른 게시물', Icons.favorite_border, () {
                    // TODO: 추후 라우팅
                    // ex) context.pushNamed('likedPosts');
                  }),
                  _buildMenuTile('여행 지출 내역', Icons.receipt_long, () {
                    // ✅ go_router로 하위 상세 화면 push
                    // '/profile' 브랜치의 child 라우트로 등록되어 있어야 합니다. (name: 'expenseHistory')
                    context.pushNamed('expenseHistory');
                  }),

                  const SizedBox(height: 20),

                  // ===== 메뉴 그룹 2: 소셜 / 커뮤니티 =====
                  const Text('👥 소셜 / 커뮤니티', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  _buildMenuTile('숨김/차단 관리', Icons.visibility_off, () {
                    // TODO
                    // ex) context.pushNamed('blockList');
                  }),

                  const SizedBox(height: 20),

                  // ===== 메뉴 그룹 3: 계정 설정 =====
                  const Text('⚙️ 계정 설정', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  _buildMenuTile('로그아웃', Icons.logout, _logout),
                  _buildMenuTile('회원 탈퇴', Icons.delete_forever, () {
                    // TODO: 회원탈퇴 플로우
                    // ex) context.pushNamed('accountDelete');
                  }),
                ],
              ),
            ),
    );
  }

  /// 요약 수치 컴포넌트(간단한 텍스트 묶음)
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

  /// 공통 메뉴 타일
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
