import 'dart:math';
import 'package:flutter/foundation.dart';
import '../domain/models.dart';
import '../domain/repositories.dart';
import 'location_service.dart';

/// 페이즈: 수집 → 처리중 → 결과 → 오류
enum ForYouPhase { collecting, processing, ready, error }

/// 보기/정렬 UI 상태
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

  EmotionAnalysis? analysis;
  TravelTheme? theme;
  List<TravelCategory> categories = const [];
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

  /// 입력 저장 후 처리 시작
  Future<void> submit(RankRequest updated) async {
    _request.value = updated;
    await startProcessing(minSpinMs: 1200);
  }

  /// 추천 요청(최소 로딩 표시 시간 포함)
  Future<void> startProcessing({int minSpinMs = 800}) async {
    phase = ForYouPhase.processing;
    error = null;
    notifyListeners();

    final t0 = DateTime.now();
    try {
      // 현재 위치 시도(거부/실패시 null)
      final (lat, lng) = await loc.getCurrentLatLng();
      userLat = lat;
      userLng = lng;

      // API 호출
      final resp = await repo.recommend(
        request,
        userLat: userLat,
        userLng: userLng,
      );
      analysis = resp.analysis;
      theme = resp.theme;
      categories = resp.categories;
      places = _withDistance(resp.places);

      // 로딩 최소시간 보장
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

  // Haversine: km
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
