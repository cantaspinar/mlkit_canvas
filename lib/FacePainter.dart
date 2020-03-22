import 'dart:ui' as ui;
import 'dart:math';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';


class FacePainter extends CustomPainter {
  FacePainter(this.image, this.faces);

  final ui.Image image;
  final List<Face> faces;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < faces.length; i++) {
      final rect = faces[i].boundingBox;
      final center = rect.center;
      final radius = rect.longestSide / 2;

      // Body
      final paint = Paint()..color = Colors.yellow;
      canvas.drawCircle(center, radius, paint);

      // Mouth
      final smilePaint = Paint()
        ..style = PaintingStyle.fill
        ..strokeWidth = 8
        ..isAntiAlias = true
        ..color = Colors.red;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius / 1.5), 0,
          pi, false, smilePaint);

      // Eyes
      canvas.drawCircle(
          Offset(center.dx - radius / 2.5, center.dy - radius / 2.5),
          radius / 4,
          Paint());
      canvas.drawCircle(
          Offset(center.dx + radius / 2.5, center.dy - radius / 2.5),
          radius / 4,
          Paint());
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) =>
      image != oldDelegate.image || faces != oldDelegate.faces;
}
