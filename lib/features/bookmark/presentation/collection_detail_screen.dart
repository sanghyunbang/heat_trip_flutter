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

    // 1) 이 컬렉션의 아이템 목록(최신순) 불러오기 (contentId + [optional] contentTypeId)
    final items = await api.fetchCollectionItems(widget.collectionId);
    if (items.isEmpty) return const <_Post>[];

    // 2) 타입 없는 항목은 배치로 타입 resolve(선택적; API 없으면 생략)
    final needTypeIds = items.where((e) => e.contentTypeId == null).map((e) => e.contentId).toList();
    Map<String, int> typeMap = {};
    if (needTypeIds.isNotEmpty) {
      typeMap = await api.resolveTypesBatch(needTypeIds); // 실패해도 빈 맵 반환
    }

    // 3) 이미지 배치 resolve
    final ids = items.map((e) => e.contentId).toList();
    final imgMap = await api.resolveImageUrlsBatch(ids);

    // 4) Post로 변환
    return items.map((it) {
      final typeId = it.contentTypeId ?? typeMap[it.contentId];
      return _Post(
        contentId: it.contentId,
        contentTypeId: typeId,
        imageUrl: (imgMap[it.contentId] ?? ''),
      );
    }).toList();
  }

  void _goDetail(BuildContext context, _Post post) {
    // place_card와 동일: 명명된 라우트 'explore_detail'
    if (post.contentTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상세로 이동할 수 없어요 (콘텐츠 유형 정보를 찾을 수 없음)')),
      );
      return;
    }
    context.pushNamed(
      'explore_detail',
      pathParameters: {
        'contentId': post.contentId,
        'contentTypeId': '${post.contentTypeId}',
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
              crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2, childAspectRatio: 1,
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
  final int? contentTypeId; // go_router 이동에 필요 (없으면 안내 토스트)
  final String imageUrl;
  const _Post({
    required this.contentId,
    required this.imageUrl,
    this.contentTypeId,
  });
}

class _PostTile extends StatelessWidget {
  const _PostTile({required this.post, required this.onTap});
  final _Post post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = post.imageUrl.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: hasImage ? _NetImage(post.imageUrl) : const _ThumbPlaceholder(),
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
          child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
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
  final int? contentTypeId;
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

  /// 특정 컬렉션의 아이템(contentId [+ contentTypeId]) 목록을 최신순으로 반환
  Future<List<_ItemSummary>> fetchCollectionItems(int collectionId) async {
    final res = await http.get(
      Uri.parse('$base/collections/$collectionId/items'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception('컬렉션 아이템 조회 실패(${res.statusCode})');
    }
    final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    return list.map((e) {
      final id = (e['contentId'] ?? '').toString();
      final type = e['contentTypeId'];
      return _ItemSummary(
        contentId: id,
        contentTypeId: type == null ? null : (type as num).toInt(),
      );
    }).where((it) => it.contentId.isNotEmpty).toList();
  }

  /// 배치: contentId → imageUrl
  Future<Map<String, String>> resolveImageUrlsBatch(List<String> contentIds) async {
    if (contentIds.isEmpty) return {};
    final res = await http.post(
      Uri.parse('$base/bookmarks/images:batchResolve'),
      headers: await _headers(),
      body: jsonEncode({'contentIds': contentIds}),
    );
    if (res.statusCode != 200) return {};
    final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    final out = <String, String>{};
    for (final e in list) {
      final id = (e['contentId'] ?? '').toString();
      final url = (e['imageUrl'] ?? e['firstimage'] ?? '').toString();
      if (id.isNotEmpty && url.isNotEmpty) out[id] = url;
    }
    return out;
  }

  /// (선택) 배치: contentId → contentTypeId
  /// 백엔드에 없으면 200이 아닌 상태가 될 수 있으며, 그 경우 빈 맵을 반환합니다.
  Future<Map<String, int>> resolveTypesBatch(List<String> contentIds) async {
    try {
      final res = await http.post(
        Uri.parse('$base/bookmarks/types:batchResolve'),
        headers: await _headers(),
        body: jsonEncode({'contentIds': contentIds}),
      );
      if (res.statusCode != 200) return {};
      final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
      final out = <String, int>{};
      for (final e in list) {
        final id = (e['contentId'] ?? '').toString();
        final t = e['contentTypeId'];
        if (id.isNotEmpty && t != null) out[id] = (t as num).toInt();
      }
      return out;
    } catch (_) {
      return {};
    }
  }
}
