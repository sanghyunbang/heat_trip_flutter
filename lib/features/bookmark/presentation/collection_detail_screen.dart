// lib/features/bookmark/presentation/collection_detail_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';

class CollectionDetailScreen extends StatefulWidget {
  const CollectionDetailScreen({
    super.key,
    required this.collectionId,
    required this.title,
  });

  final int collectionId;
  final String title;

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  late final Future<List<_Post>> _postsFut;

  @override
  void initState() {
    super.initState();
    _postsFut = _load();
  }

  Future<List<_Post>> _load() async {
    final api = _Api();

    // 1) 컬렉션 아이템 목록(contentId + (optional) contentTypeId)
    final items = await api.fetchCollectionItems(widget.collectionId);
    if (items.isEmpty) return const <_Post>[];

    // 2) 메타 배치 조회 (imageUrl + (optional) contentTypeId) — 이미지 프리뷰 + 타입 보강
    final ids = items.map((e) => e.contentId).toList();
    final metaMap = await api.resolveMetaBatch(ids); // {contentId: {imageUrl, contentTypeId}}

    // 3) Post로 변환 (아이템에 타입 없으면 메타 배치의 타입으로 보강)
    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return items.map((it) {
      final meta = metaMap[it.contentId];
      final img = (meta?['imageUrl'] as String?) ?? '';
      final typeFromMeta = _toInt(meta?['contentTypeId']);
      final finalType = it.contentTypeId ?? typeFromMeta;

      // 최종 타입이 없으면(아주 드문 케이스) 해당 항목은 스킵
      if (finalType == null) return null;

      return _Post(
        contentId: it.contentId,
        contentTypeId: finalType,
        imageUrl: img,
      );
    }).whereType<_Post>().toList();
  }

  void _goDetail(BuildContext context, _Post post) {
    // ✅ 명명된 라우트로 즉시 이동 (탭 시 바로 화면 전환)
    context.pushNamed(
      'explore_detail',
      pathParameters: {
        'contentId': post.contentId,
        'contentTypeId': post.contentTypeId.toString(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<_Post>>(
        future: _postsFut,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '불러오는 중 오류가 발생했습니다.\n${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final posts = snap.data ?? const <_Post>[];
          if (posts.isEmpty) {
            return const Center(child: Text('이 컬렉션에 저장된 항목이 없어요'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(2),
            itemCount: posts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, i) => _PostTile(
              post: posts[i],
              onTap: () => _goDetail(context, posts[i]),
            ),
          );
        },
      ),
    );
  }
}

/* ---------------- 내부 모델/뷰/네트워크 헬퍼 ---------------- */

class _Post {
  final String contentId;
  final int contentTypeId; // go_router 이동에 필요 (최종 보장)
  final String imageUrl;
  const _Post({
    required this.contentId,
    required this.contentTypeId,
    required this.imageUrl,
  });
}

class _PostTile extends StatelessWidget {
  const _PostTile({required this.post, required this.onTap});
  final _Post post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = post.imageUrl.isNotEmpty;

    // ✅ 탭 피드백/히트영역 안정화를 위해 Material+InkWell 사용
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: hasImage ? _NetImage(post.imageUrl) : const _ThumbPlaceholder(),
        ),
      ),
    );
  }
}

class _NetImage extends StatelessWidget {
  const _NetImage(this.url);
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (c, w, p) => p == null
            ? w
            : const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorBuilder: (c, e, s) => const Center(
          child: Icon(Icons.broken_image_outlined, size: 28, color: Colors.black26),
        ),
      ),
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: Color(0xFFF3F4F6)),
      child: Center(
        child: Icon(Icons.photo_size_select_actual_outlined, color: Colors.black26, size: 22),
      ),
    );
  }
}

class _ItemSummary {
  final String contentId;
  final int? contentTypeId; // ★ nullable: 백엔드가 아직 안 줄 수도 있음
  _ItemSummary({required this.contentId, this.contentTypeId});
}

class _Api {
  final String base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('로그인이 필요합니다');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// 특정 컬렉션의 아이템(contentId + (optional) contentTypeId) 목록을 최신순으로 반환
  Future<List<_ItemSummary>> fetchCollectionItems(int collectionId) async {
    final res = await http.get(
      Uri.parse('$base/collections/$collectionId/items'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception('컬렉션 아이템 조회 실패(${res.statusCode})');
    }
    final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();

    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    // 타입 없어도 그대로 반환(나중에 메타 배치에서 보강)
    return list
        .map((e) {
      final id = (e['contentId'] ?? '').toString();
      final type = _toInt(e['contentTypeId']);
      return _ItemSummary(contentId: id, contentTypeId: type);
    })
        .where((it) => it.contentId.isNotEmpty)
        .toList();
  }

  /// 배치 메타: contentId → { imageUrl:String, contentTypeId:int? }
  Future<Map<String, Map<String, dynamic>>> resolveMetaBatch(List<String> contentIds) async {
    if (contentIds.isEmpty) return {};
    final res = await http.post(
      Uri.parse('$base/bookmarks/images:batchResolve'),
      headers: await _headers(),
      body: jsonEncode({'contentIds': contentIds}),
    );
    if (res.statusCode != 200) return {};
    final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    final out = <String, Map<String, dynamic>>{};
    for (final e in list) {
      final id = (e['contentId'] ?? '').toString();
      if (id.isEmpty) continue;
      out[id] = {
        'imageUrl': (e['imageUrl'] ?? e['firstimage'] ?? '').toString(),
        if (e['contentTypeId'] != null)
          'contentTypeId': (e['contentTypeId'] is num)
              ? (e['contentTypeId'] as num).toInt()
              : int.tryParse(e['contentTypeId'].toString()),
      };
    }
    return out;
  }
}
