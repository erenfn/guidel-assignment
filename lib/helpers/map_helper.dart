import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapHelper {
  // Function to handle zoom in
  static double zoomIn(double zoomLevel) {
    if (zoomLevel < 20) {
      return zoomLevel + 1;
    }
    return zoomLevel;
  }

  // Function to handle zoom out
  static double zoomOut(double zoomLevel) {
    if (zoomLevel > 3) {
      return zoomLevel - 1;
    }
    return zoomLevel;
  }


  // Handle mouse scroll zoom functionality
static void handleZoomScroll(
    DragUpdateDetails details,
    double zoomLevel,
    Function(double) setZoomLevel,
    GoogleMapController controller,
    LatLng currentPosition,
  ) {
    double newZoomLevel = zoomLevel;  // Store updated zoom level

    // Increase zoom when scrolling up, decrease zoom when scrolling down
    if (details.primaryDelta! > 0) {
      // Scrolling down (zoom out)
      if (zoomLevel < 20) {
        newZoomLevel = zoomLevel + 1;  // Update zoom level
      }
    } else if (details.primaryDelta! < 0) {
      // Scrolling up (zoom in)
      if (zoomLevel > 3) {
        newZoomLevel = zoomLevel - 1;  // Update zoom level
      }
    }

    // Call setZoomLevel to update the state in the parent widget
    setZoomLevel(newZoomLevel);

    // Animate camera to the new zoom level
    controller.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: currentPosition, zoom: newZoomLevel)),
    );
  }


  // Update markers logic if needed in future.
  static void updateMarkers(Set<Marker> markers, GoogleMapController controller, LatLng currentPosition, double zoomLevel) {
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
          CameraPosition(target: currentPosition, zoom: zoomLevel)),
    );
  }
}
