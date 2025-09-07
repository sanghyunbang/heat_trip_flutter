// lib/features/profile/presentation/widgets/tabs/bookmark_tab.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import 'package:heat_trip_flutter/features/bookmark/service/bookmark_store.dart';
import 'package:heat_trip_flutter/features/bookmark/service/collection_store.dart'; // ★ 추가
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
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => const CollectionListScreen()),
      );
    }
    _refreshCollections();
  }

  // 프리뷰 아이템 터치: 외부 콜백 없으면 상세 push 후 새로고침
  Future<void> _openCollection(_CollectionSummary c) async {
    if (widget.onTapCollection != null) {
      widget.onTapCollection!(c.id.toString());
    } else {
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => CollectionDetailScreen(
            collectionId: c.id,
            title: c.title,
          ),
        ),
      );
    }
    _refreshCollections();
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
                  onPressed: _onPressSeeAll, // ★ 변경
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
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _EmptyStateCard(
                    icon: Icons.folder_open_outlined,
                    title: '아직 만든 컬렉션이 없어요',
                    subtitle: '가보고 싶은 장소를 모아 컬렉션을 만들어보세요',
                    actionText: '컬렉션 관리로 가기',
                    onAction: _onPressSeeAll,
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
                          onTap: () => _openCollection(c), // ★ 변경
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
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: Row(
              children: const [
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

              // 이미지 비동기 로드
              BookmarkStore.instance.ensureImagesFor(ids);

              final posts = ids
                  .map((id) => _Post(
                contentId: id,
                imageUrl: BookmarkStore.instance.imageFor(id),
              ))
                  .toList();

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
  final String imageUrl;
  const _Post({required this.contentId, required this.imageUrl});
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
    if (res.statusCode != 200) throw Exception('컬렉션 조회 실패(${res.statusCode})');
    final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    final cols = list.map(_CollectionSummary.fromJson).toList();

    final preview =
    cols.take(4).where((c) => (c.latestItemContentId ?? '').isNotEmpty).toList();
    if (preview.isNotEmpty) {
      final ids = preview.map((c) => c.latestItemContentId!).toList();
      final batch = await _resolveImageUrlsBatch(ids);
      for (final c in preview) {
        c.latestItemImageUrl = batch[c.latestItemContentId!];
      }
    }
    return cols;
  }

  Future<Map<String, String>> _resolveImageUrlsBatch(List<String> contentIds) async {
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
        // TODO: 상세 이동 시 post.contentId 사용
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
            child:
            SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
        errorBuilder: (c, e, s) =>
        const Center(child: Icon(Icons.broken_image_outlined, size: 28, color: Colors.black26)),
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
            Text(subtitle!, style: TextStyle(fontSize: 13, color: subtle), textAlign: TextAlign.center),
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
