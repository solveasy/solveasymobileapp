import 'package:flutter/material.dart';

class ScanningAnimation extends StatefulWidget {
  final Rect cropRect;

  const ScanningAnimation({Key? key, required this.cropRect}) : super(key: key);

  @override
  _ScanningAnimationState createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<ScanningAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _verticalAnimation;
  late Animation<double> _horizontalAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _verticalAnimation = Tween<double>(
      begin: widget.cropRect.top,
      end: widget.cropRect.bottom - 4,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5),
    ));
    _horizontalAnimation = Tween<double>(
      begin: widget.cropRect.left,
      end: widget.cropRect.right - 4,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.5, 1.0),
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: widget.cropRect.top,
              bottom: MediaQuery.of(context).size.height - widget.cropRect.bottom,
              left: _horizontalAnimation.value,
              child: Container(
                width: 2,
                color: Colors.grey,
              ),
            ),
          ],
        );
      },
    );
  }
}