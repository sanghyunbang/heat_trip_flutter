// lib/features/profile/presentation/widgets/tabs/statics_tab.dart

import 'package:flutter/material.dart';
import '../../profile.dart'; // LineChartPainter, CourseItem 등 재사용 위젯 모음

class StaticsTab extends StatelessWidget {
  const StaticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // ----- 감정 그래프 카드 -----
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '나의 감정 그래프',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Monthly Emotion Trends',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: LineChartPainter(), // 공용 라인차트 페인터
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ----- 감정별 상태 보기 -----
        const Text(
          '감정별 상태보기',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        const CourseItem(
          icon: Icons.sentiment_satisfied_alt,
          title: '기쁨',
          author: 'happiness',
          progress: 0.70,
        ),
        const SizedBox(height: 12),
        const CourseItem(
          icon: Icons.sentiment_very_dissatisfied,
          title: '슬픔',
          author: 'sadness',
          progress: 0.45,
        ),
        const SizedBox(height: 12),
        const CourseItem(
          icon: Icons.sentiment_very_dissatisfied_outlined,
          title: '두려움',
          author: 'fear',
          progress: 0.45,
        ),
      ],
    );
  }
}
