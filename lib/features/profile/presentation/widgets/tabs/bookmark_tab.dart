// lib/features/profile/presentation/widgets/tabs/bookmark_tab.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart'; // ★ go_router 내비게이션

import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import 'package:heat_trip_flutter/features/bookmark/service/bookmark_store.dart';
import 'package:heat_trip_flutter/features/bookmark/service/collection_store.dart';
// 아래 두 import는 화면 직접 push 안 쓰면 사실 필요 없지만,
// 프로젝트 내 다른 곳에서 재사용할 수 있으니 유지해도 무방합니다.
import 'package:heat_trip_flutter/features/bookmark/presentation/collection_list_screen.dart';
import 'package:heat_trip_flutter/features/bookmark/presentation/collection_detail_screen.dart';

class BookmarkTab extends StatefulWidget {
  const BookmarkTab({
    super.key,
    this.onTapSeeAllCollections,
    this.onTapCollection,
  });

  /// 상단 “모두 보기” 콜백(없으면 컬렉션 관리 화면으로 이동)
  final VoidCallback? onTapSeeAllCollections;

  /// 컬렉션 프리뷰 클릭 콜백(없으면 상세 화면으로 이동)
  final void Function(String collectionId)? onTapCollection;

  @override
  State<BookmarkTab> createState() => _BookmarkTabState();
}

class _BookmarkTabState extends State<BookmarkTab> {
  late Future<List<_CollectionSummary>> _collectionsFut;

  @override
  void initState() {
    super.initState();
    BookmarkStore.instance.ensureInitialized();

    // 최초 로드
    _collectionsFut = _Api().fetchCollectionsAndResolvePreviews();

    // ★ 컬렉션 상태 변경되면 자동 새로고침
    CollectionStore.instance.addListener(_refreshCollections);
  }

  @override
  void dispose() {
    CollectionStore.instance.removeListener(_refreshCollections);
    super.dispose();
  }

  // ★ 서버에서 컬렉션/카운트 다시 가져오기
  void _refreshCollections() {
    if (!mounted) return;
    setState(() {
      _collectionsFut = _Api().fetchCollectionsAndResolvePreviews();
    });
  }

  // 상단 “모두 보기” 버튼 처리: 외부 콜백 없으면 관리화면 push 후 새로고침
  Future<void> _onPressSeeAll() async {
    if (widget.onTapSeeAllCollections != null) {
      widget.onTapSeeAllCollections!();
    } else {
      // ✅ GoRouter로 같은 브랜치 스택에 push → 하단바 유지
      await context.pushNamed('collection_list');
    }
    _refreshCollections();
  }

  // 프리뷰 아이템 터치: 외부 콜백 없으면 상세 push 후 새로고침
  Future<void> _openCollection(_CollectionSummary c) async {
    if (widget.onTapCollection != null) {
      widget.onTapCollection!(c.id.toString());
    } else {
      // ✅ GoRouter로 pushNamed (제목은 query로 전달)
      await context.pushNamed(
        'collection_detail',
        pathParameters: {'collectionId': c.id.toString()},
        queryParameters: {'title': c.title},
      );
    }
    _refreshCollections();
  }

  /// 그리드용: ids에 대한 메타(썸네일, contentTypeId)를 배치로 가져와 `_Post` 리스트 구성
  Future<List<_Post>> _buildPosts(List<String> ids) async {
    // 이미지 프리페치 (기존 스토어 로직 유지)
    BookmarkStore.instance.ensureImagesFor(ids);

    // 서버에서 contentTypeId와 imageUrl(백업)을 받아옴
    final metaMap = await _Api().resolveMetaBatch(ids);
    final posts = <_Post>[];

    for (final id in ids) {
      final meta = metaMap[id];
      final imageFromStore = BookmarkStore.instance.imageFor(id);
      final fallbackImage = meta?['imageUrl']?.toString() ?? '';
      final img = (imageFromStore.isNotEmpty) ? imageFromStore : fallbackImage;

      // contentTypeId가 없으면 관광지(12)로 폴백
      final ctype = (meta?['contentTypeId'] as int?) ?? 12;

      posts.add(_Post(
        contentId: id,
        contentTypeId: ctype,
        imageUrl: img,
      ));
    }
    return posts;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ─── 컬렉션 헤더 ───
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Text('컬렉션',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton(
                  onPressed: _onPressSeeAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                  ),
                  child: const Text('모두 보기', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        ),

        // ─── 컬렉션 리스트 or 빈 상태 ───
        SliverToBoxAdapter(
          child: FutureBuilder<List<_CollectionSummary>>(
            future: _collectionsFut,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: _EmptyStateCard(
                    icon: Icons.error_outline,
                    title: '컬렉션을 불러오지 못했어요',
                    subtitle: '${snap.error}',
                    actionText: '컬렉션 관리로 가기',
                    onAction: _onPressSeeAll,
                  ),
                );
              }

              final all = snap.data ?? const <_CollectionSummary>[];
              final preview = all.take(4).toList();

              if (preview.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _EmptyStateCard(
                    icon: Icons.folder_open_outlined,
                    title: '아직 만든 컬렉션이 없어요',
                    subtitle: '가보고 싶은 장소를 모아 컬렉션을 만들어보세요',
                    actionText: '컬렉션 관리로 가기',
                  ),
                );
              }

              return Column(
                children: [
                  const Divider(height: 1, thickness: 0.5, color: Color(0xFFE9E9E9)),
                  ...List.generate(preview.length, (i) {
                    final c = preview[i];
                    return Column(
                      children: [
                        _CollectionRowTile(
                          collection: c,
                          onTap: () => _openCollection(c),
                        ),
                        const Divider(height: 1, thickness: 0.5, color: Color(0xFFE9E9E9)),
                      ],
                    );
                  }),
                ],
              );
            },
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // ─── 저장한 관광지 헤더 ───
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: Row(
              children: [
                Text('내가 저장한 관광지',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Spacer(),
              ],
            ),
          ),
        ),

        // ─── 북마크 그리드 ───
        SliverToBoxAdapter(
          child: AnimatedBuilder(
            animation: BookmarkStore.instance,
            builder: (context, _) {
              final ids = BookmarkStore.instance.idsOrdered;
              if (ids.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _EmptyStateCard(
                    icon: Icons.favorite_border,
                    title: '저장한 관광지가 없어요',
                  ),
                );
              }

              // ids 기준으로 서버에서 contentTypeId/thumbnail을 배치로 가져와 `_Post` 구성
              return FutureBuilder<List<_Post>>(
                future: _buildPosts(ids),
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: _EmptyStateCard(
                        icon: Icons.error_outline,
                        title: '목록을 불러오지 못했어요',
                        subtitle: '${snap.error}',
                      ),
                    );
                  }

                  final posts = snap.data ?? const <_Post>[];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: posts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, i) => _PostTile(post: posts[i]),
                    ),
                  );
                },
              );
            },
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

