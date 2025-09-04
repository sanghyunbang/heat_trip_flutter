import 'package:flutter/material.dart';

/// "감정 기반 추천" 카드(설명 + 맞춤 뱃지)
class MoodRecommendCard extends StatelessWidget {
  const MoodRecommendCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xE6EAFBF1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const ListTile(
        leading: Icon(Icons.explore, color: Colors.green),
        title: Text('감정 기반 추천'),
        subtitle: Text('분석 결과에 따른 맞춤 여행지'),
        trailing: Chip(
          label: Text('맞춤'),
          backgroundColor: Colors.green,
          labelStyle: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
