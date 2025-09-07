import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/bookmark/service/collection_store.dart';

/// 브랜드 컬러
const Color _brand = Color(0xFFEB9C64);

/// 바텀시트 결과
class CollectionPickerResult {
  /// null이면 '일반 저장(컬렉션 없이)'
  final int? collectionId;

  /// 북마크 해제를 선택했을 때 true
  final bool removed;

  const CollectionPickerResult({this.collectionId, this.removed = false});
}

/// 인스타 스타일: 하트를 눌렀을 때 띄우는 바텀시트
/// - alreadyBookmarked: 현재 북마크 상태(해제 버튼 노출 여부 판단)
Future<CollectionPickerResult?> showCollectionPickerSheet(
    BuildContext context, {
      required bool alreadyBookmarked,
    }) async {
  // 최신 목록 보장
  await CollectionStore.instance.refresh();

  const int _maxVisibleRows = 4;    // 최대 보이는 줄 수
  const double _rowExtent = 68.0;   // 아이템 대략 높이(타일 + 패딩)
  const double _dividerHeight = 1;  // 구분선 높이

  return showModalBottomSheet<CollectionPickerResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 그랩 핸들
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Row(
                children: [
                  const Text(
                    '어디에 저장할까요?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: '새 컬렉션',
                    onPressed: () async {
                      final name = await _promptNewCollection(ctx);
                      if (name != null && name.trim().isNotEmpty) {
                        await CollectionStore.instance.create(name.trim());
                        // 시트 다시 그리기 (목록 즉시 반영)
                        (ctx as Element).markNeedsBuild();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 목록 (최대 4줄까지만 확장 → 그 이상은 스크롤)
              AnimatedBuilder(
                animation: CollectionStore.instance,
                builder: (_, __) {
                  final items = CollectionStore.instance.items;
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 22),
                      child: Text('생성된 컬렉션이 없습니다. + 버튼으로 만들어보세요.'),
                    );
                  }

                  final int visible = items.length > _maxVisibleRows
                      ? _maxVisibleRows
                      : items.length;
                  final double maxHeight = (visible * _rowExtent) +
                      (visible > 1 ? (visible - 1) * _dividerHeight : 0);

                  return SizedBox(
                    height: maxHeight,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: _dividerHeight),
                      itemBuilder: (_, i) {
                        final c = items[i];
                        return SizedBox(
                          height: _rowExtent, // ✅ 고정 높이
                          child: ListTile(
                            onTap: () => Navigator.pop(
                              ctx,
                              CollectionPickerResult(collectionId: c.id),
                            ),
                            title: Text(
                              c.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text('항목 ${c.count}개'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              // 일반 저장(컬렉션 없이) 버튼 — 브랜드 색상
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(
                    ctx,
                    const CollectionPickerResult(collectionId: null),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('그냥 저장하기'),
                ),
              ),

              if (alreadyBookmarked) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(
                      ctx,
                      const CollectionPickerResult(removed: true),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _brand,
                      side: const BorderSide(color: _brand),
                      overlayColor: _brand.withOpacity(0.06),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('북마크 해제'),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

/// 새 컬렉션 이름 입력(센터 모달)
Future<String?> _promptNewCollection(BuildContext context) async {
  final ctrl = TextEditingController();
  String value = '';
  String? errorText;

  bool canSubmit(String v) => v.trim().isNotEmpty;

  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          void onChanged(String v) {
            value = v;
            errorText = v.trim().isEmpty ? '이름을 입력해 주세요' : null;
            setState(() {});
          }

          final enabled = canSubmit(value);

          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            // ⬇️ 글씨 크기 살짝 줄임
            title: const Text(
              '새 컬렉션',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            contentPadding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onChanged: onChanged,
              onSubmitted: (_) {
                if (enabled) Navigator.pop(ctx, value.trim());
              },
              cursorColor: _brand,
              decoration: InputDecoration(
                hintText: '예: 제주도 맛집',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: _brand, width: 1.6),
                ),
                errorText: errorText,
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _brand,
                  side: const BorderSide(color: _brand),
                  overlayColor: _brand.withOpacity(0.06),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('취소'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: enabled ? () => Navigator.pop(ctx, value.trim()) : null,
                style: FilledButton.styleFrom(
                  backgroundColor: _brand,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _brand.withOpacity(0.35),
                  disabledForegroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('생성'),
              ),
            ],
          );
        },
      );
    },
  );
}
