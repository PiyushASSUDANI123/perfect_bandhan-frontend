import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
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
import 'package:flutter_web_plugins/url_strategy.dart'; // for path URL strategy
import 'screens/profile_detail_wrapper.dart'; // deep linking wrapper

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); // removes the '#' from flutter web URLs
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was in cold state (terminated)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      print("Failed to get initial link: $e");
    }

    // Handle link when app is in warm state (foreground/background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      print("Failed to listen to deep links: $err");
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.path.startsWith('/profile/')) {
      final profileId = uri.path.replaceFirst('/profile/', '');
      _navigatorKey.currentState?.pushNamed('/profile/$profileId');
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Perfect Bandhan',
      theme: AppTheme.themeData,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/profile/')) {
          final profileId = settings.name!.replaceFirst('/profile/', '');
          return MaterialPageRoute(
            builder: (context) => ProfileDetailWrapper(profileId: profileId),
          );
        }
        return null;
      },
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

            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: MediaQuery.of(context).textScaler.clamp(
                  minScaleFactor: 1.0, 
                  maxScaleFactor: 1.15,
                ),
              ),
              child: Stack(
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
                  ), // Closes Positioned
              ],
            ), // Closes Stack
          ); // Closes MediaQuery
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
  bool _updatePopupShown = false;

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
    
    if (!_updatePopupShown && authProvider.appConfig != null && authProvider.appConfig!['forceUpdate'] == true) {
      _updatePopupShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUpdateDialog(authProvider.appConfig!['updateMessage'] ?? 'A new version of Perfect Bandhan is available. Please update for the best experience.', authProvider.appConfig!['downloadUrl']);
      });
    }

    if (authProvider.status == AuthStatus.authenticated) {
      if (authProvider.isProfileComplete || authProvider.isAdmin) {
        return const DashboardScreen();
      } else {
        return const ProfileOnboardingScreen();
      }
    }
    return const LoginScreen();
  }

  void _showUpdateDialog(String message, String? url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardGray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Update Available', style: GoogleFonts.cinzel(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
        content: Text(message, style: GoogleFonts.montserrat(color: AppTheme.textWhite)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Later', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold),
            onPressed: () async {
              Navigator.pop(ctx);
              if (url != null && await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            },
            child: Text('Update Now', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
