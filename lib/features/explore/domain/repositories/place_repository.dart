import 'package:heat_trip_flutter/features/explore/domain/entities/place_item.dart';

abstract class PlaceRepository {
  Future<List<PlaceItem>> getPlaceItems({String? category});
}