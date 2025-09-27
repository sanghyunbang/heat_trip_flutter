// 기기에서 이미지/비디오를 선택하는 유틸리티 레이어
// - image_picker 패키지를 캡슐화하여 상위 레이어가 의존성을 직접 알 필요가 없도록 함
// - 나중에 라이브러리를 교체하더라도 이 파일만 수정하면 됨

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/media_models.dart';

class AppMediaPicker {
  final _picker = ImagePicker();

  /// 갤러리에서 여러 장의 이미지를 선택
  /// - 리뷰/다이어리 이미지 업로드에 적합
  Future<List<PickedMedia>> pickMultiImages() async {
    final xs = await _picker.pickMultiImage();
    return xs
        .map((x) => PickedMedia(
              path: x.path,
              isVideo: false,
              bytes: File(x.path).lengthSync(),
            ))
        .toList();
  }

  /// 갤러리에서 단일 비디오 선택
  /// - 현재 서버 엔드포인트는 다중도 수용하지만 UX상 보통 단일로 처리
  Future<PickedMedia?> pickSingleVideoFromGallery() async {
    final x = await _picker.pickVideo(source: ImageSource.gallery);
    if (x == null) return null;
    return PickedMedia(
      path: x.path,
      isVideo: true,
      bytes: File(x.path).lengthSync(),
    );
  }

  /// 카메라로 사진 촬영 후 단일 이미지 반환
  Future<PickedMedia?> captureImage() async {
    final x = await _picker.pickImage(source: ImageSource.camera);
    if (x == null) return null;
    return PickedMedia(
      path: x.path,
      isVideo: false,
      bytes: File(x.path).lengthSync(),
    );
  }
}
