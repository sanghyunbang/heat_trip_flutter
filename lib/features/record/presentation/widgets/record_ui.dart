import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/shared/presentation/widgets/headers.dart';

/// ====== Tokens ======
const kBg = Colors.white;
const kSurface = Colors.white;
const kCard = Colors.white;
const kTextMain = Color(0xFF111827);
const kTextMuted = Color(0xFF6B7280);
const kBorder = Color(0xFFE5E7EB);
const kAccentDark = Color(0xFF0B0B14);
const kSuccessBg = Color(0xFFE8FFF1);
const kSuccessText = Color(0xFF0E9F6E);
const kPendingBg = Color(0xFFFFF6EC);
const kPendingText = Color(0xFFEB9C64);
const kRadius = 16.0;

/// ========== 공용 페이지 컨테이너 ==========
class WhitePage extends StatelessWidget {
  final Widget child;
  const WhitePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final textScale = media.textScaleFactor.clamp(1.0, 1.2);

    return MediaQuery(
      data: media.copyWith(textScaleFactor: textScale),
      child: Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(
          backgroundColor: kBg,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 0, // 상단을 여백 없이
        ),
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// ========== 헤더 ==========
/// - SectionHeader(공통) 래핑
class RecordHeader extends StatelessWidget {
  final VoidCallback onAdd;
  final ValueChanged<String> onSearchChanged;
  const RecordHeader({
    super.key,
    required this.onAdd,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      title: 'Record',
      subtitle: 'Schedule & plan your trips',
      actionLabel: 'Add Item',
      actionIcon: Icons.add,
      onAction: onAdd,
      searchHint: 'Search schedule…',
      onSearchChanged: onSearchChanged,
    );
  }
}

/// ========== 풀-폭 세그먼트 바 ==========
enum ViewTab { schedule, calendar }

class WideSegmentBar extends StatelessWidget {
  final ViewTab value;
  final ValueChanged<ViewTab> onChanged;
  const WideSegmentBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final w = c.maxWidth;
        final half = w / 2;
        return Container(
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                left: value == ViewTab.schedule ? 4 : half - 4,
                top: 4,
                child: Container(
                  width: half - 8,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kBorder),
                  ),
                ),
              ),
              Row(
                children: [
                  _segBtn(
                    half,
                    'Schedule',
                    value == ViewTab.schedule,
                    () => onChanged(ViewTab.schedule),
                  ),
                  _segBtn(
                    half,
                    'Calendar',
                    value == ViewTab.calendar,
                    () => onChanged(ViewTab.calendar),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _segBtn(double width, String text, bool selected, VoidCallback onTap) {
    return SizedBox(
      width: width,
      height: 44,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

/// ========== 카드/칩 ==========
class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});
  @override
  Widget build(BuildContext context) {
    final ok = status.toLowerCase() == 'confirmed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ok ? kSuccessBg : kPendingBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: ok ? kSuccessText : kPendingText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ScheduleListCard extends StatelessWidget {
  final Widget leadingIcon;
  final String title;
  final String subtitle;
  final String? description;
  final Widget? trailing;
  final VoidCallback? onTap;
  const ScheduleListCard({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    this.description,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kCard,
      borderRadius: BorderRadius.circular(kRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kRadius),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadius),
            border: Border.all(color: kBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leadingIcon,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (trailing != null) trailing!,
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(color: kTextMuted, fontSize: 13),
                    ),
                    if (description != null &&
                        description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        description!,
                        style: const TextStyle(fontSize: 13, color: kTextMain),
                      ),
                    ],
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

Widget circleEmojiIcon(Color bg, String emoji) {
  return Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
    alignment: Alignment.center,
    child: Text(emoji, style: const TextStyle(fontSize: 18)),
  );
}
