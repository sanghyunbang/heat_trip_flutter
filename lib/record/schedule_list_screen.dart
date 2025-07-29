import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  _ScheduleListScreenState createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  // 임시 스케줄 데이터
  final List<Map<String, dynamic>> _schedules = [
    {'title': '회의', 'date': DateTime(2025, 7, 29)},
    {'title': '점심 약속', 'date': DateTime(2025, 7, 30)},
    {'title': '프로젝트 마감', 'date': DateTime(2025, 8, 1)},
    {'title': '출장', 'date': DateTime(2025, 8, 2)},
  ];

  // 검색 상태
  String _searchTitle = '';
  DateTime? _searchDate;

  // 날짜 선택기
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _searchDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _searchDate) {
      setState(() {
        _searchDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    // 필터링된 스케줄 리스트
    final filteredSchedules = _schedules.where((schedule) {
      final titleMatch = schedule['title']
          .toString()
          .toLowerCase()
          .contains(_searchTitle.toLowerCase());
      final dateMatch = _searchDate == null ||
          formatter.format(schedule['date']) ==
              formatter.format(_searchDate!);
      return titleMatch && dateMatch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(title: const Text(' 스케쥴 ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 검색 필터 UI
            Row(
              children: [
                // 제목 검색
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
                // 날짜 검색 버튼
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

            // 스케줄 리스트
            Expanded(
              child: ListView.builder(
                itemCount: filteredSchedules.length,
                itemBuilder: (context, index) {
                  final schedule = filteredSchedules[index];
                  return Card(
                    child: ListTile(
                      title: Text(schedule['title']),
                      subtitle: Text(formatter.format(schedule['date'])),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
