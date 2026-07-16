import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_loader.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? prefillPhone;
  const ForgotPasswordScreen({super.key, this.prefillPhone});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Step 1 — phone
  final _phoneController = TextEditingController();

  // Step 2 — email verify
  final _emailController = TextEditingController();
  String? _maskedEmail;

  // Step 3 — new password
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _step = 1; // 1 | 2 | 3
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    if (widget.prefillPhone != null) {
      _phoneController.text = widget.prefillPhone!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _setError(String? msg) => setState(() => _errorMsg = msg);

  // ── Step 1: Get email hint ────────────────────────────────────────────────
  Future<void> _handleGetEmailHint() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10 || !RegExp(r'^\d{10}$').hasMatch(phone)) {
      _setError('Please enter a valid 10-digit mobile number.');
      return;
    }

    setState(() { _isLoading = true; _errorMsg = null; });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final maskedEmail = await authProvider.getEmailHint(phone);
    setState(() { _isLoading = false; });

    if (maskedEmail != null) {
      setState(() {
        _maskedEmail = maskedEmail;
        _step = 2;
        _errorMsg = null;
      });
    } else {
      _setError(authProvider.errorMessage ?? 'No account found with this number.');
    }
  }

  // ── Step 2: Verify real email ─────────────────────────────────────────────
  Future<void> _handleVerifyEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _setError('Please enter a valid email address.');
      return;
    }
    setState(() { _step = 3; _errorMsg = null; });
  }

  // ── Step 3: Set new password ──────────────────────────────────────────────
  Future<void> _handleResetPassword() async {
    final newPwd = _newPasswordController.text.trim();
    final confirmPwd = _confirmPasswordController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (newPwd.length < 6) {
      _setError('Password must be at least 6 characters.');
      return;
    }
    if (newPwd != confirmPwd) {
      _setError('Passwords do not match.');
      return;
    }

    setState(() { _isLoading = true; _errorMsg = null; });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetPasswordWithEmail(phone, email, newPwd);
    setState(() { _isLoading = false; });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              const Expanded(child: Text('Password reset! Please login with your new password.', style: TextStyle(color: Colors.white))),
            ],
          ),
          backgroundColor: const Color(0xFF2ECC71),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      // Go back to login
      if (mounted) Navigator.pop(context);
    } else {
      _setError(authProvider.errorMessage ?? 'Email does not match our records.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 600;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(gradient: AppTheme.darkMinimalBackground),
          ),

          SafeArea(
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: IconButton(
                      onPressed: () {
                        if (_step > 1) {
                          setState(() { _step -= 1; _errorMsg = null; });
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70),
                    ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 24.0 : 16.0,
                        vertical: 24.0,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isDesktop ? 440 : size.width),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 28.0 : 20.0,
                            vertical: 36.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.cardGray,
                            borderRadius: BorderRadius.circular(28.0),
                            border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icon + title
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.accentGold.withValues(alpha: 0.12),
                                  border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3), width: 1),
                                ),
                                child: const Icon(Icons.lock_reset_rounded, color: AppTheme.accentGold, size: 30),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Forgot Password',
                                style: GoogleFonts.cinzel(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textWhite,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Step indicator
                              _buildStepIndicator(),

                              const SizedBox(height: 28),

                              // Step content
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _step == 1
                                    ? _buildStep1()
                                    : _step == 2
                                        ? _buildStep2()
                                        : _buildStep3(),
                              ),

                              // Error message
                              if (_errorMsg != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xFFFF453A).withValues(alpha: 0.08),
                                    border: Border.all(
                                      color: const Color(0xFFFF453A).withValues(alpha: 0.3),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded,
                                          color: Color(0xFFFF453A), size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMsg!,
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
                              ],

                              const SizedBox(height: 20),

                              // Action button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.premiumGoldGradient,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accentGold.withValues(alpha: 0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _onAction,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: _isLoading
                                        ? const CustomLoader(size: 12, color: AppTheme.backgroundBlack)
                                        : Text(
                                            _step == 1
                                                ? 'Find My Account'
                                                : _step == 2
                                                    ? 'Verify Email'
                                                    : 'Reset Password',
                                            style: GoogleFonts.cinzel(
                                              color: AppTheme.backgroundBlack,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
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
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardGray,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomLoader(size: 16, color: AppTheme.accentGold),
                    const SizedBox(height: 14),
                    Text(
                      _step == 1 ? 'Looking up account...' : 'Resetting password...',
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
  }

  void _onAction() {
    _setError(null);
    if (_step == 1) _handleGetEmailHint();
    else if (_step == 2) _handleVerifyEmail();
    else _handleResetPassword();
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = _step == i + 1;
        final done = _step > i + 1;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: active ? 28 : 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: done
                    ? const Color(0xFF2ECC71)
                    : active
                        ? AppTheme.accentGold
                        : Colors.white12,
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: active ? AppTheme.backgroundBlack : Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (i < 2)
              Container(
                width: 32,
                height: 1,
                color: done ? const Color(0xFF2ECC71) : Colors.white12,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
          ],
        );
      }),
    );
  }

  // ── Step 1 Widget ─────────────────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      key: const ValueKey('step1'),
      children: [
        Text(
          'Enter your registered mobile number',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            color: AppTheme.textMuted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          labelText: 'Mobile Number',
          hintText: 'Enter 10-digit number',
          prefixIcon: Icons.phone_android_rounded,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
        ),
      ],
    );
  }

  // ── Step 2 Widget ─────────────────────────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      key: const ValueKey('step2'),
      children: [
        Text(
          'We found an account linked to this email:',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 12),
        // Masked email display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.accentGold.withValues(alpha: 0.08),
            border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3), width: 0.8),
          ),
          child: Row(
            children: [
              const Icon(Icons.email_rounded, color: AppTheme.accentGold, size: 18),
              const SizedBox(width: 10),
              Text(
                _maskedEmail ?? '',
                style: GoogleFonts.montserrat(
                  color: AppTheme.accentGold,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Enter your full email address to verify:',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          labelText: 'Email Address',
          hintText: 'Enter your registered email',
          prefixIcon: Icons.alternate_email_rounded,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  // ── Step 3 Widget ─────────────────────────────────────────────────────────
  Widget _buildStep3() {
    return Column(
      key: const ValueKey('step3'),
      children: [
        Text(
          'Set your new password',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          labelText: 'New Password',
          hintText: 'Min 6 characters',
          prefixIcon: Icons.lock_outline_rounded,
          controller: _newPasswordController,
          isPassword: true,
        ),
        const SizedBox(height: 4),
        CustomTextField(
          labelText: 'Confirm Password',
          hintText: 'Re-enter new password',
          prefixIcon: Icons.lock_outline_rounded,
          controller: _confirmPasswordController,
          isPassword: true,
        ),
      ],
    );
  }
}
