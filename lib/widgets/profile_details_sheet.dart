import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/profile.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../screens/chat_screen.dart';

class ProfileDetailsSheet extends StatefulWidget {
  final Profile profile;

  const ProfileDetailsSheet({super.key, required this.profile});

  @override
  State<ProfileDetailsSheet> createState() => _ProfileDetailsSheetState();
}

class _ProfileDetailsSheetState extends State<ProfileDetailsSheet> {
  @override
  void initState() {
    super.initState();
    // Track profile visit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.profile.phone != 'LOCKED' && widget.profile.phone.isNotEmpty) {
        Provider.of<AuthProvider>(context, listen: false).trackActivity(widget.profile.phone, 'profile_visit');
      }
    });
  }

  int _currentPhotoIndex = 0;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  void _openFullScreenPhoto(String photoUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: photoUrl.startsWith('data:image/')
                    ? (() {
                        try {
                          final String base64Data = photoUrl.split(',')[1];
                          final Uint8List imageBytes = base64Decode(base64Data);
                          return Image.memory(imageBytes, fit: BoxFit.contain);
                        } catch (_) {
                          return const Icon(Icons.broken_image, color: Colors.white, size: 64);
                        }
                      })()
                    : Image.network(
                        photoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, color: Colors.white, size: 64),
                      ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String photo) {
    if (photo.startsWith('data:image/')) {
      try {
        final String base64Data = photo.split(',')[1];
        final Uint8List imageBytes = base64Decode(base64Data);
        return Image.memory(imageBytes,
            fit: BoxFit.cover, width: double.infinity, height: double.infinity);
      } catch (_) {
        return const Icon(Icons.broken_image, color: Colors.white);
      }
    } else {
      return Image.network(photo,
          fit: BoxFit.cover, width: double.infinity, height: double.infinity,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, color: Colors.white));
    }
  }

  Widget _buildHouseImage(String housePhoto) {
    if (housePhoto.startsWith('data:image/')) {
      try {
        final String base64Data = housePhoto.split(',')[1];
        final Uint8List imageBytes = base64Decode(base64Data);
        return Image.memory(imageBytes, fit: BoxFit.cover);
      } catch (_) {
        return const Icon(Icons.broken_image, color: Colors.white);
      }
    } else {
      return Image.network(
        housePhoto,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, color: Colors.white),
      );
    }
  }

  Future<void> _launchWhatsApp() async {
    if (widget.profile.phone == 'LOCKED') return;

    // Generate a beautiful preset invitation message targeting Sindhi families
    final String message = Uri.encodeComponent(
      "Jai Jhulelal! I am interested in discussing the profile of ${widget.profile.name} (${widget.profile.age}, ${widget.profile.profession}) on Perfect Bandhan. Let's connect."
    );
    // Use the dynamic unlocked profile contact number
    final String whatsappUrl = "https://wa.me/91${widget.profile.phone}?text=$message";
    final Uri url = Uri.parse(whatsappUrl);
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $whatsappUrl';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not open WhatsApp. Opening web browser instead..."),
            backgroundColor: AppTheme.accentGold,
          ),
        );
        try {
          await launchUrl(url, mode: LaunchMode.platformDefault);
        } catch (_) {}
      }
    }
  }

  void _openInAppChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(profile: widget.profile),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 900;
    
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
      ),
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // Slide Bar / Drag Handle
                const SizedBox(height: 12.0),
                Center(
                  child: Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.glassBorderColor,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
    
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Photo Carousel / Premium Bento Hero Card
                          const SizedBox(height: 12.0),
                          _buildPhotoCarousel(size),
                          const SizedBox(height: 20.0),
    
                          // Match Rate & Compatibility Tag
                          _buildHeaderSection(),
                          const SizedBox(height: 24.0),
    
                          // Bento Blocks Layout
                          _buildBentoBlocks(isDesktop),
                          const SizedBox(height: 24.0),

                          // UGC Safety details (Play Store compliance)
                          _buildUgcSafetyButtons(),
                          const SizedBox(height: 32.0),
                        ],
                      ),
                    ),
                  ),
                ),
    
                // Sticky Bottom CTA Bar
                _buildStickyBottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCarousel(Size size) {
    // Generate dummy photos colors if none provided, or map using gradient colors
    final colors = widget.profile.gradientColors;

    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Stack(
          children: [
            // PageView Carousel
            PageView.builder(
              controller: _pageController,
              itemCount: widget.profile.photos.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPhotoIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final String photo = widget.profile.photos[index];
                final bool hasImage = photo.isNotEmpty && (photo.startsWith('http') || photo.startsWith('data:image/'));

                return GestureDetector(
                  onTap: () {
                    if (hasImage) {
                      _openFullScreenPhoto(photo);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors[0].withValues(alpha: 0.8),
                          colors[colors.length > 1 ? 1 : 0].withValues(alpha: 0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: hasImage
                        ? _buildProfileImage(photo)
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              // Elite grid pattern background simulation
                              Positioned.fill(
                                child: Opacity(
                                  opacity: 0.05,
                                  child: GridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: 25,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 5,
                                    ),
                                    itemBuilder: (context, index) => Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black, width: 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Premium Monogram Logo
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      widget.profile.initials,
                                      style: GoogleFonts.cinzel(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textCarbon,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                    decoration: BoxDecoration(
                                      color: AppTheme.textCarbon.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Text(
                                      "PHOTO ${index + 1} OF ${widget.profile.photos.length}",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textCarbon,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),

            // Subtle Glass Indicator Dots
            if (widget.profile.photos.length > 1)
              Positioned(
                bottom: 16.0,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.profile.photos.length,
                    (index) => GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        height: 6.0,
                        width: _currentPhotoIndex == index ? 20.0 : 6.0,
                        decoration: BoxDecoration(
                          color: _currentPhotoIndex == index
                              ? AppTheme.accentGold
                              : Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Top verified premium badge
            Positioned(
              top: 16.0,
              right: 16.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: AppTheme.glassColor,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: AppTheme.glassBorderGold, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, color: AppTheme.accentGold, size: 14.0),
                    const SizedBox(width: 4.0),
                    Text(
                      'VERIFIED ELITE',
                      style: GoogleFonts.montserrat(
                        color: AppTheme.textCarbon,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'COMPATIBILITY PROFILE',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentGold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_rounded, color: Colors.green, size: 14.0),
                const SizedBox(width: 4.0),
                Text(
                  '${widget.profile.compatibilityScore}% Matches Rules',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12.0),
                GestureDetector(
                  onTap: () {
                    final shareUrl = 'https://app.perfectbandhan.in/profile/${widget.profile.id}';
                    Share.share('Check out ${widget.profile.name}\'s profile on Perfect Bandhan!\n$shareUrl');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.glassBorderGold),
                    ),
                    child: const Icon(Icons.share_rounded, color: AppTheme.accentGold, size: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        Row(
          children: [
            Text(
              widget.profile.name,
              style: GoogleFonts.cinzel(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.textCarbon,
              ),
            ),
            if (widget.profile.isSeriousSeeker) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.amber.shade300, Colors.amber.shade600]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('Serious Seeker', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.textMuted),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppTheme.cardWhite,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppTheme.accentGold),
                          const SizedBox(width: 8),
                          Text('Serious Seeker Badge', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: AppTheme.textCarbon, fontSize: 18)),
                        ],
                      ),
                      content: Text(
                        'This badge is awarded to highly active users who reply to interests (Accept or Decline) within 24 hours. Serious Seekers get 3x more visibility on Perfect Bandhan!',
                        style: GoogleFonts.montserrat(color: AppTheme.textCarbon, height: 1.5, fontSize: 14),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Got it', style: GoogleFonts.montserrat(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  );
                },
              )
            ]
          ],
        ),
        const SizedBox(height: 6.0),
        Text(
          widget.profile.bio,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: AppTheme.textMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBentoBlockContact() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBlockTitle('Contact Information'),
          const SizedBox(height: 14.0),
          _buildInfoRow(Icons.phone_android_outlined, 'Mobile Number', widget.profile.phone.isEmpty ? 'Not Provided' : widget.profile.phone),
          _buildInfoRow(Icons.chat_outlined, 'WhatsApp Number', widget.profile.whatsappNumber.isEmpty ? 'Not Provided' : widget.profile.whatsappNumber),
        ],
      ),
    );
  }

  Widget _buildBentoBlocks(bool isDesktop) {
    if (isDesktop) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildBentoBlock1()),
              const SizedBox(width: 16.0),
              Expanded(child: _buildBentoBlock2()),
            ],
          ),
          const SizedBox(height: 16.0),
          _buildBentoBlockKundali(),
          const SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildBentoBlock3()),
              const SizedBox(width: 16.0),
              Expanded(child: _buildBentoBlockContact()),
            ],
          ),
          const SizedBox(height: 16.0),
          _buildBentoBlockAdvanced(),
        ],
      );
    }

    return Column(
      children: [
        _buildBentoBlockContact(),
        const SizedBox(height: 16.0),
        _buildBentoBlockKundali(),
        const SizedBox(height: 16.0),
        _buildBentoBlock1(),
        const SizedBox(height: 16.0),
        _buildBentoBlock2(),
        const SizedBox(height: 16.0),
        _buildBentoBlock3(),
        const SizedBox(height: 16.0),
        _buildBentoBlockAdvanced(),
      ],
    );
  }

  Widget _buildBentoBlockKundali() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppTheme.accentGold, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBlockTitle('Astrology & Kundali'),
          const SizedBox(height: 14.0),
          _buildInfoRow(Icons.access_time_outlined, 'Birth Time', widget.profile.birthTime.isEmpty ? 'Not Provided' : widget.profile.birthTime),
          _buildInfoRow(Icons.location_on_outlined, 'Birth Place', widget.profile.birthPlace.isEmpty ? 'Not Provided' : widget.profile.birthPlace),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: AppTheme.accentGold, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.profile.kundaliMessage ?? 'Kundali data unavailable',
                  style: GoogleFonts.cinzel(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textCarbon,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoBlockAdvanced() {
    final hasHousePhoto = widget.profile.housePhoto.isNotEmpty &&
        (widget.profile.housePhoto.startsWith('http') || widget.profile.housePhoto.startsWith('data:image/'));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBlockTitle('Additional Attributes & House Info'),
          const SizedBox(height: 14.0),
          if (widget.profile.nukh.isNotEmpty)
            _buildInfoRow(Icons.history_edu_outlined, 'Clan Nukh', widget.profile.nukh),
          if (widget.profile.complexion.isNotEmpty)
            _buildInfoRow(Icons.palette_outlined, 'Complexion', widget.profile.complexion),
          if (widget.profile.physicalDisability.isNotEmpty)
            _buildInfoRow(Icons.accessibility_new_outlined, 'Physical Status / Disability', widget.profile.physicalDisability),
          if (widget.profile.ownHouse.isNotEmpty)
            _buildInfoRow(Icons.home_outlined, 'House Ownership Status', widget.profile.ownHouse),
          if (widget.profile.requirements.isNotEmpty)
            _buildInfoRow(Icons.assignment_outlined, 'Partner Requirements', widget.profile.requirements),
          if (widget.profile.whatWeProvide.isNotEmpty)
            _buildInfoRow(Icons.card_giftcard_outlined, 'What We Provide / Family Background Details', widget.profile.whatWeProvide),
          if (hasHousePhoto) ...[
            const SizedBox(height: 14.0),
            Text(
              'House / Property Photo',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 8.0),
            GestureDetector(
              onTap: () {
                _openFullScreenPhoto(widget.profile.housePhoto);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: AppTheme.backgroundLight,
                  child: _buildHouseImage(widget.profile.housePhoto),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Block 1: Basic Info
  Widget _buildBentoBlock1() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBlockTitle('Basic Credentials'),
          const SizedBox(height: 14.0),
          _buildInfoRow(Icons.calendar_today_rounded, 'Age', '${widget.profile.age} Years'),
          _buildInfoRow(Icons.height_rounded, 'Height', widget.profile.height),
          if (widget.profile.weight.isNotEmpty)
            _buildInfoRow(Icons.monitor_weight_outlined, 'Weight', '${widget.profile.weight} kg'),
          _buildInfoRow(Icons.location_on_outlined, 'Location', widget.profile.location),
          if (widget.profile.sindhiType.isNotEmpty)
            _buildInfoRow(Icons.account_balance_outlined, 'Sindhi Sect / Type', widget.profile.sindhiType),
          _buildInfoRow(Icons.fingerprint_rounded, 'Marital Status', widget.profile.interestStatus == 'accepted' ? 'Connected' : 'Looking'),
        ],
      ),
    );
  }

  // Block 2: Career & Education
  Widget _buildBentoBlock2() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBlockTitle('Career & Financials'),
          const SizedBox(height: 14.0),
          _buildInfoRow(Icons.school_outlined, 'Education', widget.profile.education),
          _buildInfoRow(Icons.work_outline_rounded, 'Job Title', widget.profile.profession),
          _buildInfoRow(Icons.business_center_outlined, 'Company', widget.profile.company),
          _buildInfoRow(Icons.currency_rupee_rounded, 'Annual Income', widget.profile.incomeBracket),
        ],
      ),
    );
  }

  // Block 3: Family Details & Clan Nukh
  Widget _buildBentoBlock3() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBlockTitle('Family & Clan Heritage'),
          const SizedBox(height: 14.0),
          _buildInfoRow(Icons.people_outline_rounded, 'Clan (Caste)', widget.profile.caste),
          _buildInfoRow(Icons.family_restroom_rounded, 'Clan Nukh', widget.profile.initials.isNotEmpty ? widget.profile.initials : 'Sadhwani'),
          _buildInfoRow(Icons.business_outlined, "Father's Status", widget.profile.fatherStatus),
          if (widget.profile.fatherStatus == 'Alive' && widget.profile.fathersOccupation.isNotEmpty)
            _buildInfoRow(Icons.business_outlined, "Father's Occupation", widget.profile.fathersOccupation),
          _buildInfoRow(Icons.business_outlined, "Mother's Status", widget.profile.motherStatus),
          if (widget.profile.motherStatus == 'Alive' && widget.profile.mothersOccupation.isNotEmpty)
            _buildInfoRow(Icons.business_outlined, "Mother's Occupation", widget.profile.mothersOccupation),
          _buildInfoRow(Icons.child_care_rounded, "Siblings Count", widget.profile.siblingsCount),
          if (widget.profile.siblingsDetails.isNotEmpty)
            _buildInfoRow(Icons.info_outline_rounded, "Siblings Details", widget.profile.siblingsDetails),
        ],
      ),
    );
  }

  Widget _buildBlockTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4.0,
          height: 16.0,
          decoration: BoxDecoration(
            color: AppTheme.accentGold,
            borderRadius: BorderRadius.circular(2.0),
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: GoogleFonts.cinzel(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textCarbon,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.0, color: AppTheme.accentGold),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textCarbon,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar() {
    final provider = Provider.of<AuthProvider>(context);
    final profile = widget.profile;
    final isLocked = profile.phone == 'LOCKED';
    final interestStatus = profile.interestStatus;
    final isDeveloper = provider.phoneNumber == '9413879444' || provider.phoneNumber == '+919413879444';

    Widget actionButton;
    Widget? bannerWidget;

    final chatButton = Expanded(
      child: Container(
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
          onPressed: _openInAppChat,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 18.0),
                const SizedBox(width: 8.0),
                Text(
                  'CHAT',
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (interestStatus == 'accepted' || isDeveloper) {
      actionButton = Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3), width: 0.5),
              ),
              child: ElevatedButton(
                onPressed: _launchWhatsApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat, color: Color(0xFF10B981), size: 18.0),
                      const SizedBox(width: 8.0),
                      Text(
                        'WHATSAPP',
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          chatButton, // In-app chat button
        ],
      );
    } else if (interestStatus == 'pending') {
      bannerWidget = Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 0.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.hourglass_empty_rounded, color: Colors.amber, size: 16),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'Interest pending. Waiting for mutual connection approval.',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      actionButton = Expanded(
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: AppTheme.glassBorderColor, width: 1.0),
          ),
          child: ElevatedButton(
            onPressed: () async {
              final targetPhone = profile.phone;
              if (targetPhone != 'LOCKED') {
                final success = await provider.cancelInterest(targetPhone, profile.id);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request cancelled.')),
                  );
                }
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
                const Icon(Icons.close_rounded, color: AppTheme.textCarbon, size: 18.0),
                const SizedBox(width: 8.0),
                Text(
                  'CANCEL REQUEST',
                  style: GoogleFonts.cinzel(
                    color: AppTheme.textCarbon,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (interestStatus == 'incoming') {
      bannerWidget = Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3), width: 0.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Colors.green, size: 16),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'Connection request received! Accept to unlock chat contact.',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      actionButton = Expanded(
        child: Container(
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
            onPressed: () async {
              final targetPhone = profile.phone;
              if (targetPhone != 'LOCKED') {
                final success = await provider.acceptInterest(targetPhone, profile.id);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Connection accepted! Contact unlocked.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                }
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
                const Icon(Icons.check_circle_outline_rounded, color: Colors.black, size: 18.0),
                const SizedBox(width: 8.0),
                Text(
                  'ACCEPT CONNECTION',
                  style: GoogleFonts.cinzel(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      bannerWidget = Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3), width: 0.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_outline_rounded, color: AppTheme.accentGold, size: 16),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'Chat contact locked. Send interest to initiate mutual connection handshake.',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textCarbon,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      actionButton = Expanded(
        child: Container(
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
            onPressed: () async {
              final targetPhone = profile.phone;
              final success = await provider.sendInterest(targetPhone, profile.id);
              if (success && mounted) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppTheme.cardWhite,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 64),
                        const SizedBox(height: 16),
                        Text('Request Sent!', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Your interest has been sent to ${profile.name}.', textAlign: TextAlign.center, style: GoogleFonts.montserrat(color: AppTheme.textCarbon)),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('OK', style: GoogleFonts.montserrat(color: AppTheme.primaryRed, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
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
                const Icon(Icons.favorite_rounded, color: Colors.black, size: 18.0),
                const SizedBox(width: 8.0),
                Text(
                  'SEND INTEREST',
                  style: GoogleFonts.cinzel(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0, bottom: 28.0),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppTheme.glassBorderColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            bannerWidget ?? const SizedBox.shrink(),
            Row(
              children: [
                // Close Button
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close_rounded, color: AppTheme.textCarbon),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(child: actionButton),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () {
                  final shareUrl = 'https://play.google.com/store/apps/details?id=com.piyush.assudani';
                  final message = '🔱 *Jai Jhulelal!*\n\n📋 *Profile — Perfect Bandhan*\n━━━━━━━━━━━━━━━━\n👤 *Name:* ${widget.profile.name}\n🎂 *Age:* ${widget.profile.age} yrs\n🏢 *Profession:* ${widget.profile.profession}\n🎓 *Education:* ${widget.profile.education}\n📍 *Location:* ${widget.profile.location}\n🧬 *Nukh:* ${widget.profile.nukh.isNotEmpty ? widget.profile.nukh : widget.profile.caste}\n━━━━━━━━━━━━━━━━\n\n📲 *Download app to view full profile & connect:*\n$shareUrl\n\n_Shared via Perfect Bandhan_ 🤝';
                  final whatsappUrl = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
                  launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.family_restroom_rounded, size: 18, color: Color(0xFF25D366)),
                label: Text(
                  'SHARE TO FAMILY (WHATSAPP)',
                  style: GoogleFonts.cinzel(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF25D366),
                    letterSpacing: 0.5,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: const Color(0xFF25D366).withOpacity(0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUgcSafetyButtons() {
    return Center(
      child: Column(
        children: [
          const Divider(color: AppTheme.glassBorderColor, height: 1),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => _confirmReport(),
                icon: const Icon(Icons.report_problem_outlined, color: Colors.redAccent, size: 16),
                label: Text(
                  'REPORT USER',
                  style: GoogleFonts.montserrat(
                    color: Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 24.0),
              Container(width: 1, height: 16, color: AppTheme.glassBorderColor),
              const SizedBox(width: 24.0),
              TextButton.icon(
                onPressed: () => _confirmBlock(),
                icon: const Icon(Icons.block_flipped, color: Colors.redAccent, size: 16),
                label: Text(
                  'BLOCK USER',
                  style: GoogleFonts.montserrat(
                    color: Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReport() async {
    String selectedReason = 'Inappropriate Content';
    final detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.cardWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              'Report Profile',
              style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Are you sure you want to report this profile?\n\nIf you find this user posting abusive content, fake pictures, or violating the community rules, we will review the report and take action within 24 hours.',
                    style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 12, height: 1.6)),
                  const SizedBox(height: 16),
                  Text('Reason:', style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    items: ['Inappropriate Content', 'Fake Profile', 'Spam', 'Harassment', 'Other']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.montserrat(fontSize: 13))))
                        .toList(),
                    onChanged: (val) => setState(() => selectedReason = val!),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Details (Optional):', style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: detailsController,
                    maxLines: 3,
                    style: GoogleFonts.montserrat(fontSize: 13),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: 'Provide more info...',
                      hintStyle: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final provider = Provider.of<AuthProvider>(context, listen: false);
                  final success = await provider.reportUser(widget.profile.phone, selectedReason, detailsController.text);
                  if (success && context.mounted) {
                    Navigator.pop(context); // close details sheet
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile reported successfully. We will review it within 24 hours.'), backgroundColor: Colors.green));
                  }
                },
                child: Text('Report', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _confirmBlock() async {
    String selectedReason = 'Not Interested';
    final detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.cardWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              'Block Profile',
              style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Are you sure you want to block this profile?\n\nOnce blocked, you will no longer see their profile on your feed, and they will not be able to interact with you.',
                    style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 12, height: 1.6)),
                  const SizedBox(height: 16),
                  Text('Reason:', style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    items: ['Not Interested', 'Harassment', 'Spam', 'Fake Profile', 'Other']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.montserrat(fontSize: 13))))
                        .toList(),
                    onChanged: (val) => setState(() => selectedReason = val!),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Details (Optional):', style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: detailsController,
                    maxLines: 3,
                    style: GoogleFonts.montserrat(fontSize: 13),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: 'Provide more info...',
                      hintStyle: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final provider = Provider.of<AuthProvider>(context, listen: false);
                  final success = await provider.blockUser(widget.profile.phone, selectedReason, detailsController.text);
                  if (success && context.mounted) {
                    Navigator.pop(context); // close details sheet
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile blocked successfully. Feed will refresh.'), backgroundColor: Colors.green));
                    provider.fetchDailyPicks(refresh: true);
                  }
                },
                child: Text('Block', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      ),
    );
  }
}
