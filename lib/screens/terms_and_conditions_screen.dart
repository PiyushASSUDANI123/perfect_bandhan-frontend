import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'TERMS & CONDITIONS',
          style: GoogleFonts.cinzel(
            color: AppTheme.textCarbon,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.cardWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textCarbon, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.gavel_rounded,
                          color: AppTheme.accentGold,
                          size: 48,
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          'PERFECT BANDHAN MATRIMONY',
                          style: GoogleFonts.cinzel(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textCarbon,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'User Agreement & Play Store UGC Safety Policy',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  _buildSectionTitle('1. Eligibility Rules'),
                  _buildSectionBody(
                    'Perfect Bandhan is an exclusive matrimonial platform designed solely for the All India Sindhi Samaj. By registering or using the services, you confirm that:\n'
                    '• You belong to the Sindhi community.\n'
                    '• You are of legal marriageable age according to local laws (18+ for females, 21+ for males).\n'
                    '• You are registering with genuine credentials for the sole purpose of finding a life partner.',
                  ),
                  const SizedBox(height: 20.0),
                  _buildSectionTitle('2. User Generated Content (UGC) Policy'),
                  _buildSectionBody(
                    'Perfect Bandhan acts as a platform for user-created profile dossiers (photos, bios, details). We enforce a zero-tolerance policy against objectionable or abusive content:\n'
                    '• No vulgarity, explicit materials, nudity, or offensive language in photos or bios.\n'
                    '• No harassment, hate speech, threats, or stalking of other matches.\n'
                    '• No misrepresentation or fake credentials (e.g., false education, false earnings, fake names).\n\n'
                    'Any violations will result in immediate profile suspension and permanent device block.',
                  ),
                  const SizedBox(height: 20.0),
                  _buildSectionTitle('3. UGC Safety: Blocking & Reporting'),
                  _buildSectionBody(
                    'To maintain user safety and comply with app store guidelines, Perfect Bandhan offers built-in tools to act against abusive users:\n'
                    '• **Block User:** You can block any match at any time. Blocked users will immediately disappear from your search results and feed, and they will never be able to contact you.\n'
                    '• **Report User:** You can flag any profile for review. Our administrative moderation team will investigate and act on reported profiles within 24 hours. Accounts found violating our terms will be permanently deleted.',
                  ),
                  const SizedBox(height: 20.0),
                  _buildSectionTitle('4. Account Deletion & Data Privacy'),
                  _buildSectionBody(
                    'We value your privacy. In accordance with Play Store developer policies, users can request permanent deletion of their account and all associated data at any time via the "Delete Account" button on the Settings screen. Once requested, your profile, photos, and chat logs are permanently expunged from our database.',
                  ),
                  const SizedBox(height: 20.0),
                  _buildSectionTitle('5. Disclaimer & Indemnity'),
                  _buildSectionBody(
                    'Perfect Bandhan provides profile information on an "as-is" basis. While we verify accounts via WhatsApp handshake, users are strictly advised to perform independent background checks before finalizing any marriage matches. Perfect Bandhan is not liable for any matrimonial disputes or false claims.',
                  ),
                  const SizedBox(height: 40.0),
                  Center(
                    child: Text(
                      'Made for All India Sindhi Samaj Only',
                      style: GoogleFonts.cinzel(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cinzel(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppTheme.accentGold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSectionBody(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          color: AppTheme.textCarbon,
          height: 1.6,
        ),
      ),
    );
  }
}
