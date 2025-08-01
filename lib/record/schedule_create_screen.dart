import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleCreateScreen extends StatefulWidget {
  const ScheduleCreateScreen({super.key});

  @override
  State<ScheduleCreateScreen> createState() => _ScheduleCreateScreenState();
}

class _ScheduleCreateScreenState extends State<ScheduleCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _locations = ['평택', '파주', '안산', '양주', '이천'];
  final List<String> _purposes = ['a1', 'a2', 'a3'];
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  String? _selectedLocation;
  String? _selectedPurpose;
  DateTimeRange? _selectedRange;
  final List<Map<String, String>> _places = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedRange,
    );
    if (picked != null) {
      setState(() => _selectedRange = picked);
    }
  }

  void _showAddPlaceDialog() {
    final memoController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('목적지 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: '장소 이름',
                border: OutlineInputBorder(),
              ),
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
              if (locationController.text.trim().isNotEmpty) {
                setState(() {
                  _places.add({
                    'location': locationController.text.trim(),
                    'memo': memoController.text.trim(),
                  });
                });
                Navigator.pop(context);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 완료: ${_titleController.text}')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 항목을 입력해주세요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('스케줄 작성')),
      body: Column(
        children: [
          // ✅ 상단 여행 제목 입력 영역
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              border: const Border(
                bottom: BorderSide(color: Colors.pinkAccent, width: 0.6),
              ),
            ),
            child: TextFormField(
              controller: _titleController,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: '여행 제목',
                labelStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? '여행 제목을 입력해주세요.' : null,
            ),
          ),

          const SizedBox(height: 8),

          // ✅ 나머지 입력 폼 스크롤 영역
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 16),

                  // 지역 선택
                  DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    decoration: const InputDecoration(
                      labelText: '지역 선택',
                      border: OutlineInputBorder(),
                    ),
                    items: _locations
                        .map(
                          (loc) =>
                              DropdownMenuItem(value: loc, child: Text(loc)),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedLocation = value),
                    validator: (value) => value == null ? '지역을 선택해주세요.' : null,
                  ),

                  const SizedBox(height: 16),

                  // 기간 선택
                  GestureDetector(
                    onTap: _pickDateRange,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: '여행 기간',
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

                  const SizedBox(height: 16),

                  // 목적 선택
                  DropdownButtonFormField<String>(
                    value: _selectedPurpose,
                    decoration: const InputDecoration(
                      labelText: '여행 목적',
                      border: OutlineInputBorder(),
                    ),
                    items: _purposes
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedPurpose = value),
                    validator: (value) => value == null ? '목적을 선택해주세요.' : null,
                  ),

                  const SizedBox(height: 28),

                  // 목적지 추가 영역
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '🗺️ 목적지 상세 추가',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _showAddPlaceDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('장소 추가'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink[200],
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_places.isEmpty)
                          const Center(
                            child: Text(
                              '추가된 장소가 없습니다.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          ListView.separated(
                            itemCount: _places.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final place = _places[index];
                              return ListTile(
                                title: Text(place['location'] ?? ''),
                                subtitle: (place['memo']?.isNotEmpty ?? false)
                                    ? Text(place['memo']!)
                                    : null,
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() => _places.removeAt(index));
                                  },
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 기타 메모
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: '기타 메모',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? '내용을 입력해주세요.' : null,
                  ),

                  const SizedBox(height: 30),

                  // 저장 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.save),
                      label: const Text('저장하기'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
