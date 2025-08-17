import 'package:flutter/material.dart';

/// 탐색화면 세팅 화면
/// - 실제 Explore 화면의 동작에 맞춰 공유 상태(Provider/Bloc 등)로 연동하세요.
class ExploreViewSettingScreen extends StatefulWidget {
  const ExploreViewSettingScreen({super.key});

  @override
  State<ExploreViewSettingScreen> createState() =>
      _ExploreViewSettingScreenState();
}

class _ExploreViewSettingScreenState extends State<ExploreViewSettingScreen> {
  bool _showMapFirst = false;
  bool _showRecommendations = true;
  bool _useGridLayout = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('탐색화면 세팅')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('앱 실행 시 지도 먼저 보기'),
            value: _showMapFirst,
            onChanged: (v) => setState(() => _showMapFirst = v),
          ),
          SwitchListTile(
            title: const Text('추천 콘텐츠 섹션 보이기'),
            value: _showRecommendations,
            onChanged: (v) => setState(() => _showRecommendations = v),
          ),
          SwitchListTile(
            title: const Text('카드 대신 그리드 레이아웃 사용'),
            value: _useGridLayout,
            onChanged: (v) => setState(() => _useGridLayout = v),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '※ 실제 반영은 Explore 화면과의 상태 공유가 필요합니다.',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
