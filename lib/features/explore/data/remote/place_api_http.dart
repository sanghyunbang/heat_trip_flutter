// 실제 HTTP 통신으로 백엔드와 대화하는 구현체
// ------------------------------------------------------------
// - http.Client 사용
// - 타임아웃/에러 처리
// - 환경별 호스트 전환 (Dart-define로 주입)

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heat_trip_flutter/features/auth/token_provider.dart';
import 'package:heat_trip_flutter/features/explore/data/models/cursor_page_response.dart';
import 'package:heat_trip_flutter/features/explore/data/models/place_detail_dto.dart';
import 'package:heat_trip_flutter/features/explore/data/models/place_item_dto.dart';
import 'package:heat_trip_flutter/features/explore/data/remote/place_api.dart';
import 'package:http/http.dart' as http;
import 'package:heat_trip_flutter/core/config/env.dart';

class PlaceApiHttp implements PlaceApi {
  final String baseUrl = Env.apiBase ?? '';

  final http.Client _client;
  final Duration _timeout;

  // final TokenProvider _tokenProvider;

  PlaceApiHttp({http.Client? client, Duration? timeout})
    : _client = client ?? http.Client(),
      _timeout = timeout ?? const Duration(seconds: 10);

  @override
  Future<CursorPageResponse<PlaceItemDto>> fetchCursor({
    ExploreFilters? filters,
    String? cursor,
    int size = 20,
  }) async {
    // 1) 커서/필터 포함해 쿼리를 구성
    final query = <String, String>{
      ...?filters?.toQuery(),
      'size': '$size',
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
    };

    // 2) 요청 URL 및 헤더 구성
    final uri = Uri.parse(
      '$baseUrl/api/explore/places/scroll',
    ).replace(queryParameters: query);
    final headers = {'Content-Type': 'application/json'};

    // 3) HTTP GET 요청
    final resp = await _client.get(uri, headers: headers).timeout(_timeout);

    // 4) 에러 핸들링
    if (resp.statusCode != 200) {
      throw Exception(
        'Failed to fetch cursor page: ${resp.statusCode} - ${resp.body}',
      );
    }

    // 5) 디코딩
    final json =
        jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;

    return CursorPageResponse.fromJson<PlaceItemDto>(
      json,
      itemFromJson: (m) => PlaceItemDto.fromJson(m),
    );
  }

  @override
  Future<PlaceDetailDto> fetchDetail(int contentid) async {
    final uri = Uri.parse('$baseUrl/api/explore/places/$contentid');
    final headers = {'Content-Type': 'application/json'};
    final resp = await _client.get(uri, headers: headers).timeout(_timeout);

    if (resp.statusCode != 200) {
      throw Exception('fetchDetail failed: ${resp.statusCode} ${resp.body}');
    }

    final json =
        jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    return PlaceDetailDto.fromJson(json);
  }
}
