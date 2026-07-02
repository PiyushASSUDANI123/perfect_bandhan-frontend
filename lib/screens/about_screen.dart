import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../providers/language_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.piyush.assudani';
  static const String _developerUrl = 'https://piyushassudani.in';

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isHindi = lang.currentLanguage == 'hi';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.accentGold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset('assets/logo.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              isHindi ? 'हमारे बारे में' : 'About Perfect Bandhan',
              style: GoogleFonts.cinzel(
                color: AppTheme.accentGold,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Logo ────────────────────────────────────────────────────
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.4),
                    blurRadius: 36,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset('assets/logo.png', fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'परफेक्ट बंधन | Perfect Bandhan',
              style: GoogleFonts.cinzel(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentGold,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            Text(
              isHindi
                  ? 'केवल सिंधी समाज के लिए एक विशेष पहल'
                  : 'An exclusive initiative for the Sindhi Samaj',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: AppTheme.textMuted,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Version chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Version 1.0.0',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 28),

            _goldDivider(),

            const SizedBox(height: 24),

            // ── Mission Statement ─────────────────────────────────────
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(isHindi ? 'हमारा उद्देश्य' : 'Our Mission'),
                  const SizedBox(height: 10),
                  Text(
                    isHindi
                        ? 'परफेक्ट बंधन में आपका स्वागत है। (जय झूलेलाल)\n\nसिंधी समाज के युवाओं के लिए एक नई और भरोसेमंद शुरुआत। हमारा एकमात्र प्रयास है कि आपको अपने विचारों, संस्कारों और प्राथमिकताओं के अनुसार एक योग्य जीवनसाथी मिले।\n\nआज ही अपनी पूरी जानकारी के साथ प्रोफ़ाइल बनाएं, अपने मापदंड तय करें और अपनी पसंद के अनुसार सही रिश्ते की ओर कदम बढ़ाएं।'
                        : 'Welcome to Perfect Bandhan. (Jai Jhulelal)\n\nAn exclusive initiative crafted for the Sindhi community to build meaningful connections. Our goal is simple: to help you find a truly compatible life partner who aligns with your values and lifestyle.\n\nSet up your detailed profile, define your preferences, and take charge of finding the perfect match for your future.',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Developer Section ─────────────────────────────────────
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(isHindi ? 'डेवलपर के बारे में' : 'About the Developer'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.premiumGoldGradient,
                        ),
                        child: const Center(
                          child: Text(
                            'PA',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Piyush Assudani',
                              style: GoogleFonts.cinzel(
                                color: AppTheme.textCarbon,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isHindi
                                  ? 'सॉफ्टवेयर इंजीनियर • असुदानी ग्रुप'
                                  : 'Software Engineer • Assudani Group',
                              style: GoogleFonts.montserrat(
                                color: AppTheme.textMuted,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isHindi
                        ? 'परफेक्ट बंधन को सिंधी समाज की सेवा और डिजिटल सशक्तिकरण के उद्देश्य से बनाया गया है। यह एक पूर्ण रूप से स्वतंत्र और निःशुल्क पहल है।'
                        : 'Perfect Bandhan is built with a vision to empower the Sindhi community through technology. This is a fully independent and free initiative dedicated to the Sindhi Samaj.',
                    style: GoogleFonts.montserrat(
                      fontSize: 12.5,
                      color: AppTheme.textMuted,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => _launch(_developerUrl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.glassColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language_rounded, color: AppTheme.accentGold, size: 15),
                          const SizedBox(width: 8),
                          Text(
                            'piyushassudani.in',
                            style: GoogleFonts.montserrat(
                              color: AppTheme.accentGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: AppTheme.accentGold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.open_in_new_rounded, color: AppTheme.accentGold, size: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── App Functionality ─────────────────────────────────────
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(isHindi ? 'मुख्य विशेषताएं' : 'Key Features'),
                  const SizedBox(height: 12),
                  _buildFeatureItem(Icons.search_rounded, 'Advanced Matchmaking', 'Find verified profiles matching your preferences.'),
                  const SizedBox(height: 12),
                  _buildFeatureItem(Icons.security_rounded, 'Secure & Private', 'Your data is protected. Only approved members can view full profiles.'),
                  const SizedBox(height: 12),
                  _buildFeatureItem(Icons.chat_bubble_outline_rounded, 'Direct Connect', 'Express interest and connect instantly with matches.'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Changelog ─────────────────────────────────────────────
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(isHindi ? 'नया क्या है (v1.1.0)' : 'What\'s New (v1.1.0)'),
                  const SizedBox(height: 12),
                  _buildChangelogItem('• Added Admin Dashboard for analytics.'),
                  _buildChangelogItem('• Introduced Real-time Broadcast Notifications.'),
                  _buildChangelogItem('• Added OTP Resend cooldown to prevent WhatsApp blocks.'),
                  _buildChangelogItem('• Improved overall UI performance and animations.'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Rate App Button ───────────────────────────────────────
            GestureDetector(
              onTap: () => _launch(_playStoreUrl),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.premiumGoldGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGold.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.black, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      isHindi
                          ? 'हमें Play Store पर रेट करें ★★★★★'
                          : 'Rate Us on Play Store ★★★★★',
                      style: GoogleFonts.cinzel(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Legal Links ───────────────────────────────────────────
            _sectionCard(
              child: Column(
                children: [
                  _legalTile(
                    icon: Icons.privacy_tip_outlined,
                    label: isHindi ? 'गोपनीयता नीति' : 'Privacy Policy',
                    onTap: () {},
                  ),
                  const Divider(color: AppTheme.glassBorderColor, height: 1),
                  _legalTile(
                    icon: Icons.description_outlined,
                    label: isHindi ? 'उपयोग की शर्तें' : 'Terms & Conditions',
                    onTap: () {},
                  ),
                  const Divider(color: AppTheme.glassBorderColor, height: 1),
                  _legalTile(
                    icon: Icons.shop_rounded,
                    label: isHindi ? 'Play Store खोलें' : 'Open on Play Store',
                    onTap: () => _launch(_playStoreUrl),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 14, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Footer ────────────────────────────────────────────────
            _goldDivider(),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/logo.png', width: 40, height: 40),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2025 Assudani Group',
              style: GoogleFonts.cinzel(
                color: AppTheme.accentGold,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'A Property of Assudani Group',
              style: GoogleFonts.montserrat(
                color: AppTheme.textMuted,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _launch(_developerUrl),
              child: Text(
                'Developed by Piyush Assudani',
                style: GoogleFonts.montserrat(
                  color: AppTheme.accentGold.withValues(alpha: 0.7),
                  fontSize: 10,
                  decoration: TextDecoration.underline,
                  decorationColor: AppTheme.accentGold.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _goldDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppTheme.accentGold.withValues(alpha: 0.5)],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.favorite, color: AppTheme.accentGold, size: 12),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accentGold.withValues(alpha: 0.5), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.cinzel(
        color: AppTheme.accentGold,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _legalTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.accentGold, size: 18),
      title: Text(
        label,
        style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 13),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 18),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: AppTheme.glassBorderColor),
          ),
          child: Icon(icon, color: AppTheme.accentGold, size: 20),
        ),
        const SizedBox(width: 12.0),
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
    );
  }

  Widget _buildChangelogItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          color: AppTheme.textMuted,
          height: 1.5,
        ),
      ),
    );
  }
}
