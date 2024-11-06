import 'package:flutter/material.dart';

class ZoomButtonsWidget extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const ZoomButtonsWidget({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton(
          onPressed: onZoomIn,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.zoom_in),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          onPressed: onZoomOut,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.zoom_out),
        ),
      ],
    );
  }
}
