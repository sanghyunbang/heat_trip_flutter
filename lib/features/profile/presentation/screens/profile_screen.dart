import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; //  추가
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import '../profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final authRepository = AuthRepositoryImpl();
  String realName = '';
  String nickname = '';
  late final TabController _tabController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final token = await TokenStorage.getToken();
    if (!mounted) return;

    if (token == null) {
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

  void _openRightMenuSheet() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Profile Menu',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: Align(
            alignment: Alignment.centerRight,
            child: RightSideMenuPanel(onClose: () => Navigator.of(ctx).pop()),
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    await TokenStorage.clearToken();

    // 팝업만 닫아주고
    final rootNav = Navigator.of(context, rootNavigator: true);
    rootNav.popUntil((route) => route is! PopupRoute);

    // go_router로 Start로 복귀 (스택 정리는 go_router가 담당)
    if (!mounted) return;
    context.go('/start'); // or: context.goNamed('start');
  }

  @override
  Widget build(BuildContext context) {
    // ... 생략: 기존 UI 그대로 ...
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _openRightMenuSheet,
          ),
        ],
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('이름: $realName', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  Text('닉네임: $nickname', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 24),
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: '정보'),
                      Tab(text: '설정'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Center(child: Text('정보 탭 내용')),
                        Center(child: Text('설정 탭 내용')),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
