import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SocialLoginButton extends StatefulWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<SocialLoginButton> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.diagonal3Values(_isTapped ? 0.97 : 1.0, _isTapped ? 0.97 : 1.0, 1.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: _isTapped 
              ? AppTheme.accentGold.withValues(alpha: 0.1) 
              : AppTheme.glassColor,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: _isTapped 
                ? AppTheme.accentGold 
                : AppTheme.glassBorderColor,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.icon,
            const SizedBox(width: 10.0),
            Text(
              widget.label,
              style: GoogleFonts.montserrat(
                color: AppTheme.textCarbon,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
