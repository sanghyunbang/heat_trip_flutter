import 'entities.dart';
import 'repositories.dart';

/// WHY: UI가 저장소 구현을 직접 몰라도 되도록 유스케이스로 경계 생성
class SaveSelection {
  final CurationRepository repo;
  SaveSelection(this.repo);
  Future<void> call(UserSelection selection) => repo.save(selection);
}

class LoadSelection {
  final CurationRepository repo;
  LoadSelection(this.repo);
  Future<UserSelection?> call() => repo.load();
}

class ResetSelection {
  final CurationRepository repo;
  ResetSelection(this.repo);
  Future<void> call() => repo.reset();
}
