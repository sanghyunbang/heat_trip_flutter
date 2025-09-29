// 공통적으로 사용하는 타입/DTO 정의 파일
// - 서버 응답과 매핑되는 UploadedMedia
// - 로컬에서 선택된 파일을 표현하는 PickedMedia
// - 업로드 카테고리 enum(서버 UploadCategory와 문자열 이름이 일치해야 함)

/// 서버 UploadCategory와 이름을 맞춥니다 (ex: REVIEW, DIARY, PROFILE).
enum UploadCategory { JOURNEY_IMAGE, PROFILE_IMAGE, REVIEW_IMAGE }

/// 문자열 → enum 파서 (서버 응답 'category'가 문자열로 오기 때문)
UploadCategory parseCategory(String s) =>
    UploadCategory.values.firstWhere((e) => e.name == s);

/// 사용자가 기기에서 선택한 미디어(아직 서버에 업로드 전)
class PickedMedia {
  /// 기기 내 로컬 파일 경로
  final String path;

  /// 비디오 여부 (이미지/비디오 선택 UI가 섞일 수 있어 구분)
  final bool isVideo;

  /// 파일 크기(바이트). 용량 제한/경고 등에 활용 가능
  final int? bytes;

  const PickedMedia({required this.path, required this.isVideo, this.bytes});
}

/// 서버에 업로드 완료 후 반환되는 정보(메타데이터)
class UploadedMedia {
  /// 서버 DB의 식별자 (media_objects.id)
  final int id;

  /// S3 object key (DB에는 URL이 아니라 key를 저장)
  final String key;

  /// 서버가 조합해 준 공개 URL (CloudFront 등)
  final String url;

  /// MIME 타입 (예: image/jpeg)
  final String? contentType;

  /// 바이트 크기
  final int? size;

  /// 업로드 카테고리
  final UploadCategory category;

  /// 어떤 리소스와 연결되었는지(도메인 타입/ID)
  final String? refType;
  final String? refId;

  const UploadedMedia({
    required this.id,
    required this.key,
    required this.url,
    required this.category,
    this.contentType,
    this.size,
    this.refType,
    this.refId,
  });

  /// 서버 응답(JSON) → 객체 변환
  factory UploadedMedia.fromJson(Map<String, dynamic> j) => UploadedMedia(
    id: (j['id'] as num).toInt(),
    key: j['key'] as String,
    url: j['url'] as String,
    contentType: j['contentType'] as String?,
    size: (j['size'] as num?)?.toInt(),
    category: parseCategory(j['category'] as String),
    refType: j['refType'] as String?,
    refId: j['refId'] as String?,
  );
}