/* ───────────────── 내부 모델 ───────────────── */

class _CollectionSummary {
  final int id;
  final String title;
  final int count;
  final String? latestItemContentId;
  String? latestItemImageUrl;

  _CollectionSummary({
    required this.id,
    required this.title,
    required this.count,
    this.latestItemContentId,
    this.latestItemImageUrl,
  });

  factory _CollectionSummary.fromJson(Map<String, dynamic> j) {
    return _CollectionSummary(
      id: (j['id'] as num).toInt(),
      title: (j['name'] ?? '').toString(),
      count: (j['count'] as num?)?.toInt() ?? 0,
      latestItemContentId:
      j['latestItemContentId'] == null ? null : j['latestItemContentId'].toString(),
    );
  }
}

class _Post {
  final String contentId;
  final int contentTypeId;
  final String imageUrl;
  const _Post({
    required this.contentId,
    required this.contentTypeId,
    required this.imageUrl,
  });
}

/* ────────────── 서버 통신 유틸 ────────────── */

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

  /// 컬렉션 목록 + 프리뷰 4개의 썸네일 resolve
  Future<List<_CollectionSummary>> fetchCollectionsAndResolvePreviews() async {
    final res = await http.get(Uri.parse('$base/collections'), headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('컬렉션 조회 실패(${res.statusCode})');
    }
    final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    final cols = list.map(_CollectionSummary.fromJson).toList();

    final preview =
    cols.take(4).where((c) => (c.latestItemContentId ?? '').isNotEmpty).toList();

    if (preview.isNotEmpty) {
      final ids = preview.map((c) => c.latestItemContentId!).toList();
      final batch = await resolveMetaBatch(ids);
      for (final c in preview) {
        final m = batch[c.latestItemContentId!];
        c.latestItemImageUrl = (m?['imageUrl'] as String?) ?? '';
      }
    }
    return cols;
  }

  /// contentIds → { imageUrl:String, contentTypeId:int } 맵으로 반환
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
      final ctype = (e['contentTypeId'] is num)
          ? (e['contentTypeId'] as num).toInt()
          : int.tryParse('${e['contentTypeId']}');

      if (id.isEmpty || ctype == null) {
        // 필수 누락: 스킵
        continue;
      }
      out[id] = {
        'imageUrl': (e['imageUrl'] ?? e['firstimage'] ?? '').toString(),
        'contentTypeId': ctype,
      };
    }
    return out;
  }
}

/* ────────────── 위젯들 ────────────── */

class _CollectionRowTile extends StatelessWidget {
  const _CollectionRowTile({required this.collection, required this.onTap});
  final _CollectionSummary collection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: (collection.latestItemImageUrl != null &&
                      collection.latestItemImageUrl!.isNotEmpty)
                      ? _NetImage(collection.latestItemImageUrl!)
                      : const _ThumbPlaceholder(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text('항목 ${collection.count}개',
                        style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9DA3AA)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostTile extends StatelessWidget {
  const _PostTile({required this.post});
  final _Post post;

  @override
  Widget build(BuildContext context) {
    final hasImage = post.imageUrl.isNotEmpty;
    return GestureDetector(
      onTap: () {
        // ✅ go_router: explore_detail 라우트로 이동 (Provider 스코프 유지)
        context.pushNamed(
          'explore_detail',
          pathParameters: {
            'contentId': post.contentId, // String
            'contentTypeId': post.contentTypeId.toString(),
          },
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: hasImage ? _NetImage(post.imageUrl) : const _ThumbPlaceholder(),
          ),
        ],
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
                width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
        errorBuilder: (c, e, s) => const Center(
            child: Icon(Icons.broken_image_outlined, size: 28, color: Colors.black26)),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 46, color: subtle),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!,
                style: TextStyle(fontSize: 13, color: subtle),
                textAlign: TextAlign.center),
          ],
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 14),
            TextButton(onPressed: onAction, child: Text(actionText!, style: const TextStyle(fontSize: 13))),
          ],
        ],
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
