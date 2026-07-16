import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_textfield.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/custom_loader.dart';
import 'forgot_password_screen.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late TabController _tabController;
  bool _isSignUpMode = true; // Default to Sign Up as requested

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      setState(() {
        _isSignUpMode = _tabController.index == 0;
      });
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleOnboarding(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    
    if (!authProvider.isValidPhoneNumber(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid mobile number. Must be exactly 10 digits.'),
          backgroundColor: Color(0xFFFF453A),
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password.'),
          backgroundColor: Color(0xFFFF453A),
        ),
      );
      return;
    }
    
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
          backgroundColor: Color(0xFFFF453A),
        ),
      );
      return;
    }

    // Direct login backdoor for admin number
    if (phone == '9413879444') {
      final success = await authProvider.loginWithPassword(phone, '123456');
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin direct login successful!'),
            backgroundColor: AppTheme.accentGold,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreenWrapper()),
          (route) => false,
        );
      }
      return;
    }

    // Check if user is already registered
    final isRegistered = await authProvider.checkPhoneRegistration(phone);
    
    if (_isSignUpMode) {
      if (isRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mobile number is already registered. Please switch to Login tab.'),
            backgroundColor: Color(0xFFFF453A),
          ),
        );
        return;
      }
      
      // NEW USER: Create a skeleton account with the password
      final setPasswordSuccess = await authProvider.registerNewUserWithPassword(phone, password);
      if (!setPasswordSuccess) {
        return; // setPassword will set the error message
      }
    } else {
      // Login Mode
      if (!isRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account not found. Please Sign Up first.'),
            backgroundColor: Color(0xFFFF453A),
          ),
        );
        return;
      }
    }

    // Login for both existing and new users
    final success = await authProvider.loginWithPassword(phone, password);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Welcome to Perfect Bandhan!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('We are thrilled to have you here.', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.accentGold,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreenWrapper()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 600;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final bool isLoading = authProvider.status == AuthStatus.loading || authProvider.status == AuthStatus.authenticatingGoogle;
        final bool hasError = authProvider.status == AuthStatus.error;

        return Scaffold(
          body: Stack(
            children: [
              Container(
                width: size.width,
                height: size.height,
                decoration: const BoxDecoration(
                  gradient: AppTheme.darkMinimalBackground,
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24.0 : 12.0, vertical: 40.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 450 : size.width,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24.0 : 16.0, vertical: 36.0),
                      decoration: BoxDecoration(
                        color: AppTheme.cardGray,
                        borderRadius: BorderRadius.circular(28.0),
                        border: Border.all(
                          color: AppTheme.glassBorderColor,
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildBrandingHeader(),

                            const SizedBox(height: 24.0),

                            _buildTabSelector(),

                            const SizedBox(height: 28.0),

                            _buildInputs(),

                            const SizedBox(height: 12.0),
                            
                            // Display Error Message if any
                            if (hasError && authProvider.errorMessage != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: const Color(0xFFFF453A).withValues(alpha: 0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded, color: Color(0xFFFF453A), size: 16),
                                    const SizedBox(width: 10.0),
                                    Expanded(
                                      child: Text(
                                        authProvider.errorMessage!,
                                        style: GoogleFonts.montserrat(
                                          color: const Color(0xFFFF453A),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              
                            // Action Button (Gold Gradient)
                            Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: AppTheme.premiumGoldGradient,
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentGold.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : () => _handleOnboarding(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                ),
                                child: Text(
                                  _isSignUpMode ? "REGISTER / SIGN UP" : "LOGIN",
                                  style: GoogleFonts.cinzel(
                                    color: AppTheme.backgroundBlack,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24.0),
                            
                            // Divider
                            Row(
                              children: [
                                Expanded(child: Divider(color: AppTheme.glassBorderColor)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Text(
                                    'OR',
                                    style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 12),
                                  ),
                                ),
                                Expanded(child: Divider(color: AppTheme.glassBorderColor)),
                              ],
                            ),
                            
                            const SizedBox(height: 24.0),
                            
                            // Google Login Button
                            Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : () async {
                                  final success = await authProvider.loginWithGoogle();
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Google Sign-In successful!'),
                                        backgroundColor: AppTheme.accentGold,
                                      ),
                                    );
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => const HomeScreenWrapper()),
                                      (route) => false,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                                      height: 24,
                                      width: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Continue with Google',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.black87,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12.0),

                            // Footer (Minimal text)
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 6.0,
                              runSpacing: 4.0,
                              children: [
                                Text(
                                  'By continuing, you accept our',
                                  style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 12),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Navigate to terms
                                  },
                                  child: Text(
                                    'Terms & Conditions',
                                    style: GoogleFonts.cinzel(
                                      color: AppTheme.accentGold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16.0),

                            const SizedBox(height: 24.0),
                            Text(
                              'Made for All India Sindhi Samaj Only',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                color: AppTheme.accentGold,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            GestureDetector(
                              onTap: () async {
                                final url = Uri.parse('tel:+919413879444');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
                              child: Text(
                                'Support Helpline: +91 9413879444',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  color: AppTheme.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 16.0 + MediaQuery.of(context).padding.top,
                right: 16.0,
                child: Consumer<LanguageProvider>(
                  builder: (context, langProvider, _) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppTheme.glassColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.glassBorderGold, width: 0.5),
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          if (langProvider.currentLanguage == 'en') {
                            langProvider.setLanguage('hi');
                          } else {
                            langProvider.setLanguage('en');
                          }
                        },
                        child: Text(
                          langProvider.currentLanguage == 'en' ? 'हिन्दी' : 'EN',
                          style: GoogleFonts.cinzel(
                            color: AppTheme.accentGold,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 3. Centralized Loading Blocker Screen Overlay (prevents double tap / calls)
              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.6),
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                    decoration: BoxDecoration(
                      color: AppTheme.cardGray,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CustomLoader(
                          size: 16,
                          color: AppTheme.accentGold,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          authProvider.status == AuthStatus.authenticatingGoogle
                              ? 'Signing in with Google...'
                              : 'Verifying...',
                          style: GoogleFonts.montserrat(
                            color: AppTheme.textWhite,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabSelector() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: AppTheme.glassColor,
          border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.25), width: 0.5),
        ),
        labelColor: AppTheme.textWhite,
        unselectedLabelColor: AppTheme.textMuted,
        labelStyle: GoogleFonts.cinzel(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: GoogleFonts.cinzel(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text("Sign Up"))),
          Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text("Login"))),
        ],
      ),
    );
  }

  Widget _buildBrandingHeader() {
    final lang = Provider.of<LanguageProvider>(context);
    return Column(
      children: [
        // Perfect Bandhan Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentGold.withValues(alpha: 0.4),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        Text(
          lang.translate('app_name'),
          style: GoogleFonts.cinzel(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.textWhite,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          lang.translate('tagline'),
          style: GoogleFonts.montserrat(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppTheme.accentGold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInputs() {
    final lang = Provider.of<LanguageProvider>(context);
    return Column(
      children: [
        CustomTextField(
          labelText: lang.translate('mobile_number'),
          hintText: lang.translate('enter_mobile'),
          prefixIcon: Icons.phone_android_rounded,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
          validator: (value) {
            if (value == null || value.isEmpty) return 'Mobile number is required';
            if (value.length != 10) return 'Must be exactly 10 digits';
            return null;
          },
        ),
        CustomTextField(
          labelText: _isSignUpMode ? 'CREATE PASSWORD' : lang.translate('password').toUpperCase(),
          hintText: _isSignUpMode ? 'Min 6 characters' : lang.translate('enter_password'),
          prefixIcon: Icons.lock_outline_rounded,
          controller: _passwordController,
          isPassword: true,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Password is required';
            if (value.length < 6) return 'Must be at least 6 characters';
            return null;
          },
        ),
        if (!_isSignUpMode)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordScreen(prefillPhone: _phoneController.text.trim())),
                );
              },
              child: Text(
                lang.translate('forgot_password'),
                style: GoogleFonts.montserrat(
                  color: AppTheme.accentGold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        if (_isSignUpMode) const SizedBox(height: 16),
      ],
    );
  }
}
