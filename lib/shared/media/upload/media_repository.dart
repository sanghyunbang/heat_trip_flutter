// 비즈니스 규칙/정책을 포함하는 중간 계층
// - 재시도, 압축/리사이즈, 로깅, 에러 매핑 등은 여기서
// - 상위 위젯/뷰모델은 이 레이어만 의존하도록 하여 테스트 용이성↑

import 'dart:io';
import '../models/media_models.dart';
import 'media_api_client.dart';

class MediaRepository {
  final MediaApiClient api;
  MediaRepository(this.api);

  /// 이미지 여러 장 업로드 (리뷰/다이어리에서 사용)
  /// - 필요 시 이 레이어에서 압축/리사이즈 정책을 선처리
  Future<List<UploadedMedia>> uploadImages({
    required List<PickedMedia> items,
    required UploadCategory category,
    String? refType,
    String? refId,
  }) async {
    // 비디오를 제외하고 이미지 파일만 추출
    final files =
        items.where((e) => !e.isVideo).map((e) => File(e.path)).toList();
    if (files.isEmpty) return [];

    // TODO: 압축/리사이즈가 필요하면 여기서 처리 후 files를 대체

    return api.uploadMany(
      files: files,
      category: category,
      refType: refType,
      refId: refId,
    );
  }

  /// 단일 비디오 업로드 (필요 시)
  Future<UploadedMedia?> uploadSingleVideo({
    required PickedMedia video,
    required UploadCategory category,
    String? refType,
    String? refId,
  }) async {
    final list = await api.uploadMany(
      files: [File(video.path)],
      category: category,
      refType: refType,
      refId: refId,
    );
    return list.isEmpty ? null : list.first;
  }

  /// 기존 미디어 교체(프로필 사진 등)
  Future<UploadedMedia> replace({
    required int mediaId,
    required PickedMedia media,
  }) async {
    return api.replaceFile(mediaId: mediaId, file: File(media.path));
  }

  Future<void> deleteById(int mediaId) => api.deleteById(mediaId);

  Future<void> deleteByRef({required String refType, required String refId}) =>
      api.deleteByRef(refType: refType, refId: refId);
}
