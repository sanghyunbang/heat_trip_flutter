import 'package:flutter/material.dart';
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

  late String _selectedMood;
  late String _selectedWeather;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _bodyController = TextEditingController(text: widget.entry.body);
    _locationController = TextEditingController(text: widget.entry.location);
    _selectedMood = widget.entry.moodLabel;
    _selectedWeather = widget.entry.weatherLabel;
    _selectedDate = widget.entry.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _save() {
    final updatedEntry = widget.entry.copyWith(
      title: _titleController.text,
      body: _bodyController.text,
      location: _locationController.text,
      moodLabel: _selectedMood,
      weatherLabel: _selectedWeather,
      date: _selectedDate,
    );
    Navigator.pop(context, updatedEntry);
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
          DropdownButtonFormField<String>(
            value: _selectedMood,
            decoration: const InputDecoration(labelText: 'Mood'),
            items: ['Happy', 'Sad', 'Excited', 'Tired']
                .map((mood) => DropdownMenuItem(value: mood, child: Text(mood)))
                .toList(),
            onChanged: (value) => setState(() => _selectedMood = value ?? ''),
          ),
          const SizedBox(height: 12),

          // 날씨 선택
          DropdownButtonFormField<String>(
            value: _selectedWeather,
            decoration: const InputDecoration(labelText: 'Weather'),
            items: ['Sunny', 'Cloudy', 'Rainy', 'Snowy']
                .map(
                  (weather) =>
                      DropdownMenuItem(value: weather, child: Text(weather)),
                )
                .toList(),
            onChanged: (value) =>
                setState(() => _selectedWeather = value ?? ''),
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
