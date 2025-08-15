// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ✅ go_router 네비게이션
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final authRepository = AuthRepositoryImpl();

  String realName = '';
  String nickname = '';
  String profileImageUrl =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSnRCDEVIMXXel2QFByCN48ls28VRkE7GneTg&s';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// ✅ SharedPreferences에 저장된 JWT로 사용자 정보를 불러오는 로직
  Future<void> _loadUserProfile() async {
    final token = await TokenStorage.getToken();
    if (!mounted) return;

    if (token == null) {
      // 토큰이 없으면 게스트 상태로 렌더링
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

  /// ✅ 로그아웃: 토큰 삭제 → 로그인 라우트로 교체 이동
  Future<void> _logout() async {
    await TokenStorage.clearToken();
    if (!mounted) return;
    context.goNamed('login'); // 라우터에 '/auth/login'이 등록되어 있어야 함
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(title: const Text('My Profile'), centerTitle: true),
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
                  }),
                  _buildMenuTile('좋아요 누른 게시물', Icons.favorite_border, () {
                    // TODO: 추후 라우팅
                  }),
                  _buildMenuTile('여행 지출 내역', Icons.receipt_long, () {
                    // ✅ go_router로 하위 상세 화면 push
                    context.pushNamed('expenseHistory');
                  }),

                  const SizedBox(height: 20),

                  // ===== 메뉴 그룹 2: 소셜 =====
                  const Text('👥 소셜 / 커뮤니티', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  _buildMenuTile('숨김/차단 관리', Icons.visibility_off, () {
                    // TODO
                  }),

                  const SizedBox(height: 20),

                  // ===== 메뉴 그룹 3: 계정 설정 =====
                  const Text('⚙️ 계정 설정', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  _buildMenuTile('로그아웃', Icons.logout, _logout),
                  _buildMenuTile('회원 탈퇴', Icons.delete_forever, () {
                    // TODO: 회원탈퇴 플로우
                  }),
                ],
              ),
            ),
    );
  }

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

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart'; //  추가
// import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
// import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
// import '../profile.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen>
//     with SingleTickerProviderStateMixin {
//   final authRepository = AuthRepositoryImpl();
//   String realName = '';
//   String nickname = '';
//   late final TabController _tabController;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _loadUserProfile();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadUserProfile() async {
//     final token = await TokenStorage.getToken();
//     if (!mounted) return;

//     if (token == null) {
//       setState(() => isLoading = false);
//       return;
//     }

//     try {
//       final userInfo = await authRepository.getMyProfile(token);
//       if (!mounted) return;
//       if (userInfo != null) {
//         setState(() {
//           realName = userInfo['name'] ?? '';
//           nickname = userInfo['nickname'] ?? '이름없음';
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//       }
//     } catch (_) {
//       setState(() => isLoading = false);
//     }
//   }

//   void _openRightMenuSheet() {
//     showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: 'Profile Menu',
//       barrierColor: Colors.black54,
//       transitionDuration: const Duration(milliseconds: 280),
//       pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
//       transitionBuilder: (ctx, anim, _, __) {
//         return SlideTransition(
//           position: Tween(
//             begin: const Offset(1, 0),
//             end: Offset.zero,
//           ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
//           child: Align(
//             alignment: Alignment.centerRight,
//             child: RightSideMenuPanel(onClose: () => Navigator.of(ctx).pop()),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _logout() async {
//     await TokenStorage.clearToken();

//     // 팝업만 닫아주고
//     final rootNav = Navigator.of(context, rootNavigator: true);
//     rootNav.popUntil((route) => route is! PopupRoute);

//     // go_router로 Start로 복귀 (스택 정리는 go_router가 담당)
//     if (!mounted) return;
//     context.go('/start'); // or: context.goNamed('start');
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ... 생략: 기존 UI 그대로 ...
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'My Profile',
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.menu),
//             onPressed: _openRightMenuSheet,
//           ),
//         ],
//       ),
//       body: Center(
//         child: isLoading
//             ? const CircularProgressIndicator()
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text('이름: $realName', style: const TextStyle(fontSize: 20)),
//                   const SizedBox(height: 8),
//                   Text('닉네임: $nickname', style: const TextStyle(fontSize: 18)),
//                   const SizedBox(height: 24),
//                   TabBar(
//                     controller: _tabController,
//                     tabs: const [
//                       Tab(text: '정보'),
//                       Tab(text: '설정'),
//                     ],
//                   ),
//                   Expanded(
//                     child: TabBarView(
//                       controller: _tabController,
//                       children: [
//                         Center(child: Text('정보 탭 내용')),
//                         Center(child: Text('설정 탭 내용')),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }
