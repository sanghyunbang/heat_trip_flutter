// lib/features/record/presentation/screens/schedule_edit_screen.dart
//
// [목표]
//  - TokenStorage 직접 접근/수동 헤더 제거 → ApiClient가 Authorization 자동 첨부
//  - AuthRepositoryImpl은 주입형 생성자(AuthRepositoryImpl(ApiClient)) 사용
//  - 저장/수정 요청은 ApiClient(or Repo) 경유로 단순화
//  - 불필요 import(Env, http, TokenStorage) 제거
//
// [핵심 변경]
//  ① Provider에서 ApiClient 읽어와 레포를 주입.
//  ② _fetchUser()는 token 매개 없이 authRepo.getMyProfile() 사용.
//  ③ _submit()은 ApiClient를 통해 POST/PUT (Authorization 자동).
//  ④ ★ 저장 성공 시 JourneyState.refreshSchedules() 호출 → Diary 탭 실시간 반영

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';                       // ★ DI

import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/record/data/schedule_repository_impl.dart';
import 'package:heat_trip_flutter/features/record/data/model/schedule_response.dart';
import 'package:heat_trip_flutter/features/record/presentation/widgets/record_ui.dart';
import 'package:heat_trip_flutter/shared/network/api_client.dart';

// ★ 추가: Journey 탭에 실시간 반영
import 'package:heat_trip_flutter/features/journey/state/journey_state.dart';

class ScheduleEditScreen extends StatefulWidget {
  final ScheduleResponse? schedule;
  const ScheduleEditScreen({super.key, this.schedule});

  @override
  State<ScheduleEditScreen> createState() => _ScheduleEditScreenState();
}

class _ScheduleEditScreenState extends State<ScheduleEditScreen> {
  // ★ 주입형 레포/클라
  late final ApiClient _api;
  late final AuthRepositoryImpl _authRepository;
  late final ScheduleRepositoryImpl _scheduleRepository;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final DateFormat _fm = DateFormat('yyyy-MM-dd');
  DateTimeRange? _range;
  String? _authorName;

  @override
  void initState() {
    super.initState();
    // Provider에서 ApiClient 읽고 레포 주입
    _api = context.read<ApiClient>();
    _authRepository = AuthRepositoryImpl(_api);
    _scheduleRepository = ScheduleRepositoryImpl(_api);

    // 편집 모드 초기 채우기
    if (widget.schedule != null) {
      _titleController.text = widget.schedule!.title;
      _descriptionController.text = widget.schedule!.content ?? '';
      _range = DateTimeRange(
        start: widget.schedule!.dateFrom,
        end: widget.schedule!.dateTo,
      );
    }
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    // ★ 토큰을 직접 꺼낼 필요 없이 AuthRepo가 ApiClient로 Authorization 헤더를 붙입니다.
    try {
      final user = await _authRepository.getMyProfile();
      if (!mounted) return;
      setState(() => _authorName = (user?['name'] ?? '알 수 없음'));
    } catch (_) {
      if (!mounted) return;
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
    // 유효성 검사
    if (!(_formKey.currentState!.validate()) || _range == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 항목을 입력해주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final isEditing = widget.schedule != null;

    // 서버로 보낼 JSON
    final body = {
      "title": _titleController.text,
      "dateFrom": _fm.format(_range!.start),
      "dateTo": _fm.format(_range!.end),
      "content": _descriptionController.text,
    };

    try {
      final res = isEditing
          ? await _api.put(
              '/public/schedules/${widget.schedule!.scheduleId}',
              body: jsonEncode(body),
            )
          : await _api.postJson('/public/schedules', body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        // ★★★ 여기! 저장 성공 → Journey 탭 데이터 즉시 갱신
        final journey = context.read<JourneyState>();
        await journey.refreshSchedules();   // Trips 목록 즉시 반영
        // await journey.refreshDiaries();  // (선택) 스케줄 변경이 다이어리 계산에 영향 있으면 켜기

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? '스케줄이 수정되었습니다.' : '스케줄이 저장되었습니다.'),
          ),
        );
        Navigator.pop(context, true); // (선택) 부모가 pop result로도 감지 가능
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패 (${res.statusCode})')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('서버 오류: $e')),
      );
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
                      labelText: '스케쥴 메모',
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
