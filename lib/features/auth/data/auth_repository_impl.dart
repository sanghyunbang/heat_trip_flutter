// lib/features/auth/data/auth_repository_impl.dart
//
// 목적:
// - 인증/프로필 관련 API 호출을 담당하는 Repository 구현체
// - 공용 ApiClient(헤더/토큰 자동화)를 주입받아 사용 (화면에서 new 금지)

import 'dart:convert';
import 'package:heat_trip_flutter/features/auth/data/dto/login_request.dart';
import 'package:heat_trip_flutter/features/auth/data/dto/register_request.dart';
import 'package:heat_trip_flutter/features/profile/data/dto/update_profile_request.dart';
import 'package:heat_trip_flutter/shared/network/api_client.dart';
import 'package:http/http.dart' as http;

class AuthRepositoryImpl {
  /// 공용 HTTP 클라이언트 (토큰 자동 첨부, JSON 편의 메서드 등)
  final ApiClient api;

  /// 생성자 주입: 상위(DI)에서 ApiClient를 전달
  AuthRepositoryImpl(this.api);

  // ───────────────── 로그인 ─────────────────

  /// 로그인: 성공 시 토큰 문자열 반환(계약상 200 + plain text)
  Future<String?> login(LoginRequest request) async {
    final res = await api.postJson('/auth/login', request.toJson());

    if (res.statusCode == 200) {
      // (가정) 본문에 토큰 문자열만 내려옴
      return res.body;
    }

    // (대안) JSON { "token": "..." } 라면:
    // final data = jsonDecode(res.body) as Map<String, dynamic>;
    // return data['token'] as String?;

    print('[X] 로그인 실패: ${res.statusCode} / ${res.body}');
    return null;
  }

  // ───────────────── 회원가입 ─────────────────

  /// 회원가입: 200 OK 또는 201 Created → true
  Future<bool> register(RegisterRequest request) async {
    final res = await api.postJson('/auth/signup', request.toJson());
    return res.statusCode == 200 || res.statusCode == 201;
  }

  // ───────────────── 내 프로필 조회 ─────────────────

  /// 내 프로필 조회: 성공 시 Map 반환 (Authorization 자동 첨부)
  Future<Map<String, dynamic>?> getMyProfile() async {
    final res = await api.get('/auth/me');
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    print('[X] getMyProfile 실패: ${res.statusCode} / ${res.body}');
    return null;
  }

  // ───────────────── 내 프로필 수정 ─────────────────

  /// 내 프로필 수정: 200 OK → true
  Future<bool> updateMyProfile(UpdateProfileRequest req) async {
    final res = await api.put('/auth/me', body: jsonEncode(req.toJson()));
    return res.statusCode == 200;
  }

  // ───────────────── 회원 탈퇴 ─────────────────

  /// 회원 탈퇴: 200 OK 또는 204 No Content → true
  Future<bool> deleteMyAccount() async {
    final res = await api.delete('/auth/me');
    return res.statusCode == 200 || res.statusCode == 204;
  }
}

/* ───────────── 각주 ─────────────
[에러 처리 확장]
  - 단순 bool/null 대신 커스텀 예외를 던지거나 Either<Failure, T>를 사용하면
    ViewModel에서 메시지/상태를 일관되게 관리하기 좋습니다.

[401 처리]
  - ApiClient 차원에서 401 감지 → (한 번만) 리프레시 → 재시도
  - 실패 시 AuthState.logout() 호출로 전역 로그아웃 처리 등을 공통화 권장
──────────────────────── */
