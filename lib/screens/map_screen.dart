import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/places_service.dart';
import 'package:custom_info_window/custom_info_window.dart';
import '../services/location_service.dart';
import '../widgets/zoom_buttons_widget.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  LatLng _currentPosition = const LatLng(41.0082, 28.9784); // Istanbul
  LatLng _currentMapCenter = const LatLng(41.0082, 28.9784);
  Set<Marker> _markers = {};
  late GoogleMapController mapController;
  late PlacesService _placesService;
  final CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();
  double _zoomLevel = 15.0;

  @override
  void initState() {
    super.initState();
    _placesService = PlacesService(customInfoWindowController: _customInfoWindowController);
    _initializeMap();
  }

  /// Initializes map with user's current position and loads nearby markers
  Future<void> _initializeMap() async {
    _currentPosition = await LocationService.getCurrentLocation();
    _currentMapCenter = _currentPosition;
    _updateMarkers(_currentPosition);
    _resetPosition();
  }

  /// Updates markers on the map based on the new position
  Future<void> _updateMarkers(LatLng position) async {
    final markers = await _placesService.fetchNearbyRestaurants(position);
    setState(() {
      _markers = markers;
    });
  }

  /// Refreshes the map markers at the center of the current view
  void _searchHere() {
    _updateMarkers(_currentMapCenter);
  }

  /// Zooms into the map
  void _zoomIn() {
    if (_zoomLevel < 20) {
      setState(() {
        _zoomLevel++;
      });
      mapController.animateCamera(CameraUpdate.zoomIn());
    }
  }

  /// Zooms out of the map
  void _zoomOut() {
    if (_zoomLevel > 3) {
      setState(() {
        _zoomLevel--;
      });
      mapController.animateCamera(CameraUpdate.zoomOut());
    }
  }

  /// Resets the map position to the user's current location
  void _resetPosition() {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition, zoom: _zoomLevel),
      ),
    );
  }

  /// Sets up the map controller and links it with the CustomInfoWindowController
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _customInfoWindowController.googleMapController = controller;
  }

  @override
  void dispose() {
    // Dispose of the custom info window controller when the widget is destroyed
    _customInfoWindowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Restaurants Map'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          // Google Map with markers and custom info window
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _currentPosition, zoom: _zoomLevel),
            markers: _markers,
            // Update _currentMapCenter when the camera moves
            onCameraMove: (position) {
              _currentMapCenter = position.target;
              _customInfoWindowController.onCameraMove!();
            },
            onTap: (position) => _customInfoWindowController.hideInfoWindow!(),
            zoomControlsEnabled: false,
          ),
          // Custom info window widget overlay
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 150,
            width: 200,
            offset: 50,
          ),
          // "Search Here" button
          Positioned(
            top: 10,
            left: MediaQuery.of(context).size.width * 0.35,
            child: ElevatedButton(
              onPressed: _searchHere,
              child: const Text("Search here"),
            ),
          ),
          // Zoom controls at the bottom right
          Positioned(
            bottom: 30,
            right: 15,
            child: ZoomButtonsWidget(
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
              onResetPosition: _resetPosition,
            ),
          ),
        ],
      ),
    );
  }
}
