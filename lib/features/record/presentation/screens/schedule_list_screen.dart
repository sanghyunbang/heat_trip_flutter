import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// 도메인/데이터/프레젠테이션 의존성
import 'package:heat_trip_flutter/features/record/data/model/schedule_response.dart';
import 'package:heat_trip_flutter/features/record/data/schedule_repository_impl.dart';
import 'package:heat_trip_flutter/features/record/presentation/screens/schedule_edit_screen.dart';
import 'package:heat_trip_flutter/features/record/presentation/screens/schedule_detail_screen.dart';
import 'package:heat_trip_flutter/features/record/presentation/widgets/record_ui.dart';

/// 점 3개 메뉴
enum _CardMenu { edit, delete }

/// 아이콘/색 스펙 (Dart 2.x 호환)
class _IconSpec {
  final IconData icon;
  final Color color;
  const _IconSpec(this.icon, this.color);
}

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
  DateTime? _searchDate; // 리스트용 날짜 필터
  String _filterType = '전체'; // '전체' | '과거' | '예정'

  // 탭(리스트/달력) & 캘린더 상태
  ViewTab _tab = ViewTab.schedule;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 스크롤/앵커
  final _scrollController = ScrollController();
  final _selectedSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// 서버에서 스케줄 목록 로딩
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repository.fetchSchedules();
      setState(() => _all = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  // ─────────────────────────────────────
  // 필터링
  // ─────────────────────────────────────
  List<ScheduleResponse> get _filteredForList {
    // _filterType 표시 문자열을 기존 레포지토리 규약('전체/지나간/앞으로')에 맞춰 매핑
    final repoFilter = switch (_filterType) {
      '과거' => '지나간',
      '예정' => '앞으로',
      _ => '전체',
    };
    return _repository.filterSchedules(
      all: _all,
      title: _searchTitle,
      date: _searchDate,
      filterType: repoFilter,
    );
  }

  List<ScheduleResponse> get _filteredForCalendar {
    final repoFilter = switch (_filterType) {
      '과거' => '지나간',
      '예정' => '앞으로',
      _ => '전체',
    };
    return _repository.filterSchedules(
      all: _all,
      title: _searchTitle,
      date: null, // 달력은 날짜 필터 미사용
      filterType: repoFilter,
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
    if (sameYear) return '$s – $e';
    return '${DateFormat.yMMMEd().format(start)} – ${DateFormat.yMMMEd().format(end)}';
  }

  Future<void> _pickSearchDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _searchDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _searchDate = picked);
  }

  // ─────────────────────────────────────
  // 아이콘 & 색상 매핑 (컬러 아이콘)
  // ─────────────────────────────────────
  Color _tint(Color c, [double o = .14]) => c.withOpacity(o);

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

  _IconSpec _iconSpecFor(ScheduleResponse s) {
    final t = ('${s.title} ${s.content ?? ''}').toLowerCase();

    if (t.contains('flight') || t.contains('plane') || t.contains('air')) {
      return const _IconSpec(Icons.flight_takeoff, Color(0xFF7C3AED)); // 보라
    }
    if (t.contains('hotel') || t.contains('stay') || t.contains('check-in')) {
      return const _IconSpec(Icons.hotel, Color(0xFF2563EB)); // 파랑
    }
    if (t.contains('lunch') ||
        t.contains('dinner') ||
        t.contains('sushi') ||
        t.contains('restaurant') ||
        t.contains('food')) {
      return const _IconSpec(Icons.restaurant, Color(0xFFF97316)); // 오렌지
    }
    if (t.contains('market') || t.contains('photo') || t.contains('camera')) {
      return const _IconSpec(Icons.photo_camera, Color(0xFF16A34A)); // 그린
    }
    if (t.contains('museum') || t.contains('art') || t.contains('gallery')) {
      return const _IconSpec(Icons.palette, Color(0xFFEC4899)); // 핑크
    }
    return const _IconSpec(Icons.push_pin, Color(0xFF0EA5E9)); // 기본(시안)
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
  // 빌드
  // ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const WhitePage(child: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return WhitePage(child: Center(child: Text('에러: $_error')));
    }

    final fm = DateFormat('yyyy-MM-dd');
    final listFiltered = _filteredForList;

    return WhitePage(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 추가/검색
            RecordHeader(
              onAdd: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScheduleEditScreen()),
                ).then((_) => _load());
              },
              onSearchChanged: (v) => setState(() => _searchTitle = v),
            ),
            const SizedBox(height: 16),

            // 뷰 전환(리스트/달력)
            WideSegmentBar(
              value: _tab,
              onChanged: (v) => setState(() => _tab = v),
            ),
            const SizedBox(height: 14),

            _filterChips(),
            const SizedBox(height: 10),

            _searchDateRow(fm),
            const SizedBox(height: 12),

            _summaryRow(),
            const SizedBox(height: 12),

            if (_tab == ViewTab.schedule)
              _listContent(fm, listFiltered)
            else
              _calendarContent(fm),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // UI 조각
  // ─────────────────────────────────────

  /// 상태칩(전체/과거/예정) — **아이콘 없음**, 작게, 선택 시만 컬러
  Widget _filterChips() {
    const allColor = Color(0xFF8B5CF6); // 보라
    const pastColor = Color(0xFFF59E0B); // 앰버
    const nextColor = Color(0xFF10B981); // 에메랄드

    Widget chip({
      required String label,
      required String key,
      required Color color,
    }) {
      final selected = _filterType == key;

      return ChoiceChip(
        selected: selected,
        onSelected: (_) => setState(() => _filterType = key),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -3, vertical: -4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const StadiumBorder(),
        side: BorderSide(color: selected ? color.withOpacity(.45) : kBorder),
        backgroundColor: Colors.white,
        selectedColor: _tint(color),

        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? color : kTextMain,
          ),
        ),
      );
    }

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          chip(label: '전체', key: '전체', color: allColor),
          chip(label: '과거 스케쥴', key: '과거', color: pastColor),
          chip(label: '예정 스케쥴', key: '예정', color: nextColor),
        ],
      ),
    );
  }

  /// 날짜 검색(선택/클리어)
  Widget _searchDateRow(DateFormat fm) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: _pickSearchDate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: kTextMain,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: kBorder),
            ),
          ),
          child: Text(_searchDate != null ? fm.format(_searchDate!) : '날짜 선택'),
        ),
        if (_searchDate != null)
          IconButton(
            icon: const Icon(Icons.clear, color: kTextMuted),
            onPressed: () => setState(() => _searchDate = null),
          ),
      ],
    );
  }

  // 요약 카드용 배지
  Widget _badge(IconData icon, Color color) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(.35)),
        boxShadow: [BoxShadow(color: color.withOpacity(.10), blurRadius: 8)],
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 16, color: color),
    );
  }

  // ✅ Bottom overflow 방지: 고정 height 제거 → minHeight만 지정
  Widget _metricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        // height: 88, // ❌ 고정 높이 제거
        constraints: const BoxConstraints(minHeight: 88), // ✅ 최소 높이만
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(.08), color.withOpacity(.02)],
          ),
          border: Border.all(color: color.withOpacity(.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // 내용에 맞게
          children: [
            _badge(icon, color),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: color.withOpacity(.9)),
            ),
          ],
        ),
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
    }).toList()..sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

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

    return Row(
      children: [
        _metricCard(
          icon: Icons.event,
          title: 'Next',
          value: closest != null
              ? '${closest.title} (D-${closestDaysLeft})'
              : 'None',
          color: const Color(0xFF6366F1), // 인디고
        ),
        _metricCard(
          icon: Icons.today,
          title: 'Total days',
          value: '$totalDays',
          color: const Color(0xFF06B6D4), // 시안
        ),
        _metricCard(
          icon: Icons.flight_takeoff,
          title: 'Trips',
          value: '$completed',
          color: const Color(0xFFFB7185), // 로즈
        ),
      ],
    );
  }

  // ─────────────────────────────────────
  // 리스트 탭(진행 중 + 전체)
  // ─────────────────────────────────────
  Widget _listContent(DateFormat fm, List<ScheduleResponse> filtered) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final ongoing = _all.where((s) {
      final start = DateTime(s.dateFrom.year, s.dateFrom.month, s.dateFrom.day);
      final end = DateTime(s.dateTo.year, s.dateTo.month, s.dateTo.day);
      return !today.isBefore(start) && !today.isAfter(end);
    }).toList()..sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

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
  // 카드 (공용)
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
            leadingIcon: _leadingFor(s), // 컬러풀 아이콘
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
    final upcomingSchedules =
        _filteredForCalendar
            .where(
              (s) => !DateTime(
                s.dateTo.year,
                s.dateTo.month,
                s.dateTo.day,
              ).isBefore(today),
            )
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

        // 선택한 날짜 섹션
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
              final start = DateTime(
                s.dateFrom.year,
                s.dateFrom.month,
                s.dateFrom.day,
              );
              final end = DateTime(s.dateTo.year, s.dateTo.month, s.dateTo.day);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Material(
                  color: kCard,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      final todayInRange =
                          !today.isBefore(start) && !today.isAfter(end);
                      setState(
                        () => _selectedDay = todayInRange ? today : start,
                      );
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
  // 삭제 확인 & 호출
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
        content: Text('"${schedule.title}" 스케줄을 삭제하시겠습니까?'),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('스케줄이 삭제되었습니다.')));
        await _load();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }
}
