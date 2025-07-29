/* 메인 화면에서 하단 메뉴 profile 클릭 시 보여지는 화면 */
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[100],
      child: Center(
        child: Text(
          '마이페이지 화면',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }
}
