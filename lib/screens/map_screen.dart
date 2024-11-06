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
  Set<Marker> _markers = {};
  late GoogleMapController mapController;
  double _zoomLevel = 15.0; // Default zoom level

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    _currentPosition = await LocationService.getCurrentLocation(); // Get current location
    _initialPosition = _currentPosition; // Set initial position to current location
    _updateMarkers();
  }

  Future<void> _updateMarkers() async {
    final markers = await PlacesService.fetchNearbyRestaurants(_currentPosition);
    setState(() {
      _markers = markers;
    });
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: _zoomLevel)),
    );
  }

  // Function to handle zoom in
  void _zoomIn() {
    if (_zoomLevel < 20) {
      setState(() {
        _zoomLevel++;
      });
      mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: _zoomLevel)));
    }
  }

  // Function to handle zoom out
  void _zoomOut() {
    if (_zoomLevel > 3) {
      setState(() {
        _zoomLevel--;
      });
      mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: _zoomLevel)));
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

  // This will be called when the camera position changes (e.g., zooming or panning)
  void _onCameraMove(CameraPosition position) {
    setState(() {
      _zoomLevel = position.zoom; // Update the zoom level as the camera moves
    });
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
            onCameraMove: _onCameraMove,
            zoomControlsEnabled: false, // Manually create zoom in and zoom out buttons
          ),
          // Position Zoom and Reset Buttons at the bottom right
          Positioned(
            bottom: 30,
            right: 15,
            child: ZoomButtonsWidget(
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
              onResetPosition: _resetPosition, // Pass reset position callback
            ),
          ),
        ],
      ),
    );
  }
}
