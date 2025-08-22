// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:heat_trip_flutter/features/explore/data/sources/place_api.dart';
// import 'package:heat_trip_flutter/features/explore/domain/entities/place_item.dart';
// import 'package:heat_trip_flutter/features/explore/domain/repositories/place_repository.dart';

// class PlaceRepositoryImpl implements PlaceRepository {
//   final PlaceApi remote;
//   PlaceRepositoryImpl(this.remote);

//   final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

//   // 현재 페이지 정보 주고 페이지네이션 값 받아오기

//   @override
//   Future<List<PlaceItem>> getPlaceItems({String? category}) {
//     return remote.fetchPlaceItems(category: category);
//   }
// }
