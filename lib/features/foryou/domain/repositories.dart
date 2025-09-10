import 'entities.dart';

abstract class ForYouRepository {
  Future<List<RankedPlace>> fetchRanked({required RankRequest request});
  Future<List<CategoryScore>> fetchCategories({
    required RankRequest request,
    int topN,
  });
}
