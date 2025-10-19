import 'dart:math';
import 'package:flutter/foundation.dart';
import '../domain/models.dart';
import '../domain/repositories.dart';
import 'location_service.dart';

enum ForYouPhase { collecting, processing, ready, error }

class ForYouUi {
  final String mode; // 'list' | 'map'
  final String sort; // 'match' | 'distance'
  const ForYouUi({this.mode = 'list', this.sort = 'match'});
}

class ForYouVM extends ChangeNotifier {
  final ForYouRepository repo;
  final LocationService loc;
  final ValueNotifier<RankRequest> _request;
  ForYouUi ui;

  ForYouPhase phase = ForYouPhase.collecting;
  String? error;

  LlmMeta? llm;
  List<Place> places = const [];

  double? userLat;
  double? userLng;

  ForYouVM({
    required this.repo,
    required RankRequest initial,
    LocationService? locationService,
    this.ui = const ForYouUi(),
  }) : _request = ValueNotifier<RankRequest>(initial),
       loc = locationService ?? LocationService();

  RankRequest get request => _request.value;
  ValueListenable<RankRequest> get requestListenable => _request;

  Future<void> submit(RankRequest updated) async {
    _request.value = updated;
    await startProcessing(minSpinMs: 1200);
  }

  Future<void> startProcessing({int minSpinMs = 800}) async {
    phase = ForYouPhase.processing;
    error = null;
    notifyListeners();

    final t0 = DateTime.now();
    try {
      final (lat, lng) = await loc.getCurrentLatLng();
      userLat = lat;
      userLng = lng;

      final resp = await repo.recommend(
        request,
        userLat: userLat,
        userLng: userLng,
      );

      llm = resp.llm;
      places = _withDistance(resp.places);

      final elapsed = DateTime.now().difference(t0).inMilliseconds;
      if (elapsed < minSpinMs) {
        await Future.delayed(Duration(milliseconds: minSpinMs - elapsed));
      }

      _sortPlaces();
      phase = ForYouPhase.ready;
    } catch (e) {
      error = '$e';
      phase = ForYouPhase.error;
    }
    notifyListeners();
  }

  void setMode(String mode) {
    ui = ForYouUi(mode: mode, sort: ui.sort);
    notifyListeners();
  }

  void setSort(String sort) {
    ui = ForYouUi(mode: ui.mode, sort: sort);
    _sortPlaces();
    notifyListeners();
  }

  void _sortPlaces() {
    if (ui.sort == 'distance') {
      places = [...places]
        ..sort((a, b) => (a.distanceKm ?? 1e9).compareTo(b.distanceKm ?? 1e9));
    } else {
      places = [...places]
        ..sort((a, b) => b.finalScore.compareTo(a.finalScore));
    }
  }

  List<Place> _withDistance(List<Place> src) {
    if (userLat == null || userLng == null) return src;
    return src.map((p) {
      if (p.lat == null || p.lng == null) return p;
      return p.withDistanceKm(_haversine(userLat!, userLng!, p.lat!, p.lng!));
    }).toList();
  }

  static double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _deg2rad(double d) => d * pi / 180.0;
}
