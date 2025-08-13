import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/record/data/schedule_repository_impl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';

class ScheduleCreateScreen extends StatefulWidget {
  const ScheduleCreateScreen({super.key});

  @override
  State<ScheduleCreateScreen> createState() => _ScheduleCreateScreenState();
}

class _ScheduleCreateScreenState extends State<ScheduleCreateScreen> {
  final authRepository = AuthRepositoryImpl(); //유저관련 백엔드호출
  final scheduleRepository = ScheduleRepositoryImpl(); //게시물관련 백엔드호출
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  DateTimeRange? _selectedRange;

  String? _authorName;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final token = await TokenStorage.getToken();

      if (token == null) {
        setState(() => _authorName = '알 수 없음');
        return;
      }

      final userInfo = await authRepository.getMyProfile(token);

      if (userInfo != null) {
        setState(() {
          _authorName = userInfo['name'] ?? '알 수 없음';
        });
      } else {
        setState(() => _authorName = '알 수 없음');
      }
    } catch (e) {
      debugPrint('유저 정보 불러오기 실패: $e');
      setState(() => _authorName = '알 수 없음');
    }
  }

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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedRange != null) {
      final baseUrl = dotenv.env['API_BASE_URL'];
      final url = Uri.parse('$baseUrl/public/schedules');

      final body = jsonEncode({
        "title": _titleController.text,
        "dateFrom": _dateFormat.format(_selectedRange!.start),
        "dateTo": _dateFormat.format(_selectedRange!.end),
        "description": _descriptionController.text,
        "author": _authorName,
      });

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('서버에 저장 완료: ${_titleController.text}')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('저장 실패: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('서버와 통신 중 오류가 발생했습니다: $e')));
      }
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 작성자 (읽기전용)
              TextFormField(
                initialValue: _authorName ?? '',
                decoration: const InputDecoration(
                  labelText: '작성자',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
              const SizedBox(height: 16),

              // 제목
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '여행 제목',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? '여행 제목을 입력해주세요.' : null,
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

              // 내용 (기타 메모)
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
            ],
          ),
        ),
      ),
    );
  }
}
