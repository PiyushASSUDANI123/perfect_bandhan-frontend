import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class CongratulationsScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const CongratulationsScreen({super.key, required this.profileData});

  @override
  State<CongratulationsScreen> createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _cardController;
  late AnimationController _textController;
  late AnimationController _buttonController;
  late Animation<double> _cardScale;
  late Animation<double> _cardOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Confetti
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Card entrance
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
    );
    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    // Text entrance
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // Button entrance
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeIn),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutCubic),
    );

    // Generate confetti particles
    final random = Random();
    for (int i = 0; i < 60; i++) {
      _particles.add(_ConfettiParticle(
        x: random.nextDouble(),
        speed: 0.3 + random.nextDouble() * 0.7,
        size: 4 + random.nextDouble() * 8,
        color: [
          AppTheme.accentGold,
          const Color(0xFFF3E5AB),
          const Color(0xFFB8860B),
          Colors.white,
          const Color(0xFFE8D5B7),
          const Color(0xFFFFD700),
        ][random.nextInt(6)],
        rotation: random.nextDouble() * 360,
        rotationSpeed: random.nextDouble() * 4 - 2,
        swayAmplitude: random.nextDouble() * 30,
        swaySpeed: 1 + random.nextDouble() * 2,
        shape: random.nextInt(3), // 0=rect, 1=circle, 2=diamond
      ));
    }

    // Stagger animations
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _confettiController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _cardController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _cardController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  int _calculateAge() {
    final dobStr = widget.profileData['dob'] ?? '';
    if (dobStr.isEmpty) return 0;
    try {
      final dob = DateTime.parse(dobStr);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.profileData;
    final firstName = data['firstName'] ?? '';
    final lastName = data['lastName'] ?? data['surname'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    final age = _calculateAge();
    final height = data['height'] ?? '';
    final city = data['city'] ?? '';
    final state = data['state'] ?? '';
    final profession = data['profession'] ?? '';
    final jobPost = data['jobPost'] ?? '';
    final education = data['education'] ?? '';
    final yearlyIncome = data['yearlyIncome'] ?? '';
    final nukh = data['nukh'] ?? '';
    final photos = data['uploadedPhotos'] as List<dynamic>?;
    final firstPhoto = (photos != null && photos.isNotEmpty && photos[0] != null && photos[0].toString().isNotEmpty)
        ? photos[0].toString()
        : null;

    final locationText = [city, state].where((s) => s.isNotEmpty).join(', ');
    final professionText = profession == 'Not Working'
        ? 'Not Working'
        : (jobPost.isNotEmpty ? jobPost : profession);

    String incomeText = '';
    if (profession != 'Not Working' && yearlyIncome.isNotEmpty && yearlyIncome != '0') {
      final incomeNum = double.tryParse(yearlyIncome) ?? 0;
      if (incomeNum >= 100000) {
        incomeText = 'Rs. ${(incomeNum / 100000).toStringAsFixed(1)} Lakh p.a.';
      } else {
        incomeText = 'Rs. $yearlyIncome p.a.';
      }
    }

    // Build info chips
    final infoItems = <String>[];
    if (height.isNotEmpty) infoItems.add(height);
    if (locationText.isNotEmpty) infoItems.add(locationText);
    if (nukh.isNotEmpty) infoItems.add(nukh);
    if (professionText.isNotEmpty) infoItems.add(professionText);
    if (incomeText.isNotEmpty) infoItems.add(incomeText);
    if (education.isNotEmpty) infoItems.add(education);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Congratulations text
                      SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textOpacity,
                          child: Column(
                            children: [
                              Text(
                                '🎉',
                                style: const TextStyle(fontSize: 48),
                              ),
                              const SizedBox(height: 8),
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFFD4AF37), Color(0xFFB8860B), Color(0xFFD4AF37)],
                                ).createShader(bounds),
                                child: Text(
                                  'CONGRATULATIONS!',
                                  style: GoogleFonts.cinzel(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your profile is now live on Perfect Bandhan',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: AppTheme.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Profile Card
                      ScaleTransition(
                        scale: _cardScale,
                        child: FadeTransition(
                          opacity: _cardOpacity,
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 360),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                                BoxShadow(
                                  color: AppTheme.accentGold.withValues(alpha: 0.15),
                                  blurRadius: 40,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                children: [
                                  // Photo or gradient background
                                  Container(
                                    height: 420,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    child: firstPhoto != null
                                        ? Image.network(
                                            firstPhoto,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) => Center(
                                              child: Icon(
                                                data['gender'] == 'Male' ? Icons.person : Icons.person_2,
                                                size: 120,
                                                color: Colors.white24,
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Icon(
                                              data['gender'] == 'Male' ? Icons.person : Icons.person_2,
                                              size: 120,
                                              color: Colors.white24,
                                            ),
                                          ),
                                  ),

                                  // Dark gradient overlay at bottom
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    height: 220,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.6),
                                            Colors.black.withValues(alpha: 0.9),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // "Just Joined" badge
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5), width: 1),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.fiber_new_rounded, color: AppTheme.accentGold, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Just Joined',
                                            style: GoogleFonts.montserrat(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Bottom info
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Name & Age
                                          Text(
                                            '$fullName${age > 0 ? ', $age' : ''}',
                                            style: GoogleFonts.cinzel(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Info chips
                                          Text(
                                            infoItems.join('  •  '),
                                            style: GoogleFonts.montserrat(
                                              color: Colors.white70,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              height: 1.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // "Team Perfect Bandhan wishes you all the best!"
                      SlideTransition(
                        position: _buttonSlide,
                        child: FadeTransition(
                          opacity: _buttonOpacity,
                          child: Column(
                            children: [
                              Text(
                                'Jai Jhulelal! 🙏',
                                style: GoogleFonts.cinzel(
                                  fontSize: 16,
                                  color: AppTheme.accentGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Team Perfect Bandhan wishes you all the best!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: AppTheme.textMuted,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Begin Journey Button
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.burgundyButtonGradient,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accentGold.withValues(alpha: 0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(builder: (_) => const DashboardScreen()),
                                        (route) => false,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: Text(
                                      'Begin Your Journey',
                                      style: GoogleFonts.cinzel(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Confetti overlay
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, _) {
              return IgnorePointer(
                child: CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _confettiController.value,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double speed;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final double swayAmplitude;
  final double swaySpeed;
  final int shape;

  _ConfettiParticle({
    required this.x,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.swayAmplitude,
    required this.swaySpeed,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    for (final p in particles) {
      final yPos = -p.size + (size.height + p.size * 2) * progress * p.speed;
      final xPos = p.x * size.width + sin(progress * p.swaySpeed * pi * 2) * p.swayAmplitude;
      final opacity = progress < 0.8 ? 1.0 : (1.0 - (progress - 0.8) / 0.2);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(xPos, yPos);
      canvas.rotate((p.rotation + progress * p.rotationSpeed * 360) * pi / 180);

      switch (p.shape) {
        case 0: // Rectangle
          canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6), paint);
          break;
        case 1: // Circle
          canvas.drawCircle(Offset.zero, p.size * 0.4, paint);
          break;
        case 2: // Diamond
          final path = Path()
            ..moveTo(0, -p.size * 0.5)
            ..lineTo(p.size * 0.3, 0)
            ..lineTo(0, p.size * 0.5)
            ..lineTo(-p.size * 0.3, 0)
            ..close();
          canvas.drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
