// lib/features/foryou/data/foryou_repository_impl.dart
//
// 도메인 레포지토리 구현(Mock).
// - energy/social만 간단히 사용하여 "열린/활기" vs "아늑/차분" 취향을 반영.
import '../domain/entities/context.dart';
import '../domain/entities/local_destination.dart';
import '../domain/foryou_repository.dart';
import 'remote/recsys_api.dart';

class ForYouRepositoryImpl implements ForYouRepository {
  final RecSysApi api;
  ForYouRepositoryImpl(this.api);

  @override
  Future<List<LocalDestination>> getTopK(Context ctx, {int k = 8}) async {
    final items = await api.fetchTopK(k);
    final preferOpen = ctx.energy >= 6 || ctx.social >= 6;
    return items
        .where((e) {
          if (preferOpen) {
            return e.type == PlaceType.city ||
                e.type == PlaceType.coastal ||
                e.type == PlaceType.cafe;
          } else {
            return e.type == PlaceType.healing ||
                e.type == PlaceType.nature ||
                e.type == PlaceType.cultural;
          }
        })
        .toList(growable: false);
  }

  @override
  Future<List<LocalDestination>> getByCategory(
    String categoryId, {
    int limit = 20,
  }) {
    return api.fetchByCategory(categoryId, limit: limit);
  }
}
