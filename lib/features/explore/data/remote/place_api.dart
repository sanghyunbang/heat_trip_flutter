import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heat_trip_flutter/features/explore/data/models/cursor_page_response.dart';
import 'package:heat_trip_flutter/features/explore/data/models/place_detail_dto.dart';
import 'package:heat_trip_flutter/features/explore/data/models/place_item_dto.dart';

// 서버 검색 필터를 Flutter에서 표현(필요한 키만 노출)

class ExploreFilters {
  final int? areacode; // 지역 코드 (시도/구군)
  final int? sigungucode; // 시군구 코드 (동/읍면)
  final String? cat1; // 카테고리 코드 (대분류)
  final String? cat2; // 카테고리 코드 (중분류)
  final String? cat3; // 카테고리 코드 (소분류)
  final List<String>? cat3List; // 여러개 소분류 묶음으로 전달

  const ExploreFilters({
    this.areacode,
    this.sigungucode,
    this.cat1,
    this.cat2,
    this.cat3,
    this.cat3List,
  });

  // 쿼리 파라미터를 맵으로 변환

  Map<String, String> toQuery() {
    final params = <String, String>{};

    if (areacode != null) {
      params['areacode'] = areacode.toString();
    }
    if (sigungucode != null) {
      params['sigungucode'] = sigungucode.toString();
    }
    if (cat1 != null && cat1!.isNotEmpty) {
      params['cat1'] = cat1!;
    }
    if (cat2 != null && cat2!.isNotEmpty) {
      params['cat2'] = cat2!;
    }

    // 핵심: 리스트가 우선. 없으면 단일 cat3
    // 주의 모내는건 어쨌뜬 'cat3'
    if (cat3List != null && cat3List!.isNotEmpty) {
      params['cat3'] = cat3List!.join(',');
    } else if (cat3 != null && cat3!.isNotEmpty) {
      params['cat3'] = cat3!;
    }

    return params;
  }
}

/// Explore용 api 동작 정의 (목록 / 커서 / 상세)

abstract class PlaceApi {
  /// 커서 기반 목록(무한 스크롤)
  Future<CursorPageResponse<PlaceItemDto>> fetchCursor({
    ExploreFilters? filters,
    String? cursor,
    int size = 20,
  });

  /// 상세 화면에서 장소 정보 가져오기
  Future<PlaceDetailDto> fetchDetail(int contentid);
}
