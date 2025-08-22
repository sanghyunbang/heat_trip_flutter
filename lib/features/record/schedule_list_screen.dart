import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:heat_trip_flutter/features/record/data/model/schedule_response.dart';
import 'package:heat_trip_flutter/features/record/schedule_create_screen.dart';
import 'package:heat_trip_flutter/features/record/schedule_detail_screen.dart';
import 'package:heat_trip_flutter/features/record/data/schedule_repository_impl.dart';

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
      for (final s in schedules) {
        print(
          'Schedule Loaded: ${s.title}, From: ${s.dateFrom}, To: ${s.dateTo}',
        );
      }
      setState(() {
        _allSchedules = schedules;
      });
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _searchDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _searchDate = picked;
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
      backgroundColor: Colors.amber,
      appBar: AppBar(
        backgroundColor: Colors.amber,
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
                ),
                elevation: 2,
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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  buildFilterChips(),
                  const SizedBox(height: 12),
                  buildSearchBar(formatter),
                  _buildSummaryInfo(formatter),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ongoingSchedules.isNotEmpty) ...[
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
                                  onPressed: () {
                                    setState(() {
                                      _showOngoingSchedules =
                                          !_showOngoingSchedules;
                                    });
                                  },
                                  child: Text(
                                    _showOngoingSchedules ? '접기' : '보기',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_showOngoingSchedules)
                              ...ongoingSchedules.map(
                                (s) => buildScheduleCard(s, formatter),
                              ),
                            const SizedBox(height: 16),
                          ],
                          const Text(
                            '📅 전체 스케쥴',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...filteredSchedules.map(
                            (s) => buildScheduleCard(s, formatter),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
            onSelected: (_) => setState(() => _filterType = '전체'),
          ),
          ChoiceChip(
            label: const Text('지나간 스케쥴'),
            selected: _filterType == '지나간',
            onSelected: (_) => setState(() => _filterType = '지나간'),
          ),
          ChoiceChip(
            label: const Text('앞으로의 스케쥴'),
            selected: _filterType == '앞으로',
            onSelected: (_) => setState(() => _filterType = '앞으로'),
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
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchTitle = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => _selectDate(context),
          child: Text(
            _searchDate != null ? formatter.format(_searchDate!) : '날짜 선택',
          ),
        ),
        if (_searchDate != null)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => setState(() => _searchDate = null),
          ),
      ],
    );
  }

  Widget _buildSummaryInfo(DateFormat formatter) {
    if (_allSchedules.isEmpty) return const SizedBox();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcomingSchedules = _allSchedules.where((s) {
      final startDate = DateTime(
        s.dateFrom.year,
        s.dateFrom.month,
        s.dateFrom.day,
      );
      return startDate.isAtSameMomentAs(today) || startDate.isAfter(today);
    }).toList()..sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

    print('upcomingSchedules count: ${upcomingSchedules.length}');

    final closest = upcomingSchedules.isNotEmpty
        ? upcomingSchedules.first
        : null;
    final closestDaysLeft = closest != null
        ? DateTime(
                closest.dateFrom.year,
                closest.dateFrom.month,
                closest.dateFrom.day,
              ).difference(today).inDays +
              1
        : null;

    int totalTravelDays = 0;
    for (final s in _allSchedules) {
      // 이미 종료된 여행만 포함
      if (s.dateTo.isBefore(now)) {
        totalTravelDays += s.dateTo.difference(s.dateFrom).inDays + 1;
      }
    }

    final completedTrips = _allSchedules
        .where((s) => s.dateTo.isBefore(now))
        .length;

    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 12),
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
            value: '$totalTravelDays일',
          ),
          _buildInfoCard(
            icon: Icons.flight_takeoff,
            label: '여행 횟수',
            value: '$completedTrips회',
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
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

  Widget buildScheduleCard(ScheduleResponse schedule, DateFormat formatter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isPast = schedule.dateTo.isBefore(now);
    final isOngoing = !isPast && !schedule.dateFrom.isAfter(today);
    final dDayText = isOngoing
        ? '여행중'
        : _repository.getDDayText(schedule.dateFrom, schedule.dateTo);

    return Card(
      color: isPast ? Colors.grey[300] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(schedule.title)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPast ? Colors.grey : Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                dDayText,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${formatter.format(schedule.dateFrom)} ~ ${formatter.format(schedule.dateTo)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScheduleCreateScreen(schedule: schedule),
                  ),
                ).then((_) => _loadSchedules());
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('삭제 확인'),
                    content: Text('"${schedule.title}" 스케줄을 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        child: const Text('취소'),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      TextButton(
                        child: const Text(
                          '삭제',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  final error = await _repository.deleteSchedule(
                    schedule.scheduleId,
                  );
                  if (error == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('스케줄이 삭제되었습니다.')),
                    );
                    _loadSchedules();
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error)));
                  }
                }
              },
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScheduleDetailScreen(schedule: schedule),
            ),
          );
        },
      ),
    );
  }
}
