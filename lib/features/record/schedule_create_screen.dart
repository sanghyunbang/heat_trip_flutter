import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/record/data/schedule_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heat_trip_flutter/features/record/data/model/schedule_response.dart';

class ScheduleCreateScreen extends StatefulWidget {
  final ScheduleResponse? schedule; // 수정 모드 확인용

  const ScheduleCreateScreen({super.key, this.schedule});

  @override
  State<ScheduleCreateScreen> createState() => _ScheduleCreateScreenState();
}

class _ScheduleCreateScreenState extends State<ScheduleCreateScreen> {
  final authRepository = AuthRepositoryImpl();
  final scheduleRepository = ScheduleRepositoryImpl();
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
    _initializeFormIfEditing();
  }

  void _initializeFormIfEditing() {
    if (widget.schedule != null) {
      _titleController.text = widget.schedule!.title;
      _descriptionController.text = widget.schedule!.content ?? '';
      _selectedRange = DateTimeRange(
        start: widget.schedule!.dateFrom,
        end: widget.schedule!.dateTo,
      );
    }
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
    final token = await TokenStorage.getToken();
    if (_formKey.currentState!.validate() && _selectedRange != null) {
      final baseUrl = dotenv.env['API_BASE_URL'];
      final isEditing = widget.schedule != null;

      final url = isEditing
          ? Uri.parse(
              '$baseUrl/public/schedules/${widget.schedule!.scheduleId}',
            )
          : Uri.parse('$baseUrl/public/schedules');

      final body = jsonEncode({
        "title": _titleController.text,
        "dateFrom": _dateFormat.format(_selectedRange!.start),
        "dateTo": _dateFormat.format(_selectedRange!.end),
        "content": _descriptionController.text,
      });

      try {
        final response = await (isEditing
            ? http.put(
                url,
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
                body: body,
              )
            : http.post(
                url,
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
                body: body,
              ));

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? '스케줄이 수정되었습니다.' : '스케줄이 저장되었습니다.'),
              backgroundColor: Colors.pink.shade300,
            ),
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
        ).showSnackBar(SnackBar(content: Text('서버 오류: $e')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 항목을 입력해주세요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.schedule != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '스케줄 수정' : '스케줄 작성'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 작성자 (읽기 전용)
              TextFormField(
                initialValue: _authorName ?? '',
                decoration: InputDecoration(
                  labelText: '작성자',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.pink.shade50,
                ),
                enabled: false,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 16),

              // 제목
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: '여행 제목',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                    decoration: InputDecoration(
                      labelText: '여행 기간',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: Colors.pink,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    controller: TextEditingController(
                      text: _selectedRange != null
                          ? '${_dateFormat.format(_selectedRange!.start)} ~ ${_dateFormat.format(_selectedRange!.end)}'
                          : '',
                    ),
                    validator: (_) =>
                        _selectedRange == null ? '기간을 선택해주세요.' : null,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 내용
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: '기타 메모',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? '내용을 입력해주세요.' : null,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 30),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.save),
                  label: Text(isEditing ? '수정하기' : '저장하기'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
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
