import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Calculates profile completion percentage based on filled fields.
/// Returns a value from 0 to 100.
int calculateProfileCompletion(Map<String, dynamic>? profile) {
  if (profile == null) return 0;

  final fields = <String, int>{
    // Photos = 20%
    'uploadedPhotos': 20,
    // Basic Info = 10%
    'firstName': 5,
    'dob': 5,
    // Education & Work = 15%
    'education': 5,
    'profession': 5,
    'company': 5,
    // Location = 10%
    'city': 5,
    'state': 5,
    // Bio = 5%
    'bio': 5,
    // Family = 15%
    'fathersOccupation': 5,
    'mothersOccupation': 5,
    'siblings': 5,
    // Kundali / Birth = 15%
    'birthTime': 8,
    'birthPlace': 7,
    // Extended Details = 10%
    'monthlyIncome': 3,
    'properAddress': 3,
    'jobPost': 2,
    'ownHouse': 2,
  };

  int score = 0;

  for (final entry in fields.entries) {
    final key = entry.key;
    final weight = entry.value;
    final val = profile[key];

    if (key == 'uploadedPhotos') {
      if (val is List && val.isNotEmpty && val[0] != null && val[0].toString().isNotEmpty) {
        score += weight;
      }
    } else if (key == 'dob') {
      if (val != null && val.toString().isNotEmpty) {
        score += weight;
      }
    } else {
      if (val != null && val.toString().trim().isNotEmpty) {
        score += weight;
      }
    }
  }

  return score.clamp(0, 100);
}

/// A beautiful circular progress ring for profile completion.
class ProfileCompletionRing extends StatelessWidget {
  final int percentage;
  final double size;
  final double strokeWidth;
  final bool showLabel;
  final VoidCallback? onTap;

  const ProfileCompletionRing({
    super.key,
    required this.percentage,
    this.size = 42,
    this.strokeWidth = 4.0,
    this.showLabel = true,
    this.onTap,
  });

  Color _getColor() {
    if (percentage >= 85) return Colors.green;
    if (percentage >= 60) return AppTheme.accentGold;
    if (percentage >= 40) return Colors.orange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: '$percentage% Profile Complete',
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: _RingPainter(
                    progress: percentage / 100.0,
                    color: color,
                    backgroundColor: color.withOpacity(0.15),
                    strokeWidth: strokeWidth,
                  ),
                ),
              ),
              Text(
                '$percentage%',
                style: GoogleFonts.montserrat(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
