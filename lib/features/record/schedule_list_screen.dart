import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:heat_trip_flutter/features/record/data/model/schedule_response.dart';
import 'package:heat_trip_flutter/features/record/schedule_create_screen.dart';
import 'package:heat_trip_flutter/features/record/data/schedule_repository_impl.dart';
import 'package:heat_trip_flutter/features/record/schedule_detail_screen.dart';

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
    final now = DateTime.now();

    final filteredSchedules = _allSchedules.where((schedule) {
      final titleMatch = schedule.title.toLowerCase().contains(
        _searchTitle.toLowerCase(),
      );

      final dateMatch =
          _searchDate == null ||
          (_searchDate!.isAfter(
                schedule.dateFrom.subtract(const Duration(days: 1)),
              ) &&
              _searchDate!.isBefore(
                schedule.dateTo.add(const Duration(days: 1)),
              ));

      final isPast = schedule.dateTo.isBefore(now);
      final isFuture = schedule.dateFrom.isAfter(now);

      final filterMatch =
          _filterType == '전체' ||
          (_filterType == '지나간' && isPast) ||
          (_filterType == '앞으로' && isFuture);

      return titleMatch && dateMatch && filterMatch;
    }).toList();

    final ongoingSchedules = _allSchedules.where((schedule) {
      return now.isAfter(schedule.dateFrom.subtract(const Duration(days: 1))) &&
          now.isBefore(schedule.dateTo.add(const Duration(days: 1)));
    }).toList();

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
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ongoingSchedules.isNotEmpty) ...[
                            const Text(
                              '📌 현재 진행 중인 스케쥴',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
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

  Widget buildScheduleCard(ScheduleResponse schedule, DateFormat formatter) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(schedule.title),
        subtitle: Text(
          '${formatter.format(schedule.dateFrom)} ~ ${formatter.format(schedule.dateTo)}',
        ),
        isThreeLine: false,
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
