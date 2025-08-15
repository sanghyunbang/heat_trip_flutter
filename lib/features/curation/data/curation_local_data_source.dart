import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// WHAT: 웹의 localStorage에 해당하는 간단한 로컬 KV 저장
class CurationLocalDataSource {
  static const String key = 'emotionEnvironmentData';

  Future<void> saveJson(Map<String, dynamic> json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(json));
  }

  Future<Map<String, dynamic>?> loadJson() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(key);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
