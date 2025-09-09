import 'package:flutter/material.dart';
import '../../domain/models.dart';
import 'new_diary_screen.dart';

class DetailScreen extends StatelessWidget {
  final Schedule schedule;
  const DetailScreen({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(schedule.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📅 기간: ${schedule.dateFrom} ~ ${schedule.dateTo}'),
            const SizedBox(height: 8),
            Text('📍 장소: ${schedule.location ?? "미정"}'),
            const SizedBox(height: 8),
            Text('📝 내용: ${schedule.content ?? "내용 없음"}'),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.edit_note),
              label: const Text('Add Diary'),
              onPressed: () async {
                final entry = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: NewDiaryScreen(scheduleId: schedule.id),
                  ),
                );

                // 작성 후 처리 (예: 돌아가기, 새로고침 등)
                if (entry != null && context.mounted) {
                  Navigator.pop(context, true); // 작성 완료 → 뒤로
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
