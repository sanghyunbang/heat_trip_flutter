import 'package:flutter/material.dart';

/// 우측에서 슬라이드 인되는 사이드 메뉴 패널
/// - showGeneralDialog의 child로 사용
class RightSideMenuPanel extends StatelessWidget {
  final VoidCallback onClose;

  const RightSideMenuPanel({super.key, required this.onClose});

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
              // 헤더(타이틀 + X 버튼)
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

              // 메뉴 리스트(예시)
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: 9,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, i) {
                    final selected = i == 5; // 예시 강조
                    return InkWell(
                      onTap: onClose, // 탭하면 닫기
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
                        child: const Text('Menu item', style: TextStyle(fontSize: 16)),
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
