// lib/features/foryou/data/remote/recsys_api.dart
//
// (Mock) 추천 API 클라이언트 껍데기.
// 실제 서비스 시 HTTP 로직을 여기에 채웁니다.
import '../../domain/entities/local_destination.dart';

class RecSysApi {
  final String baseUrl;
  RecSysApi(this.baseUrl);

  // TSX 목과 유사한 샘플 데이터
  static const _list = [
    LocalDestination(
      id: 'jeju-1',
      name: '제주 올레길',
      location: '제주도',
      type: PlaceType.nature,
      rating: 4.8,
      reviewCount: 1247,
      duration: '4-6시간',
      difficulty: 'medium',
      imageUrl:
          'https://images.unsplash.com/photo-1704872451594-b4474b70cac2?w=1080&q=80',
      tags: ['자연', '걷기', '바다', '힐링'],
      description: '제주의 아름다운 자연을 걸으며 느끼는 평온한 시간',
      price: '무료',
    ),
    LocalDestination(
      id: 'busan-1',
      name: '해운대 해변',
      location: '부산',
      type: PlaceType.coastal,
      rating: 4.6,
      reviewCount: 892,
      duration: '2-3시간',
      difficulty: 'easy',
      imageUrl:
          'https://images.unsplash.com/photo-1671087478128-a4ea2e91473e?w=1080&q=80',
      tags: ['바다', '휴식', '일몰', '산책'],
      description: '부산의 대표 해변에서 즐기는 여유로운 시간',
      price: '무료',
    ),
    LocalDestination(
      id: 'seoul-1',
      name: '북촌 한옥마을',
      location: '서울',
      type: PlaceType.cultural,
      rating: 4.5,
      reviewCount: 634,
      duration: '1-2시간',
      difficulty: 'easy',
      imageUrl:
          'https://images.unsplash.com/photo-1710388766264-07a47a416e93?w=1080&q=80',
      tags: ['전통', '한옥', '문화', '사진'],
      description: '전통 한옥의 아름다움을 느낄 수 있는 문화 공간',
      price: '무료',
    ),
    LocalDestination(
      id: 'seoul-2',
      name: '홍대 카페거리',
      location: '서울',
      type: PlaceType.cafe,
      rating: 4.4,
      reviewCount: 523,
      duration: '2-4시간',
      difficulty: 'easy',
      imageUrl:
          'https://images.unsplash.com/photo-1626546143530-d8b56e09eab8?w=1080&q=80',
      tags: ['카페', '젊음', '문화', '예술'],
      description: '트렌디한 카페들이 모여있는 청춘의 거리',
      price: '15,000-25,000원',
    ),
    LocalDestination(
      id: 'temple-1',
      name: '조계사',
      location: '서울',
      type: PlaceType.healing,
      rating: 4.7,
      reviewCount: 412,
      duration: '1-2시간',
      difficulty: 'easy',
      imageUrl:
          'https://images.unsplash.com/photo-1697112725257-37064f90f2b9?w=1080&q=80',
      tags: ['명상', '평온', '영성', '힐링'],
      description: '도심 속에서 찾는 마음의 평안과 명상의 시간',
      price: '무료',
    ),
    LocalDestination(
      id: 'seoul-3',
      name: '남산타워',
      location: '서울',
      type: PlaceType.city,
      rating: 4.3,
      reviewCount: 756,
      duration: '2-3시간',
      difficulty: 'medium',
      imageUrl:
          'https://images.unsplash.com/photo-1595553919333-e9eb49a3b8d6?w=1080&q=80',
      tags: ['전망', '야경', '랜드마크', '데이트'],
      description: '서울 전경을 한눈에 볼 수 있는 대표 랜드마크',
      price: '15,000원',
    ),
  ];

  Future<List<LocalDestination>> fetchTopK(int k) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _list.take(k).toList();
  }

  Future<List<LocalDestination>> fetchByCategory(
    String categoryId, {
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    PlaceType? t;
    switch (categoryId) {
      case 'nature':
        t = PlaceType.nature;
        break;
      case 'city':
        t = PlaceType.city;
        break;
      case 'coastal':
        t = PlaceType.coastal;
        break;
      case 'cultural':
        t = PlaceType.cultural;
        break;
      case 'cafe':
        t = PlaceType.cafe;
        break;
      case 'healing':
        t = PlaceType.healing;
        break;
      default:
        t = null;
    }
    final src = t == null ? _list : _list.where((e) => e.type == t);
    return src.take(limit).toList();
  }
}
