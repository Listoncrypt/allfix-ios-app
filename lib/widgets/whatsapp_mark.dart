import 'package:flutter/material.dart';

/// A compact WhatsApp-style mark for dispatch actions, drawn without a font
/// dependency so it renders consistently on Android and iOS.
class WhatsAppMark extends StatelessWidget {
  final Color color;
  final double size;

  const WhatsAppMark({super.key, this.color = Colors.white, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _WhatsAppBubblePainter(color),
          ),
          Transform.rotate(
            angle: -0.62,
            child: Icon(Icons.call_rounded, size: size * 0.47, color: color),
          ),
        ],
      ),
    );
  }
}

class _WhatsAppBubblePainter extends CustomPainter {
  final Color color;

  const _WhatsAppBubblePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    final bubble = Path()
      ..moveTo(20.1, 11.5)
      ..cubicTo(20.1, 16.1, 16.4, 19.7, 11.8, 19.7)
      ..cubicTo(10.4, 19.7, 9.1, 19.4, 7.9, 18.8)
      ..lineTo(3.5, 20.1)
      ..lineTo(4.8, 15.9)
      ..cubicTo(4.1, 14.6, 3.8, 13.1, 3.8, 11.6)
      ..cubicTo(3.8, 7.1, 7.4, 3.5, 11.9, 3.5)
      ..cubicTo(16.4, 3.5, 20.1, 7.1, 20.1, 11.5)
      ..close();
    canvas.save();
    canvas.scale(scale);
    canvas.drawPath(
      bubble,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WhatsAppBubblePainter oldDelegate) =>
      oldDelegate.color != color;
}
