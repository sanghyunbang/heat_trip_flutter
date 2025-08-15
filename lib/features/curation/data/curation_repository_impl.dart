import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'curation_local_data_source.dart';

/// Data 계층 구현: 도메인 모델 ↔ JSON 직렬화/역직렬화
class CurationRepositoryImpl implements CurationRepository {
  final CurationLocalDataSource local;
  CurationRepositoryImpl(this.local);

  @override
  Future<UserSelection?> load() async {
    final json = await local.loadJson();
    if (json == null) return null;
    return UserSelection.fromJson(json);
  }

  @override
  Future<void> reset() => local.reset();

  @override
  Future<void> save(UserSelection selection) =>
      local.saveJson(selection.toJson());
}
