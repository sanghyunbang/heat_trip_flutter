import 'entities.dart';

abstract class ForYouRepository {
  /// 여행지 랭킹 목록
  Future<List<RankedPlace>> fetchRanked({
    required RankRequest request,
    double? userLat,
    double? userLng,
  });

  /// 카테고리별 점수 목록 -> LLM에 맡기는걸로 변경
  Future<List<CategoryScore>> fetchCategories({
    required RankRequest request,
    int topN,
  });
}
