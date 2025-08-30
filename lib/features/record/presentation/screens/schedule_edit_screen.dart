import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/record/data/schedule_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heat_trip_flutter/features/record/data/model/schedule_response.dart';
import 'package:heat_trip_flutter/features/record/presentation/widgets/record_ui.dart';

class ScheduleEditScreen extends StatefulWidget {
  final ScheduleResponse? schedule;
  const ScheduleEditScreen({super.key, this.schedule});

  @override
  State<ScheduleEditScreen> createState() => _ScheduleEditScreenState();
}

class _ScheduleEditScreenState extends State<ScheduleEditScreen> {
  final authRepository = AuthRepositoryImpl();
  final scheduleRepository = ScheduleRepositoryImpl();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final DateFormat _fm = DateFormat('yyyy-MM-dd');
  DateTimeRange? _range;
  String? _authorName;

  @override
  void initState() {
    super.initState();
    _fetchUser();
    if (widget.schedule != null) {
      _titleController.text = widget.schedule!.title;
      _descriptionController.text = widget.schedule!.content ?? '';
      _range = DateTimeRange(
        start: widget.schedule!.dateFrom,
        end: widget.schedule!.dateTo,
      );
    }
  }

  Future<void> _fetchUser() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return setState(() => _authorName = '알 수 없음');
      final user = await authRepository.getMyProfile(token);
      setState(() => _authorName = (user?['name'] ?? '알 수 없음'));
    } catch (_) {
      setState(() => _authorName = '알 수 없음');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _range,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: kAccentDark,
              onPrimary: Colors.white,
              surface: kSurface,
              onSurface: kTextMain,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: kAccentDark),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _submit() async {
    final token = await TokenStorage.getToken();
    if (!(_formKey.currentState!.validate()) || _range == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 항목을 입력해주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final baseUrl = dotenv.env['API_BASE_URL'];
    final isEditing = widget.schedule != null;

    final url = isEditing
        ? Uri.parse('$baseUrl/public/schedules/${widget.schedule!.scheduleId}')
        : Uri.parse('$baseUrl/public/schedules');

    final body = jsonEncode({
      "title": _titleController.text,
      "dateFrom": _fm.format(_range!.start),
      "dateTo": _fm.format(_range!.end),
      "content": _descriptionController.text,
    });

    try {
      final res = await (isEditing
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

      if (res.statusCode == 200 || res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? '스케줄이 수정되었습니다.' : '스케줄이 저장되었습니다.'),
          ),
        );
        if (mounted) Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('저장 실패')));
      }
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('서버 오류')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.schedule != null;

    return WhitePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 간단 타이틀 + 뒤로가기
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: kTextMain),
              ),
              const SizedBox(width: 4),
              Text(
                isEditing ? 'Edit Schedule' : 'New Schedule',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    initialValue: _authorName ?? '',
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: '작성자',
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? '여행 제목을 입력해주세요.' : null,
                    decoration: InputDecoration(
                      labelText: '여행 제목',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kBorder, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickRange,
                    child: AbsorbPointer(
                      child: TextFormField(
                        validator: (_) => _range == null ? '기간을 선택해주세요.' : null,
                        controller: TextEditingController(
                          text: _range == null
                              ? ''
                              : '${_fm.format(_range!.start)} ~ ${_fm.format(_range!.end)}',
                        ),
                        decoration: InputDecoration(
                          labelText: '여행 기간',
                          suffixIcon: const Icon(
                            Icons.calendar_today,
                            color: kTextMuted,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: kBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: kBorder),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? '내용을 입력해주세요.' : null,
                    decoration: InputDecoration(
                      labelText: '기타 메모',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: Text(
                        isEditing ? '수정하기' : '저장하기',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
