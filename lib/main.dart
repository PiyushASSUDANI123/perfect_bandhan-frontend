import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'utils/storage_helper.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/splash_screen.dart';

import 'package:flutter/foundation.dart'; // added for kIsWeb

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (!kIsWeb) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    print('Firebase initialization skipped or failed: $e');
  }
  
  // Initialize Local Notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..tryAutoLogin()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perfect Bandhan',
      theme: AppTheme.themeData,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final config = auth.appConfig;
            final bool isMaintenance = config?['isMaintenanceMode'] == true;
            final bool bannerEnabled = config?['globalBannerEnabled'] == true;
            final String maintMsg = config?['maintenanceMessage'] ?? 'Software under maintenance, come back later.';
            final String bannerMsg = config?['globalBannerMessage'] ?? 'Welcome to Perfect Bandhan!';

            Widget mainContent = child ?? const SizedBox.shrink();

            if (isMaintenance) {
              mainContent = Scaffold(
                backgroundColor: AppTheme.backgroundLight,
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.build_circle_outlined, size: 80, color: AppTheme.accentGold),
                        const SizedBox(height: 24),
                        Text('Under Maintenance', style: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textCarbon)),
                        const SizedBox(height: 16),
                        Text(maintMsg, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 14, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Stack(
              children: [
                mainContent,
                if (bannerEnabled && !isMaintenance)
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: SafeArea(
                      bottom: false,
                      child: Material(
                        elevation: 4,
                        color: AppTheme.accentGold,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          width: double.infinity,
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.black, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  bannerMsg,
                                  style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
      home: const SplashScreen(),
    );
  }
}

class HomeScreenWrapper extends StatefulWidget {
  const HomeScreenWrapper({super.key});

  @override
  State<HomeScreenWrapper> createState() => _HomeScreenWrapperState();
}

class _HomeScreenWrapperState extends State<HomeScreenWrapper> {
  bool _showWelcome = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstLaunch();
    });
  }

  Future<void> _checkFirstLaunch() async {
    try {
      await _requestAppPermissions();
      final seen = await AppStorage.get('welcome_seen');
      final lang = await AppStorage.get('app_language');

      if (seen != 'true') {
        // First launch — show welcome screen
        setState(() => _showWelcome = true);
        
        // Trigger Welcome Mobile Push Notification
        final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'welcome_channel', 'Welcome Notifications',
          importance: Importance.max, priority: Priority.high,
        );
        const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
          id: 0,
          title: 'Welcome to Perfect Bandhan! 🎉',
          body: 'We are thrilled to have you here. Complete your profile to get started.',
          notificationDetails: platformChannelSpecifics,
        );
        
      } else if (lang == null) {
        // Returning user but no language set — show language dialog
        _showLanguageSelectionDialog();
      }
    } catch (_) {}
  }

  Future<void> _requestAppPermissions() async {
    try {
      await [
        Permission.camera,
        Permission.photos,
        Permission.notification,
      ].request();
    } catch (_) {}
  }

  void _onWelcomeNext() async {
    await AppStorage.save('welcome_seen', 'true');
    setState(() => _showWelcome = false);
    if (mounted) {
      _showLanguageSelectionDialog();
    }
  }

  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.cardWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
          title: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset('assets/logo.png', width: 70, height: 70),
              ),
              const SizedBox(height: 12),
              Text(
                'SELECT LANGUAGE / भाषा चुनें',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.textCarbon,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome to Perfect Bandhan Matrimony.\nPlease select your preferred language.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textCarbon,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
                onPressed: () {
                  Provider.of<LanguageProvider>(context, listen: false).setLanguage('en');
                  Navigator.pop(dialogContext);
                },
                child: Text('🇬🇧  ENGLISH', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12.0),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppTheme.premiumGoldGradient,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  onPressed: () {
                    Provider.of<LanguageProvider>(context, listen: false).setLanguage('hi');
                    Navigator.pop(dialogContext);
                  },
                  child: Text('🇮🇳  हिन्दी (HINDI)', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'A Property of Assudani Group',
                style: GoogleFonts.montserrat(
                  fontSize: 9,
                  color: AppTheme.accentGold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show welcome screen on first launch
    if (_showWelcome) {
      return WelcomeScreen(onNext: _onWelcomeNext);
    }

    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.status == AuthStatus.authenticated) {
      if (authProvider.isProfileComplete || authProvider.isAdmin) {
        return const DashboardScreen();
      } else {
        return const ProfileOnboardingScreen();
      }
    }
    return const LoginScreen();
  }
}
