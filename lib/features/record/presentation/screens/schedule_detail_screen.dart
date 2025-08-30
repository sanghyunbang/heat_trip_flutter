import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:heat_trip_flutter/features/record/data/model/schedule_response.dart';
import 'package:heat_trip_flutter/features/record/presentation/widgets/record_ui.dart';

class ScheduleDetailScreen extends StatelessWidget {
  final ScheduleResponse schedule;
  const ScheduleDetailScreen({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    final fm = DateFormat('yyyy-MM-dd');

    return WhitePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 뒤로가기 + 타이틀
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: kTextMain),
              ),
              const SizedBox(width: 4),
              const Text(
                'Schedule Detail',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorder),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: kTextMain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.date_range, color: kTextMuted, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${fm.format(schedule.dateFrom)} ~ ${fm.format(schedule.dateTo)}',
                        style: const TextStyle(color: kTextMuted),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  const Text(
                    'Notes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        (schedule.content ?? '').trim().isEmpty
                            ? 'No content.'
                            : schedule.content!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: kTextMain,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
