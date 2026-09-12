import 'package:flutter/material.dart';
import '../colors.dart';

class Brand extends StatelessWidget {
  final bool wordmark;
  const Brand({super.key, this.wordmark = false});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: blue,
          borderRadius: BorderRadius.circular(14),
        ),
        child: CustomPaint(painter: _Mark()),
      ),
      if (wordmark)
        const Padding(
          padding: EdgeInsets.only(left: 7),
          child: Text(
            'Lancebox',
            style: TextStyle(
              color: blue,
              fontSize: 26,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
    ],
  );
}

/// Full-screen transition matching the supplied loading-state design.
class BrandLoading extends StatelessWidget {
  const BrandLoading({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.white,
    child: Center(
      child: Semantics(
        label: 'Loading, please wait',
        child: SizedBox(
          width: 114,
          height: 114,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(
                child: CircularProgressIndicator(color: blue, strokeWidth: 1.5),
              ),
              Transform.scale(scale: 1.55, child: const Brand()),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Mark extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(6, 18)
      ..lineTo(19, 12)
      ..lineTo(17, 22)
      ..lineTo(5, 27)
      ..close();
    canvas.drawPath(p, Paint()..color = navy);
    final q = Path()
      ..moveTo(19, 12)
      ..lineTo(27, 24)
      ..lineTo(36, 20)
      ..lineTo(34, 29)
      ..lineTo(24, 33)
      ..lineTo(17, 22)
      ..close();
    canvas.drawPath(q, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
