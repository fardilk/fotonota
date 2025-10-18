import 'package:flutter/material.dart';

class CameraOverlay extends StatelessWidget {
  final Rect? focusRect;
  final Color strokeColor;
  final double strokeWidth;
  final double maskOpacity; // 0..1

  const CameraOverlay({
    super.key,
    this.focusRect,
    this.strokeColor = Colors.red,
    this.strokeWidth = 3,
    this.maskOpacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final rect = focusRect ?? _defaultRect(size);
        return CustomPaint(
          painter: _OverlayPainter(
            rect: rect,
            strokeColor: strokeColor,
            strokeWidth: strokeWidth,
            maskOpacity: maskOpacity,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Rect _defaultRect(Size size) {
    // 70% width, 28% height (approx amount area aspect), centered
    final w = size.width * 0.8;
    final h = size.height * 0.25;
    final left = (size.width - w) / 2;
    final top = (size.height - h) / 2;
    return Rect.fromLTWH(left, top, w, h);
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect rect;
  final Color strokeColor;
  final double strokeWidth;
  final double maskOpacity;

  _OverlayPainter({
    required this.rect,
    required this.strokeColor,
    required this.strokeWidth,
    required this.maskOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dark mask
    final bg = Paint()
      ..color = Colors.black.withValues(alpha: maskOpacity)
      ..style = PaintingStyle.fill;

    final full = Path()..addRect(Offset.zero & size);
    final hole = Path()..addRRect(RRect.fromRectXY(rect, 12, 12));
    final masked = Path.combine(PathOperation.difference, full, hole);
    canvas.drawPath(masked, bg);

    // Red stroke
    final border = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRRect(RRect.fromRectXY(rect, 12, 12), border);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) {
    return rect != oldDelegate.rect ||
        strokeColor != oldDelegate.strokeColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        maskOpacity != oldDelegate.maskOpacity;
  }
}
