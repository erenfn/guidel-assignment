import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlacesService {
  /// Fetches nearby restaurants within a given [radius] (default 1km) from the given [currentPosition].
  ///
  /// This method makes a request to the Google Places API to find restaurants
  /// near the provided location. If the request is successful, it returns a set of [Marker] objects
  /// representing the nearby restaurants. The markers include details such
  /// as the restaurant's name, vicinity, and coordinates, which are displayed in an info window
  /// when the marker is tapped on the map. If the request fails or an error occurs, it returns
  /// an empty set and logs an error message.
  ///
  /// Parameters:
  /// - [currentPosition]: A [LatLng] object representing the current location
  ///   from which nearby restaurants will be searched.
  ///
  /// Returns:
  /// - A [Set<Marker>] representing the nearby restaurants. Each marker includes
  ///   the restaurant's position, name, vicinity, and coordinates.

  static Future<Set<Marker>> fetchNearbyRestaurants(LatLng currentPosition,
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

        // Create a Marker for each restaurant in the results
        return results.map<Marker>((result) {
          final LatLng position = LatLng(
            result['geometry']['location']['lat'],
            result['geometry']['location']['lng'],
          );

          return Marker(
            markerId: MarkerId(result['place_id']),
            position: position,

            // Set the info window content (restaurant name and coordinates)
            infoWindow: InfoWindow(
              title: result['name'],
              snippet:
                  '${position.latitude}, ${position.longitude}',
            ),
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
