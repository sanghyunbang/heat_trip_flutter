// lib/features/foryou/domain/foryou_repository.dart
//
// UI가 의존하는 추상 인터페이스 (HTTP/DB와 분리)
import 'entities/context.dart';
import 'entities/local_destination.dart';

abstract class ForYouRepository {
  Future<List<LocalDestination>> getTopK(Context ctx, {int k = 8});
  Future<List<LocalDestination>> getByCategory(
    String categoryId, {
    int limit = 20,
  });
}
