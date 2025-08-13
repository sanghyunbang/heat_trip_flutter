import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/presentation/screens/start_screen.dart';
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';

/// 시안 기반 Profile 화면
/// - 상단 AppBar(우측 햄버거 → 우측 사이드 메뉴 패널)
/// - 헤더(설정/타이틀/로그아웃 + 아바타 + 탭바)
/// - 탭 2개: statics(차트 + Continue watching), bookmark(스켈레톤)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final authRepository = AuthRepositoryImpl();
  String realName = '';
  String nickname = '';
  // statics / bookmark 탭 제어용 컨트롤러
  late final TabController _tabController;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _tabController = TabController(length: 2, vsync: this); // 탭 2개 생성
  }

  Future<void> _loadUserProfile() async {
    final token = await TokenStorage.getToken(); // ✅ SharedPreferences에서 토큰 읽기

    if (token == null) {
      print('[X] 저장된 토큰 없음');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final userInfo = await authRepository.getMyProfile(token);

    if (userInfo != null) {
      setState(() {
        realName = userInfo['name'] ?? '';
        nickname = userInfo['nickname'] ?? '이름없음';
      });
    } else {
      print('[X] 사용자 정보 불러오기 실패');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // 메모리 누수 방지
    super.dispose();
  }

  // =========================
  // ✅ 우측에서 슬라이드 인되는 메뉴 시트 열기
  //   - showGeneralDialog + SlideTransition 사용
  //   - barrier(반투명 배경) 탭 시 닫힘
  // =========================
  void _openRightMenuSheet() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,                 // 배경 탭하면 닫기
      barrierLabel: 'Profile Menu',             // 접근성 라벨
      barrierColor: Colors.black54,             // 배경 딤 컬러
      transitionDuration: const Duration(milliseconds: 280), // 애니메이션 시간
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        // 오른쪽(1,0) → 제자리(0,0)로 슬라이드
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(curved),
          child: Align(
            alignment: Alignment.centerRight,
            child: _RightSideMenuPanel(
              // 패널 내부 X 버튼/항목 탭 시 닫기
              // 🔑 dialog 컨텍스트(ctx)로 pop → 페이지가 아니라 '메뉴'만 닫힘
              onClose: () => Navigator.of(ctx).pop(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const headerBg = Color(0xFFDCD6CD); // 상단 배경색 (시안의 베이지 톤)

    return Scaffold(
      // ===== 상단 앱바 =====
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.blur_circular_outlined),
          onPressed: () {
            // TODO: 왼쪽 아이콘 동작(설정/알림 등 연결)
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _openRightMenuSheet, // ✅ 우측 사이드 메뉴 열기
          )
        ],
      ),

      // ===== 본문 =====
      body: SafeArea(
        child: Column(
          children: [
            // ===== 상단 프로필 영역 =====
            Container(
              color: headerBg,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                children: [
                  // 상단 Settings / Profile / Logout
                  Row(
                    children: [
                      // 좌측: Edit (모양 그대로, 클릭만 가능)
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft, // 텍스트를 왼쪽 정렬 유지
                          child: TextButton(
                            onPressed: () {
                              // TODO: 프로필 편집 화면 이동/기능 실행
                            },
                            // TextButton을 "순수 텍스트"처럼 보이게 하는 스타일
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,                      // 내부 여백 제거 → 레이아웃 변화 없음
                              minimumSize: const Size(0, 0),                 // 최소 크기 제거 → 높이/폭 변경 없음
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 터치 영역 과확장 방지
                              alignment: Alignment.centerLeft,               // 텍스트 왼쪽 정렬 유지
                              foregroundColor: Colors.black54,               // 활성 텍스트 색
                              overlayColor: Colors.transparent,              // 잉크 리플 제거 → 시각 변화 없음
                            ),
                            child: const Text(
                              'Edit',
                              style: TextStyle(fontSize: 14, color: Colors.black54), // 기존 텍스트 스타일 그대로
                            ),
                          ),
                        ),
                      ),

                      // 중앙: 닉네임 (변경 없음)
                      Text(
                        nickname,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .2,
                        ),
                      ),

                      // 우측: Logout (모양 그대로, 클릭만 가능)
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight, // 오른쪽 정렬 유지
                          child: TextButton(
                            onPressed: () async {
                              // TODO: 로그아웃 로직 (토큰 삭제 → 로그인 화면 등)
                              // 1) 로그인 토큰/세션 정리
                              // await auth.signOut();  // TODO: 실제 로그아웃 로직
                              await TokenStorage.clearToken(); // ✅ 토큰 삭제

                              // 2) 모든 팝업(다이얼로그/시트) 먼저 닫기
                              final rootNav = Navigator.of(context, rootNavigator: true);
                              // PopupRoute(다이얼로그류)만 제거
                              rootNav.popUntil((route) => route is! PopupRoute);

                              // 3) StartScreen으로 스택 비우고 이동 (뒤로가기 눌러도 안 돌아오게)
                              rootNav.pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const StartScreen()), // TODO: 실제 시작 화면
                              (route) => false,
                              );
                            },
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
                              style: TextStyle(fontSize: 14, color: Colors.black54), // 기존 텍스트 스타일 그대로
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 프로필 사진 (동그란 아바타)
                  Container(
                    padding: const EdgeInsets.all(3), // 흰색 테두리 공간
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
                    child: const CircleAvatar(
                      radius: 54,
                      backgroundImage: NetworkImage(
                        // NOTE: 실제 사용자 프로필 이미지 URL로 교체
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSnRCDEVIMXXel2QFByCN48ls28VRkE7GneTg&s'
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 탭바 (statics / bookmark)
                  Container
                    (
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor: Colors.black45,
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                        ),
                        insets: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 6,
                        ),
                      ),
                      tabs: const [
                        Tab(text: 'statics'),
                        Tab(text: 'bookmark'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ===== 탭 내용 =====
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1️⃣ Statics 탭
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      // 감정 통계 카드
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
                                'Emotion Statistics',
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
                              // 간단한 라인 그래프 (CustomPainter)
                              SizedBox(
                                height: 140,
                                child: CustomPaint(
                                  painter: _LineChartPainter(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // "Continue watching" 리스트 (예시 2개)
                      const Text(
                        'Continue watching',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      const _CourseItem(
                        icon: Icons.security_outlined,
                        title: 'Intro to Cyber-security',
                        author: 'Paul Newman',
                        progress: 0.70,
                      ),
                      const SizedBox(height: 12),
                      const _CourseItem(
                        icon: Icons.hexagon_outlined,
                        title: 'Intro to Polymer',
                        author: 'Zahir Khan',
                        progress: 0.45,
                      ),
                    ],
                  ),

                  // 2️⃣ Bookmark 탭 (스켈레톤 UI)
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: const [
                          _SkeletonBox(height: 110, width: 140),
                          _SkeletonBox(height: 110, width: 200),
                          _SkeletonBox(height: 140, width: double.infinity),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: const [
                          Expanded(child: _SkeletonBox(height: 60)),
                          SizedBox(width: 16),
                          Expanded(child: _SkeletonBox(height: 60)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const _SkeletonBox(height: 60),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// 아래부터는 이 파일 전용 "내부 위젯/클래스"
// 프로젝트 규모가 커지면 별도 파일로 분리하는 것을 권장
// ----------------------------------------------------------------------

/// ✅ 우측 사이드 메뉴 패널
/// - 폭: 화면의 78% (필요 시 0.72~0.85 사이로 조절)
/// - 상단: 타이틀 + 닫기(X) 버튼
/// - 본문: 메뉴 리스트
class _RightSideMenuPanel extends StatelessWidget {
  final VoidCallback onClose;

  const _RightSideMenuPanel({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.78;

    return Material(
      color: Colors.transparent, // 둥근 모서리 밖은 투명
      child: Container(
        width: width,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(-8, 0), // 왼쪽 방향 그림자
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 상단 타이틀 + 닫기 버튼
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // 메뉴 리스트(예시 9개)
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: 9,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, i) {
                    final selected = i == 5; // 예시: 5번째 강조

                    return InkWell(
                      onTap: () {
                        // TODO: 메뉴별 액션 수행
                        onClose(); // 탭하면 닫기
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.deepPurple.withOpacity(.06)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Menu item',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 북마크 탭의 스켈레톤 박스
class _SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  const _SkeletonBox({required this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final w = width ?? double.infinity;
    return Container(
      width: w,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black12.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

/// "Continue watching" 코스 아이템 카드
class _CourseItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String author;
  final double progress;
  const _CourseItem({
    required this.icon,
    required this.title,
    required this.author,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final p = (progress * 100).round(); // 진행률 % 계산

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: 상세화면 이동 등
        },
        child: Container(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              // 왼쪽 색상 바
              Container(
                width: 6,
                height: double.infinity,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              // 아이콘
              CircleAvatar(
                radius: 18,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),

              // 제목 + 작성자
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      author,
                      style:
                      const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // 진행률 원형 프로그래스
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                    ),
                  ),
                  Text(
                    '$p%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 간단한 라인 차트 (CustomPainter)
class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 축/가이드 라인
    final axis = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1;

    // 수평 가이드 5줄
    for (var i = 0; i <= 4; i++) {
      final y = size.height - (size.height * i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), axis);
    }

    // 예시 데이터 (시안과 유사한 곡선)
    final points = <Offset>[
      Offset(0, size.height * .85),
      Offset(size.width * .18, size.height * .45),
      Offset(size.width * .36, size.height * .60),
      Offset(size.width * .54, size.height * .65),
      Offset(size.width * .72, size.height * .20),
      Offset(size.width * .98, size.height * .22),
    ];

    // 영역 채움 Path (아래로 닫음)
    final areaPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath.lineTo(points.last.dx, size.height);
    areaPath.close();

    // 영역 그라데이션(아래 진하게 → 위 투명)
    final areaPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.black.withOpacity(.05), Colors.transparent],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(areaPath, areaPaint);

    // 라인 스트로크
    final line = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
