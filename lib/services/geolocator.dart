// @dart=2.9

import 'package:geolocator/geolocator.dart';

class GeolocatorService {
  final Geolocator geo = Geolocator();
  Stream<Position> getStreamLocation() {
    return Geolocator.getPositionStream(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.best));
  }

  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
  }

  Future<Position> getLastLocation() async {
    return await Geolocator.getLastKnownPosition();
  }
}
