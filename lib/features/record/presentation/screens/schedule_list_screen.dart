// lib/features/record/presentation/screens/schedule_list_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// 도메인/데이터/프레젠테이션 의존성
import 'package:heat_trip_flutter/features/record/data/model/schedule_response.dart';
import 'package:heat_trip_flutter/features/record/data/schedule_repository_impl.dart';
import 'package:heat_trip_flutter/features/record/presentation/screens/schedule_edit_screen.dart';
import 'package:heat_trip_flutter/features/record/presentation/screens/schedule_detail_screen.dart';
import 'package:heat_trip_flutter/features/record/presentation/widgets/record_ui.dart';
// ↑ record_ui.dart 안의 kTextMain, kTextMuted, kBorder, kCard, ViewTab,
//   WideSegmentBar, StatusChip, ScheduleListCard 등 사용

import 'package:heat_trip_flutter/core/errors/app_exception.dart';

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
  final ScheduleRepositoryImpl _repository = ScheduleRepositoryImpl();
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
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repository.fetchSchedules();
      setState(() => _all = data);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = '일시적인 오류가 발생했어요. 잠시 후 다시 시도해 주세요.');
    } finally {
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
      date: null, // 날짜 필터 없음
      filterType: _filterType,
    );
  }

  List<ScheduleResponse> get _filteredForCalendar {
    return _repository.filterSchedules(
      all: _all,
      title: _searchTitle,
      date: null, // 날짜 필터 없음
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
      return (icon: Icons.flight_takeoff, color: const Color(0xFF7C3AED)); // 보라
    }
    if (t.contains('hotel') || t.contains('stay') || t.contains('check-in')) {
      return (icon: Icons.hotel, color: const Color(0xFF2563EB)); // 파랑
    }
    if (t.contains('lunch') ||
        t.contains('dinner') ||
        t.contains('sushi') ||
        t.contains('restaurant') ||
        t.contains('food')) {
      return (icon: Icons.restaurant, color: const Color(0xFFF97316)); // 오렌지
    }
    if (t.contains('market') || t.contains('photo') || t.contains('camera')) {
      return (icon: Icons.photo_camera, color: const Color(0xFF16A34A)); // 그린
    }
    if (t.contains('museum') || t.contains('art') || t.contains('gallery')) {
      return (icon: Icons.palette, color: const Color(0xFFEC4899)); // 핑크
    }
    return (icon: Icons.push_pin, color: const Color(0xFF0EA5E9)); // 기본(시안)
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
        statusBarIconBrightness: Brightness.dark, // Android
        statusBarBrightness: Brightness.light, // iOS
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
    // 로딩
    if (_loading) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
        backgroundColor: Colors.white,
      );
    }

    // 에러
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
                  _error!, // 깔끔한 메시지 그대로
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (isAuth)
                  FilledButton(
                    onPressed: () {
                      context.go('/auth/login');
                      Navigator.pushNamed(context, '/auth/login');
                    },
                    child: const Text('로그인 하러 가기'),
                  )
                else
                  OutlinedButton(
                    onPressed: _load,
                    child: const Text('다시 시도'),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // ✅ 전체가 비어있으면 바로 Empty UI
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

            // ✅ 리스트 탭: 필터 후 0개면 Empty 텍스트
            if (_tab == ViewTab.schedule)
              (listFiltered.isEmpty ? _emptyState() : _listContent(fm, listFiltered))
            else
            // ✅ 달력 탭: 필터 결과가 0개면 Empty, 아니면 기존 달력
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
  // UI 조각
  // ─────────────────────────────────────

  /// 상태칩(전체/과거/예정)
  Widget _filterChips() {
    const allColor = Color(0xFF7C3AED); // purple
    const pastColor = Color(0xFF0EA5E9); // cyan
    const nextColor = Color(0xFF22C55E); // green

    Widget chip({
      required String label,
      required String key,
      required Color color,
    }) {
      final selected = _filterType == key;
      final bg = selected ? color.withOpacity(.14) : Colors.white;
      final bd = selected ? color.withOpacity(.45) : kBorder;
      final txt = selected ? color : kTextMain;

      return ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: txt,
          ),
        ),
        selected: selected,
        onSelected: (_) => setState(() => _filterType = key),
        backgroundColor: Colors.white,
        selectedColor: bg,
        side: BorderSide(color: bd),
        shape: const StadiumBorder(),
        labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
      );
    }

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          chip(label: '전체', key: '전체', color: allColor),
          chip(label: '과거 스케쥴', key: '지나간', color: pastColor),
          chip(label: '예정 스케쥴', key: '앞으로', color: nextColor),
        ],
      ),
    );
  }

  /// 상단 요약(가까운 일정 / 누적 일수 / 여행 횟수)
  Widget _summaryRow() {
    if (_all.isEmpty) return const SizedBox();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcoming = _all.where((s) {
      final start = DateTime(s.dateFrom.year, s.dateFrom.month, s.dateFrom.day);
      return start.isAtSameMomentAs(today) || start.isAfter(today);
    }).toList()
      ..sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

    final closest = upcoming.isNotEmpty ? upcoming.first : null;
    final closestDaysLeft = closest == null
        ? null
        : DateTime(
      closest.dateFrom.year,
      closest.dateFrom.month,
      closest.dateFrom.day,
    ).difference(today).inDays +
        1;

    int totalDays = 0;
    for (var s in _all) {
      if (s.dateTo.isBefore(now)) {
        totalDays += s.dateTo.difference(s.dateFrom).inDays + 1;
      }
    }
    final completed = _all.where((s) => s.dateTo.isBefore(now)).length;

    Widget info({
      required IconData icon,
      required String label,
      required String value,
      required Color color,
    }) {
      return Expanded(
        child: Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(.30)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w800, color: color),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: color.withOpacity(.8)),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        info(
          icon: Icons.event,
          label: 'Next',
          value: closest != null ? '${closest.title} (D-${closestDaysLeft})' : 'None',
          color: const Color(0xFF7C3AED),
        ),
        info(
          icon: Icons.today,
          label: 'Total days',
          value: '$totalDays',
          color: const Color(0xFF0EA5E9),
        ),
        info(
          icon: Icons.flight_takeoff,
          label: 'Trips',
          value: '$completed',
          color: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  // ─────────────────────────────────────
  // 리스트 탭
  // ─────────────────────────────────────
  Widget _listContent(DateFormat fm, List<ScheduleResponse> filtered) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final ongoing = _all.where((s) {
      final start = DateTime(s.dateFrom.year, s.dateFrom.month, s.dateFrom.day);
      final end = DateTime(s.dateTo.year, s.dateTo.month, s.dateTo.day);
      return !today.isBefore(start) && !today.isAfter(end);
    }).toList()
      ..sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ongoing.isNotEmpty) ...[
          const Text(
            'Today / Ongoing',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...ongoing.map((s) => _cardFor(s, fm)).toList(),
          const SizedBox(height: 16),
        ],
        const Text(
          'All schedules',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ...filtered.map((s) => _cardFor(s, fm)).toList(),
      ],
    );
  }

  // ─────────────────────────────────────
  // 카드 공용
  // ─────────────────────────────────────
  Widget _cardMenuButton(ScheduleResponse s) {
    return PopupMenuButton<_CardMenu>(
      tooltip: 'More',
      position: PopupMenuPosition.over,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 160),
      itemBuilder: (context) => const [
        PopupMenuItem<_CardMenu>(
          value: _CardMenu.edit,
          child: ListTile(
            dense: true,
            leading: Icon(Icons.edit, size: 18),
            title: Text('Edit'),
            horizontalTitleGap: 8,
            minLeadingWidth: 18,
          ),
        ),
        PopupMenuItem<_CardMenu>(
          value: _CardMenu.delete,
          child: ListTile(
            dense: true,
            leading: Icon(Icons.delete_outline, size: 18),
            title: Text('Delete'),
            horizontalTitleGap: 8,
            minLeadingWidth: 18,
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case _CardMenu.edit:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScheduleEditScreen(schedule: s),
              ),
            ).then((_) => _load());
            break;
          case _CardMenu.delete:
            _confirmDelete(s);
            break;
        }
      },
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(Icons.more_horiz, size: 20, color: kTextMuted),
      ),
    );
  }

  Widget _cardFor(ScheduleResponse s, DateFormat fm) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isPast = s.dateTo.isBefore(now);
    final isOngoing = !isPast && !s.dateFrom.isAfter(today);
    final status = isOngoing ? 'pending' : (isPast ? 'confirmed' : 'confirmed');

    void _openDetail() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ScheduleDetailScreen(schedule: s)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _openDetail,
          child: ScheduleListCard(
            leadingIcon: _leadingFor(s),
            title: s.title,
            subtitle: '${fm.format(s.dateFrom)} · ${fm.format(s.dateTo)}',
            description: s.content,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusChip(status),
                const SizedBox(width: 6),
                _cardMenuButton(s),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // 달력 탭
  // ─────────────────────────────────────
  Widget _calendarContent(DateFormat fm) {
    final selectedItems = _selectedDay == null
        ? <ScheduleResponse>[]
        : _schedulesOn(_selectedDay!);

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final upcomingSchedules = _filteredForCalendar
        .where((s) => !DateTime(s.dateTo.year, s.dateTo.month, s.dateTo.day)
        .isBefore(today))
        .toList()
      ..sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: TableCalendar<ScheduleResponse>(
              firstDay: DateTime(2020, 1, 1),
              lastDay: DateTime(2030, 12, 31),
              focusedDay: _focusedDay,
              rowHeight: 34,
              daysOfWeekHeight: 20,
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: '월간'},
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                leftChevronMargin: EdgeInsets.only(left: 8),
                rightChevronMargin: EdgeInsets.only(right: 8),
                headerPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
              onDaySelected: (sel, foc) {
                setState(() {
                  _selectedDay = DateTime(sel.year, sel.month, sel.day);
                  _focusedDay = foc;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final ctx = _selectedSectionKey.currentContext;
                  if (ctx != null) {
                    Scrollable.ensureVisible(
                      ctx,
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                      alignment: 0.1,
                    );
                  }
                });
              },
              onPageChanged: (foc) => _focusedDay = foc,
              eventLoader: (day) => _schedulesOn(day),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  if (_schedulesOn(day).isEmpty) return null;
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kBorder, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: kTextMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              calendarStyle: const CalendarStyle(markersMaxCount: 0),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 선택한 날짜
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: Column(
            key: _selectedSectionKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '선택한 날짜의 스케쥴',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (selectedItems.isEmpty)
                const Text('No events', style: TextStyle(color: kTextMuted))
              else
                ...selectedItems.map((s) => _cardFor(s, fm)).toList(),
              const SizedBox(height: 24),
            ],
          ),
        ),

        if (upcomingSchedules.isNotEmpty) ...[
          const Text(
            'Upcoming Events',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: upcomingSchedules.length.clamp(0, 10),
            itemBuilder: (context, i) {
              final s = upcomingSchedules[i];
              final start = DateTime(s.dateFrom.year, s.dateFrom.month, s.dateFrom.day);
              final end = DateTime(s.dateTo.year, s.dateTo.month, s.dateTo.day);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Material(
                  color: kCard,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      final todayInRange = !today.isBefore(start) && !today.isAfter(end);
                      setState(() => _selectedDay = todayInRange ? today : start);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final ctx = _selectedSectionKey.currentContext;
                        if (ctx != null) {
                          Scrollable.ensureVisible(
                            ctx,
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOut,
                            alignment: 0.1,
                          );
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatRange(start, end),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: kTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Wrap(spacing: 6, children: _chipIconsFor([s])),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────
  // 삭제 확인 & 실제 삭제 호출
  // ─────────────────────────────────────
  Future<void> _confirmDelete(ScheduleResponse schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kBorder, width: 1),
        ),
        title: const Text('삭제 확인'),
        content: Text('"${schedule.title}" 스케쥴을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final error = await _repository.deleteSchedule(schedule.scheduleId);
      if (error == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('스케줄이 삭제되었습니다.')));
        await _load();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }
}
