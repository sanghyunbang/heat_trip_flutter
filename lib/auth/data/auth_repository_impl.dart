import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heat_trip_flutter/auth/data/dto/login_request.dart';
import 'package:heat_trip_flutter/auth/data/dto/register_request.dart';
import 'package:http/http.dart' as http;

/// 실제 HTTP 요청을 통해 백엔드와 통신하는 클래스
/// 회원가입 및 로그인 요청을 처리

class AuthRepositoryImpl {
  // .env 파일에 저장된 API_BASE_URL을 불러옴
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// 로그인 요청
  /// 서버에 이메일/비밀번호를 전달하고, 성공하면 서버가 JWT 발급
  /// 이 토큰은 클라이언트에서 저장하고 이후 인증에 사용

  Future<String?> login(LoginRequest request) async {
    // 로그인  API URL 설정
    final url = Uri.parse('$baseUrl/auth/login');

    // HTTP POST 요청 전송
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json', // JSON 형식 명시
      },
      body: jsonEncode(request.toJson()),
    );

    // 응답코드가 200이면 성공
    if (response.statusCode == 200) {
      // 백엔드가 발급한 JWT 토큰을 반환
      final token = response.body;
      return token;
    } else {
      // 실패한 경우 콘솔에 상태 코드 및 응답을 출력
      print('[X] 로그인 실패 : ${response.statusCode} / ${response.body}');
      return null;
    }
  }

  /// 회원 가입 요청
  /// - 서버에 회원 정보를 전송
  /// - 성공하면 true, 실패하면 false 반환
  Future<bool> register(RegisterRequest request) async {
    // 회원가입 API URL 설정
    final url = Uri.parse('$baseUrl/auth/signup');

    // HTTP POST 요청 전송
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()), //요청 바디를 JSON 문자열로
    );
    // 응답코드가 201(Created)이면 회원 가입 성공
    if (response.statusCode == 201) {
      return true;
    } else {
      // 실패한 경우에 콘솔에 사태 코드 및 응답 출력
      print('[X] 회원가입 실패 : ${response.statusCode} / ${response.body}');
      return false;
    }
  }
}
