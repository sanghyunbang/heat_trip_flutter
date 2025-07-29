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
    {'title': '회의', 'date': DateTime(2025, 7, 29), 'image': 'https://media.istockphoto.com/id/2206475453/ko/%EC%82%AC%EC%A7%84/sunset.jpg?s=1024x1024&w=is&k=20&c=8Q5VIUclm0kSyi4jHhOGK-cVu5PpIG0i_YuSJagG7Gk='},
    {'title': '점심 약속', 'date': DateTime(2025, 7, 30), 'image' : 'https://cdn.pixabay.com/photo/2020/07/19/14/15/sky-5420151_1280.jpg'},
    {'title': '프로젝트 마감', 'date': DateTime(2025, 8, 1), 'image' : 'https://cdn.pixabay.com/photo/2024/05/15/16/15/sky-8763986_1280.jpg'},
    {'title': '출장', 'date': DateTime(2025, 8, 2), 'image' : 'https://cdn.pixabay.com/photo/2019/05/11/17/31/lamps-4196132_1280.jpg'},
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
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(' 스케쥴 ')),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((255 * 0.3).toInt()),  // 반투명 오버레이
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            schedule['title'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              shadows: [
                Shadow(blurRadius: 2, color: Colors.black),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('yyyy-MM-dd').format(schedule['date']),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              shadows: [
                Shadow(blurRadius: 2, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
    ),
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
