// lib/features/bookmark/presentation/collection_list_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import 'package:heat_trip_flutter/features/bookmark/service/collection_store.dart';
import 'package:heat_trip_flutter/features/bookmark/presentation/collection_detail_screen.dart';
import 'package:heat_trip_flutter/core/config/env.dart';

class CollectionListScreen extends StatefulWidget {
  const CollectionListScreen({super.key});
  @override
  State<CollectionListScreen> createState() => _CollectionListScreenState();
}

class _CollectionListScreenState extends State<CollectionListScreen> {
  static const int _nameMaxLen = 40;
  static const Color _brand = Color(0xFFEB9C64); // 버튼/포커스 컬러

  // id -> preview image url
  Map<int, String> _thumbs = {};
  bool _loadingThumbs = false;

  @override
  void initState() {
    super.initState();
    // 컬렉션 목록 로드
    CollectionStore.instance.refresh();
    // 썸네일 초기 로드
    _loadThumbs();
    // 컬렉션 변경 감지 시 썸네일 갱신
    CollectionStore.instance.addListener(_loadThumbs);
  }

  @override
  void dispose() {
    CollectionStore.instance.removeListener(_loadThumbs);
    super.dispose();
  }

  Future<void> _loadThumbs() async {
    if (_loadingThumbs) return;
    setState(() => _loadingThumbs = true);
    try {
      final map = await _ApiColl().fetchCollectionThumbs();
      if (!mounted) return;
      setState(() {
        _thumbs = map; // { collectionId : imageUrl }
      });
    } finally {
      if (mounted) setState(() => _loadingThumbs = false);
    }
  }

  Future<void> _create() async {
    final name = await _showNameSheet(title: '새 컬렉션 이름');
    if (name != null && name.trim().isNotEmpty) {
      await CollectionStore.instance.create(name.trim());
    }
  }

  Future<void> _rename(int id, String current) async {
    final name = await _showNameSheet(title: '이름 변경', initial: current);
    if (name != null && name.trim().isNotEmpty) {
      await CollectionStore.instance.rename(id, name.trim());
    }
  }

  Future<void> _remove(int id) async {
    await CollectionStore.instance.remove(id);
  }

