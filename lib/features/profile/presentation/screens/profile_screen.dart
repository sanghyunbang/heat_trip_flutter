import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ✅ go_router 네비게이션
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';

// 프로필 feature 내부 재사용 위젯 export (ProfileHeader, LineChartPainter, 등)
import '../profile.dart';

/// 시안 기반 Profile 화면
/// - 로그인 상태에 따라 헤더의 액션이 달라짐(로그인: Edit/Logout, 비로그인: Login/Sign up)
/// - 로그인 시 사용자 정보 조회 후 닉네임/아바타 바인딩
/// - 비로그인 시: 헤더만 표시 + 안내 문구, TabBar/TabBarView 숨김
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
  bool isLoading = true; // 화면 로딩 스피너 제어
  bool isLoggedIn = false; // ✅ 로그인 여부
  String realName = ''; // 실명(옵션)
  String nickname = ''; // 닉네임(로그인 시 표시)
  String avatarUrl =
      'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'; // 기본 아바타(비로그인도 사용)

  // 탭 제어용 컨트롤러 (statics, bookmark)
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserProfile(); // ✅ 사용자 정보 로드(로그인 판단)
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// ✅ 토큰 존재 여부로 로그인 판단 → 로그인 시 사용자 정보 로드
  Future<void> _loadUserProfile() async {
    try {
      final token = await TokenStorage.getToken(); // SharedPreferences 토큰 조회
      if (!mounted) return;

      if (token == null) {
        // ⭕ 비로그인: 스피너 해제만
        setState(() {
          isLoggedIn = false;
          isLoading = false;
        });
        return;
      }

      // ⭕ 로그인: 프로필 API 조회
      final userInfo = await authRepository.getMyProfile(token);
      if (!mounted) return;

      if (userInfo != null) {
        setState(() {
          isLoggedIn = true;
          realName = userInfo['name'] ?? '';
          nickname = userInfo['nickname'] ?? '';
          // avatarUrl = userInfo['avatarUrl'] ?? avatarUrl; // 서버가 내려주면 사용
          isLoading = false;
        });
      } else {
        // 토큰은 있으나 프로필 조회 실패 → 비로그인 처리
        setState(() {
          isLoggedIn = false;
        });
      }
    } catch (_) {
      // 에러 시에도 비로그인 처리로 폴백
      if (!mounted) return;
      setState(() {
        isLoggedIn = false;
        isLoading = false;
      });
    }
  }

  /// ✅ 우측에서 슬라이드 메뉴 시트 열기 (선택 기능: 기존과 동일)
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
              onClose: () => Navigator.of(ctx).pop(), // 다이얼로그 컨텍스트로 닫기
            ),
          ),
        );
      },
    );
  }

  /// ✅ 로그아웃: 토큰 삭제 → 라우터로 로그인 화면 이동(스택 정리)
  Future<void> _logout() async {
    await TokenStorage.clearToken(); // 토큰/세션 정리
    if (!mounted) return;
    context.goNamed('login'); // 라우터 설정에 'login' 네임이 있어야 함
  }

  /// ✅ 로그인 버튼 동작: 로그인 화면으로 이동
  void _goLogin() {
    context.goNamed('login'); // '/auth/login' 등 네임드 라우트 필요
  }

  /// ✅ 회원가입 버튼 동작: 회원가입 화면으로 이동
  void _goSignUp() {
    context.goNamed('signUp'); // '/auth/signup' 등 네임드 라우트 필요
  }

  @override
  Widget build(BuildContext context) {
    const headerBg = Color(0xFFEBE2CD); // 상단 베이지 톤

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
                  // ===== 상단 헤더 (로그인 분기 전달) =====
                  ProfileHeader(
                    backgroundColor: const Color(0xFFEBE2CD),
                    tabController: _tabController,
                    avatarUrl: avatarUrl,
                    nickname: nickname,
                    isLoggedIn: isLoggedIn, // ✅ 헤더가 TabBar 표시 여부를 판단
                    onEdit: () {
                      // ✅ go_router 네임드 라우트 이동
                      context.goNamed('profileEdit');
                    },
                    onLogout: _logout,
                    onLogin: _goLogin, // ✅ 비로그인일 때 Login 버튼 콜백
                    onSignUp: _goSignUp, // ✅ 비로그인일 때 Sign up 버튼 콜백
                    guestLabel: '게스트',
                  ),

                  // ===== 아래 컨텐츠: ✅ 로그인된 경우에만 탭 내용 표시 =====
                  if (isLoggedIn)
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // 1) Statics 탭
                          ListView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            children: [
                              Card(
                                elevation: 0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '나의 감정 그래프',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Monthly Emotion Trends',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      SizedBox(
                                        height: 140,
                                        width: double.infinity,
                                        child: CustomPaint(
                                          painter: LineChartPainter(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                '감정별 상태보기',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 12),
                              CourseItem(
                                icon: Icons.sentiment_satisfied_alt,
                                title: '기쁨',
                                author: 'happiness',
                                progress: 0.70,
                              ),
                              SizedBox(height: 12),
                              CourseItem(
                                icon: Icons.sentiment_very_dissatisfied,
                                title: '슬픔',
                                author: 'sadness',
                                progress: 0.45,
                              ),
                              SizedBox(height: 12),
                              CourseItem(
                                icon:
                                    Icons.sentiment_very_dissatisfied_outlined,
                                title: '두려움',
                                author: 'fear',
                                progress: 0.45,
                              ),
                            ],
                          ),

                          // 2) Bookmark 탭 - (지금은 스켈레톤 예시)
                          ListView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            children: const [
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  SkeletonBox(height: 110, width: 160),
                                  SkeletonBox(height: 110, width: 200),
                                  SkeletonBox(
                                    height: 140,
                                    width: double.infinity,
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: SkeletonBox(height: 60)),
                                  SizedBox(width: 16),
                                  Expanded(child: SkeletonBox(height: 60)),
                                ],
                              ),
                              SizedBox(height: 16),
                              SkeletonBox(height: 60),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    // ✅ 비로그인 상태: 안내 문구(아이콘 + 텍스트)만 노출
                    Expanded(
                      child: Center(
                        // 가로로 아이콘 + 텍스트를 나란히 배치
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ), // 좌우 여백
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // 내용물만큼만 가로 차지
                            children: [
                              // 원 안에 느낌표 아이콘
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle, // 동그란 배경
                                  border: Border.all(
                                    color: Colors.black54,
                                  ), // 테두리 색상
                                ),
                                child: const Icon(
                                  Icons.priority_high_rounded, // 느낌표 아이콘
                                  size: 12, // 아이콘 크기
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 10), // 아이콘과 텍스트 간격
                              // 안내 문구
                              const Flexible(
                                child: Text(
                                  '로그인하면 더 많은 기능을 사용할 수 있어요',
                                  textAlign: TextAlign.center, // 가운데 정렬
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54, // 살짝 옅은 톤
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
