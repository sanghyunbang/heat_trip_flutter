import 'package:flutter/material.dart';

// 각 메뉴 클릭 시 이동할 화면들
import 'package:heat_trip_flutter/features/profile/presentation/screens/menu/feedback_screen.dart';
import 'package:heat_trip_flutter/features/profile/presentation/screens/menu/share_app_screen.dart';
import 'package:heat_trip_flutter/features/profile/presentation/screens/menu/terms_screen.dart';
import 'package:heat_trip_flutter/features/profile/presentation/screens/menu/privacy_policy_screen.dart';
import 'package:heat_trip_flutter/features/profile/presentation/screens/menu/about_screen.dart';
import 'package:heat_trip_flutter/features/profile/presentation/screens/menu/account_delete_screen.dart';

/// 우측에서 슬라이드 인되는 사이드 메뉴 패널
/// - showGeneralDialog 의 child 로 사용
/// - "테마설정", "약관 및 정책"은 드롭다운(ExpansionTile)로 2차 메뉴 표시
class RightSideMenuPanel extends StatelessWidget {
  final VoidCallback onClose; // 패널 닫기 콜백(보통 Navigator.pop)

  /// ✅ 로그인 여부(회원탈퇴 항목 노출 제어)
  final bool isLoggedIn;

  const RightSideMenuPanel({
    super.key,
    required this.onClose,
    this.isLoggedIn = false, // 기본값: 비로그인
  });

  /// 패널을 닫은 뒤, 하위 화면으로 네비게이션
  /// - 다이얼로그(pop)가 끝난 다음 push 해야 하기 때문에 microtask로 스케줄
  void _closeThenPush(BuildContext context, Widget screen) {
    Navigator.of(context).pop(); // 패널 먼저 닫기
    Future.microtask(() {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => screen),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.78; // 패널 폭

    return Material(
      color: Colors.transparent,
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
              offset: const Offset(-8, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ===== 헤더: 타이틀 + X 버튼 =====
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Menu',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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

              // ===== 메뉴 리스트 =====
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    // 1) 소개
                    _MenuLeaf(
                      leading: const Icon(Icons.info_outline),
                      title: '소개',
                      onTap: () => _closeThenPush(
                        context,
                        const AboutScreen(),
                      ),
                    ),

                    // 2) 약관 및 정책 (드롭다운)
                    _MenuExpansion(
                      leading: const Icon(Icons.description_outlined),
                      title: '약관 및 정책',
                      children: [
                        _MenuLeaf(
                          title: '이용약관',
                          onTap: () => _closeThenPush(
                            context,
                            const TermsScreen(),
                          ),
                        ),
                        _MenuLeaf(
                          title: '개인정보처리방침',
                          onTap: () => _closeThenPush(
                            context,
                            const PrivacyPolicyScreen(),
                          ),
                        ),
                      ],
                    ),

                    // 3) 의견보내기
                    _MenuLeaf(
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: '의견보내기',
                      onTap: () => _closeThenPush(
                        context,
                        const FeedbackScreen(),
                      ),
                    ),

                    // 4) 앱추천
                    _MenuLeaf(
                      leading: const Icon(Icons.share_outlined),
                      title: '앱 추천',
                      onTap: () => _closeThenPush(
                        context,
                        const ShareAppScreen(),
                      ),
                    ),

                    // 5) 회원탈퇴 (로그인 상태에서만 노출)
                    if (isLoggedIn)
                      _MenuLeaf(
                        leading: const Icon(Icons.delete_outline, color: Colors.red),
                        title: '회원탈퇴',
                        isDestructive: true,
                        onTap: () => _closeThenPush(
                          context,
                          const AccountDeleteScreen(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 드롭다운(ExpansionTile) 메뉴 공통 위젯
class _MenuExpansion extends StatelessWidget {
  final Widget? leading;
  final String title;
  final List<_MenuLeaf> children;

  const _MenuExpansion({
    required this.title,
    required this.children,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      // ExpansionTile의 기본 splash/ink 등을 최소화해서 패널 톤과 맞춤
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: leading,
        title: Text(title, style: const TextStyle(fontSize: 16)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding:
        const EdgeInsets.only(left: 12 + 24, right: 12, bottom: 8),
        children: children
            .map((leaf) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: leaf,
        ))
            .toList(),
      ),
    );
  }
}

/// 단일 항목(leaf) 공통 위젯
class _MenuLeaf extends StatelessWidget {
  final Widget? leading;
  final String title;
  final bool isDestructive; // 빨간 텍스트 등 파괴적 액션 강조
  final VoidCallback onTap;

  const _MenuLeaf({
    required this.title,
    required this.onTap,
    this.leading,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isDestructive ? Colors.red : Colors.black87;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.0), // 필요 시 선택 배경
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              IconTheme(data: IconThemeData(color: fg), child: leading!),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
