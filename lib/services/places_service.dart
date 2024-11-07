import 'dart:convert';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidel_assignment/widgets/custom_info_window.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlacesService {
final CustomInfoWindowController customInfoWindowController;

  PlacesService({required this.customInfoWindowController});

  /// Fetches nearby restaurants within a given [radius] (default 1km) from the given [currentPosition].
  ///
  /// This method makes a request to the Google Places API to find restaurants
  /// near the provided location. If the request is successful, it returns a set of [Marker] objects
  /// representing the nearby restaurants. The markers include details such
  /// as the restaurant's name, coordinates, and a photo.
  ///
  /// Parameters:
  /// - [currentPosition]: A [LatLng] object representing the current location
  ///   from which nearby restaurants will be searched.
  ///
  /// Returns:
  /// - A [Set<Marker>] representing the nearby restaurants. Each marker includes
  ///   the restaurant's position, name, vicinity, and coordinates.
  ///   If the restaurant has a photo, it will be displayed; otherwise, a placeholder image is used.

  Future<Set<Marker>> fetchNearbyRestaurants(LatLng currentPosition,
      {int radius = 1000}) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

    // Construct the API URL with the current position and search parameters
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${currentPosition.latitude},${currentPosition.longitude}'
      '&radius=$radius&type=restaurant&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];

        // Create markers for each restaurant
        return results.map<Marker>((result) {
          final LatLng position = LatLng(
            result['geometry']['location']['lat'],
            result['geometry']['location']['lng'],
          );

          // Check for available photo reference
          String? photoReference;
          if (result['photos'] != null && result['photos'].isNotEmpty) {
            photoReference = result['photos'][0]['photo_reference'];
          }

          // Create photo URL if photo reference is available
          final photoUrl = photoReference != null
              ? 'https://maps.googleapis.com/maps/api/place/photo'
                  '?maxwidth=400&photoreference=$photoReference&key=$apiKey'
              : 'https://via.placeholder.com/400x300.png?text=No+Image+Available'; // Placeholder image

          // Return marker that opens a custom info window with restaurant info
          return Marker(
            markerId: MarkerId(result['place_id']),
            position: position,
            onTap: () {
              customInfoWindowController.addInfoWindow!(
                CustomizedInfoWindow(
                  name: result['name'],
                  latitude: position.latitude,
                  longitude: position.longitude,
                  photoUrl: photoUrl,
                ),
                position,
              );
            },
          );
        }).toSet();
      } else {
        print('Failed to fetch nearby restaurants');
        return {};
      }
    } catch (e) {
      print('Error fetching places: $e');
      return {};
    }
  }
}
