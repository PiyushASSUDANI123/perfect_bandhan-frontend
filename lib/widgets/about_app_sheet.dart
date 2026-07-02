import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class AboutAppSheet extends StatelessWidget {
  const AboutAppSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
      ),
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(height: 24.0),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Icon / Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.cardGray,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5), width: 1.5),
                    ),
                    child: const Icon(Icons.favorite_rounded, color: AppTheme.accentGold, size: 40),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Perfect Bandhan',
                    style: GoogleFonts.cinzel(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textCarbon,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Version ${AuthProvider.localAppVersion}',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  
                  // App Functionality
                  _buildSectionHeader('Key Features'),
                  _buildFeatureItem(Icons.search_rounded, 'Advanced Matchmaking', 'Find verified profiles matching your preferences.'),
                  _buildFeatureItem(Icons.security_rounded, 'Secure & Private', 'Your data is protected. Only approved members can view full profiles.'),
                  _buildFeatureItem(Icons.chat_bubble_outline_rounded, 'Direct Connect', 'Express interest and connect instantly with matches.'),
                  
                  const SizedBox(height: 24.0),
                  
                  // Changelog
                  _buildSectionHeader('What\'s New (v1.1.0)'),
                  _buildChangelogItem('• Added Admin Dashboard for analytics.'),
                  _buildChangelogItem('• Introduced Real-time Broadcast Notifications.'),
                  _buildChangelogItem('• Added OTP Resend cooldown to prevent WhatsApp blocks.'),
                  _buildChangelogItem('• Improved overall UI performance and animations.'),
                  
                  const SizedBox(height: 40.0),
                  Text(
                    '© 2026 Perfect Bandhan. All rights reserved.',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      color: AppTheme.textMuted.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppTheme.glassBorderColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentGold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppTheme.glassBorderColor)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: AppTheme.accentGold, size: 20),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textCarbon,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  desc,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangelogItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: AppTheme.textWhite,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
