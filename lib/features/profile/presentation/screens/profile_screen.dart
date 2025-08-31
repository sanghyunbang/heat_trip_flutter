// lib/features/profile/presentation/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';

// 재사용 위젯들 (ProfileHeader, LineChartPainter, SkeletonBox, CourseItem, RightSideMenuPanel 등)
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
  bool isLoading = true;      // 프로필 전체 로딩
  bool isLoggedIn = false;    // 로그인 여부
  String realName = '';       // 실명
  String nickname = '';       // 닉네임
  String avatarUrl = '';      // 이미지 URL (없으면 빈 문자열로 유지)

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        setState(() {
          isLoggedIn = false;
          isLoading = false;
        });
        return;
      }

      final userInfo = await authRepository.getMyProfile(token);

      /// 디버깅용
      print('[ProfileScreen] raw userInfo: $userInfo');

      if (!mounted) return;

      if (userInfo != null) {
        // 서버 키 매핑: name, nickname, image_url
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


  /// 우측에서 여는 메뉴 시트 (선택 기능)
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

  void _goLogin() {
    context.goNamed('login');
  }

  void _goSignUp() {
    context.goNamed('signUp');
  }

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
              tabController: _tabController,
              avatarUrl: avatarUrl,     // ← 서버의 image_url 그대로
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
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(height: 20),
                        const Text(
                          '감정별 상태보기',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const CourseItem(
                          icon: Icons.sentiment_satisfied_alt,
                          title: '기쁨',
                          author: 'happiness',
                          progress: 0.70,
                        ),
                        const SizedBox(height: 12),
                        const CourseItem(
                          icon: Icons.sentiment_very_dissatisfied,
                          title: '슬픔',
                          author: 'sadness',
                          progress: 0.45,
                        ),
                        const SizedBox(height: 12),
                        const CourseItem(
                          icon: Icons.sentiment_very_dissatisfied_outlined,
                          title: '두려움',
                          author: 'fear',
                          progress: 0.45,
                        ),
                      ],
                    ),

                    // 2) Bookmark 탭 (스켈레톤 예시)
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      children: const [
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SkeletonBox(height: 110, width: 160),
                            SkeletonBox(height: 110, width: 200),
                            SkeletonBox(height: 140, width: double.infinity),
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
