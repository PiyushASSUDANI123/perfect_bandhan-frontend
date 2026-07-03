import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../main.dart'; // To access HomeScreenWrapper

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final provider = Provider.of<AuthProvider>(context, listen: false);

    // Wait for BOTH the 2.5s minimum splash animation AND the config API check
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 2500)),
      provider.fetchAppConfig(),
    ]);

    if (!mounted) return;

    if (provider.forceUpdateRequired) {
      // KILL SWITCH TRIPPED: Block the app entirely on the splash screen
      _showForceUpdateDialog(provider);
      return; 
    }

    // Pass through if safe
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreenWrapper(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _showForceUpdateDialog(AuthProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false, // Cannot dismiss
      barrierColor: Colors.black.withValues(alpha: 0.95),
      builder: (ctx) => PopScope(
        canPop: false, // Cannot back-swipe
        child: AlertDialog(
          backgroundColor: AppTheme.cardGray,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.system_update, color: AppTheme.accentGold, size: 28),
              const SizedBox(width: 12),
              Text(
                "Update Required",
                style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: AppTheme.textCarbon, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            provider.updateMessage,
            style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final url = Uri.parse(provider.updateDownloadUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                "Update Now",
                style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/logo.png',
                    width: 120,
                    height: 120,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'PERFECT BANDHAN',
                  style: GoogleFonts.cinzel(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textCarbon,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Made for All India Sindhi Samaj Only',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentGold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
