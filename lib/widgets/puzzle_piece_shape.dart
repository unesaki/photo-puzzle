import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'puzzle_piece_shape.dart';
import '../models/puzzle_piece_model.dart';

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

    // Optional: Add border
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

    // Top side
    path.moveTo(0, 0);
    _drawSide(path, Offset(0, 0), Offset(size.width, 0), shape.top, isVertical: false, knobSize: Size(knobWidth, knobHeight));

    // Right side
    _drawSide(path, Offset(size.width, 0), Offset(size.width, size.height), shape.right, isVertical: true, knobSize: Size(knobWidth, knobHeight));

    // Bottom side
    _drawSide(path, Offset(size.width, size.height), Offset(0, size.height), shape.bottom, isVertical: false, knobSize: Size(knobWidth, knobHeight), reverse: true);

    // Left side
    _drawSide(path, Offset(0, size.height), Offset(0, 0), shape.left, isVertical: true, knobSize: Size(knobWidth, knobHeight), reverse: true);

    path.close();
    return path;
  }

  void _drawSide(Path path, Offset from, Offset to, EdgeType type, {required bool isVertical, required Size knobSize, bool reverse = false}) {
    if (type == EdgeType.flat) {
      path.lineTo(to.dx, to.dy);
      return;
    }

    final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
    final direction = (type == EdgeType.outward) ^ reverse ? 1 : -1;

    if (isVertical) {
      path.lineTo(mid.dx, mid.dy - direction * knobSize.height);
      path.quadraticBezierTo(
        mid.dx + knobSize.width / 2, mid.dy - direction * knobSize.height * 2,
        mid.dx, mid.dy + direction * knobSize.height,
      );
    } else {
      path.lineTo(mid.dx - direction * knobSize.width, mid.dy);
      path.quadraticBezierTo(
        mid.dx - direction * knobSize.width * 2, mid.dy + knobSize.height / 2,
        mid.dx + direction * knobSize.width, mid.dy,
      );
    }

    path.lineTo(to.dx, to.dy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}