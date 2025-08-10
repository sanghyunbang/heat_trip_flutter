import 'package:heat_trip_flutter/features/explore/data/sources/place_api.dart';
import 'package:heat_trip_flutter/features/explore/domain/entities/place_item.dart';
import 'package:heat_trip_flutter/features/explore/domain/repositories/place_repository.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  final PlaceApi remote;
  PlaceRepositoryImpl(this.remote);

  @override
  Future<List<PlaceItem>> getPlaceItems({String? category}) {
    return remote.fetchPlaceItems(category: category);
  }
}