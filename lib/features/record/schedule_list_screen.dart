import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'schedule_create_screen.dart';

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  _ScheduleListScreenState createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  final List<Map<String, dynamic>> _schedules = [
    {
      'title': '농장체험',
      'dateRange': DateTimeRange(
        start: DateTime(2025, 7, 28),
        end: DateTime(2025, 7, 29),
      ),
      'image':
          'https://media.istockphoto.com/id/2206475453/ko/%EC%82%AC%EC%A7%84/sunset.jpg?s=1024x1024&w=is&k=20&c=8Q5VIUclm0kSyi4jHhOGK-cVu5PpIG0i_YuSJagG7Gk=',
    },
    {
      'title': '템플 스테이',
      'dateRange': DateTimeRange(
        start: DateTime(2025, 7, 30),
        end: DateTime(2025, 7, 30),
      ),
      'image':
          'https://cdn.pixabay.com/photo/2020/07/19/14/15/sky-5420151_1280.jpg',
    },
    {
      'title': '카페투어',
      'dateRange': DateTimeRange(
        start: DateTime(2025, 8, 1),
        end: DateTime(2025, 8, 2),
      ),
      'image':
          'https://cdn.pixabay.com/photo/2024/05/15/16/15/sky-8763986_1280.jpg',
    },
    {
      'title': '대부도 힐링',
      'dateRange': DateTimeRange(
        start: DateTime(2025, 8, 2),
        end: DateTime(2025, 8, 4),
      ),
      'image':
          'https://cdn.pixabay.com/photo/2019/05/11/17/31/lamps-4196132_1280.jpg',
    },
  ];

  String _searchTitle = '';
  DateTime? _searchDate;
  String _filterType = '전체';

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

    final ongoingSchedules = _schedules.where((schedule) {
      final dateRange = schedule['dateRange'] as DateTimeRange;
      return now.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
          now.isBefore(dateRange.end.add(const Duration(days: 1)));
    }).toList();

    final filteredSchedules = _schedules.where((schedule) {
      final titleMatch = schedule['title'].toString().toLowerCase().contains(
        _searchTitle.toLowerCase(),
      );

      final dateRange = schedule['dateRange'] as DateTimeRange;
      final dateMatch =
          _searchDate == null ||
          (_searchDate!.isAfter(
                dateRange.start.subtract(const Duration(days: 1)),
              ) &&
              _searchDate!.isBefore(
                dateRange.end.add(const Duration(days: 1)),
              ));

      final isPast = dateRange.end.isBefore(now);
      final isFuture = dateRange.start.isAfter(now);

      final filterMatch =
          _filterType == '전체' ||
          (_filterType == '지나간' && isPast) ||
          (_filterType == '앞으로' && isFuture);

      return titleMatch && dateMatch && filterMatch;
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
                    builder: (context) => const ScheduleCreateScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
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
            ),
            const SizedBox(height: 12),
            Row(
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
                    _searchDate != null
                        ? formatter.format(_searchDate!)
                        : '날짜 선택',
                  ),
                ),
                if (_searchDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchDate = null;
                      });
                    },
                  ),
              ],
            ),
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
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ongoingSchedules.length,
                        itemBuilder: (context, index) {
                          final schedule = ongoingSchedules[index];
                          final dateRange =
                              schedule['dateRange'] as DateTimeRange;
                          return buildScheduleCard(
                            schedule,
                            dateRange,
                            formatter,
                          );
                        },
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
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredSchedules.length,
                      itemBuilder: (context, index) {
                        final schedule = filteredSchedules[index];
                        final dateRange =
                            schedule['dateRange'] as DateTimeRange;
                        return buildScheduleCard(
                          schedule,
                          dateRange,
                          formatter,
                        );
                      },
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

  Widget buildScheduleCard(
    Map<String, dynamic> schedule,
    DateTimeRange dateRange,
    DateFormat formatter,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.hardEdge,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(schedule['image']),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 텍스트
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatter.format(dateRange.start)} ~ ${formatter.format(dateRange.end)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // TODO: 수정 기능 연결
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
