import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';
import '../widgets/zoom_buttons_widget.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  LatLng _initialPosition = const LatLng(41.0082, 28.9784); // Default initial location (Istanbul)
  LatLng _currentPosition = const LatLng(41.0082, 28.9784);
  LatLng _currentMapCenter = const LatLng(41.0082, 28.9784); // Stores the map’s current center
  Set<Marker> _markers = {};
  late GoogleMapController mapController;
  double _zoomLevel = 15.0; // Default zoom level

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    _currentPosition = await LocationService.getCurrentLocation(); 
    _initialPosition = _currentPosition; // Set initial position to current location
    _currentMapCenter = _currentPosition; // Initialize map center with initial location
    _updateMarkers(_currentPosition); // Fetch POIs for initial position
  }

  Future<void> _updateMarkers(LatLng position) async {
    final markers = await PlacesService.fetchNearbyRestaurants(position);
    setState(() {
      _markers = markers;
    });
  }

  // Refresh POIs based on current map center
  void _searchHere() {
    _updateMarkers(_currentMapCenter); // Use stored map center position
  }

  // Function to handle zoom in
  void _zoomIn() {
    if (_zoomLevel < 20) {
      setState(() {
        _zoomLevel++;
      });
      mapController.animateCamera(CameraUpdate.zoomIn());
    }
  }

  // Function to handle zoom out
  void _zoomOut() {
    if (_zoomLevel > 3) {
      setState(() {
        _zoomLevel--;
      });
      mapController.animateCamera(CameraUpdate.zoomOut());
    }
  }

  // Reset camera to initial position
  void _resetPosition() {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _initialPosition, zoom: _zoomLevel),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
          // Show Google Maps
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _currentPosition, zoom: _zoomLevel),
            markers: _markers,
            onCameraMove: (position) {
              // Update _currentMapCenter when the camera moves
              _currentMapCenter = position.target;
            },
            zoomControlsEnabled: false, // Manually create zoom in and zoom out buttons
          ),
          // "Search here" button at the top center
          Positioned(
            top: 10,
            left: MediaQuery.of(context).size.width * 0.3, // Center the button horizontally
            child: ElevatedButton(
              onPressed: _searchHere,
              child: const Text("Search here"),
            ),
          ),
          // Position Zoom and Reset Buttons at the bottom right
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
