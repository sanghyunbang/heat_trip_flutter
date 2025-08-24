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
                child: Text(entry.location, overflow: TextOverflow.ellipsis, style: TextStyle(color: cs.onSurfaceVariant)),
              ),
            ]),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InputChip(
                  label: Row(mainAxisSize: MainAxisSize.min, children: const [
                    Text('😊'),
                    SizedBox(width: 6),
                    Text('Amazed'),
                  ]),
                  onPressed: () {},
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                InputChip(
                  label: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.wb_cloudy_rounded, size: 18),
                    const SizedBox(width: 6),
                    Text(entry.weatherLabel),
                  ]),
                  onPressed: () {},
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (entry.photos.isNotEmpty) _DiaryPhotoRow(photos: entry.photos),
            if (entry.photos.isNotEmpty) const SizedBox(height: 16),
            Text(entry.body, style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }
}

/// 사진 2장 행
class _DiaryPhotoRow extends StatelessWidget {
  final List<String> photos;
  const _DiaryPhotoRow({required this.photos});

  @override
  Widget build(BuildContext context) {
    final p0 = photos[0];
    final p1 = photos.length > 1 ? photos[1] : null;

    return Row(
      children: [
        Expanded(child: _RoundedImage(url: p0)),
        const SizedBox(width: 12),
        Expanded(child: _RoundedImage(url: p1)),
      ],
    );
  }
}

/// 둥근 모서리 네트워크 이미지
class _RoundedImage extends StatelessWidget {
  final String? url;
  const _RoundedImage({required this.url});

  @override
  Widget build(BuildContext context) {
    const placeholder =
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1200&auto=format&fit=crop';
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(url ?? placeholder, fit: BoxFit.cover),
      ),
    );
  }
}
