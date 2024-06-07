import 'package:flutter/material.dart';

class CropOverlay extends StatelessWidget {
  final Rect cropRect;

  const CropOverlay({required this.cropRect});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: cropRect.top,
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: MediaQuery.of(context).size.height - cropRect.bottom,
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),
        Positioned(
          left: 0,
          top: cropRect.top,
          bottom: MediaQuery.of(context).size.height - cropRect.bottom,
          width: cropRect.left,
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),
        Positioned(
          right: 0,
          top: cropRect.top,
          bottom: MediaQuery.of(context).size.height - cropRect.bottom,
          width: MediaQuery.of(context).size.width - cropRect.right,
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),
        Positioned.fromRect(
          rect: cropRect,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}