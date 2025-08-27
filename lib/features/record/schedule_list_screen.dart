import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:heat_trip_flutter/features/record/data/model/schedule_response.dart';
import 'package:heat_trip_flutter/features/record/schedule_create_screen.dart';
import 'package:heat_trip_flutter/features/record/schedule_detail_screen.dart';
import 'package:heat_trip_flutter/features/record/data/schedule_repository_impl.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});
  @override
  _ScheduleListScreenState createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  final ScheduleRepositoryImpl _repository = ScheduleRepositoryImpl();
  List<ScheduleResponse> _allSchedules = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _searchTitle = '';
  DateTime? _searchDate;
  String _filterType = '전체';
  bool _showOngoingSchedules = true;

  // 달력 보기 관련 상태 값
  bool _isCalendarView = false;
  Map<DateTime, List<ScheduleResponse>> _events = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now(); // 달력에서 오늘 날짜
  DateTime? _selectedDay; //유저가 선택한 날짜

  // 디자인 토큰(보더 컬러/라운드)
  static const Color _borderColor = Color(0xFFE5E7EB); // slate-200 유사
  static const double _radius = 12.0;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final schedules = await _repository.fetchSchedules();
      setState(() {
        _allSchedules = schedules;
      });
      _groupEventsByDate();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _groupEventsByDate() {
    final filtered = _repository.filterSchedules(
      all: _allSchedules,
      title: _searchTitle,
      date: _searchDate,
      filterType: _filterType,
    );

    final Map<DateTime, List<ScheduleResponse>> data = {};
    for (final schedule in filtered) {
      DateTime date = DateTime(
        schedule.dateFrom.year,
        schedule.dateFrom.month,
        schedule.dateFrom.day,
      );
      final end = DateTime(
        schedule.dateTo.year,
        schedule.dateTo.month,
        schedule.dateTo.day,
      );
      while (!date.isAfter(end)) {
        final key = DateTime(date.year, date.month, date.day);
        data.putIfAbsent(key, () => []).add(schedule);
        date = date.add(const Duration(days: 1));
      }
    }

    setState(() {
      _events = data;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _searchDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _searchDate = picked;
        _groupEventsByDate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    final filteredSchedules = _repository.filterSchedules(
      all: _allSchedules,
      title: _searchTitle,
      date: _searchDate,
      filterType: _filterType,
    );
    final ongoingSchedules = _repository.getOngoingSchedules(_allSchedules);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 237, 221),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 247, 246, 245),
        elevation: 0, // 그림자 제거
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          // 상단 AppBar에도 아주 얇은 하단 보더
          bottom: BorderSide(color: _borderColor, width: 1),
        ),
        title: const Text('내 스케쥴'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(
                    color: _borderColor,
                    width: 1,
                  ), // 버튼 외곽선
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              icon: const Icon(Icons.add),
              label: const Text('스케쥴 작성'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScheduleCreateScreen(),
                  ),
                ).then((_) => _loadSchedules());
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text('에러 발생: $_errorMessage'))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildFilterChips(),
                    const SizedBox(height: 12),
                    buildSearchBar(formatter),
                    _buildSummaryInfo(formatter),
                    const SizedBox(height: 10),
                    buildViewToggleChips(),
                    const SizedBox(height: 12),
                    _isCalendarView
                        ? buildCalendarView(formatter)
                        : buildListView(
                            formatter,
                            ongoingSchedules,
                            filteredSchedules,
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildFilterChips() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text('전체'),
            selected: _filterType == '전체',
            onSelected: (_) => setState(() {
              _filterType = '전체';
              _groupEventsByDate();
            }),
            side: const BorderSide(color: _borderColor), // 칩 외곽선
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          ChoiceChip(
            label: const Text('지나간 스케쥴'),
            selected: _filterType == '지나간',
            onSelected: (_) => setState(() {
              _filterType = '지나간';
              _groupEventsByDate();
            }),
            side: const BorderSide(color: _borderColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          ChoiceChip(
            label: const Text('앞으로의 스케쥴'),
            selected: _filterType == '앞으로',
            onSelected: (_) => setState(() {
              _filterType = '앞으로';
              _groupEventsByDate();
            }),
            side: const BorderSide(color: _borderColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar(DateFormat formatter) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 45,
            child: TextField(
              decoration: const InputDecoration(
                labelText: '제목 검색',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 21, 89, 224),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 27, 89, 214),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 16, 79, 206),
                    width: 2,
                  ),
                ),
              ),
              onChanged: (v) => setState(() {
                _searchTitle = v;
                _groupEventsByDate();
              }),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: _borderColor, width: 1), // 버튼 외곽선
            ),
          ),
          onPressed: () => _selectDate(context),
          child: Text(
            _searchDate != null ? formatter.format(_searchDate!) : '날짜 선택',
          ),
        ),
        if (_searchDate != null)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => setState(() {
              _searchDate = null;
              _groupEventsByDate();
            }),
          ),
      ],
    );
  }

  Widget buildViewToggleChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text('리스트 보기'),
          selected: !_isCalendarView,
          onSelected: (_) => setState(() {
            _isCalendarView = false;
            _groupEventsByDate();
          }),
          side: const BorderSide(color: _borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('달력 보기'),
          selected: _isCalendarView,
          onSelected: (_) => setState(() {
            _isCalendarView = true;
            _groupEventsByDate();
          }),
          side: const BorderSide(color: _borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }

  Widget buildCalendarView(DateFormat formatter) {
    final eventsForSelectedDay = _selectedDay != null
        ? (_events[_selectedDay!] ?? [])
        : [];

    return Column(
      children: [
        TableCalendar<ScheduleResponse>(
          firstDay: DateTime(2020, 1, 1),
          lastDay: DateTime(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {CalendarFormat.month: '월간'},
          selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
          onDaySelected: (sel, foc) {
            setState(() {
              _selectedDay = DateTime(sel.year, sel.month, sel.day);
              _focusedDay = foc;
            });
          },
          onPageChanged: (foc) => _focusedDay = foc,
          eventLoader: (day) {
            final key = DateTime(day.year, day.month, day.day);
            return _events[key] ?? [];
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final key = DateTime(day.year, day.month, day.day);
              final schedulesForDay = _events[key] ?? [];

              if (schedulesForDay.isEmpty) return null;

              final s = schedulesForDay.first;
              final from = DateTime(
                s.dateFrom.year,
                s.dateFrom.month,
                s.dateFrom.day,
              );
              final to = DateTime(s.dateTo.year, s.dateTo.month, s.dateTo.day);

              Color bgColor;
              final today = DateTime.now();

              if (to.isBefore(today)) {
                bgColor = const Color.fromARGB(
                  255,
                  241,
                  178,
                  115,
                ).withOpacity(0.8);
              } else if (!from.isAfter(today) && !to.isBefore(today)) {
                bgColor = Colors.white.withOpacity(0.8);
              } else {
                bgColor = Colors.yellow.withOpacity(0.8);
              }

              final isStart = key == from;
              final isEnd = key == to;
              final isSingle = from == to;

              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: isSingle
                      ? BorderRadius.circular(10)
                      : BorderRadius.horizontal(
                          left: isStart
                              ? const Radius.circular(10)
                              : Radius.zero,
                          right: isEnd
                              ? const Radius.circular(10)
                              : Radius.zero,
                        ),
                  border: Border.all(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),

          calendarStyle: const CalendarStyle(
            markersMaxCount: 0,
            markerDecoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedDay != null && eventsForSelectedDay.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: eventsForSelectedDay.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '📌 선택한 날짜의 스케쥴',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              }
              final schedule = eventsForSelectedDay[index - 1];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScheduleDetailScreen(schedule: schedule),
                    ),
                  );
                },
                child: buildScheduleCard(schedule, formatter),
              );
            },
          ),
      ],
    );
  }

  Widget buildListView(
    DateFormat formatter,
    List<ScheduleResponse> ongoing,
    List<ScheduleResponse> filtered,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ongoing.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📌 현재 진행 중인 스케쥴',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(
                    () => _showOngoingSchedules = !_showOngoingSchedules,
                  ),
                  child: Text(
                    _showOngoingSchedules ? '접기' : '보기',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_showOngoingSchedules)
              ...ongoing.map((s) => buildScheduleCard(s, formatter)),
            const SizedBox(height: 16),
          ],
          const Text(
            '📅 전체 스케쥴',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w200,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          ...filtered.map((s) => buildScheduleCard(s, formatter)),
        ],
      ),
    );
  }

  Widget _buildSummaryInfo(DateFormat formatter) {
    if (_allSchedules.isEmpty) return const SizedBox();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcoming = _allSchedules.where((s) {
      final start = DateTime(s.dateFrom.year, s.dateFrom.month, s.dateFrom.day);
      return start.isAtSameMomentAs(today) || start.isAfter(today);
    }).toList()..sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

    final closest = upcoming.isNotEmpty ? upcoming.first : null;
    final closestDaysLeft = closest != null
        ? DateTime(
                closest.dateFrom.year,
                closest.dateFrom.month,
                closest.dateFrom.day,
              ).difference(today).inDays +
              1
        : null;

    int totalDays = 0;
    for (var s in _allSchedules) {
      if (s.dateTo.isBefore(now)) {
        totalDays += s.dateTo.difference(s.dateFrom).inDays + 1;
      }
    }

    final completed = _allSchedules.where((s) => s.dateTo.isBefore(now)).length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoCard(
            icon: Icons.event,
            label: '가까운 일정',
            value: closest != null
                ? '${closest.title} (D-${closestDaysLeft})'
                : '없음',
          ),
          _buildInfoCard(
            icon: Icons.today,
            label: '총 여행일수',
            value: '$totalDays일',
          ),
          _buildInfoCard(
            icon: Icons.flight_takeoff,
            label: '여행 횟수',
            value: '$completed회',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: _borderColor, width: 1), // ✅ 외곽선
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.redAccent, size: 18),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget buildScheduleCard(ScheduleResponse s, DateFormat fm) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isPast = s.dateTo.isBefore(now);
    final isOngoing = !isPast && !s.dateFrom.isAfter(today);
    final dDayText = isOngoing
        ? '여행중'
        : _repository.getDDayText(s.dateFrom, s.dateTo);

    final Color? bgColor = isPast
        ? Colors.grey[200]
        : isOngoing
        ? Colors.orange[100]
        : Colors.lightBlue[50];

    // 상태에 따라 아주 살짝 진한 보더
    final Color borderForState = isPast
        ? const Color(0xFFCBD5E1) // slate-300
        : isOngoing
        ? const Color(0xFFF59E0B) // amber-500 근처
        : const Color(0xFF60A5FA); // blue-400 근처

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(
          color: borderForState.withOpacity(0.6),
          width: 1,
        ), // ✅ 외곽선
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              buildDDayBadge(dDayText, isPast),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScheduleCreateScreen(schedule: s),
                    ),
                  ).then((_) => _loadSchedules());
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _confirmDelete(s),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text('${fm.format(s.dateFrom)} ~ ${fm.format(s.dateTo)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDDayBadge(String text, bool isPast) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPast
              ? [Colors.grey, Colors.black38]
              : [Colors.redAccent, Colors.deepOrange],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1), // 뱃지에도 얇은 외곽선
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(ScheduleResponse schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        elevation: 0, // 그림자 제거
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: const BorderSide(color: _borderColor, width: 1), // ✅ 외곽선
        ),
        title: const Text('삭제 확인'),
        content: Text('"${schedule.title}" 스케줄을 삭제하시겠습니까?'),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: _borderColor, width: 1), // 버튼 외곽선
              ),
              foregroundColor: Colors.black87,
              backgroundColor: Colors.white,
            ),
            child: const Text('취소'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: _borderColor, width: 1),
              ),
              foregroundColor: Colors.red,
              backgroundColor: Colors.white,
            ),
            child: const Text('삭제'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final error = await _repository.deleteSchedule(schedule.scheduleId);
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('스케줄이 삭제되었습니다.'),
            elevation: 0,
            behavior: SnackBarBehavior.floating, // 떠 있게 하면 외곽선이 잘 보임
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: _borderColor, width: 1), // ✅ 외곽선
            ),
            margin: const EdgeInsets.all(12),
            backgroundColor: Colors.white,
            // 텍스트 컬러 대비를 위해
          ),
        );
        _loadSchedules();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: _borderColor, width: 1),
            ),
            margin: const EdgeInsets.all(12),
            backgroundColor: Colors.white,
          ),
        );
      }
    }
  }
}
