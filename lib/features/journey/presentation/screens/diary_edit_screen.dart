import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/journey/data/journey_api.dart';
import '../../domain/models.dart';

class DiaryEditScreen extends StatefulWidget {
  final DiaryEntry entry;

  const DiaryEditScreen({super.key, required this.entry});

  @override
  State<DiaryEditScreen> createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends State<DiaryEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late TextEditingController _locationController;
  late TextEditingController _weatherController;

  final _moods = const [
    ('😀', 'Happy'),
    ('😊', 'Delighted'),
    ('😌', 'Calm'),
    ('😮', 'Amazed'),
    ('😢', 'Sad'),
    ('😡', 'Angry'),
  ];
  int _moodIndex = 0;

  late DateTime _selectedDate;

  // ✅ 실제 API 인스턴스
  final JourneyApi _journeyApi = RealJourneyApi();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _bodyController = TextEditingController(text: widget.entry.body);
    _locationController = TextEditingController(text: widget.entry.location);
    _weatherController = TextEditingController(text: widget.entry.weatherLabel);
    _selectedDate = widget.entry.date;

    final moodLabel = widget.entry.moodLabel;
    final index = _moods.indexWhere((m) => m.$2 == moodLabel);
    _moodIndex = index != -1 ? index : 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _locationController.dispose();
    _weatherController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updatedEntry = widget.entry.copyWith(
      title: _titleController.text,
      body: _bodyController.text,
      location: _locationController.text,
      moodLabel: _moods[_moodIndex].$2,
      weatherLabel: _weatherController.text,
      date: _selectedDate,
    );

    try {
      final result = await _journeyApi.updateDiary(updatedEntry); // ✅ 서버에 수정 요청
      if (!mounted) return;
      Navigator.pop(context, result); // 수정된 객체 반환
    } catch (e) {
      print('❌ Failed to update diary: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update diary')));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Diary'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 제목
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),

          // 날짜 선택
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
          const Divider(),

          // 감정 선택
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
                      Text(_moods[i].$1, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(_moods[i].$2),
                    ],
                  ),
                  selected: _moodIndex == i,
                  onSelected: (_) => setState(() => _moodIndex = i),
                  selectedColor: const Color(0xFFEBE2CD),
                  labelStyle: TextStyle(
                    color: _moodIndex == i ? const Color(0xFF353535) : null,
                    fontWeight: FontWeight.w600,
                  ),
                  side: const BorderSide(color: Color(0xFFE6E6E6)),
                  backgroundColor: const Color(0xFFF6F6F6),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // 날씨 입력
          TextField(
            controller: _weatherController,
            decoration: const InputDecoration(
              labelText: 'Weather',
              hintText: 'e.g. Sunny, 25°C',
            ),
          ),
          const SizedBox(height: 12),

          // 장소
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Location'),
          ),
          const SizedBox(height: 16),

          // 본문
          TextField(
            controller: _bodyController,
            decoration: const InputDecoration(labelText: 'Diary Content'),
            maxLines: 8,
          ),
        ],
      ),
    );
  }
}
