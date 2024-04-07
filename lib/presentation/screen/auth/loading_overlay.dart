import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: SimpleCircularProgressBar(
                backColor: Colors.white, // Color of the progress bar
                backStrokeWidth: 8, // Width of the progress bar
                size: 50, // Size of the progress bar
              ),
            ),
          ),
      ],
    );
  }
}
