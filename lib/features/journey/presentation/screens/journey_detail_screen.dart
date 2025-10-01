// 📁 journey_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/features/journey/presentation/screens/diary_detail_screen.dart';
import 'package:heat_trip_flutter/features/journey/presentation/screens/diary_edit_screen.dart';
import 'package:heat_trip_flutter/features/journey/presentation/widgets/diary_list.dart';

import '../../domain/models.dart';
import '../../data/journey_api.dart';

class JourneyDetailScreen extends StatefulWidget {
  const JourneyDetailScreen({super.key, required this.id, this.initial});

  final int id;
  final Schedule? initial;

  @override
  State<JourneyDetailScreen> createState() => _JourneyDetailScreenState();
}

class _JourneyDetailScreenState extends State<JourneyDetailScreen> {
  final JourneyApi _api = RealJourneyApi();
  List<DiaryEntry>? _entries;
  Schedule? _data;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _data = widget.initial;
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = _data == null);
    try {
      final fresh = await _api.fetchScheduleById(widget.id);
      final diaries = await _api.fetchDiariesBySchedule(widget.id);
      if (!mounted) return;
      setState(() {
        _data = fresh ?? _data;
        _entries = diaries;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleEdit(DiaryEntry entry) async {
    final updatedEntry = await Navigator.push<DiaryEntry>(
      context,
      MaterialPageRoute(builder: (_) => DiaryEditScreen(entry: entry)),
    );
    if (updatedEntry != null) {
      await _fetch();
    }
  }

  Future<void> _handleDelete(DiaryEntry entry) async {
    try {
      await _api.deleteDiary(entry.id!);
      await _fetch();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('다이어리를 삭제했어요.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedule = _data;
    if (schedule == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hero =
        schedule.heroImageUrl ??
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1600&auto=format&fit=crop';

    final photosCount = schedule.memoriesCount;
    final journeyCount = _entries?.length ?? 0;
    final int? tripDays = (schedule.dateFrom != null && schedule.dateTo != null)
        ? schedule.dateTo!.difference(schedule.dateFrom!).inDays + 1
        : null;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schedule.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              'Journey details & memories',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 8.4,
                  child: Image.network(
                    hero,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF3F3F3),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        size: 28,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            schedule.location ?? '—',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            _formatRange(schedule.dateFrom, schedule.dateTo),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tags',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 4,
                        runSpacing: 8,
                        children: [
                          for (final t in schedule.tags.take(3))
                            _TagPill(text: t),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _StatMini(
                              icon: Icons.photo_camera_outlined,
                              iconColor: const Color(0xFF4E7CFF),
                              value: '$photosCount',
                              label: 'Photos',
                            ),
                          ),
                          Expanded(
                            child: _StatMini(
                              icon: Icons.menu_book_outlined,
                              iconColor: const Color(0xFF8B5CF6),
                              value: '$journeyCount',
                              label: 'Diary Entries',
                            ),
                          ),
                          Expanded(
                            child: _StatMini(
                              icon: Icons.place_outlined,
                              iconColor: const Color(0xFF2ECC71),
                              value: tripDays?.toString() ?? '—',
                              label: 'Days',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    context.pushNamed(
                      'newDiaryForSchedule',
                      pathParameters: {'id': widget.id.toString()},
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Diary Entry'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF191C21),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    overlayColor: Colors.white.withOpacity(.06),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              if (_entries == null)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Diary Entries',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F2F5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$journeyCount entries',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_entries!.isEmpty)
                      _EmptyDiaryCard(title: schedule.title)
                    else
                      DiaryList(
                        entries: _entries!,
                        embedded: true,
                        padding: EdgeInsets.zero,
                        onTap: (entry) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DiaryDetailScreen(entry: entry),
                            ),
                          );
                        },
                        onEdit: _handleEdit,
                        onDelete: _handleDelete,
                      ),
                  ],
                ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRange(DateTime? from, DateTime? to) {
    String f(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    if (from == null && to == null) return 'Dates TBA';
    if (from != null && to == null) return f(from);
    if (from == null && to != null) return f(to);
    return '${f(from!)} ~ ${f(to!)}';
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4B5563),
        ),
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  const _StatMini({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: subtle)),
      ],
    );
  }
}

class _EmptyDiaryCard extends StatelessWidget {
  const _EmptyDiaryCard({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        children: [
          Icon(Icons.draw_outlined, size: 46, color: subtle),
          const SizedBox(height: 14),
          const Text(
            'No diary entries yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Start documenting your $title memories!',
            style: TextStyle(fontSize: 13, color: subtle),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            'Tap the "New Diary Entry" button above to get started',
            style: TextStyle(fontSize: 12, color: subtle),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
