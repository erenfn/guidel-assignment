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
  LatLng _currentPosition =
      const LatLng(41.0082, 28.9784); // Default placeholder (Istanbul)
  Set<Marker> _markers = {};
  late GoogleMapController mapController;
  double _zoomLevel = 15.0; // Default zoom level

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    _currentPosition = await LocationService
        .getCurrentLocation(); // Get custom or actual location
    _updateMarkers();
  }

  Future<void> _updateMarkers() async {
    final markers =
        await PlacesService.fetchNearbyRestaurants(_currentPosition);
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

  // This will be called when the camera position changes (e.g., zooming or panning)
  void _onCameraMove(CameraPosition position) {
    setState(() {
      _zoomLevel = position.zoom; // Update the zoom level as the camera moves
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

    // Handle mouse scroll zoom functionality
  void _handleZoomScroll(DragUpdateDetails details) {
    // Increase zoom when scrolling up, decrease zoom when scrolling down
    if (details.primaryDelta! > 0) {
      // Scrolling down (zoom out)
      if (_zoomLevel < 20) {
        setState(() {
          _zoomLevel++;
        });
      }
    } else if (details.primaryDelta! < 0) {
      // Scrolling up (zoom in)
      if (_zoomLevel > 3) {
        setState(() {
          _zoomLevel--;
        });
      }
    }

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: _currentPosition, zoom: _zoomLevel)),
    );
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
            zoomControlsEnabled: false, // to manually create the zoom in and zoom out buttons
          ),
          // Position Zoom Buttons at the bottom right
          Positioned(
            bottom: 30,
            right: 15,
            child: ZoomButtonsWidget(
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
            ),
          ),
        ],
      ),
    );
  }
}
