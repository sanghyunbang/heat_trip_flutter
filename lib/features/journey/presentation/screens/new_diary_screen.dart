// lib/features/journey/presentation/screens/new_diary_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:heat_trip_flutter/shared/media/media.dart'; // MediaGridField, UploadCategory
import '../../domain/models.dart';
import '../../state/journey_state.dart';

class NewDiaryScreen extends StatefulWidget {
  const NewDiaryScreen({super.key, this.scheduleId, this.initial});

  /// 스케줄에서 바로 쓰기
  final int? scheduleId;

  /// 수정 모드일 때 전달 (null이면 생성 모드)
  final DiaryEntry? initial;

  @override
  State<NewDiaryScreen> createState() => _NewDiaryScreenState();
}

class _NewDiaryScreenState extends State<NewDiaryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _weather;
  late final TextEditingController _body;
  late DateTime _date;

  final _moods = const [
    ('😊','기쁨'),
    ('😢','슬픔'),
    ('😰','불안'),
    ('😡','분노'),
    ('😌','평온'),
    ('✨','설렘'),
  ];
  int _moodIndex = 0;

  /// 업로드/기존 사진 URL
  late List<String> _photos;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;

    _title = TextEditingController(text: init?.title ?? '');
    _location = TextEditingController(text: init?.location ?? '');
    _weather = TextEditingController(text: init?.weatherLabel ?? '');
    _body = TextEditingController(text: init?.body ?? '');
    _date = init?.date ?? DateTime.now();

    _photos = List<String>.from(init?.photos ?? const []);
    if (init != null) {
      final idx = _moods.indexWhere((m) => m.$2 == init.moodLabel);
      _moodIndex = idx >= 0 ? idx : 0;
    }
  }

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
      helpText: 'Select date',
      confirmText: 'Save',
      cancelText: 'Cancel',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final moodLabel = _moods[_moodIndex].$2;

    final entry = DiaryEntry(
      id: widget.initial?.id, // 수정 모드면 id 유지
      scheduleId: widget.scheduleId ?? widget.initial?.scheduleId,
      authorInitials: widget.initial?.authorInitials ?? 'ME',
      title: _title.text.trim(),
      date: _date,
      location: _location.text.trim().isEmpty ? '—' : _location.text.trim(),
      moodLabel: moodLabel,
      weatherLabel: _weather.text.trim().isEmpty ? '—' : _weather.text.trim(),
      photos: List<String>.from(_photos),
      body: _body.text.trim(),
    );

    final state = context.read<JourneyState>();

    // ✅ 수정/생성 분기 — 둘 다 String? error 패턴
    String? error;
    if (_isEdit) {
      error = await state.updateDiary(entry);
    } else {
      error = await state.createDiary(entry);
    }

    if (error != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $error')),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Diary saved')));
    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(_isEdit ? '다이어리 수정' : '다이어리 쓰기'),
        actions: [TextButton(onPressed: _submit, child: const Text('Save'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.scheduleId != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F2F5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Schedule #${widget.scheduleId}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              if (widget.scheduleId != null) const SizedBox(height: 12),

              // ───────────────── Basic ─────────────────
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
                          hintText: '예) 00여행기',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
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
                          hintText: '예) 00해변',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ─────────────── Mood & Weather ───────────────
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
                                Text(_moods[i].$1,
                                    style: const TextStyle(fontSize: 16)),
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
                          hintText: '예) 맑음, 22도',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ───────────────── Photos ─────────────────
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Photos'),
                    const SizedBox(height: 8),

                    // 업로드 UI (정의된 시그니처만 사용)
                    MediaGridField(
                      category: UploadCategory.JOURNEY_IMAGE,
                      onUploaded: (items) {
                        setState(() {
                          _photos.addAll(items.map((e) => e.url));
                        });
                      },
                    ),

                    // 기존/업로드된 사진 미리보기 + 삭제
                    if (_photos.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _photos.map((url) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  url,
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 96,
                                    height: 96,
                                    color: const Color(0xFFF3F3F3),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -6,
                                top: -6,
                                child: InkWell(
                                  onTap: () => setState(() {
                                    _photos.remove(url);
                                  }),
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ───────────────── Story ─────────────────
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
                        hintText: '일기를 작성해 보세요...',
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
                  label: Text(
                    _isEdit ? 'Update Diary' : 'Save Diary',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B0B14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800));
  }
}

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

class NewDiaryForScheduleRoute extends StatelessWidget {
  const NewDiaryForScheduleRoute({super.key, required this.state});
  final GoRouterState state;
  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
    return NewDiaryScreen(scheduleId: id);
  }
}
