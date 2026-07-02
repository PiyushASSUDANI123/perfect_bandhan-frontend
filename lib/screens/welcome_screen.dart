import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onNext;
  const WelcomeScreen({super.key, required this.onNext});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      body: Stack(
        children: [
          // Elegant Background Gradients
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFC5A059).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B0000).withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // --- Main scrollable content ---
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            // ── Jhulelal Image ─────────────────────────────────────────
                            ScaleTransition(
                              scale: _logoScale,
                              child: FadeTransition(
                                opacity: _logoFade,
                                child: Container(
                                  width: double.infinity,
                                  height: 110,
                                  margin: const EdgeInsets.only(bottom: 20),
                                  child: Image.asset(
                                    'assets/jhulelal.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
        
                            // ── Logo ──────────────────────────────────────────────────
                            ScaleTransition(
                              scale: _logoScale,
                              child: FadeTransition(
                                opacity: _logoFade,
                                child: Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: const Color(0xFFC5A059).withValues(alpha: 0.5),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFC5A059).withValues(alpha: 0.25),
                                        blurRadius: 30,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.asset(
                                      'assets/logo.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
        
                            const SizedBox(height: 24),
        
                            // ── App Name ──────────────────────────────────────────────
                            FadeTransition(
                              opacity: _textFade,
                              child: Text(
                                'परफेक्ट बंधन',
                                style: GoogleFonts.cinzel(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF8B0000),
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFF8B0000).withValues(alpha: 0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            FadeTransition(
                              opacity: _textFade,
                              child: Text(
                                'PERFECT BANDHAN',
                                style: GoogleFonts.cinzel(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFC5A059),
                                  letterSpacing: 5,
                                ),
                              ),
                            ),
        
                            const SizedBox(height: 32),
        
                            // ── Gold Divider ──────────────────────────────────────────
                            SlideTransition(
                              position: _textSlide,
                              child: FadeTransition(
                                opacity: _textFade,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1.5,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.transparent, Color(0xFFC5A059)],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: const Icon(Icons.favorite, color: Color(0xFF8B0000), size: 16),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1.5,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Color(0xFFC5A059), Colors.transparent],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
        
                            const SizedBox(height: 32),
        
                            // ── Messages Container ─────────────────────────────────
                            SlideTransition(
                              position: _textSlide,
                              child: FadeTransition(
                                opacity: _textFade,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: const Color(0xFFC5A059).withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF8B0000).withValues(alpha: 0.05),
                                        blurRadius: 30,
                                        spreadRadius: -5,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: BackdropFilter(
                                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Padding(
                                        padding: const EdgeInsets.all(28.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Hindi Section
                                            Text(
                                              '''परफेक्ट बंधन में आपका स्वागत है।
(जय झूलेलाल)''',
                                              style: GoogleFonts.yatraOne(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF8B0000),
                                                height: 1.4,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              '''सिंधी समाज के युवाओं के लिए एक नई और भरोसेमंद शुरुआत। हमारा एकमात्र प्रयास है कि आपको अपने विचारों, संस्कारों और प्राथमिकताओं के अनुसार एक योग्य जीवनसाथी मिले।

आज ही अपनी पूरी जानकारी के साथ प्रोफ़ाइल बनाएं, अपने मापदंड तय करें और अपनी पसंद के अनुसार सही रिश्ते की ओर कदम बढ़ाएं।''',
                                              style: GoogleFonts.mukta(
                                                fontSize: 15,
                                                color: const Color(0xFF333333),
                                                height: 1.6,
                                              ),
                                            ),
                                            
                                            const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 20),
                                              child: Divider(color: Color(0xFFE5D5B5), thickness: 1),
                                            ),
        
                                            // English Section
                                            Text(
                                              '''Welcome to Perfect Bandhan.
(Jai Jhulelal)''',
                                              style: GoogleFonts.cinzel(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF8B0000),
                                                height: 1.4,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              '''An exclusive initiative crafted for the Sindhi community to build meaningful connections. Our goal is simple: to help you find a truly compatible life partner who aligns with your values and lifestyle.

Set up your detailed profile, define your preferences, and take charge of finding the perfect match for your future.''',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 13,
                                                color: const Color(0xFF555555),
                                                height: 1.6,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            
                                            const SizedBox(height: 20),
                                            
                                            // Free Badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF8B0000).withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: const Color(0xFF8B0000).withValues(alpha: 0.15),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.verified, color: Color(0xFFC5A059), size: 20),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      'यह सेवा सिंधी समाज के लिए पूर्ण रूप से निःशुल्क (100% Free) है।',
                                                      style: GoogleFonts.mukta(
                                                        fontSize: 14,
                                                        color: const Color(0xFF8B0000),
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
        
                    // ── Bottom Bar ────────────────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B0000).withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Next button
                              FadeTransition(
                                opacity: _textFade,
                                child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [Color(0xFF9E0000), Color(0xFF700000)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF8B0000).withValues(alpha: 0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: widget.onNext,
                                      splashColor: const Color(0xFFC5A059).withValues(alpha: 0.3),
                                      highlightColor: Colors.black12,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'आगे बढ़ें',
                                              style: GoogleFonts.yatraOne(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              width: 4,
                                              height: 4,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFC5A059),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'NEXT',
                                              style: GoogleFonts.cinzel(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.arrow_forward_rounded, color: Color(0xFFC5A059), size: 22),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Welcome Host
                              Text(
                                'Welcome Host: Piyush Chandra Prakash Assudani',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: const Color(0xFF8B0000),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              // Footer
                              Text(
                                'A Property of Assudani Group',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  color: const Color(0xFFC5A059),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

