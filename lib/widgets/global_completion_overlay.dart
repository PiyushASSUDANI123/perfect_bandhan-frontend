import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../providers/auth_provider.dart';
import '../widgets/profile_completion_ring.dart';
import '../theme/app_theme.dart';

class GlobalCompletionOverlay extends StatefulWidget {
  const GlobalCompletionOverlay({super.key});

  @override
  State<GlobalCompletionOverlay> createState() => _GlobalCompletionOverlayState();
}

class _GlobalCompletionOverlayState extends State<GlobalCompletionOverlay> {
  late ConfettiController _confettiController;
  bool _hasCelebrated = false;
  bool _forceComplete = false; // Developer toggle state

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final profile = auth.myProfile;
        if (profile == null) return const SizedBox.shrink();

        int completion = calculateProfileCompletion(profile);
        if (_forceComplete) {
          completion = 100;
        }

        final isDeveloper = profile['phone'] == '9413879444' || profile['phone'] == '+919413879444';

        if (completion >= 100 && !_hasCelebrated) {
          // Defer the start of confetti so it happens outside of the build phase
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _hasCelebrated = true;
              });
              _confettiController.play();
            }
          });
        } else if (completion < 100 && _hasCelebrated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _hasCelebrated = false;
              });
            }
          });
        }

        return Stack(
          children: [
            // Confetti Explosion at the center
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
                createParticlePath: drawStar,
              ),
            ),
            
            // Celebration Typography Overlay
            if (_hasCelebrated && _confettiController.state == ConfettiControllerState.playing)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Text(
                        'Congratulations!',
                        style: GoogleFonts.cinzel(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentGold,
                          shadows: [
                            const Shadow(
                              color: Colors.black54,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Global Ring and Developer Toggle at top right
            Positioned(
              top: MediaQuery.of(context).padding.top + 6, // Placed accurately in the AppBar's reserved space
              right: 16,
              child: SafeArea(
                child: AnimatedOpacity(
                  opacity: completion >= 100 ? 0.0 : 1.0,
                  duration: const Duration(seconds: 1),
                  child: Column(
                    children: [
                      if (isDeveloper)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _forceComplete = !_forceComplete;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.glassColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.glassBorderColor),
                            ),
                            child: const Text('💯', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ProfileCompletionRing(
                        percentage: completion,
                        size: 48,
                        strokeWidth: 4.5,
                        onTap: () {
                          final missingFields = getMissingProfileFields(profile);
                          
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: AppTheme.cardWhite,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            builder: (ctx) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                                  top: 24, left: 20, right: 20
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 40, height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(2)
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        ProfileCompletionRing(percentage: completion, size: 50, strokeWidth: 5),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Complete Your Profile',
                                                style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textCarbon),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${missingFields.length} items left to reach 100%',
                                                style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 12),
                                              )
                                            ]
                                          )
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    if (missingFields.isNotEmpty) ...[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'MISSING ITEMS',
                                          style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.accentGold),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.backgroundLight,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppTheme.glassBorderColor)
                                        ),
                                        child: Column(
                                          children: missingFields.map((f) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.circle_outlined, size: 14, color: Colors.grey),
                                                const SizedBox(width: 12),
                                                Text(f, style: GoogleFonts.montserrat(fontSize: 13, color: AppTheme.textCarbon, fontWeight: FontWeight.w500)),
                                              ]
                                            ),
                                          )).toList(),
                                        ),
                                      )
                                    ],
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          // Note: In real app, we'd navigate to Edit Profile Sheet.
                                          // Because this is inside Dashboard, we can use the provider to trigger it or route.
                                          // For now, let's just close the sheet and let user go to My Profile manually.
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.accentGold,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: Text(
                                          'Go to My Profile',
                                          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    )
                                  ]
                                )
                              );
                            }
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Path drawStar(Size size) {
    // Basic star path for confetti
    double degToRad(double deg) => deg * (pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
                  halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
                  halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }
}
