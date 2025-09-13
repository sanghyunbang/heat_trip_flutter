// lib/features/profile/presentation/screens/profile_screen.dart
//
// [변경 요약]
// 1) 두 번째 탭을 BookmarkTab()으로 교체 (인스타 저장탭 같은 화면)
// 2) 첫 번째 탭(감정 그래프 등) UI는 별도 파일 statics_tab.dart로 분리
//
// [유지한 것]
// - 로그인/프로필 로딩 로직
// - 우측 메뉴( RightSideMenuPanel ) 호출 방식
// - 헤더(ProfileHeader)와 탭 컨트롤러 구조

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import 'package:heat_trip_flutter/features/profile/presentation/widgets/tabs/bookmark_tab.dart';
import 'package:heat_trip_flutter/features/profile/presentation/widgets/tabs/statics_tab.dart';

// 공용 위젯들 (ProfileHeader, LineChartPainter, CourseItem, SkeletonBox, RightSideMenuPanel 등)
import '../profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  // === 의존성 ===
  final authRepository = AuthRepositoryImpl();

  // === 상태 ===
  bool isLoading = true;      // 프로필 전체 로딩 스피너 표시 여부
  bool isLoggedIn = false;    // 로그인 여부
  String realName = '';       // 실명
  String nickname = '';       // 닉네임
  String avatarUrl = '';      // 이미지 URL (없으면 빈 문자열로 유지)

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2개 탭 유지
    _loadUserProfile(); // 토큰 확인 → 프로필 로드
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 토큰 존재 여부 확인 후, 로그인 시 서버에서 내 프로필 로드
  Future<void> _loadUserProfile() async {
    try {
      final token = await TokenStorage.getToken();
      if (!mounted) return;

      if (token == null) {
        // 토큰이 없으면 비로그인 상태로 처리
        setState(() {
          isLoggedIn = false;
          isLoading  = false;
        });
        return;
      }

      final userInfo = await authRepository.getMyProfile(token);

      if (!mounted) return;

      if (userInfo != null) {
        // 서버 키 매핑: name, nickname, imageUrl
        final imageUrl = (userInfo['imageUrl'] as String?)?.trim() ?? '';

        setState(() {
          isLoggedIn = true;
          realName   = (userInfo['name'] ?? '').toString();
          nickname   = (userInfo['nickname'] ?? '').toString();
          avatarUrl  = imageUrl;
          isLoading  = false;
        });
      } else {
        setState(() {
          isLoggedIn = false;
          isLoading  = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoggedIn = false;
        isLoading  = false;
      });
    }
  }

  /// 우측에서 여는 메뉴 시트
  void _openRightMenuSheet() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Profile Menu',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(curved),
          child: Align(
            alignment: Alignment.centerRight,
            child: RightSideMenuPanel(
              onClose: () => Navigator.of(ctx).pop(),
              isLoggedIn: isLoggedIn, // ← 로그인 상태를 패널에도 전달
            ),
          ),
        );
      },
    );
  }

  /// 로그아웃: 토큰 삭제 후 로그인 화면으로
  Future<void> _logout() async {
    await TokenStorage.clearToken();
    if (!mounted) return;
    context.goNamed('login');
  }

  void _goLogin() => context.goNamed('login');
  void _goSignUp() => context.goNamed('signUp');

  @override
  Widget build(BuildContext context) {
    const headerBg = Color(0xFFF8F2E7); // sign up과 동일 톤

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _openRightMenuSheet,
            tooltip: 'Menu',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [
            // ===== 상단 헤더 =====
            ProfileHeader(
              backgroundColor: headerBg,
              tabController: _tabController,
              avatarUrl: avatarUrl,     // ← 서버의 imageUrl 그대로
              nickname: nickname,
              isLoggedIn: isLoggedIn,
              onEdit: () => context.goNamed('profileEdit'),
              onLogout: _logout,
              onLogin: _goLogin,
              onSignUp: _goSignUp,
              guestLabel: '게스트',
            ),

            // ===== 아래 컨텐츠 =====
            if (isLoggedIn)
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    // 1) Statics 탭 (분리한 파일)
                    StaticsTab(),
                    // 2) Bookmark 탭 (상단 컬렉션 + 하단 그리드)
                    BookmarkTab(),
                  ],
                ),
              )
            else
            // 비로그인 상태 안내
              const Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 원 테두리 + 느낌표 아이콘
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: DecoratedBox(
                            decoration: ShapeDecoration(
                              shape: CircleBorder(
                                side: BorderSide(color: Colors.black54),
                              ),
                            ),
                            child: Icon(Icons.priority_high_rounded,
                                size: 12, color: Colors.black54),
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            '로그인하면 더 많은 기능을 사용할 수 있어요',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
