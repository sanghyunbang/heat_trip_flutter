// lib/features/record/presentation/screens/schedule_list_screen.dart
//
// [목표]
//  - http/토큰 헤더 작업을 레포 내부가 아닌 공용 ApiClient에서 처리(주입형)
//  - Repository도 DI(Provider)로 주입 → 테스트/교체 용이
//  - setState 호출 타이밍 안전화(mounted 체크)
//  - 외부 네비게이션은 go_router를 그대로 사용, 내부 상세/수정은 Navigator 유지 가능
//
// [핵심 변경]
//  ① _repository를 직접 생성하지 않고 Provider에서 ApiClient를 받아 주입.
//  ② _load의 finally에서 mounted 확인 후 setState.
//  ③ 에러-로그인 버튼은 go_router의 push 사용 유지.
//  ④ 네트워크/토큰 처리는 ScheduleRepositoryImpl(ApiClient) 내부로 이관(별도 파일).

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // ★ 추가: DI
import 'package:table_calendar/table_calendar.dart';

// 도메인/데이터/프레젠테이션 의존성
import 'package:heat_trip_flutter/features/record/data/model/schedule_response.dart';
import 'package:heat_trip_flutter/features/record/data/schedule_repository_impl.dart';
import 'package:heat_trip_flutter/features/record/presentation/screens/schedule_edit_screen.dart';
import 'package:heat_trip_flutter/features/record/presentation/screens/schedule_detail_screen.dart';
import 'package:heat_trip_flutter/features/record/presentation/widgets/record_ui.dart';
import 'package:heat_trip_flutter/core/errors/app_exception.dart';
import 'package:heat_trip_flutter/shared/network/api_client.dart'; // ★ 추가: ApiClient 주입 원천

