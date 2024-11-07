import 'package:flutter/material.dart';

class CustomizedInfoWindow extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double latitude;
  final double longitude;

  const CustomizedInfoWindow({
    super.key, 
    required this.name,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: _boxDecoration(),
      constraints: const BoxConstraints(
        maxHeight: 350,
        maxWidth: 250, 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (photoUrl != null) _buildImage(),
          const SizedBox(height: 8), // Spacing between image and name
          _buildName(),
          const SizedBox(height: 4), // Space between name and coordinates
          _buildCoordinates(),
        ],
      ),
    );
  }

  // Box decoration for the container
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 8,
        ),
      ],
    );
  }

  // Builds the image if a photo URL is available
  Widget _buildImage() {
    return Image.network(
      photoUrl!,
      height: 80,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  // Builds the restaurant name text widget
  Widget _buildName() {
    return Text(
      name,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      overflow: TextOverflow.ellipsis, // Ensure text doesn't overflow
      maxLines: 1, // Limits the name text to one line
    );
  }

  // Builds the coordinates text widget
  Widget _buildCoordinates() {
    return Text(
      'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}',
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12, 
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}
