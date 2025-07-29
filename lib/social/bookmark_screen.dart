/* 메인 화면에서 하단 메뉴 bookmark 클릭 시 보여지는 화면 */
import 'package:flutter/material.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[100],
      child: Center(
        child: Text(
          '북마크 화면',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }
}
