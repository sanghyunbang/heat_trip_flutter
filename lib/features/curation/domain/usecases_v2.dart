import '../../../core/utils/result.dart';
import 'entities_v2.dart';
import 'repositories_v2.dart';

/// ------------------------------------------------------------
/// Use Case: ForYou 피드를 가져오는 작업을 정의
/// ------------------------------------------------------------
class FetchForYouFeed {
  final CurationRepository repo;

  /// 의존성 주입: repository를 생성자 인자로 받음
  FetchForYouFeed(this.repo);

  /// 커서 기반 추천 피드 요청
  /// - [cursor]: 무한 스크롤을 위한 다음 포인터
  /// - [categoryId]: 특정 카테고리 ID (선택)
  /// - [size]: 요청할 피드 수 (기본값 20)
  /// - [diagnosis]: 감정 진단 결과 (개인화 추천용)
  Future<Result<ForYouFeed>> call({
    String? cursor,
    String? categoryId,
    int size = 20,
    DiagnosisResult? diagnosis,
  }) => repo.fetchForYou(
    cursor: cursor,
    categoryId: categoryId,
    size: size,
    diagnosis: diagnosis,
  );
}

/// ------------------------------------------------------------
/// Use Case: 큐레이션 사용자 이벤트 로그 저장
/// ------------------------------------------------------------
class LogCurationEvent {
  final CurationRepository repo;
  LogCurationEvent(this.repo);

  /// [CurationEvent]를 repository에 전달해 저장
  /// - 로그는 추후 flush로 서버 전송 가능
  Future<Result<void>> call(CurationEvent e) => repo.logEvent(e);
}

/// ------------------------------------------------------------
/// Use Case: 마지막으로 선택한 카테고리를 저장
/// ------------------------------------------------------------
class SaveLastCategory {
  final CurationRepository repo;
  SaveLastCategory(this.repo);

  /// 로컬에 마지막 카테고리 ID 저장
  /// - 보통 shared_preferences 또는 local db 사용
  Future<Result<void>> call(String id) => repo.saveLastCategory(id);
}

/// ------------------------------------------------------------
/// Use Case: 마지막 선택한 카테고리를 불러오기
/// ------------------------------------------------------------
class LoadLastCategory {
  final CurationRepository repo;
  LoadLastCategory(this.repo);

  /// 로컬에서 마지막 카테고리 ID 불러오기
  /// - 없으면 null 반환
  Future<Result<String?>> call() => repo.loadLastCategory();
}

/// ------------------------------------------------------------
/// Use Case: 저장해둔 이벤트 로그(flush 대상)를 서버로 전송
/// ------------------------------------------------------------
class FlushPendingLogs {
  final CurationRepository repo;
  FlushPendingLogs(this.repo);

  /// 대기 중인 로그 큐를 서버로 전송하고, 성공한 개수 반환
  /// - 네트워크 연결 시 또는 앱 재개 시 호출
  Future<Result<int>> call() => repo.flushPendingLogs();
}
