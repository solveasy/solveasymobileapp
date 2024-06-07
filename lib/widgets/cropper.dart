import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class Cropper extends StatefulWidget {
  final String imagePath;
  final Rect initialCropRect;
  final ValueChanged<Rect> onCropRectChanged;

  const Cropper({
    Key? key,
    required this.imagePath,
    required this.initialCropRect,
    required this.onCropRectChanged,
  }) : super(key: key);

  @override
  CropperState createState() => CropperState();
}

class CropperState extends State<Cropper> {
  late Rect _cropRect;
  Offset? _startTouch;
  final GlobalKey _cropKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _cropRect = widget.initialCropRect;
  }

  void _resizeCropArea(Offset delta, {bool top = false, bool left = false, bool right = false, bool bottom = false}) {
    final screenSize = MediaQuery.of(context).size;
    setState(() {
      double newLeft = _cropRect.left;
      double newTop = _cropRect.top;
      double newWidth = _cropRect.width;
      double newHeight = _cropRect.height;

      if (left) {
        newLeft += delta.dx;
        newWidth -= delta.dx;
      }
      if (right) {
        newWidth += delta.dx;
      }
      if (top) {
        newTop += delta.dy;
        newHeight -= delta.dy;
      }
      if (bottom) {
        newHeight += delta.dy;
      }

      newLeft = newLeft.clamp(0.0, screenSize.width - 50);
      newTop = newTop.clamp(0.0, screenSize.height - 50 - 100);
      newWidth = newWidth.clamp(50.0, screenSize.width - newLeft);
      newHeight = newHeight.clamp(50.0, screenSize.height - newTop - 100);

      _cropRect = Rect.fromLTWH(newLeft, newTop, newWidth, newHeight);
      widget.onCropRectChanged(_cropRect);
    });
  }

  Future<File> cropImage() async {
    final boundary = _cropKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    final originalImage = img.decodeImage(File(widget.imagePath).readAsBytesSync())!;

    final scaleFactorX = originalImage.width / MediaQuery.of(context).size.width;
    final scaleFactorY = originalImage.height / MediaQuery.of(context).size.height;

    final x = (_cropRect.left * scaleFactorX).round();
    final y = (_cropRect.top * scaleFactorY).round();
    final width = (_cropRect.width * scaleFactorX).round();
    final height = (_cropRect.height * scaleFactorY).round();

    final croppedImage = img.copyCrop(
      originalImage,
      x: x,
      y: y,
      width: width,
      height: height,
    );

    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/cropped_image.png').create();
    file.writeAsBytesSync(img.encodePng(croppedImage));
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _cropKey,
      child: Stack(
        children: [
          Image.file(
            File(widget.imagePath),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Container(color: Colors.black.withOpacity(0.5)),
                    ),
                    Positioned.fromRect(
                      rect: _cropRect,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          Positioned(
                            top: -10,
                            left: 0,
                            right: 0,
                            height: 20,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onPanUpdate: (details) {
                                _resizeCropArea(details.delta, top: true);
                              },
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                          Positioned(
                            bottom: -10,
                            left: 0,
                            right: 0,
                            height: 20,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onPanUpdate: (details) {
                                _resizeCropArea(details.delta, bottom: true);
                              },
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            bottom: 0,
                            left: -10,
                            width: 20,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onPanUpdate: (details) {
                                _resizeCropArea(details.delta, left: true);
                              },
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            bottom: 0,
                            right: -10,
                            width: 20,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onPanUpdate: (details) {
                                _resizeCropArea(details.delta, right: true);
                              },
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                          Positioned(
                            top: -10,
                            left: -10,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                _resizeCropArea(
                                    details.delta, top: true, left: true);
                              },
                              child: _buildResizer(),
                            ),
                          ),
                          Positioned(
                            top: -10,
                            right: -10,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                _resizeCropArea(
                                    details.delta, top: true, right: true);
                              },
                              child: _buildResizer(),
                            ),
                          ),
                          Positioned(
                            bottom: -10,
                            left: -10,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                _resizeCropArea(
                                    details.delta, bottom: true, left: true);
                              },
                              child: _buildResizer(),
                            ),
                          ),
                          Positioned(
                            bottom: -10,
                            right: -10,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                _resizeCropArea(
                                    details.delta, bottom: true, right: true);
                              },
                              child: _buildResizer(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: _cropRect.left + (_cropRect.width / 2) - 90,
                      top: _cropRect.bottom + 40,
                      child: const Text(
                        'Crop just one question',
                        style: TextStyle(
                          fontFamily: 'Comfortaa',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResizer() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 0),
      ),
    );
  }
}