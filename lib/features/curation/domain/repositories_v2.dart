import 'entities_v2.dart';
import '../../../core/utils/result.dart';

/// 큐레이션 관련 데이터 처리 추상 리포지토리.
/// - 데이터 소스(REST API, 로컬 캐시 등)와 상관없이 사용될 도메인 계층의 인터페이스.
/// - 실제 구현체는 `data` 계층에서 이 인터페이스를 상속받아 작성함.
abstract class CurationRepository {
  /// [ForYouFeed] 데이터를 가져오는 메서드 (추천 피드).
  ///
  /// - [cursor]: 커서 기반 페이지네이션을 위한 포인터(기존 응답의 nextCursor 등).
  /// - [categoryId]: 선택된 카테고리 ID (사용자가 특정 카테고리를 선택한 경우).
  /// - [size]: 요청할 피드 아이템 개수 (기본 페이지 크기).
  /// - [diagnosis]: 사용자의 감정 진단 결과 (PAD 기반 추천 등).
  ///
  /// [Result]로 감싸서 성공/실패 여부를 처리 (Success<ForYouFeed> or Failure).
  Future<Result<ForYouFeed>> fetchForYou({
    String? cursor,
    String? categoryId,
    int size,
    DiagnosisResult? diagnosis,
  });

  /// 사용자 행동 이벤트(예: 추천 클릭, 감정 선택 등)를 로그로 저장.
  ///
  /// - 오프라인 환경에서도 작동하도록 구현할 수 있음.
  /// - 나중에 서버로 일괄 전송(`flushPendingLogs`) 가능.
  Future<Result<void>> logEvent(CurationEvent event);

  /// 사용자가 마지막으로 선택한 카테고리 ID를 로컬에 저장.
  ///
  /// - 앱 재시작 시 사용자가 이전에 선택한 카테고리를 기억해 자동 적용 가능.
  /// - 보통 shared_preferences 또는 secure storage 등에 저장됨.
  Future<Result<void>> saveLastCategory(String categoryId);

  /// 로컬에서 마지막 선택한 카테고리 ID를 불러오기.
  ///
  /// - 저장된 값이 없다면 null이 될 수 있음.
  Future<Result<String?>> loadLastCategory();

  /// 오프라인 상태에서 저장해둔 로그들을 서버에 전송 (flush).
  ///
  /// - 예: 로그를 큐에 저장해 두었다가 앱이 온라인 상태일 때 전송.
  /// - 반환값: 성공적으로 전송된 로그 개수.
  /// - 앱 재개 시 또는 네트워크 연결 시 호출하는 것이 일반적.
  Future<Result<int>> flushPendingLogs();
}
