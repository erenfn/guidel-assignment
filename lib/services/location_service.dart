import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  // Istanbul's coordinates
  static const LatLng _istanbulLocation = LatLng(41.0082, 28.9784);

  static Future<LatLng> getCurrentLocation() async {
    return _istanbulLocation;
  }
}
