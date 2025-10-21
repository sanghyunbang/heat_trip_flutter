// lib/shared/media/widgets/media_grid_field.dart
//
// 리뷰/다이어리 등 "여러 장" 업로드 UI 위젯
// ─────────────────────────────────────────────────────────────
// 기능
//  1) + 버튼 → "카메라로 촬영 / 갤러리에서 선택" 메뉴 표시
//  2) (촬영/선택) → 로컬 미리보기 표시 → 서버 업로드 → 업로드된 썸네일로 교체
//  3) 업로드 완료 목록을 onUploaded(List<UploadedMedia>)로 상위에 전달
//
// 구성
//  - AppMediaPicker: image_picker를 감싼 유틸 (captureImage/pickMultiImages 제공)
//  - MediaRepository: 업로드/교체/삭제 비즈니스 레이어
//  - MediaApiClient: 실제 HTTP 통신(/media 컨트롤러와 1:1)
//
// 주의
//  - Android: CAMERA, READ_MEDIA_IMAGES(33+), READ_EXTERNAL_STORAGE(<=32) 권한 필요
//  - iOS: Info.plist에 NSCameraUsageDescription/NSPhotoLibraryUsageDescription 필요
//  - 이 위젯은 "업로드 완료된 URL"을 반환하므로, DiaryEntry.photos 등에 그대로 사용 가능
// ─────────────────────────────────────────────────────────────

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../media.dart';

class MediaGridField extends StatefulWidget {
  /// 업로드 카테고리(서버 UploadCategory와 문자열 이름이 일치해야 함)
  final UploadCategory category;

  /// (선택) 서버에 저장할 참조 메타 (예: refType='DIARY', refId='123')
  final String? refType;
  final String? refId;

  /// 업로드 완료 후 상위로 업로드 성공 목록을 돌려줌
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
  // 이미지/비디오 선택/촬영 유틸
  final _picker = AppMediaPicker();

  /// 업로드 중 로딩 상태 (버튼/탭 방지)
  bool _busy = false;

  /// 업로드 전 로컬 미리보기(파일)
  final List<File> _locals = [];

  /// 서버 업로드 완료 목록
  final List<UploadedMedia> _uploaded = [];

  // ─────────────────────────────────────────────
  // 갤러리에서 여러 장 선택 → 업로드
  // ─────────────────────────────────────────────
  Future<void> _pickFromGallery() async {
    // 1) 이미지 다중 선택
    final picked = await _picker.pickMultiImages();
    if (picked.isEmpty) return;

    // 2) 로컬 미리보기 먼저 보여줌(좋은 UX)
    setState(() {
      _locals
        ..clear()
        ..addAll(picked.map((p) => File(p.path)));
      _busy = true;
    });

    try {
      // 3) 업로드 실행 (비즈니스 레이어로 위임)
      final repo = context.read<MediaRepository>();
      final uploaded = await repo.uploadImages(
        items: picked,
        category: widget.category,
        refType: widget.refType,
        refId: widget.refId,
      );

      // 4) 성공 → 서버 자원으로 교체, 콜백
      setState(() {
        _uploaded.addAll(uploaded);
        _locals.clear();
      });
      widget.onUploaded?.call(List<UploadedMedia>.from(_uploaded));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ─────────────────────────────────────────────
  // 카메라로 촬영 → 업로드
  // ─────────────────────────────────────────────
  Future<void> _captureFromCamera() async {
    // 1) 카메라 촬영
    final captured = await _picker.captureImage();
    if (captured == null) return;

    // 2) 로컬 미리보기
    setState(() {
      _locals
        ..clear()
        ..add(File(captured.path));
      _busy = true;
    });

    try {
      // 3) 업로드 (단일이지만 같은 API 재사용)
      final repo = context.read<MediaRepository>();
      final uploaded = await repo.uploadImages(
        items: [captured],
        category: widget.category,
        refType: widget.refType,
        refId: widget.refId,
      );

      // 4) 성공 → 서버 자원으로 교체, 콜백
      setState(() {
        _uploaded.addAll(uploaded);
        _locals.clear();
      });
      widget.onUploaded?.call(List<UploadedMedia>.from(_uploaded));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ─────────────────────────────────────────────
  // + 버튼을 눌렀을 때 하단 시트 메뉴(촬영/갤러리)
  // ─────────────────────────────────────────────
  Future<void> _showAddMenu() async {
    if (_busy) return;
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('카메라로 촬영'),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
          ],
        ),
      ),
    );

    if (action == 'camera') {
      await _captureFromCamera();
    } else if (action == 'gallery') {
      await _pickFromGallery();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 업로드 성공(네트워크) + 로컬 미리보기 + 추가 버튼을 하나의 그리드로 구성
    final tiles = <Widget>[
      // ① 서버 업로드 완료 이미지 썸네일
      ..._uploaded.map(
        (m) => ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(m.url, fit: BoxFit.cover),
        ),
      ),

      // ② 업로드 전 로컬 미리보기(촬영/선택 직후)
      ..._locals.map(
        (f) => ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(f, fit: BoxFit.cover),
        ),
      ),

      // ③ 추가(+) 버튼 → 촬영/갤러리 선택
      InkWell(
        onTap: _busy ? null : _showAddMenu,
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
      crossAxisCount: 3,       // 한 줄에 3칸
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,        // 부모 스크롤에 종속
      physics: const NeverScrollableScrollPhysics(),
      children: tiles,
    );
  }
}
