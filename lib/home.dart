import 'package:flutter/material.dart';

class Dot extends StatelessWidget {
  final double radius;
  final Color color;

  const Dot({Key? key, required this.radius, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotPainter(radius, color),
      size: Size.infinite,
    );
  }
}

class _DotPainter extends CustomPainter {
  final double radius;
  final Paint _paint;

  _DotPainter(this.radius, Color color)
      : _paint = Paint()
          ..color = color
          ..strokeWidth = radius * 2
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, _paint);
  }

  @override
  bool shouldRepaint(_DotPainter oldDelegate) => false;
}
