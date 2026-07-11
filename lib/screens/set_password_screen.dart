import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/premium_feedback.dart';
import '../providers/auth_provider.dart';
import '../main.dart'; // To access HomeScreenWrapper

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final password = _passController.text.trim();
    final confirm = _confirmPassController.text.trim();

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match!'),
          backgroundColor: Color(0xFFFF453A),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.setPassword(password);

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      PremiumFeedback.showSuccess(
        context: context,
        title: 'Password Configured',
        message: 'Your account password has been set successfully. Please complete the remaining onboarding steps.',
        onDismiss: () {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreenWrapper()),
              (route) => false,
            );
          }
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save password. Try again.'),
          backgroundColor: Color(0xFFFF453A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 600;

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
                    border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CHOOSE PASSWORD',
                          style: GoogleFonts.cinzel(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textCarbon,
                            letterSpacing: 2.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Configure a secure password for subsequent logins.',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24.0),
                        CustomTextField(
                          labelText: 'NEW PASSWORD',
                          hintText: 'Enter at least 6 characters',
                          prefixIcon: Icons.lock_outline_rounded,
                          controller: _passController,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          labelText: 'CONFIRM PASSWORD',
                          hintText: 'Re-enter your password',
                          prefixIcon: Icons.lock_outline_rounded,
                          controller: _confirmPassController,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Confirm your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppTheme.premiumGoldGradient,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black))
                                : Text(
                                    'SET PASSWORD',
                                    style: GoogleFonts.cinzel(
                                      color: AppTheme.backgroundBlack,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
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
    );
  }
}
