import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PremiumFeedback {
  static void showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onDismiss,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      iconColor: const Color(0xFF34C759), // Apple Green
      onDismiss: onDismiss,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onDismiss,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      icon: Icons.info_outline_rounded,
      iconColor: AppTheme.accentGold,
      onDismiss: onDismiss,
    );
  }

  static void showError({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onDismiss,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      icon: Icons.error_outline_rounded,
      iconColor: const Color(0xFFFF3B30), // Apple Red
      onDismiss: onDismiss,
    );
  }

  static void show({
    required BuildContext context,
    required String title,
    required String message,
    IconData icon = Icons.favorite_rounded,
    Color iconColor = AppTheme.accentGold,
    VoidCallback? onDismiss,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final double scale = 0.85 + (anim1.value * 0.15);
        final double opacity = anim1.value;

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Align(
              alignment: Alignment.center,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.sizeOf(context).width > 450 ? 400 : MediaQuery.sizeOf(context).width * 0.85,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: AppTheme.glassBorderGold,
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Premium Concentric Ring Icon Emblem
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: iconColor.withValues(alpha: 0.35), width: 1.0),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: iconColor.withValues(alpha: 0.08),
                          ),
                          child: Icon(
                            icon,
                            color: iconColor,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22.0),
                      
                      // Title in Cinzel styling
                      Text(
                        title.toUpperCase(),
                        style: GoogleFonts.cinzel(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textCarbon,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12.0),
                      
                      // Message in Montserrat body style
                      Text(
                        message,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24.0),
                      
                      // Action dismiss button
                      Container(
                        width: double.infinity,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: AppTheme.premiumGoldGradient,
                          borderRadius: BorderRadius.circular(14.0),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentGold.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (onDismiss != null) {
                              onDismiss();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                          ),
                          child: Text(
                            'OK',
                            style: GoogleFonts.cinzel(
                              color: AppTheme.backgroundLight,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
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
        );
      },
    );
  }
}
