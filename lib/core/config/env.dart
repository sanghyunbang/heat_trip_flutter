import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static const _fromDefine = String.fromEnvironment('API_BASE', defaultValue: '');
  static String get apiBase => _fromDefine.isNotEmpty ? _fromDefine : (dotenv.env['API_BASE_URL'] ?? '');
}
