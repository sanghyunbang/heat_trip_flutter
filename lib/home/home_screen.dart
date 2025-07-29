import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container( // index 0
      color: Colors.red[100],
      child: Center(
        child: Text(
          '홈 화면',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }
}
