/* 메인 화면에서 하단 메뉴 record 클릭 시 보여지는 화면 */
import 'package:flutter/material.dart';

class ScheduleListScreen extends StatelessWidget {
  const ScheduleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange[100],
      child: Center(
        child: Text(
          '스케줄러 화면',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }
}
