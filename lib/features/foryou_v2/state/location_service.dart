import 'package:geolocator/geolocator.dart';

/// 위치 권한/좌표를 단순화한 서비스
class LocationService {
  Future<(double? lat, double? lng)> getCurrentLatLng() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return (null, null);

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return (null, null);
    }
    if (perm == LocationPermission.deniedForever) {
      return (null, null);
    }

    final pos = await Geolocator.getCurrentPosition();
    return (pos.latitude, pos.longitude);
  }
}
