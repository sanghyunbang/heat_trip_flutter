// lib/features/profile/presentation/screens/profile_screen.dart
//
// 목적
// - 프로필 헤더(아바타 포함)를 표시하고, 편집 화면에서 돌아오면 재로딩.
// - (선택) SharedPreferences의 avatarUrl 캐시를 먼저 보여 UX 개선.
// - Statics 탭은 "사실상 삭제" 상태로 남기되, 나중을 위해 전부 // 주석 처리.
//
// 핵심 변경
// - onEdit: await context.pushNamed('profileEdit')로 결과 대기 후, true면 _loadUserProfile() 재호출.
// - TabBarView는 이제 Bookmark 탭만 표시. TabController.length = 1 로 맞춤.
// - Statics 관련 import/코드 라인은 모두 주석 처리(흔적 유지).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import 'package:heat_trip_flutter/features/profile/presentation/widgets/tabs/bookmark_tab.dart';

// 공용 위젯들 (ProfileHeader, RightSideMenuPanel 등)
import '../profile.dart';

// ───────────────────────── Statics 흔적 (주석 처리) ─────────────────────────
// import 'package:heat_trip_flutter/features/profile/presentation/widgets/tabs/statics_tab.dart';
// ↑ 나중에 복구할 수 있도록 import만 주석으로 남겨둡니다.
// ────────────────────────────────────────────────────────────────────────────

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
  bool isLoading = true; // 프로필 전체 로딩 스피너 표시 여부
  bool isLoggedIn = false; // 로그인 여부
  String realName = ''; // 실명
  String nickname = ''; // 닉네임
  String avatarUrl = ''; // 이미지 URL (없으면 빈 문자열)

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 탭은 현재 북마크 1개만 활성화
    _tabController = TabController(
      length: 1, // ← (원래 2) Statics는 아래처럼 전부 주석 처리
      vsync: this,
    );
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
      // (선택) 캐시된 avatarUrl 먼저 보여주기: 서버 응답 전 초기 UX 개선.
      try {
        final sp = await SharedPreferences.getInstance();
        final cached = sp.getString('avatarUrl');
        if (cached != null && cached.isNotEmpty && mounted) {
          setState(() => avatarUrl = cached);
        }
      } catch (_) {}

      final token = await TokenStorage.getToken();
      if (!mounted) return;

      if (token == null) {
        // 토큰이 없으면 비로그인 상태
        setState(() {
          isLoggedIn = false;
          isLoading = false;
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
          realName = (userInfo['name'] ?? '').toString();
          nickname = (userInfo['nickname'] ?? '').toString();
          avatarUrl = imageUrl;
          isLoading = false;
        });

        // 최신 URL을 캐시에 반영(선택)
        try {
          final sp = await SharedPreferences.getInstance();
          await sp.setString('avatarUrl', imageUrl);
        } catch (_) {}
      } else {
        setState(() {
          isLoggedIn = false;
          isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoggedIn = false;
        isLoading = false;
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
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
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
                    tabController: _tabController, // length = 1
                    avatarUrl: avatarUrl, // ← 서버의 imageUrl 또는 캐시
                    nickname: nickname,
                    isLoggedIn: isLoggedIn,
                    // ★ 편집으로 이동 후 결과 대기 → true면 재조회.
                    onEdit: () async {
                      final changed = await context.pushNamed('profileEdit');
                      if (changed == true && mounted) {
                        await _loadUserProfile(); // 수정 반영
                      }
                    },
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
                          // 활성 탭: Bookmark
                          BookmarkTab(),

                          // ───────────── Statics 흔적 (주석 처리) ─────────────
                          // StaticsTab(),
                          // ↑ 북마크 외 탭을 다시 보이게 하려면
                          // 1) 위 라인의 주석을 풀고,
                          // 2) 상단 TabController.length 를 2 로 변경,
                          // 3) ProfileHeader 내부 탭 라벨도 2개로 맞추세요.
                          // ────────────────────────────────────────────────
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
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: DecoratedBox(
                                  decoration: ShapeDecoration(
                                    shape: CircleBorder(
                                      side: BorderSide(color: Colors.black54),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.priority_high_rounded,
                                    size: 12,
                                    color: Colors.black54,
                                  ),
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

/* ─────────────────────────── 각주 ───────────────────────────
- 편집 화면에서 Navigator.pop(true)로 결과를 돌려주고,
  ProfileScreen에서는 await pushNamed(...)로 결과를 대기한 뒤
  true면 _loadUserProfile()을 재호출해야 헤더/아바타가 즉시 갱신됩니다.

- SharedPreferences에 avatarUrl을 캐시해두면, 앱 재진입 시
  서버 응답 전에도 이전 이미지를 곧바로 보여줘 UX가 개선됩니다.

- Statics 관련 코드는 실제 동작에서 제외했지만,
  import/TabBarView 라인에 주석으로 흔적을 남겨 복구 가능하게 했습니다.
────────────────────────────────────────────────────────── */
