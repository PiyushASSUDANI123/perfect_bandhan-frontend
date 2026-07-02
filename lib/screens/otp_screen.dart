import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_feedback.dart';
import '../providers/auth_provider.dart';
import 'set_password_screen.dart';
import 'dart:async';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _expirySeconds = 300;
  int _resendSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_expirySeconds > 0) _expirySeconds--;
          if (_resendSeconds > 0) _resendSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _verifyOtp(BuildContext context) async {
    if (_expirySeconds == 0) {
      PremiumFeedback.showError(
        context: context,
        title: "OTP Expired",
        message: "Your OTP has expired. Please request a new one.",
      );
      return;
    }

    // Collate digits
    String code = _controllers.map((c) => c.text).join();
    if (code.length != 4) {
      PremiumFeedback.showError(
        context: context,
        title: "Invalid Code",
        message: "Please enter the full 4-digit verification code.",
      );
      return;
    }

    final navigator = Navigator.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyOtp(code);
    if (success && context.mounted) {
      if (!authProvider.isProfileComplete) {
        // Direct to SetPasswordScreen first
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SetPasswordScreen()),
        );
      } else {
        navigator.pop();
      }
    } else if (!success && context.mounted) {
      PremiumFeedback.showError(
        context: context,
        title: "Verification Failed",
        message: authProvider.errorMessage ?? "Invalid OTP code. Please enter the correct code.",
      );
      // Auto-clear fields on error so they can re-type
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 600;
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final bool isLoading = authProvider.status == AuthStatus.verifyingOtp;
        final bool hasError = authProvider.status == AuthStatus.error;

        return Scaffold(
          body: Stack(
            children: [
              // 1. Sleek Minimal Dark Background
              Container(
                width: size.width,
                height: size.height,
                decoration: const BoxDecoration(
                  gradient: AppTheme.darkMinimalBackground,
                ),
              ),

              // 2. Main OTP Card Container
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 450 : size.width,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
                      decoration: BoxDecoration(
                        color: AppTheme.cardGray,
                        borderRadius: BorderRadius.circular(28.0),
                        border: Border.all(
                          color: AppTheme.glassBorderColor,
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Custom Header Back Button to return
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textCarbon, size: 16),
                              onPressed: isLoading 
                                  ? null 
                                  : () {
                                      authProvider.reset();
                                      Navigator.pop(context);
                                    },
                            ),
                          ),
                          const SizedBox(height: 10.0),

                          // Header Text
                          Text(
                            'VERIFICATION CODE',
                            style: GoogleFonts.cinzel(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textCarbon,
                              letterSpacing: 2.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12.0),
                          
                          // Instruction text with phone display
                          Text(
                            'Sent via WhatsApp to +91 ${authProvider.phoneNumber ?? "your number"}.',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28.0),

                          // 6 Digit OTP fields row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(4, (index) => _buildOtpDigitField(index, isLoading)),
                          ),
                          const SizedBox(height: 20.0),

                          // Brutal Clear Error Display
                          if (hasError && authProvider.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF453A).withValues(alpha: 0.1),
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
                            const SizedBox(height: 20.0),
                          ],

                          // Verify Button
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
                              onPressed: isLoading ? null : () => _verifyOtp(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              ),
                              child: Text(
                                'VERIFY & SIGN IN',
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

                          // Timers & Resend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _expirySeconds > 0
                                    ? "Expires in ${(_expirySeconds ~/ 60).toString().padLeft(2, '0')}:${(_expirySeconds % 60).toString().padLeft(2, '0')}"
                                    : "OTP Expired",
                                style: GoogleFonts.montserrat(
                                  color: _expirySeconds > 0 ? AppTheme.textMuted : const Color(0xFFFF453A),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: _resendSeconds > 0 || isLoading
                                    ? null
                                    : () async {
                                        final auth = Provider.of<AuthProvider>(context, listen: false);
                                        final success = await auth.sendOtp(auth.phoneNumber ?? '');
                                        if (success && mounted) {
                                          PremiumFeedback.show(
                                            context: context,
                                            title: "OTP Resent",
                                            message: "A new 4-digit verification code has been sent via WhatsApp to +91 ${auth.phoneNumber}.",
                                            icon: Icons.message_rounded,
                                            iconColor: Colors.green,
                                          );
                                          // Clear old OTP from UI fields
                                          for (var controller in _controllers) {
                                            controller.clear();
                                          }
                                          _focusNodes[0].requestFocus();
                                        }
                                        setState(() {
                                          _expirySeconds = 300;
                                          _resendSeconds = 60;
                                        });
                                      },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  _resendSeconds > 0 ? 'Resend in ${_resendSeconds}s' : 'RESEND OTP',
                                  style: GoogleFonts.montserrat(
                                    color: _resendSeconds > 0 ? AppTheme.textMuted.withValues(alpha: 0.5) : AppTheme.accentGold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Centralized Loading Blocker Screen Overlay
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
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                          strokeWidth: 2.5,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'Verifying code...',
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

  // Individual digit field with automatic forward/backward focus traversal
  Widget _buildOtpDigitField(int index, bool disabled) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: SizedBox(
          height: 54,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            enabled: !disabled,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textCarbon,
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            cursorColor: AppTheme.accentGold,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.glassColor,
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: AppTheme.glassBorderColor, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: AppTheme.accentGold, width: 1.0),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: AppTheme.glassBorderColor, width: 0.2),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                // Move focus to next field if it's not the last one
                if (index < 5) {
                  _focusNodes[index + 1].requestFocus();
                } else {
                  // Final field reached, auto-dismiss keyboard
                  _focusNodes[index].unfocus();
                }
              } else {
                // Move focus to previous field if backspaced
                if (index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
