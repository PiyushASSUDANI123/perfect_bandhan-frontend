import 'dart:math' as math;
import 'package:flutter/material.dart';

class MandalaPainter extends CustomPainter {
  final Color color;
  final double scale;

  MandalaPainter({
    required this.color,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double maxRadius = math.min(size.width, size.height) * 0.45 * scale;

    // Draw background concentric details
    _drawConcentricCircles(canvas, centerX, centerY, maxRadius, paint);
    _drawMandalaPetals(canvas, centerX, centerY, maxRadius, paint);
    _drawIntricateLace(canvas, centerX, centerY, maxRadius, paint);
  }

  void _drawConcentricCircles(Canvas canvas, double cx, double cy, double maxR, Paint paint) {
    // 5 concentric circles of varying styles
    for (int i = 1; i <= 5; i++) {
      double r = maxR * (i / 5.0);
      if (i % 2 == 0) {
        paint.strokeWidth = 1.5;
      } else {
        paint.strokeWidth = 0.75;
      }
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  void _drawMandalaPetals(Canvas canvas, double cx, double cy, double maxR, Paint paint) {
    const int petalCount = 16;
    final Path petalPath = Path();

    // Draw outer petals
    for (int j = 0; j < 2; j++) {
      double r = maxR * (j == 0 ? 0.75 : 1.0);
      double innerR = maxR * (j == 0 ? 0.4 : 0.75);
      paint.strokeWidth = j == 0 ? 1.0 : 0.8;

      for (int i = 0; i < petalCount; i++) {
        double angle = (i * 2 * math.pi) / petalCount;
        double nextAngle = ((i + 1) * 2 * math.pi) / petalCount;
        double midAngle = (angle + nextAngle) / 2;

        double xStart = cx + innerR * math.cos(angle);
        double yStart = cy + innerR * math.sin(angle);
        
        double xEnd = cx + innerR * math.cos(nextAngle);
        double yEnd = cy + innerR * math.sin(nextAngle);

        // Control point for the peak of the petal
        double peakR = r * 1.25;
        double xPeak = cx + peakR * math.cos(midAngle);
        double yPeak = cy + peakR * math.sin(midAngle);

        petalPath.reset();
        petalPath.moveTo(xStart, yStart);
        petalPath.quadraticBezierTo(
          cx + r * math.cos(angle * 0.8 + midAngle * 0.2), 
          cy + r * math.sin(angle * 0.8 + midAngle * 0.2), 
          xPeak, 
          yPeak
        );
        petalPath.quadraticBezierTo(
          cx + r * math.cos(nextAngle * 0.8 + midAngle * 0.2), 
          cy + r * math.sin(nextAngle * 0.8 + midAngle * 0.2), 
          xEnd, 
          yEnd
        );
        canvas.drawPath(petalPath, paint);
      }
    }
  }

  void _drawIntricateLace(Canvas canvas, double cx, double cy, double maxR, Paint paint) {
    const int detailCount = 24;
    paint.strokeWidth = 0.5;

    // Small repeating elements in the center
    double rCenter = maxR * 0.3;
    for (int i = 0; i < detailCount; i++) {
      double angle = (i * 2 * math.pi) / detailCount;
      double x1 = cx + rCenter * math.cos(angle);
      final double y1 = cy + rCenter * math.sin(angle);
      final double x2 = cx + (rCenter * 0.5) * math.cos(angle + (math.pi / detailCount));
      final double y2 = cy + (rCenter * 0.5) * math.sin(angle + (math.pi / detailCount));
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      canvas.drawCircle(Offset(x1, y1), 2.0, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke; // restore
    }
  }

  @override
  bool shouldRepaint(covariant MandalaPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.scale != scale;
  }
}
