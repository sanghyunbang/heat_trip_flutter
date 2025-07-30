import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleCreateScreen extends StatefulWidget {
  const ScheduleCreateScreen({super.key});

  @override
  State<ScheduleCreateScreen> createState() => _ScheduleCreateScreenState();
}

class _ScheduleCreateScreenState extends State<ScheduleCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedLocation;
  DateTimeRange? _selectedRange;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _locations = ['평택', '파주', '안산', '양주', '이천'];
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  final List<Map<String, String>> _places = [];

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedRange,
      helpText: '기간을 선택하세요',
      saveText: '선택 완료',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.pinkAccent,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.pink),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedRange = picked;
      });
    }
  }

  void _showAddPlaceDialog() {
    String? selected;
    final memoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('여행지 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '여행지 선택'),
              items: _locations.map((location) {
                return DropdownMenuItem<String>(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) {
                selected = value;
              },
              validator: (value) =>
                  value == null ? '여행지를 선택해주세요.' : null,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: memoController,
              decoration: const InputDecoration(
                labelText: '메모 (선택 사항)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selected != null) {
                setState(() {
                  _places.add({
                    'location': selected!,
                    'memo': memoController.text.trim(),
                  });
                });
                Navigator.pop(context);
              } else {
                // 선택 안 했을 때 처리 가능
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _selectedRange != null &&
        _selectedLocation != null) {
      final snackBar = SnackBar(
        content: Text(
          '저장됨: ${_selectedLocation!}, ${_dateFormat.format(_selectedRange!.start)} ~ ${_dateFormat.format(_selectedRange!.end)}, ${_titleController.text}, 여행지 ${_places.length}개',
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      // TODO: 서버 전송 가능

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 항목을 입력해주세요.')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildSectionCard({required Widget child}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('스케쥴 작성')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionCard(
                child: DropdownButtonFormField<String>(
                  value: _selectedLocation,
                  decoration: const InputDecoration(
                    labelText: '지역 선택',
                    border: OutlineInputBorder(),
                  ),
                  items: _locations.map((location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLocation = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? '지역을 선택해주세요.' : null,
                ),
              ),

              _buildSectionCard(
                child: GestureDetector(
                  onTap: _pickDateRange,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: '기간 선택',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: _selectedRange != null
                            ? '${_dateFormat.format(_selectedRange!.start)} ~ ${_dateFormat.format(_selectedRange!.end)}'
                            : '',
                      ),
                      validator: (_) =>
                          _selectedRange == null ? '기간을 선택해주세요.' : null,
                    ),
                  ),
                ),
              ),

              _buildSectionCard(
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '여행 이름',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? '제목을 입력해주세요.' : null,
                ),
              ),

              // 여행지 추가 영역 카드
              // 여행지 추가 버튼 + 여행지 리스트 영역 (Card 없이 심플하게)
Padding(
  padding: const EdgeInsets.symmetric(vertical: 12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color.fromARGB(255, 255, 141, 179),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 18),
        ),
        onPressed: _showAddPlaceDialog,
        icon: const Icon(Icons.add, size: 24),
        label: const Text('여행지 추가'),
      ),
      const SizedBox(height: 16),

      if (_places.isEmpty)
        Center(
          child: Text(
            '여행지를 추가해주세요.',
            style: TextStyle(
              color: Colors.pink[300],
              fontStyle: FontStyle.italic,
              fontSize: 16,
            ),
          ),
        ),

      if (_places.isNotEmpty)
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _places.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final place = _places[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                place['location'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: (place['memo'] != null && place['memo']!.isNotEmpty)
                  ? Text(place['memo']!)
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _places.removeAt(index);
                  });
                },
              ),
            );
          },
        ),
    ],
  ),
),


              _buildSectionCard(
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: '내용',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) =>
                      value == null || value.isEmpty ? '내용을 입력해주세요.' : null,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('저장하기'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: _submitForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