/// 카드 메뉴
enum _CardMenu { edit, delete }

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});
  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  // ─────────────────────────────────────
  // 상태 & 의존성
  // ─────────────────────────────────────
  late final ScheduleRepositoryImpl _repository; // ★ 변경: 나중 주입
  List<ScheduleResponse> _all = [];
  bool _loading = true;
  String? _error;

  // 검색/필터 상태
  String _searchTitle = '';
  String _filterType = '전체'; // 전체/지나간/앞으로

  // 탭(리스트/달력) & 캘린더 상태
  ViewTab _tab = ViewTab.schedule;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 스크롤/앵커(선택 영역 자동 스크롤)
  final _scrollController = ScrollController();
  final _selectedSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // ★ ApiClient를 Provider에서 받아 Repo 주입
    final api = context.read<ApiClient>();
    _repository = ScheduleRepositoryImpl(api);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repository.fetchSchedules();
      if (!mounted) return;
      setState(() => _all = data);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = '일시적인 오류가 발생했어요. 잠시 후 다시 시도해 주세요.');
    } finally {
      if (!mounted) return; // ★ 안전 가드
      setState(() => _loading = false);
    }
  }

  // ─────────────────────────────────────
  // 필터링
  // ─────────────────────────────────────
  List<ScheduleResponse> get _filteredForList {
    return _repository.filterSchedules(
      all: _all,
      title: _searchTitle,
      date: null,
      filterType: _filterType,
    );
  }

  List<ScheduleResponse> get _filteredForCalendar {
    return _repository.filterSchedules(
      all: _all,
      title: _searchTitle,
      date: null,
      filterType: _filterType,
    );
  }

  List<ScheduleResponse> _schedulesOn(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return _filteredForCalendar.where((s) {
      final from = DateTime(s.dateFrom.year, s.dateFrom.month, s.dateFrom.day);
      final to = DateTime(s.dateTo.year, s.dateTo.month, s.dateTo.day);
      return !d.isBefore(from) && !d.isAfter(to);
    }).toList();
  }

  String _formatRange(DateTime start, DateTime end) {
    final sameYear = start.year == end.year;
    final s = DateFormat.MMMd().format(start);
    final e = DateFormat.MMMd().format(end);
    return sameYear
        ? '$s – $e'
        : '${DateFormat.yMMMEd().format(start)} – ${DateFormat.yMMMEd().format(end)}';
  }

  // ─────────────────────────────────────
  // 아이콘 & 색상 매핑
  // ─────────────────────────────────────
  Color _tint(Color c, [double o = .16]) => c.withOpacity(o);

  Widget _circleIcon(
    IconData icon,
    Color color, {
    double size = 36,
    double iconSize = 18,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _tint(color, .18),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(.45)),
        boxShadow: [BoxShadow(color: color.withOpacity(.10), blurRadius: 8)],
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: color),
    );
  }

  ({IconData icon, Color color}) _iconSpecFor(ScheduleResponse s) {
    final t = ('${s.title} ${s.content ?? ''}').toLowerCase();

    if (t.contains('flight') || t.contains('plane') || t.contains('air')) {
      return (icon: Icons.flight_takeoff, color: const Color(0xFF7C3AED));
    }
    if (t.contains('hotel') || t.contains('stay') || t.contains('check-in')) {
      return (icon: Icons.hotel, color: const Color(0xFF2563EB));
    }
    if (t.contains('lunch') ||
        t.contains('dinner') ||
        t.contains('sushi') ||
        t.contains('restaurant') ||
        t.contains('food')) {
      return (icon: Icons.restaurant, color: const Color(0xFFF97316));
    }
    if (t.contains('market') || t.contains('photo') || t.contains('camera')) {
      return (icon: Icons.photo_camera, color: const Color(0xFF16A34A));
    }
    if (t.contains('museum') || t.contains('art') || t.contains('gallery')) {
      return (icon: Icons.palette, color: const Color(0xFFEC4899));
    }
    return (icon: Icons.push_pin, color: const Color(0xFF0EA5E9));
  }

  Widget _leadingFor(ScheduleResponse s) {
    final spec = _iconSpecFor(s);
    return _circleIcon(spec.icon, spec.color);
  }

  List<Widget> _chipIconsFor(List<ScheduleResponse> items) {
    return items.take(4).map((s) {
      final spec = _iconSpecFor(s);
      return _circleIcon(spec.icon, spec.color, size: 28, iconSize: 16);
    }).toList();
  }

  // ─────────────────────────────────────
  // AppBar (큰 타이틀 + 부제 + 검색창 + Add 버튼)
  // ─────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      toolbarHeight: 56,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      title: Row(
        children: [
          const Expanded(
            child: Text(
              'Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kTextMain,
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: FilledButton.icon(
              onPressed: () {
                // 내부 서브페이지는 Navigator로 유지해도 무방
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScheduleEditScreen()),
                ).then((_) => _load());
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Item'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 26, 29, 33),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                overlayColor: Colors.white.withOpacity(.06),
              ),
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(92),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              const Text(
                'Schedule & plan your trips',
                style: TextStyle(color: kTextMuted),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: TextField(
                  onChanged: (v) => setState(() => _searchTitle = v),
                  decoration: InputDecoration(
                    hintText: 'Search schedule…',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kBorder),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // 빌드
  // ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
        backgroundColor: Colors.white,
      );
    }

    if (_error != null) {
      final isAuth = _error!.contains('로그인이 필요');
      return Scaffold(
        appBar: _buildAppBar(context),
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAuth ? Icons.lock_outline : Icons.error_outline,
                  size: 36,
                  color: kTextMuted,
                ),
                const SizedBox(height: 10),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (isAuth)
                  FilledButton(
                    onPressed: () {
                      try {
                        context.push('/auth/login'); // go_router
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('로그인 화면을 열 수 없습니다: $e')),
                        );
                      }
                    },
                    child: const Text('로그인 하러 가기'),
                  )
                else
                  OutlinedButton(onPressed: _load, child: const Text('다시 시도')),
              ],
            ),
          ),
        ),
      );
    }

    if (_all.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(context),
        backgroundColor: Colors.white,
        body: _emptyState(),
      );
    }

    final fm = DateFormat('yyyy-MM-dd');
    final listFiltered = _filteredForList;

    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WideSegmentBar(
              value: _tab,
              onChanged: (v) => setState(() => _tab = v),
            ),
            const SizedBox(height: 14),

            _filterChips(),
            const SizedBox(height: 12),

            _summaryRow(),
            const SizedBox(height: 12),

            if (_tab == ViewTab.schedule)
              (listFiltered.isEmpty ? _emptyState() : _listContent(fm, listFiltered))
            else
              (_filteredForCalendar.isEmpty ? _emptyState() : _calendarContent(fm)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // Empty UI
  // ─────────────────────────────────────
  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No schedules to show',
          style: TextStyle(color: kTextMuted, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // (★ 추가) 미정의였던 헬퍼 위젯들 구현
  // ─────────────────────────────────────

  /// 상단 필터칩들: 전체 / 지나간 / 앞으로
  Widget _filterChips() {
    final filters = const ['전체', '지나간', '앞으로'];
    return Wrap(
      spacing: 8,
      children: filters.map((label) {
        final selected = _filterType == label;
        return ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => setState(() => _filterType = label),
          selectedColor: const Color(0xFFEBEBEB),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? const Color(0xFF353535) : kTextMuted,
          ),
          side: const BorderSide(color: Color(0xFFE6E6E6)),
          backgroundColor: const Color(0xFFF6F6F6),
        );
      }).toList(),
    );
  }

  /// 요약: 총 개수 / 이번달 개수 / 검색어
  Widget _summaryRow() {
    final total = _filteredForList.length;
    final now = DateTime.now();
    final thisMonth = _filteredForList.where((s) =>
        s.dateFrom.year == now.year && s.dateFrom.month == now.month).length;

    return Row(
      children: [
        _summaryPill(icon: Icons.list_alt, label: 'Total', value: '$total'),
        const SizedBox(width: 8),
        _summaryPill(
            icon: Icons.calendar_today, label: 'This Month', value: '$thisMonth'),
        const Spacer(),
        if (_searchTitle.isNotEmpty)
          Text('Search: "$_searchTitle"',
              style: const TextStyle(color: kTextMuted)),
      ],
    );
  }

  Widget _summaryPill(
      {required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: kTextMuted),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// 리스트 탭 콘텐츠(카드 목록)
  Widget _listContent(DateFormat fm, List<ScheduleResponse> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final s = items[i];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScheduleDetailScreen(schedule: s),
              ),
            ).then((_) => _load());
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _leadingFor(s),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 + 메뉴
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          PopupMenuButton<_CardMenu>(
                            onSelected: (m) async {
                              if (m == _CardMenu.edit) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ScheduleEditScreen(schedule: s),
                                  ),
                                );
                                if (!mounted) return;
                                _load();
                              } else if (m == _CardMenu.delete) {
                                await _confirmDelete(s);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                  value: _CardMenu.edit, child: Text('Edit')),
                              PopupMenuItem(
                                  value: _CardMenu.delete, child: Text('Delete')),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.content ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: kTextMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_month,
                              size: 16, color: kTextMuted),
                          const SizedBox(width: 6),
                          Text(
                            '${_formatRange(s.dateFrom, s.dateTo)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 달력 탭 콘텐츠(TableCalendar + 해당 일자 목록)
  Widget _calendarContent(DateFormat fm) {
    final firstDay = DateTime.utc(2018, 1, 1);
    final lastDay = DateTime.utc(2035, 12, 31);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TableCalendar<ScheduleResponse>(
          firstDay: firstDay,
          lastDay: lastDay,
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (d) =>
              _selectedDay != null &&
              d.year == _selectedDay!.year &&
              d.month == _selectedDay!.month &&
              d.day == _selectedDay!.day,
          onDaySelected: (selected, focused) {
            setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
            });
          },
          eventLoader: (day) => _schedulesOn(day),
          calendarStyle: const CalendarStyle(
            markerDecoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedDay == null)
          const Text('날짜를 선택하세요.', style: TextStyle(color: kTextMuted))
        else
          _dayScheduleList(_selectedDay!),
      ],
    );
  }

  Widget _dayScheduleList(DateTime day) {
    final items = _schedulesOn(day);
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('선택한 날짜의 일정이 없습니다.',
            style: TextStyle(color: kTextMuted)),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final s = items[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: kBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _leadingFor(s),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  s.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.open_in_new, size: 18),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScheduleDetailScreen(schedule: s),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(ScheduleResponse s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제할까요?'),
        content: Text('"${s.title}" 일정을 삭제합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await _repository.deleteSchedule(s.scheduleId);
        if (!mounted) return;
        _load();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제되었습니다.')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }
}