  /// 라운드 바텀시트 입력 모달
  Future<String?> _showNameSheet({
    required String title,
    String initial = '',
  }) async {
    String value = initial;
    String? errorText;
    bool isValid(String v) {
      final t = v.trim();
      if (t.isEmpty) return false;
      if (t.characters.length > _nameMaxLen) return false;
      return true;
    }

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final subtle = Theme.of(ctx).colorScheme.onSurfaceVariant;
        final tfController = TextEditingController(text: initial);
        value = initial;

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setState) {
              void onChanged(String v) {
                value = v;
                if (v.trim().isEmpty) {
                  errorText = '이름을 입력해 주세요';
                } else if (v.characters.length > _nameMaxLen) {
                  errorText = '최대 $_nameMaxLen자까지 입력할 수 있어요';
                } else {
                  errorText = null;
                }
                setState(() {});
              }

              final canSubmit = isValid(value);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 그랩 핸들
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: subtle.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // 타이틀
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // 입력 필드
                  TextField(
                    controller: tfController,
                    autofocus: true,
                    cursorColor: _brand, // 브랜드 컬러
                    textInputAction: TextInputAction.done,
                    onChanged: onChanged,
                    onSubmitted: (_) {
                      if (canSubmit) Navigator.pop(ctx, value);
                    },
                    maxLength: _nameMaxLen,
                    decoration: InputDecoration(
                      hintText: '예: 봄에 가볼 곳',
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFFF7F8FA),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const OutlineInputBorder( // 브랜드 컬러
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: _brand, width: 1.6),
                      ),
                      errorText: errorText,
                      suffixIcon: value.isEmpty
                          ? null
                          : IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          tfController.clear();
                          onChanged('');
                        },
                      ),
                    ),
                  ),
                  // 길이 카운터
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6, right: 4),
                      child: Text(
                        '${value.characters.length}/$_nameMaxLen',
                        style: TextStyle(fontSize: 12, color: subtle),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 액션 버튼
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _brand,
                            side: const BorderSide(color: _brand),
                            overlayColor: _brand.withOpacity(0.06),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('취소'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: canSubmit ? () => Navigator.pop(ctx, value) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _brand,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _brand.withOpacity(0.35),
                            disabledForegroundColor: Colors.white70,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('확인'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// 라운드 바텀시트 메뉴 (이름 변경/삭제)
  void _showRowMenu({required int id, required String name}) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final subtle = Theme.of(context).colorScheme.onSurfaceVariant;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: subtle.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined), // 기본색 유지
                  title: const Text('이름 변경'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _rename(id, name);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('삭제', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    await _remove(id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('컬렉션 관리'), actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: _create),
      ]),
      body: AnimatedBuilder(
        animation: CollectionStore.instance,
        builder: (_, __) {
          final items = CollectionStore.instance.items;
          if (items.isEmpty) {
            return const Center(
              child: Text(
                '컬렉션이 없습니다.\n우측 상단 + 버튼으로 만들어보세요.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final c = items[i];
              final thumb = _thumbs[c.id]; // id → 썸네일 URL

              return ListTile(
                onTap: () {
                  context.pushNamed(
                    'collection_detail',
                    pathParameters: {'collectionId': '${c.id}'},
                    queryParameters: {'title': c.name},
                  );
                },
                //   Navigator.of(context).push(
                //     MaterialPageRoute(
                //       builder: (_) => CollectionDetailScreen(
                //         collectionId: c.id,
                //         title: c.name,
                //       ),
                //     ),
                //   );
                // },
                // ★ 정사각형 미리보기 썸네일
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: (thumb != null && thumb.isNotEmpty)
                        ? _NetImage(thumb)
                        : const _ThumbPlaceholder(),
                  ),
                ),
                title: Text(c.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('항목 ${c.count}개'),
                trailing: IconButton(
                  icon: const Icon(Icons.more_horiz), // 기본색 유지
                  onPressed: () => _showRowMenu(id: c.id, name: c.name),
                  tooltip: '메뉴',
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/* ────────────── 썸네일 로드를 위한 API 래퍼 ────────────── */

class _ApiColl {
  final String base =
  (Env.apiBase ?? '').replaceAll(RegExp(r'/+$'), '');

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('로그인이 필요합니다');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// /collections 에서 최신 아이템 contentId를 받고, 배치로 이미지 URL 매핑
  /// return: { collectionId : imageUrl }
  Future<Map<int, String>> fetchCollectionThumbs() async {
    final res = await http.get(Uri.parse('$base/collections'), headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('컬렉션 조회 실패(${res.statusCode})');
    }
    final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();

    // 컬렉션 → latestItemContentId
    final latestPairs = <int, String>{}; // {collectionId: contentId}
    for (final j in list) {
      final id = (j['id'] as num).toInt();
      final latest = j['latestItemContentId']?.toString() ?? '';
      if (latest.isNotEmpty) {
        latestPairs[id] = latest;
      }
    }

    if (latestPairs.isEmpty) return {};

    // 배치로 contentId → imageUrl
    final batch = await _resolveImageUrlsBatch(latestPairs.values.toList());

    // 결과: collectionId → imageUrl
    final out = <int, String>{};
    latestPairs.forEach((colId, contentId) {
      final url = batch[contentId];
      if (url != null && url.isNotEmpty) {
        out[colId] = url;
      }
    });
    return out;
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

/* ────────────── 공용 미리보기 위젯 ────────────── */

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
        loadingBuilder: (c, w, p) =>
        p == null ? w : const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
        errorBuilder: (c, e, s) =>
        const Center(child: Icon(Icons.broken_image_outlined, size: 28, color: Colors.black26)),
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
        child: Icon(Icons.photo_size_select_actual_outlined,
            color: Colors.black26, size: 22),
      ),
    );
  }
}
