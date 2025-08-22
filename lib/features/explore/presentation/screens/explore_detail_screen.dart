import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/explore/data/models/place_item_dto.dart';

class ExploreDetailScreen extends StatefulWidget {
  final PlaceItem data;
  const ExploreDetailScreen({super.key, required this.data});

  @override
  State<ExploreDetailScreen> createState() => _ExploreDetailScreenState();
}

class _ExploreDetailScreenState extends State<ExploreDetailScreen> {
  int _qty = 1;
  int _colorIndex = 0;

  // 데모용 가격/설명 (실데이터에 맞춰 갈아끼우세요)
  String get price => '\$140.-';
  final String lorem =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      // 상단은 투명 AppBar 느낌으로 back 버튼만
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ---------- 상단: 큰 이미지 + 오버레이 ----------
            Stack(
              children: [
                // 이미지
                AspectRatio(
                  aspectRatio: 1.05, // 스샷과 비슷한 비율
                  child: Hero(
                    tag: 'place:${widget.data.contentid}',
                    child: Image.network(
                      widget.data.firstimage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/placeholder.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // 좌상단 뒤로가기
                Positioned(
                  left: 8,
                  top: 8,
                  child: Material(
                    color: Colors.black.withOpacity(0.05),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.black87,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // 우하단 북마크 배지
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Material(
                    elevation: 2,
                    color: cs.primary.withOpacity(0.9),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('북마크에 저장완료! (mock)'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(Icons.bookmark_border, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ---------- 본문 카드 ----------
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x15000000),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 타이틀(관광지명)/서브타이틀(주소)/가격
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.data.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Night Stands', // 데모 서브타이틀
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.55),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  price,
                                  style: TextStyle(
                                    color: cs.primary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 설명
                      Text(
                        lorem,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.65),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 수량 / 색상
                      // Row(
                      //   children: [
                      //     // 수량
                      //     Expanded(
                      //       child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           const Text('Quantity',
                      //               style: TextStyle(
                      //                   fontWeight: FontWeight.w700)),
                      //           const SizedBox(height: 8),
                      //           _QtyStepper(
                      //             qty: _qty,
                      //             onChanged: (v) => setState(() => _qty = v),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //     const SizedBox(width: 16),
                      //     // 색상
                      //     Expanded(
                      //       child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           const Text('Colors',
                      //               style: TextStyle(
                      //                   fontWeight: FontWeight.w700)),
                      //           const SizedBox(height: 8),
                      //           _ColorDots(
                      //             selected: _colorIndex,
                      //             onChanged: (i) =>
                      //                 setState(() => _colorIndex = i),
                      //             colors: const [
                      //               Color(0xFFE9EEF6), // 연하늘
                      //               Color(0xFFC8E6C9), // 연초록
                      //               Color(0xFFF8E1E7), // 연핑크
                      //               Colors.black,
                      //               Colors.white,
                      //             ],
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 28),

                      // 바닥 그림자 느낌의 디바이더
                      Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 60),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(2),
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

/// 수량 스테퍼( + / 수량 / - )
class _QtyStepper extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;
  const _QtyStepper({required this.qty, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SquareIconBtn(
          icon: Icons.remove,
          onTap: () {
            if (qty > 1) onChanged(qty - 1);
          },
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 56,
          height: 36,
          child: TextFormField(
            key: ValueKey(qty),
            initialValue: qty.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              enabledBorder: border,
              focusedBorder: border,
            ),
            readOnly: true, // 데모에선 직접 입력 막음
          ),
        ),
        const SizedBox(width: 8),
        _SquareIconBtn(icon: Icons.add, onTap: () => onChanged(qty + 1)),
      ],
    );
  }
}

class _SquareIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SquareIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(width: 36, height: 36, child: Icon(icon, size: 18)),
      ),
    );
  }
}

/// 색상 점 선택 위젯
class _ColorDots extends StatelessWidget {
  final List<Color> colors;
  final int selected;
  final ValueChanged<int> onChanged;
  const _ColorDots({
    required this.colors,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: List.generate(colors.length, (i) {
        final c = colors[i];
        final isSel = i == selected;
        return GestureDetector(
          onTap: () => onChanged(i),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c,
              border: Border.all(
                color: isSel
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black12,
                width: isSel ? 2 : 1,
              ),
            ),
          ),
        );
      }),
    );
  }
}
