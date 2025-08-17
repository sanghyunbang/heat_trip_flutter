/// 라이트/다크/시스템 모드 라디오 선택 (실제 적용은 상위 MaterialApp.themeMode 와 연결 필요)
import 'package:flutter/material.dart';

/// 라이트/다크/시스템 테마 모드 선택 화면
/// - 실제 앱 적용은 상위(MaterialApp)에서 themeMode를 상태로 관리하면서
///   여기서 선택한 값을 저장(예: SharedPreferences) 후 반영하면 됩니다.
class ThemeModeSettingScreen extends StatefulWidget {
  const ThemeModeSettingScreen({super.key});

  @override
  State<ThemeModeSettingScreen> createState() => _ThemeModeSettingScreenState();
}

class _ThemeModeSettingScreenState extends State<ThemeModeSettingScreen> {
  ThemeMode _mode = ThemeMode.system; // 데모용 로컬 상태

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('라이트/다크 모드 설정')),
      body: ListView(
        children: [
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: _mode,
            title: const Text('시스템 기본'),
            onChanged: (v) => setState(() => _mode = v!),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: _mode,
            title: const Text('라이트 모드'),
            onChanged: (v) => setState(() => _mode = v!),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: _mode,
            title: const Text('다크 모드'),
            onChanged: (v) => setState(() => _mode = v!),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '선택 값: $_mode\n\n'
                  '실제 앱에 적용하려면 상위에서 themeMode를 상태로 관리하고, '
                  '여기서 저장한 값을 불러와 MaterialApp.themeMode에 반영하세요.',
              style: TextStyle(color: Colors.black.withOpacity(.6)),
            ),
          ),
        ],
      ),
    );
  }
}
