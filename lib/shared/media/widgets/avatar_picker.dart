// 프로필 사진 변경에 특화된 위젯
// - 원형 아바타 + 우하단 편집 버튼
// - 갤러리에서 사진 선택 → 업로드/교체 → URL 교체 표시

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../media.dart';

class AvatarPicker extends StatefulWidget {
  /// 초기 프로필 이미지 URL (없으면 placeholder)
  final String? initialUrl;

  /// 업로드/교체 완료 콜백
  final void Function(UploadedMedia media)? onUploaded;

  /// 이미 존재하는 mediaId에 대한 교체 모드라면 세팅
  final int? existingMediaId;

  const AvatarPicker({
    super.key,
    this.initialUrl,
    this.onUploaded,
    this.existingMediaId,
  });

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  final _picker = AppMediaPicker();

  /// 현재 표시 중인 URL (교체되면 갱신)
  String? _url;

  /// 로컬 미리보기 파일
  File? _local;

  /// 업로드/교체 진행 플래그
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _url = widget.initialUrl;
  }

  Future<void> _change() async {
    // 1) 갤러리에서 사진 1장 선택
    final picked = await _picker.captureImage() ?? await _picker.pickSingleVideoFromGallery(); // 우선 카메라, 실패 시 갤러리 비디오 체크(예시)
    if (picked == null || picked.isVideo) {
      // 프로필은 이미지만 허용하는 것이 보통이므로 비디오는 무시
      final img = await _picker.pickMultiImages();
      if (img.isEmpty) return;
      // 실제로는 pickImageFromGallery 하나로 단일 이미지를 받는 구현이 더 적합
      _local = File(img.first.path);
    } else {
      _local = File(picked.path);
    }
    setState(() {});

    // 2) 업로드/교체 실행
    setState(() => _busy = true);
    try {
      final repo = context.read<MediaRepository>();
      UploadedMedia up;

      if (widget.existingMediaId != null) {
        // 기존 mediaId가 있으면 교체 API 사용
        up = await repo.replace(
          mediaId: widget.existingMediaId!,
          media: PickedMedia(path: _local!.path, isVideo: false),
        );
      } else {
        // 없으면 새 업로드 (PROFILE 카테고리)
        final list = await repo.uploadImages(
          items: [PickedMedia(path: _local!.path, isVideo: false)],
          category: UploadCategory.PROFILE,
          refType: 'PROFILE',
          refId: 'ME', // 필요 시 실제 사용자 ID로 교체
        );
        up = list.first;
      }

      // 3) UI 갱신 및 콜백
      setState(() {
        _url = up.url;
        _local = null; // 로컬 미리보기 제거
      });
      widget.onUploaded?.call(up);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const radius = 40.0;

    // 표시할 아바타 소스 선택: 로컬 미리보기 > 네트워크 > 플레이스홀더
    Widget avatar;
    if (_local != null) {
      avatar = CircleAvatar(radius: radius, backgroundImage: FileImage(_local!));
    } else if (_url != null) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(_url!),
      );
    } else {
      avatar = const CircleAvatar(radius: radius, child: Icon(Icons.person));
    }

    return Stack(
      children: [
        avatar,
        // 우하단 편집 버튼 (로딩 중 비활성화)
        Positioned(
          right: 0,
          bottom: 0,
          child: IconButton.filled(
            onPressed: _busy ? null : _change,
            icon: const Icon(Icons.edit),
            tooltip: 'Change avatar',
          ),
        ),
      ],
    );
  }
}
