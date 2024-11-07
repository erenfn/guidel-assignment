import 'package:flutter/material.dart';

class ZoomButtonsWidget extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetPosition; 

  const ZoomButtonsWidget({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetPosition, 
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Button to reset position
        FloatingActionButton(
          onPressed: onResetPosition,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.my_location),
        ),
        const SizedBox(height: 10),

        // Button to zoom in
        FloatingActionButton(
          onPressed: onZoomIn,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.zoom_in, size: 30.0),
        ),
        const SizedBox(height: 10),
        
        // Button to zoom out
        FloatingActionButton(
          onPressed: onZoomOut,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.zoom_out, size: 30.0),
        ),
      ],
    );
  }
}
