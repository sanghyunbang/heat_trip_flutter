// lib/features/record/schedule_create_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ✅ 추가
import 'package:intl/intl.dart';
import 'package:heat_trip_flutter/features/record/data/schedule_repository_impl.dart';
import 'package:heat_trip_flutter/features/record/data/dto/schedule_request.dart';

class ScheduleCreateScreen extends StatefulWidget {
  const ScheduleCreateScreen({super.key});

  @override
  State<ScheduleCreateScreen> createState() => _ScheduleCreateScreenState();
}

class _ScheduleCreateScreenState extends State<ScheduleCreateScreen> {
  final scheduleRepository = ScheduleRepositoryImpl(); // ✅ 저장은 레포지토리 사용
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  DateTimeRange? _selectedRange;

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
    if (picked != null) setState(() => _selectedRange = picked);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedRange == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 항목을 입력해주세요.')));
      return;
    }

    // ✅ 레포지토리의 요청 DTO와 서버 필드명에 맞춤
    final req = ScheduleRequest(
      title: _titleController.text.trim(),
      content: _descriptionController.text.trim(),
      datefrom: _dateFormat.format(_selectedRange!.start),
      dateto: _dateFormat.format(_selectedRange!.end),
    );

    final err = await scheduleRepository.schedulepost(req);

    if (!mounted) return;
    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('서버에 저장 완료: ${_titleController.text}')),
      );
      // ✅ 호출자(List)로 "성공" 신호를 돌려줌 → List 화면에서 새로고침
      context.pop(true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('저장 실패: $err')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final rangeText = _selectedRange == null
        ? ''
        : '${_dateFormat.format(_selectedRange!.start)} ~ ${_dateFormat.format(_selectedRange!.end)}';

    return Scaffold(
      appBar: AppBar(title: const Text('스케줄 작성')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 제목
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '여행 제목',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? '여행 제목을 입력해주세요.' : null,
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
                    controller: TextEditingController(text: rangeText),
                    validator: (_) =>
                        _selectedRange == null ? '기간을 선택해주세요.' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 내용 (기타 메모)
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '기타 메모',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? '내용을 입력해주세요.' : null,
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
            ],
          ),
        ),
      ),
    );
  }
}
