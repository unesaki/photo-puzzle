import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/puzzle_piece_shape.dart';

class PuzzlePiecePainter extends CustomPainter {
  final ui.Image image;
  final Rect srcRect;
  final PuzzlePieceShape shape;
  final bool isFixed;

  PuzzlePiecePainter({
    required this.image,
    required this.srcRect,
    required this.shape,
    this.isFixed = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildJigsawPath(size, shape);
    final paint = Paint();

    if (isFixed) {
      paint.colorFilter = const ColorFilter.mode(Colors.green, BlendMode.modulate);
    }

    canvas.save();
    canvas.clipPath(path);
    canvas.drawImageRect(image, srcRect, Offset.zero & size, paint);
    canvas.restore();

    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, borderPaint);
  }

  Path _buildJigsawPath(Size size, PuzzlePieceShape shape) {
    const knobSizeRatio = 0.2;
    final knobWidth = size.width * knobSizeRatio;
    final knobHeight = size.height * knobSizeRatio;
    final path = Path();

    path.moveTo(0, 0);
    _drawSide(path, Offset(0, 0), Offset(size.width, 0), shape.top, isVertical: false, knobSize: Size(knobWidth, knobHeight));
    _drawSide(path, Offset(size.width, 0), Offset(size.width, size.height), shape.right, isVertical: true, knobSize: Size(knobWidth, knobHeight));
    _drawSide(path, Offset(size.width, size.height), Offset(0, size.height), shape.bottom, isVertical: false, knobSize: Size(knobWidth, knobHeight), reverse: true);
    _drawSide(path, Offset(0, size.height), Offset(0, 0), shape.left, isVertical: true, knobSize: Size(knobWidth, knobHeight), reverse: true);

    path.close();
    return path;
  }

  void _drawSide(Path path, Offset from, Offset to, EdgeType type,
      {required bool isVertical, required Size knobSize, bool reverse = false}) {
    if (type == EdgeType.flat) {
      path.lineTo(to.dx, to.dy);
      return;
    }

    final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
    final direction = (type == EdgeType.outward) ^ reverse ? 1.0 : -1.0;

    if (isVertical) {
      final controlPoint1 = Offset(mid.dx - knobSize.width / 2, mid.dy);
      final controlPoint2 = Offset(mid.dx + knobSize.width / 2, mid.dy);

      path.lineTo(mid.dx - knobSize.width, mid.dy);
      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy + direction * knobSize.height,
        controlPoint2.dx, controlPoint2.dy + direction * knobSize.height,
        mid.dx + knobSize.width, mid.dy,
      );
      path.lineTo(to.dx, to.dy);
    } else {
      final controlPoint1 = Offset(mid.dx, mid.dy - knobSize.height / 2);
      final controlPoint2 = Offset(mid.dx, mid.dy + knobSize.height / 2);

      path.lineTo(mid.dx, mid.dy - knobSize.height);
      path.cubicTo(
        controlPoint1.dx + direction * knobSize.width, controlPoint1.dy,
        controlPoint2.dx + direction * knobSize.width, controlPoint2.dy,
        mid.dx, mid.dy + knobSize.height,
      );
      path.lineTo(to.dx, to.dy);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}