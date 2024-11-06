import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapWidget extends StatelessWidget {
  final Function(GoogleMapController) onMapCreated;
  final LatLng initialPosition;
  final Set<Marker> markers;

  const GoogleMapWidget({
    super.key,
    required this.onMapCreated,
    required this.initialPosition,
    required this.markers,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 12,
      ),
      markers: markers,
      mapType: MapType.normal,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
    );
  }
}
