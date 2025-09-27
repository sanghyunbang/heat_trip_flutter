// 리뷰/다이어리 등 "여러 장" 업로드 UI
// - + 버튼으로 이미지 선택 → 로컬 미리보기 → 업로드 → 업로드된 결과 썸네일 표시
// - onUploaded 콜백으로 상위에 업로드 결과 전달

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../media.dart';

class MediaGridField extends StatefulWidget {
  /// 업로드 카테고리(서버에 그대로 전달)
  final UploadCategory category;

  /// 연결 정보(refType/refId) — 서버 메타 저장용
  final String? refType;
  final String? refId;

  /// 업로드 완료 후 상위로 결과 전달
  final void Function(List<UploadedMedia>)? onUploaded;

  const MediaGridField({
    super.key,
    required this.category,
    this.refType,
    this.refId,
    this.onUploaded,
  });

  @override
  State<MediaGridField> createState() => _MediaGridFieldState();
}

class _MediaGridFieldState extends State<MediaGridField> {
  final _picker = AppMediaPicker();

  /// 업로드 중 로딩 상태
  bool _busy = false;

  /// 사용자가 고른 로컬 파일(업로드 이전의 미리보기용)
  final List<File> _locals = [];

  /// 서버 업로드가 끝난 항목들
  final List<UploadedMedia> _uploaded = [];

  /// 이미지 선택 → 업로드까지 한번에 수행
  Future<void> _pickAndUpload() async {
    // 1) 이미지 다중 선택
    final picked = await _picker.pickMultiImages();
    if (picked.isEmpty) return;

    // 2) 미리보기 표시를 위해 로컬 파일 리스트를 구성
    setState(() {
      _locals
        ..clear()
        ..addAll(picked.map((p) => File(p.path)));
      _busy = true;
    });

    try {
      // 3) 실제 업로드는 Repository에 위임
      final repo = context.read<MediaRepository>();
      final uploaded = await repo.uploadImages(
        items: picked,
        category: widget.category,
        refType: widget.refType,
        refId: widget.refId,
      );

      // 4) 성공 시 상태 업데이트 및 콜백
      setState(() {
        _uploaded.addAll(uploaded);
        _locals.clear(); // 미리보기는 제거(이제 서버 자원으로 대체)
      });
      widget.onUploaded?.call(_uploaded);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 업로드 성공 항목(네트워크) + 로컬 미리보기 + 추가 버튼을 그리드로 렌더
    final tiles = <Widget>[
      // 서버 업로드 완료된 이미지들
      ..._uploaded.map((m) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(m.url, fit: BoxFit.cover),
          )),

      // 아직 업로드 전 로컬 선택 미리보기
      ..._locals.map((f) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(f, fit: BoxFit.cover),
          )),

      // 추가(+) 버튼
      InkWell(
        onTap: _busy ? null : _pickAndUpload,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: _busy
                ? const CircularProgressIndicator()
                : const Icon(Icons.add),
          ),
        ),
      ),
    ];

    return GridView.count(
      crossAxisCount: 3, // 한 줄에 3칸
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true, // 부모 스크롤에 종속
      physics: const NeverScrollableScrollPhysics(),
      children: tiles,
    );
  }
}
