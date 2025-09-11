import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import 'package:heat_trip_flutter/features/bookmark/domain/bookmark_repository.dart';
import 'package:http/http.dart' as http;
import 'package:heat_trip_flutter/core/config/env.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  final String base = (Env.apiBase ?? '').replaceAll(RegExp(r'/+$'), '');

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('로그인이 필요합니다');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<String>> fetchAllOrdered() async {
    // 서버가 정렬을 지원한다면 쿼리 파라미터를 사용하세요(스프링 데이터 JPA 예시)
    // final url = Uri.parse('$base/bookmarks').replace(queryParameters: {'sort':'createdAt,desc'});
    final url = Uri.parse('$base/bookmarks');
    final r = await http.get(url, headers: await _headers());
    if (r.statusCode != 200) return const <String>[];

    final list = (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();

    // createdAt이 있으면 클라에서 한 번 더 안전하게 최신순 정렬
    final rows = list.map((j) {
      final id = (j['contentId'] ?? '').toString();
      final createdAtStr = (j['createdAt'] ?? '').toString();
      final createdAt = DateTime.tryParse(createdAtStr);
      return _Row(id: id, createdAt: createdAt);
    }).where((e) => e.id.isNotEmpty).toList();

    rows.sort((a, b) {
      final A = a.createdAt, B = b.createdAt;
      if (A == null && B == null) return 0;
      if (A == null) return 1;  // null은 뒤로
      if (B == null) return -1;
      return B.compareTo(A);     // 최신이 먼저
    });

    // createdAt이 없으면 서버가 준 순서를 신뢰(기본 그대로 반환)
    if (rows.every((e) => e.createdAt == null)) {
      return list.map((e) => (e['contentId'] ?? '').toString()).where((id) => id.isNotEmpty).toList();
    }
    return rows.map((e) => e.id).toList();
  }

  @override
  Future<void> add(String contentId, {String? collectionId}) async {
    await http.post(
      Uri.parse('$base/bookmarks'),
      headers: await _headers(),
      body: jsonEncode({'contentId': contentId, if (collectionId != null) 'collectionId': collectionId}),
    );
  }

  @override
  Future<void> remove(String contentId) async {
    await http.delete(Uri.parse('$base/bookmarks/$contentId'), headers: await _headers());
  }

  @override
  Future<Map<String, String>> fetchImagesBatch(List<String> contentIds) async {
    if (contentIds.isEmpty) return {};
    final r = await http.post(
      Uri.parse('$base/bookmarks/images:batchResolve'),
      headers: await _headers(),
      body: jsonEncode({'contentIds': contentIds}),
    );
    if (r.statusCode != 200) return {};
    final list = (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
    final out = <String, String>{};
    for (final e in list) {
      final id = (e['contentId'] ?? '').toString();
      final url = (e['imageUrl'] ?? e['firstimage'] ?? '').toString();
      if (id.isNotEmpty && url.isNotEmpty) out[id] = url;
    }
    return out;
  }

  @override
  Future<String?> fetchImage(String contentId) async {
    final r = await http.get(Uri.parse('$base/bookmarks/img/$contentId'), headers: await _headers());
    if (r.statusCode != 200) return null;
    final j = (jsonDecode(r.body) as Map<String, dynamic>);
    final url = (j['imageUrl'] ?? j['firstimage'] ?? '').toString().trim();
    return url.isEmpty ? null : url;
  }
}

class _Row {
  final String id;
  final DateTime? createdAt;
  _Row({required this.id, required this.createdAt});
}
