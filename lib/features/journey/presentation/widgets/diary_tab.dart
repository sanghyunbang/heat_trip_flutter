import 'package:flutter/material.dart';
import '../../domain/models.dart';

/// Diary 탭 컨테이너: 상단 버튼 + 리스트
class DiaryTab extends StatelessWidget {
  final List<DiaryEntry> entries;
  const DiaryTab({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _NewDiaryButton(),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) => _DiaryCard(entry: entries[i]),
          ),
        ),
      ],
    );
  }
}

/// "+ New Diary Entry" 버튼(검정색, 전체폭)
class _NewDiaryButton extends StatelessWidget {
  const _NewDiaryButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {}, // TODO: 작성 화면 이동
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Diary Entry'),
      ),
    );
  }
}

/// 다이어리 카드(아바타/제목/메타칩/사진/본문)
class _DiaryCard extends StatelessWidget {
  final DiaryEntry entry;
  const _DiaryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0.6,
      color: Colors.white, // 카드 배경 흰색
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: cs.surfaceVariant,
                child: Text(entry.authorInitials, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(entry.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis),
              ),
              IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
            ]),
            const SizedBox(height: 8),
            Row(children: [
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
            ]),
            const SizedBox(height: 10),
            // 기존 Wrap(...) ↔ 아래로 교체
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoPill(
                  leading: const Text('🥰', style: TextStyle(fontSize: 16)),
                  text: 'Amazed',
                ),
                _InfoPill(
                  // 아이콘 대신 이모지로 톤 맞춤 (원하면 Icon으로 변경 가능)
                  leading: const Text('🌤️', style: TextStyle(fontSize: 16)),
                  text: entry.weatherLabel, // 예: "Partly cloudy, 12°C"
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ 사진 처리: 0/1/2/3/4+ 장 모두 예쁘게
            if (entry.photos.isNotEmpty) _DiaryPhotos(photos: entry.photos),

            if (entry.photos.isNotEmpty) const SizedBox(height: 16),
            Text(entry.body, style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }
}

/// ✅ 여러 장의 사진 레이아웃 처리 위젯
/// - 1장: 가로 16:9 한 장 크게
/// - 2장: 좌우 2등분
/// - 3장: 좌(큰 이미지) + 우(2장 세로 스택) 모자이크
/// - 4장 이상: 2x2 그리드(마지막 칸에 +N 오버레이)
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
          Expanded(child: _RoundedImage(url: photos[0], radius: _radius, aspectRatio: 16 / 9)),
          const SizedBox(width: _gap),
          Expanded(child: _RoundedImage(url: photos[1], radius: _radius, aspectRatio: 16 / 9)),
        ],
      );
    }

    if (count == 3) {
      // 모자이크(고정 높이) : 좌측 큰 이미지 + 우측 2개 세로 스택
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
                  Expanded(child: _RoundedImage.fill(url: photos[1], radius: _radius)),
                  const SizedBox(height: _gap),
                  Expanded(child: _RoundedImage.fill(url: photos[2], radius: _radius)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 4장 이상: 2x2 그리드 (마지막 타일에 +N)
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

/// 사진 타일(+N 오버레이 지원)
class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.url,
    required this.radius,
    this.overlayText,
  });

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
            // 네트워크 오류 대비
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_outlined, size: 28, color: Colors.black26),
            ),
          ),
          if (overlayText != null)
            Container(
              color: Colors.black45,
              alignment: Alignment.center,
              child: Text(
                overlayText!,
                style: const TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 둥근 모서리 네트워크 이미지(단일/행용)
class _RoundedImage extends StatelessWidget {
  const _RoundedImage({
    required this.url,
    required this.radius,
    required this.aspectRatio,
  }) : fill = false;

  const _RoundedImage.fill({
    required this.url,
    required this.radius,
  })  : aspectRatio = 1,
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
        child: const Icon(Icons.broken_image_outlined, size: 28, color: Colors.black26),
      ),
    );

    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: img,
    );

    // fill 모드는 부모의 높이에 맞춰 확장(모자이크 좌/우)
    if (fill) return clipped;

    // 일반 모드는 16:9 등 비율 유지
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: clipped,
    );
  }
}
const _placeholder =
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1200&auto=format&fit=crop';

/// 감정 및 날씨 칩 디자인
class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.leading,
    required this.text,
  });

  final Widget leading;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFF6F6F6),                           // 연한 회색 배경
        borderRadius: BorderRadius.circular(999),           // 완전 둥근 모서리
        border: Border.all(color: const Color(0xFFE6E6E6)), // 아주 옅은 테두리
        boxShadow: [
          // 아주 미세한 그림자로 떠 보이게 (이미지 느낌)
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
              fontSize: 13,                 // 이미지와 비슷한 크기
              fontWeight: FontWeight.w600,  // 살짝 두께
              color: Color(0xFF4B5563),     // 적당한 회색 톤
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
