// lib/features/foryou/data/remote/recsys_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../dto/context_dto.dart';
import '../dto/rank_item_dto.dart';
import '../dto/feedback_dto.dart';

/// 추천 API와 통신하는 클래스 (REST 기반)
/// → 추천 요청, 피드백 전송 등 모든 API 호출은 이 클래스를 통해 수행
class RecSysApi {
  final String baseUrl; // 예: http://localhost:8000

  RecSysApi(this.baseUrl);

  /// 카테고리 추천 요청 (/rank/categories)
  /// [ctx]: 추천 입력값 (PAD + 환경값)
  /// [k]: 추천 개수 (Top-K)
  Future<List<RankItemDto>> rankCategories(ContextDto ctx, {int k = 8}) async {
    final uri = Uri.parse('$baseUrl/rank/categories?k=$k');

    // POST 요청: JSON 바디로 context 전송
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(ctx.toJson()),
    );

    // 오류 처리: 응답이 200이 아니면 예외 발생
    if (res.statusCode != 200) {
      throw Exception('rank failed: ${res.statusCode} ${res.body}');
    }

    // 응답은 JSON 배열 → RankItemDto 리스트로 변환
    final List data = jsonDecode(res.body);
    return data.map((e) => RankItemDto.fromJson(e)).toList();
  }

  /// 피드백 전송 (/feedback)
  /// [fb]: 선택된 카테고리 및 보상 포함한 객체
  Future<void> sendFeedback(FeedbackDto fb) async {
    final uri = Uri.parse('$baseUrl/feedback');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(fb.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception('feedback failed: ${res.statusCode} ${res.body}');
    }
  }
}
