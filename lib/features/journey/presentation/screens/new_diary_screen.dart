import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/features/journey/data/journey_repository_impl.dart';
import '../../domain/models.dart';

class NewDiaryScreen extends StatefulWidget {
  const NewDiaryScreen({super.key, this.scheduleId});

  /// 스케줄 연동이면 값 존재, Diary 탭에서 진입 시 null
  final int? scheduleId;

  @override
  State<NewDiaryScreen> createState() => _NewDiaryScreenState();
}

class _NewDiaryScreenState extends State<NewDiaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _weather = TextEditingController();
  final _body = TextEditingController();
  DateTime _date = DateTime.now();

  final _moods = const [
    ('😀', 'Happy'),
    ('😊', 'Delighted'),
    ('😌', 'Calm'),
    ('😮', 'Amazed'),
    ('😢', 'Sad'),
    ('😡', 'Angry'),
  ];
  int _moodIndex = 0;
  final List<String> _photos = [];

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _weather.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDate: _date,
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _addPhotoUrlDialog() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add photo by URL'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final url = ctrl.text.trim();
              if (url.isNotEmpty) setState(() => _photos.add(url));
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removePhoto(int idx) => setState(() => _photos.removeAt(idx));

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final moodLabel = _moods[_moodIndex].$2;

    final entry = DiaryEntry(
      scheduleId: widget.scheduleId,
      authorInitials: 'ME',
      title: _title.text.trim(),
      date: _date,
      location: _location.text.trim().isEmpty ? '—' : _location.text.trim(),
      moodLabel: moodLabel,
      weatherLabel: _weather.text.trim().isEmpty ? '—' : _weather.text.trim(),
      photos: List<String>.from(_photos),
      body: _body.text.trim(),
    );

    final repo = JourneyRepositoryImpl(); // ✨ Repository 인스턴스 생성
    final error = await repo.postDiary(entry); // ✨ 서버 전송

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $error')));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Diary saved')));
    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('New Diary Entry'),
        actions: [TextButton(onPressed: _submit, child: const Text('Save'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ✅ 스케줄 연동 배지는 scheduleId 있을 때만 노출
              if (widget.scheduleId != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F2F5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Schedule #${widget.scheduleId}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (widget.scheduleId != null) const SizedBox(height: 12),

              // --- 이하 UI는 이전과 동일 (생략 없이 전체) ---
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Basic'),
                    const SizedBox(height: 8),
                    _Labeled(
                      label: 'Title',
                      child: TextFormField(
                        controller: _title,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Magical Morning at Tsukiji',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Title is required'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Labeled(
                      label: 'Date',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Labeled(
                      label: 'Location',
                      child: TextField(
                        controller: _location,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Tsukiji, Tokyo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Mood & Weather'),
                    const SizedBox(height: 8),
                    Text('Mood', style: TextStyle(fontSize: 12, color: subtle)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 0; i < _moods.length; i++)
                          ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _moods[i].$1,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Text(_moods[i].$2),
                              ],
                            ),
                            selected: _moodIndex == i,
                            onSelected: (_) => setState(() => _moodIndex = i),
                            selectedColor: const Color(0xFFEBE2CD),
                            labelStyle: TextStyle(
                              color: _moodIndex == i
                                  ? const Color(0xFF353535)
                                  : null,
                              fontWeight: FontWeight.w600,
                            ),
                            side: const BorderSide(color: Color(0xFFE6E6E6)),
                            backgroundColor: const Color(0xFFF6F6F6),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _Labeled(
                      label: 'Weather',
                      child: TextField(
                        controller: _weather,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Partly cloudy, 12°C',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Photos'),
                    const SizedBox(height: 8),
                    if (_photos.isEmpty)
                      Text(
                        'No photos yet. Add by URL.',
                        style: TextStyle(color: subtle),
                      ),
                    if (_photos.isNotEmpty)
                      _PhotoGrid(urls: _photos, onRemove: _removePhoto),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: _addPhotoUrlDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add URL'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Story'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _body,
                      minLines: 6,
                      maxLines: 12,
                      decoration: const InputDecoration(
                        hintText: 'Write your story...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please write something'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    'Save Diary',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B0B14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 라벨 + 위젯 묶음
class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: subtle)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/// 섹션 타이틀
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    );
  }
}

/// 흰색 카드 컨테이너
class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8E8E8)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: child,
    );
  }
}

/// URL 썸네일 그리드
class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.urls, required this.onRemove});
  final List<String> urls;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: urls.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (_, i) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  urls[i],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.black26,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 4,
              top: 4,
              child: InkWell(
                onTap: () => onRemove(i),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 라우트 편의용: pathParameters에서 id 읽어와 NewDiaryScreen 생성
class NewDiaryForScheduleRoute extends StatelessWidget {
  const NewDiaryForScheduleRoute({super.key, required this.state});
  final GoRouterState state;
  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
    return NewDiaryScreen(scheduleId: id);
  }
}
