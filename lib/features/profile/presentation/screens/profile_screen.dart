import 'package:flutter/material.dart';

// 시작 화면 및 인증 관련 의존성 (기존 코드 그대로 사용)
import 'package:heat_trip_flutter/presentation/screens/start_screen.dart';
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';

// 프로필 feature 내부 위젯들을 한 번에 가져오기 위한 barrel
import '../profile.dart';

/// 시안 기반 Profile 화면
/// - 상단 AppBar(우측 햄버거 → 우측 사이드 메뉴 패널)
/// - 헤더(좌: Edit / 중앙: 닉네임 / 우: Logout + 아바타 + 탭바)
/// - 탭 2개: statics(차트 + Continue watching), bookmark(스켈레톤)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  // === 상태/의존성 ===
  final authRepository = AuthRepositoryImpl();
  String realName = '';
  String nickname = '';

  // 탭 제어용 컨트롤러 (statics, bookmark)
  late final TabController _tabController;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserProfile(); // 사용자 정보 로드
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// SharedPreferences에서 토큰 로드 → 사용자 정보 호출 → 상태 업데이트
  Future<void> _loadUserProfile() async {
    final token = await TokenStorage.getToken();
    if (!mounted) return;

    if (token == null) {
      // 토큰 없으면 게스트 상태로 렌더링
      setState(() => isLoading = false);
      return;
    }

    try {
      final userInfo = await authRepository.getMyProfile(token);
      if (!mounted) return;

      if (userInfo != null) {
        setState(() {
          realName = userInfo['name'] ?? '';
          nickname = userInfo['nickname'] ?? '이름없음';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  /// ✅ 우측에서 슬라이드 인되는 메뉴 시트 열기
  /// showGeneralDialog + SlideTransition 사용
  void _openRightMenuSheet() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, // 배경 탭하면 닫기
      barrierLabel: 'Profile Menu',
      barrierColor: Colors.black54, // 딤 처리
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(curved),
          child: Align(
            alignment: Alignment.centerRight,
            // 🔑 다이얼로그 컨텍스트(ctx)로 닫기 → 페이지가 pop되지 않음
            child: RightSideMenuPanel(onClose: () => Navigator.of(ctx).pop()),
          ),
        );
      },
    );
  }

  /// 로그아웃 공통 로직
  Future<void> _logout() async {
    // 1) 토큰/세션 정리
    await TokenStorage.clearToken();

    // 2) 열린 팝업(다이얼로그/시트) 모두 닫기
    final rootNav = Navigator.of(context, rootNavigator: true);
    rootNav.popUntil((route) => route is! PopupRoute);

    // 3) StartScreen으로 스택 비우고 이동
    rootNav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const StartScreen()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const headerBg = Color(0xFFDCD6CD); // 상단 베이지 톤

    return Scaffold(
      // ===== 상단 앱바 =====
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.blur_circular_outlined),
          onPressed: () {
            // TODO: 좌측 아이콘 동작(설정/알림 등)
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _openRightMenuSheet, // ✅ 우측 사이드 메뉴 열기
          ),
        ],
      ),

      // ===== 본문 =====
      body: SafeArea(
        child: Column(
          children: [
            // ===== 상단 헤더(편집/닉네임/로그아웃 + 아바타 + 탭바) =====
            ProfileHeader(
              backgroundColor: headerBg,
              tabController: _tabController,
              // 아바타 URL (실제 사용자 이미지로 교체 가능)
              avatarUrl:
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSnRCDEVIMXXel2QFByCN48ls28VRkE7GneTg&s',
              nickname: nickname,
              // 디자인 유지 + 클릭만 가능하도록 스타일된 버튼 콜백
              onEdit: () {
                // TODO: 프로필 편집 화면 이동
              },
              onLogout: _logout,
            ),

            // ===== 탭 컨텐츠 =====
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1) Statics 탭
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      // 감정 통계 카드 + 라인 차트
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Emotion Statistics',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w700)),
                              SizedBox(height: 6),
                              Text('Monthly Emotion Trends',
                                  style:
                                  TextStyle(fontSize: 12, color: Colors.black54)),
                              SizedBox(height: 12),
                              SizedBox(
                                height: 140,
                                width: double.infinity, // 가로도 확실히
                                child: CustomPaint(
                                  painter: LineChartPainter(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Continue watching
                      const Text('Continue watching',
                          style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 12),
                      const CourseItem(
                        icon: Icons.security_outlined,
                        title: 'Intro to Cyber-security',
                        author: 'Paul Newman',
                        progress: 0.70,
                      ),
                      const SizedBox(height: 12),
                      const CourseItem(
                        icon: Icons.hexagon_outlined,
                        title: 'Intro to Polymer',
                        author: 'Zahir Khan',
                        progress: 0.45,
                      ),
                    ],
                  ),

                  // 2) Bookmark 탭 - 스켈레톤
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
                  /*
                  /// 북마크 데이터 생성 시
                  // 예시 상태값(어딘가에 선언)
                  bool isBookmarksLoading = true; // 로딩 중인지 여부
                  final List<BookmarkItem> bookmarks = []; // 실제 북마크 데이터

                  // ✅ Bookmark 탭에서 조건부 렌더링
                  Widget buildBookmarksTab() {
                    if (isBookmarksLoading) {
                      // 1) 로딩 중: 스켈레톤 표시
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        children: const [
                          // 그대로 SkeletonBox들 배치
                          // (위 스니펫과 동일)
                        ],
                      );
                    } else if (bookmarks.isEmpty) {
                      // 2) 데이터 없음: 빈 상태 안내
                      return const Center(
                        child: Text('저장된 북마크가 없어요.'),
                      );
                    } else {
                      // 3) 데이터 있음: 실제 북마크 렌더링
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemBuilder: (_, i) {
                          final b = bookmarks[i];
                          return _BookmarkCard(item: b); // ← 실제 카드 위젯
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: bookmarks.length,
                      );
                    }
                  }
                   */
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
