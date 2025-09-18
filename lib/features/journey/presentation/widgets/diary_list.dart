import 'package:flutter/material.dart';
import '../../domain/models.dart';

/// 다이어리 리스트 전용 위젯
/// - embedded=true : 부모 스크롤 안에 임베드(상세 화면 등)
/// - embedded=false: 자체 스크롤 ListView(기본)
/// - onEdit/onDelete: 상위에서 액션을 연결(확인 후 삭제 등)
class DiaryList extends StatelessWidget {
  final List<DiaryEntry> entries;
  final bool embedded;
  final EdgeInsets? padding;
  final void Function(DiaryEntry entry)? onEdit;
  final void Function(DiaryEntry entry)? onDelete;

  final void Function(DiaryEntry entry)? onTap;

  const DiaryList({
    super.key,
    required this.entries,
    this.embedded = false,
    this.padding,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text('No diary entries.'));
    }

    return ListView.separated(
      shrinkWrap: embedded,
      physics: embedded
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      padding: padding ?? EdgeInsets.zero,
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => onTap?.call(entries[i]), // ✅ 이제 정상 작동
        child: _DiaryCard(
          entry: entries[i],
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ),
    );
  }
}

/// 다이어리 카드(아바타/제목/메타칩/사진/본문)
class _DiaryCard extends StatelessWidget {
  final DiaryEntry entry;
  final void Function(DiaryEntry entry)? onEdit;
  final void Function(DiaryEntry entry)? onDelete;

  const _DiaryCard({required this.entry, this.onEdit, this.onDelete});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 경고 아이콘
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2), // red-50
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFCA5A5)), // red-300
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFDC2626),
                ), // red-600
              ),
              const SizedBox(height: 12),
              const Text(
                '삭제하시겠어요?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                '"${entry.title}" 다이어리 항목을 삭제하면 되돌릴 수 없어요.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // 취소 (Outlined)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE6E6E6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: const Color(0xFF111827),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 삭제 (Red Filled)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(ctx, true),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        '삭제',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626), // red-600
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                        overlayColor: Colors.white.withOpacity(.06),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      if (onDelete != null) {
        onDelete!(entry);
      } else {
        // 콜백이 없으면 알림만
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Delete confirmed')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0.6,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: cs.surfaceVariant,
                  child: Text(
                    entry.authorInitials,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // ⋯ 점메뉴 → Edit/Delete 리스트
                PopupMenuButton<_DiaryMenu>(
                  tooltip: 'More',
                  offset: const Offset(0, 8),
                  elevation: 0,
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
                  ),
                  constraints: const BoxConstraints(minWidth: 180),
                  icon: const Icon(Icons.more_horiz),
                  itemBuilder: (context) => [
                    PopupMenuItem<_DiaryMenu>(
                      value: _DiaryMenu.edit,
                      padding: EdgeInsets.zero,
                      child: const _MenuTile(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        fg: Color(0xFF111827),
                      ),
                    ),
                    const PopupMenuDivider(height: 6),
                    PopupMenuItem<_DiaryMenu>(
                      value: _DiaryMenu.delete,
                      padding: EdgeInsets.zero,
                      child: const _MenuTile(
                        icon: Icons.delete_outline,
                        label: 'Delete',
                        fg: Color(0xFFDC2626),
                        danger: true,
                      ),
                    ),
                  ],
                  onSelected: (v) {
                    switch (v) {
                      case _DiaryMenu.edit:
                        if (onEdit != null) {
                          onEdit!(entry);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Edit tapped')),
                          );
                        }
                        break;
                      case _DiaryMenu.delete:
                        _confirmDelete(context);
                        break;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 16),
                const SizedBox(width: 6),
                Text(entry.dateLabel),
                const SizedBox(width: 12),
                const Icon(Icons.place, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    entry.location,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const _InfoPill(
                  leading: Text('🥰', style: TextStyle(fontSize: 16)),
                  text: 'Amazed',
                ),
                _InfoPill(
                  leading: const Text('🌤️', style: TextStyle(fontSize: 16)),
                  text: entry.weatherLabel,
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (entry.photos.isNotEmpty) _DiaryPhotos(photos: entry.photos),
            if (entry.photos.isNotEmpty) const SizedBox(height: 16),

            Text(entry.body, style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }
}

enum _DiaryMenu { edit, delete }

/// 팝업 메뉴 아이템 타일 (아이콘+텍스트)
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color fg;
  final bool danger;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.fg,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: danger ? const Color(0xFFFEE2E2) : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
              border: Border.all(
                color: danger
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: fg),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 여러 장의 사진 레이아웃
class _DiaryPhotos extends StatelessWidget {
  const _DiaryPhotos({required this.photos});
  final List<String> photos;

  static const _gap = 12.0;
  static const _radius = 12.0;

  @override
  Widget build(BuildContext context) {
    final count = photos.length;

    if (count == 1) {
      return _RoundedImage(
        url: photos[0],
        radius: _radius,
        aspectRatio: 16 / 9,
      );
    }

    if (count == 2) {
      return Row(
        children: [
          Expanded(
            child: _RoundedImage(
              url: photos[0],
              radius: _radius,
              aspectRatio: 16 / 9,
            ),
          ),
          const SizedBox(width: _gap),
          Expanded(
            child: _RoundedImage(
              url: photos[1],
              radius: _radius,
              aspectRatio: 16 / 9,
            ),
          ),
        ],
      );
    }

    if (count == 3) {
      return SizedBox(
        height: 180,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: _RoundedImage.fill(url: photos[0], radius: _radius),
            ),
            const SizedBox(width: _gap),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(
                    child: _RoundedImage.fill(url: photos[1], radius: _radius),
                  ),
                  const SizedBox(height: _gap),
                  Expanded(
                    child: _RoundedImage.fill(url: photos[2], radius: _radius),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final show = photos.take(4).toList();
    final remain = count - 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: show.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: _gap,
        crossAxisSpacing: _gap,
      ),
      itemBuilder: (_, i) {
        final isLast = i == 3 && remain > 0;
        return _PhotoTile(
          url: show[i],
          radius: _radius,
          overlayText: isLast ? '+$remain' : null,
        );
      },
    );
  }
}

/// 사진 타일(+N 오버레이)
class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.url, required this.radius, this.overlayText});

  final String url;
  final double radius;
  final String? overlayText;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Icon(
                Icons.broken_image_outlined,
                size: 28,
                color: Colors.black26,
              ),
            ),
          ),
          if (overlayText != null)
            Container(
              color: Colors.black45,
              alignment: Alignment.center,
              child: Text(
                overlayText!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 둥근 모서리 네트워크 이미지
class _RoundedImage extends StatelessWidget {
  const _RoundedImage({
    required this.url,
    required this.radius,
    required this.aspectRatio,
  }) : fill = false;

  const _RoundedImage.fill({required this.url, required this.radius})
    : aspectRatio = 1,
      fill = true;

  final String? url;
  final double radius;
  final double aspectRatio;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final img = Image.network(
      url ?? _placeholder,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_outlined,
          size: 28,
          color: Colors.black26,
        ),
      ),
    );

    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: img,
    );

    return fill
        ? clipped
        : AspectRatio(aspectRatio: aspectRatio, child: clipped);
  }
}

const _placeholder =
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1200&auto=format&fit=crop';

/// 감정/날씨 칩
class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.leading, required this.text});

  final Widget leading;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE6E6E6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
