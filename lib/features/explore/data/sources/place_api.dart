import 'package:heat_trip_flutter/features/explore/data/models/place_item_dto.dart';

abstract class PlaceApi {
  Future<List<PlaceItemDto>> fetchPlaceItems({String? category});
}

class MockPlaceApi implements PlaceApi {
  // mock 데이터
  static const _all = <PlaceItemDto>[
    PlaceItemDto(
      contentid: 1,
      title: '잼배옥',
      addr1: '서울특별시 중구 세종대로9길 68-9',
      addr2: '',
      firstimage: 'http://tong.visitkorea.or.kr/cms/resource/01/2669001_image2_1.jpg',
      firstimage2: 'http://tong.visitkorea.or.kr/cms/resource/01/2669001_image2_1.jpg',
      // overview: '',
    ),
    PlaceItemDto(
      contentid: 2,
      title: '오우가',
      addr1: '서울특별시 중구 명동8가길 42',
      addr2: '',
      firstimage: '',
      firstimage2: '',
      // overview: '',
    ),
    PlaceItemDto(
      contentid: 3,
      title: '윤슬숯불구이 명동본점',
      addr1: '서울특별시 중구 명동10길 19-3 (명동2가)',
      addr2: '1층(명동2가, 삼존빌딩)',
      firstimage: 'http://tong.visitkorea.or.kr/cms/resource/87/3493087_image2_1.jpg',
      firstimage2: 'http://tong.visitkorea.or.kr/cms/resource/87/3493087_image3_1.jpg',
      // overview: '',
    ),
    PlaceItemDto(
      contentid: 4,
      title: '곰국시집',
      addr1: '서울특별시 중구 무교로 24 (무교동)',
      addr2: '2층',
      firstimage: 'http://tong.visitkorea.or.kr/cms/resource/18/3474918_image2_1.jpg',
      firstimage2: 'http://tong.visitkorea.or.kr/cms/resource/18/3474918_image3_1.jpg',
      // overview: '',
    ),
    PlaceItemDto(
      contentid: 5,
      title: '너비집',
      addr1: '서울특별시 중구 명동9길 37-8',
      addr2: '',
      firstimage: '',
      firstimage2: '',
      // overview: '',
    ),
    PlaceItemDto(
      contentid: 6,
      title: '남문토방',
      addr1: '서울특별시 중구 남대문시장길 45-3',
      addr2: '',
      firstimage: 'http://tong.visitkorea.or.kr/cms/resource/28/3474928_image2_1.jpg',
      firstimage2: 'http://tong.visitkorea.or.kr/cms/resource/28/3474928_image3_1.jpg',
      // overview: '',
    ),
    PlaceItemDto(
      contentid: 7,
      title: '은호식당',
      addr1: '서울특별시 중구 남대문시장4길 28-4 (남창동)',
      addr2: '',
      firstimage: '',
      firstimage2: '',
      // overview: '',
    ),
  ];

  @override
  Future<List<PlaceItemDto>> fetchPlaceItems({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 로딩 느낌
    if (category == null || category.isEmpty) return _all;
    // 간단한 카테고리 필터: 제목에 카테고리 문자열 포함 여부
    return _all.where((e) => e.title.toLowerCase().contains(category.toLowerCase())).toList();
  }
}