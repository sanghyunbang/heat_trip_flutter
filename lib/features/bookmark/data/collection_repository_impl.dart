import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import 'package:heat_trip_flutter/features/bookmark/domain/collection_repository.dart';
import 'package:http/http.dart' as http;
import 'package:heat_trip_flutter/core/config/env.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final String base = (Env.apiBase ?? '').replaceAll(RegExp(r'/+$'), '');

  Future<Map<String, String>> _headers() async {
    final t = await TokenStorage.getToken();
    if (t == null) throw Exception('로그인이 필요합니다');
    return {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $t'};
  }

  @override
  Future<List<CollectionSummary>> list() async {
    final r = await http.get(Uri.parse('$base/collections'), headers: await _headers());
    if (r.statusCode != 200) throw Exception('컬렉션 조회 실패');
    final list = (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
    return list.map(CollectionSummary.fromJson).toList(); // ★ fromJson이 contentTypeId도 처리
  }

  @override
  Future<CollectionSummary> create(String name) async {
    final r = await http.post(Uri.parse('$base/collections'),
        headers: await _headers(), body: jsonEncode({'name': name}));
    if (r.statusCode != 200 && r.statusCode != 201) throw Exception('컬렉션 생성 실패');
    return CollectionSummary.fromJson(jsonDecode(r.body));
  }

  @override
  Future<void> rename(int id, String name) async {
    final r = await http.put(Uri.parse('$base/collections/$id'),
        headers: await _headers(), body: jsonEncode({'name': name}));
    if (r.statusCode != 200) throw Exception('이름 변경 실패');
  }

  @override
  Future<void> delete(int id) async {
    final r = await http.delete(Uri.parse('$base/collections/$id'), headers: await _headers());
    if (r.statusCode != 204) throw Exception('삭제 실패');
  }
}
