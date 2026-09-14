// Paints short strokes and gaps to create the upload area’s dashed outline.

import 'package:flutter/material.dart';

class DashedRectangleBorder extends OutlinedBorder {
  const DashedRectangleBorder({super.side});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  DashedRectangleBorder copyWith({BorderSide? side}) =>
      DashedRectangleBorder(side: side ?? this.side);

  @override
  ShapeBorder scale(double t) => DashedRectangleBorder(side: side.scale(t));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(rect.deflate(side.width));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || rect.isEmpty) return;
    final path = Path()..addRect(rect.deflate(side.width / 2));
    final paint = side.toPaint();
    for (final metric in path.computeMetrics()) {
      for (double offset = 0; offset < metric.length; offset += 16) {
        final end = (offset + 10).clamp(0.0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(offset, end), paint);
      }
    }
  }
}
