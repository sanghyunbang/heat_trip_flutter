// lib/features/record/schedule_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ✅ 추가
import 'package:intl/intl.dart';
import 'package:heat_trip_flutter/features/record/data/model/schedule_response.dart';
import 'package:heat_trip_flutter/features/record/data/schedule_repository_impl.dart';

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  final ScheduleRepositoryImpl _repository = ScheduleRepositoryImpl();
  List<ScheduleResponse> _schedules = [];
  bool _isLoading = true;
  String? _errorMessage;

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
      setState(() => _schedules = schedules);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 스케쥴'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSchedules,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // ✅ go_router로 push하고, 결과(true)면 새로고침
              final created = await context.pushNamed<bool>('scheduleCreate');
              if (created == true) _loadSchedules();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text('에러 발생: $_errorMessage'))
          : _schedules.isEmpty
          ? const Center(child: Text('등록된 스케줄이 없습니다.'))
          : ListView.builder(
              itemCount: _schedules.length,
              itemBuilder: (context, index) {
                final s = _schedules[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(s.title),
                    subtitle: Text(
                      '${formatter.format(s.dateFrom)} ~ ${formatter.format(s.dateTo)}\n'
                      '작성자: ${s.user?.nickname ?? '알 수 없음'}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: 상세 화면 이동 (ex: context.pushNamed('scheduleDetail', pathParameters: {'id': '${s.scheduleId}'}))
                    },
                  ),
                );
              },
            ),
    );
  }
}
