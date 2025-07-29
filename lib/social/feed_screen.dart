/* 메인 화면에서 하단 메뉴 feed 클릭 시 보여지는 화면 */
import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow[100],
      child: Center(
        child: Text(
          '피드 화면',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }
}
