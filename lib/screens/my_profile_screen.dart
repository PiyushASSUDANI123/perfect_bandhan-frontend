import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/premium_feedback.dart';
import '../widgets/manage_photos_sheet.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/partner_preferences_sheet.dart';
import '../utils/image_picker_helper.dart';
import 'partner_preferences_screen.dart';
import 'terms_and_conditions_screen.dart';
import 'about_screen.dart';
import '../widgets/profile_completion_ring.dart';
import 'login_screen.dart';
import 'admin_panel_screen.dart';
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isAutoFetchingInsight = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      if (provider.myProfile == null && !provider.isLoadingMyProfile) {
        provider.fetchMyProfile();
      }
    });
  }

  void _managePhotos() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ManagePhotosSheet(),
    );
  }

  // ─── Helper ───────────────────────────────────────────────────────────────

  String _safeStr(Map<String, dynamic> data, String key,
      {String fallback = '—'}) {
    final v = data[key];
    if (v == null || v.toString().isEmpty) return fallback;
    return v.toString();
  }

  int _safeInt(Map<String, dynamic> data, String key, {int fallback = 0}) {
    final v = data[key];
    if (v == null) return fallback;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? fallback;
  }

  bool _safeBool(Map<String, dynamic> data, String key,
      {bool fallback = false}) {
    final v = data[key];
    if (v == null) return fallback;
    if (v is bool) return v;
    return v.toString() == 'true';
  }

  // ─── Delete account dialog ─────────────────────────────────────────────────

  Future<void> _confirmDeleteAccount(BuildContext ctx) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      barrierColor: Colors.black54,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          Provider.of<LanguageProvider>(ctx, listen: false).translate('delete_account'),
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFF3B30),
            fontSize: 18,
          ),
        ),
        content: Text(
          Provider.of<LanguageProvider>(ctx, listen: false).translate('delete_account_desc'),
          style: GoogleFonts.montserrat(
            color: AppTheme.textCarbon,
            fontSize: 13,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(Provider.of<LanguageProvider>(ctx, listen: false).translate('cancel_btn'),
                style: GoogleFonts.montserrat(
                    color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(Provider.of<LanguageProvider>(ctx, listen: false).translate('delete_account'),
                style: GoogleFonts.montserrat(
                    color: const Color(0xFFFF3B30),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && ctx.mounted) {
      final auth = Provider.of<AuthProvider>(ctx, listen: false);
      final success = await auth.deleteAccount();
      
      if (ctx.mounted) {
        if (success) {
          PremiumFeedback.showSuccess(
            context: ctx,
            title: Provider.of<LanguageProvider>(ctx, listen: false).translate('account_deleted'),
            message: 'Your account and all associated data have been permanently deleted.',
          );
          Navigator.pushAndRemoveUntil(
            ctx,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        } else {
          PremiumFeedback.showError(
            context: ctx,
            title: Provider.of<LanguageProvider>(ctx, listen: false).translate('deletion_failed'),
            message: 'We could not delete your account right now. Please try again.',
          );
        }
      }
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext ctx) async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: ctx,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
          title: Text(
            'CHANGE PASSWORD',
            style: GoogleFonts.cinzel(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.textCarbon,
              letterSpacing: 1.0,
            ),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    labelText: 'CURRENT PASSWORD',
                    hintText: 'Enter current password',
                    prefixIcon: Icons.lock_open_rounded,
                    controller: currentPasswordController,
                    isPassword: true,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Current password is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  CustomTextField(
                    labelText: 'NEW PASSWORD',
                    hintText: 'Enter new password',
                    prefixIcon: Icons.lock_outline_rounded,
                    controller: newPasswordController,
                    isPassword: true,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'New password is required';
                      if (val.length < 4) return 'Password must be at least 4 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  CustomTextField(
                    labelText: 'CONFIRM PASSWORD',
                    hintText: 'Re-enter new password',
                    prefixIcon: Icons.lock_rounded,
                    controller: confirmPasswordController,
                    isPassword: true,
                    validator: (val) {
                      if (val != newPasswordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                'CANCEL',
                style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final provider = Provider.of<AuthProvider>(ctx, listen: false);
                  final success = await provider.changePassword(
                    currentPasswordController.text,
                    newPasswordController.text,
                  );
                  if (success) {
                    if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                    if (ctx.mounted) {
                      PremiumFeedback.showSuccess(
                        context: ctx,
                        title: Provider.of<LanguageProvider>(ctx, listen: false).translate("password_updated"),
                        message: "Your login password has been changed successfully.",
                      );
                    }
                  } else {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text(provider.errorMessage ?? "Failed to update password."),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                }
              },
              child: Text(
                'UPDATE',
                style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFillAstrologyDetailsPopup(BuildContext context, AuthProvider provider) {
    TimeOfDay? selectedTime;
    final placeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.backgroundBlack,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Fill your detail now', style: GoogleFonts.cinzel(color: AppTheme.accentGold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (picked != null) setState(() => selectedTime = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.glassColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.glassBorderColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: AppTheme.textMuted),
                          const SizedBox(width: 12),
                          Text(selectedTime != null ? selectedTime!.format(context) : 'Select Birth Time',
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: placeController,
                    labelText: 'Place of Birth',
                    hintText: 'Place of Birth',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx), 
                  child: Text('Cancel', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold),
                  onPressed: () {
                    if (selectedTime == null || placeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill both fields')));
                      return;
                    }
                    Navigator.pop(ctx);
                    _fetchAndShowAstrologyInsight(context, provider, provider.myProfile?['dob'], selectedTime!.format(context), placeController.text);
                  },
                  child: Text('Submit', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _fetchAndShowAstrologyInsight(BuildContext context, AuthProvider provider, String? dob, String? time, String? place, {bool showBottomSheet = true}) async {
    if (showBottomSheet) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
      );
    }

    try {
      final token = provider.token;
      final response = await http.post(
        Uri.parse('${AuthProvider.baseUrl}/user/astrology-insight'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({
          'dob': dob,
          'birthTime': time,
          'birthPlace': place,
        }),
      );

      if (showBottomSheet && context.mounted) Navigator.pop(context); // Close loading

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        final insight = resData['data'];
        
        provider.myProfile?['astrologyInsight'] = insight;
        
        if (showBottomSheet && context.mounted) {
          _showAstrologyInsightBottomSheet(context, provider, insight);
        } else if (mounted) {
          setState(() {}); // Rebuild to show the newly fetched card
        }
      } else {
        if (showBottomSheet && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load insight')));
      }
    } catch (e) {
      if (showBottomSheet && context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An error occurred')));
      }
    }
  }

  void _showAstrologyInsightBottomSheet(BuildContext context, AuthProvider provider, dynamic insight) {
    bool showEnglish = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundBlack,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // The bottom sheet might have a separate variable in state
            // The bottom sheet might have a separate variable in state
            // Let's use a local variable passed in
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (_, controller) => Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('✨ Know About Yourself', style: GoogleFonts.cinzel(fontSize: 22, color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.share, color: AppTheme.accentGold),
                          onPressed: () {
                            final name = provider.myProfile?['name'] ?? 'Someone';
                            var selectedText = showEnglish ? (insight['english'] ?? '') : (insight['hindi'] ?? '');
                            
                            // Ensure proper spacing between bullet points if they exist
                            if (selectedText.contains('1.')) {
                              selectedText = selectedText.replaceAllMapped(RegExp(r'(\d\.)'), (match) => '\n${match.group(1)}').trim();
                            }
                            
                            final header = showEnglish 
                                ? "✨ AI Personality Insight for *$name* ✨" 
                                : "✨ *$name* के लिए AI व्यक्तित्व अंतर्दृष्टि ✨";
                            
                            final text = "$header\n\n$selectedText\n\n👇 Get your free Kundali & AI insights!\nDownload Perfect Bandhan - India's Premium Sindhi Matrimony App ❤️\n🔗 https://perfectbandhan.in";
                            Share.share(text);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Language Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardGray,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setModalState(() => showEnglish = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: showEnglish ? AppTheme.accentGold : Colors.transparent,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Center(child: Text('English', style: GoogleFonts.montserrat(color: showEnglish ? Colors.white : AppTheme.accentGold, fontWeight: FontWeight.bold))),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setModalState(() => showEnglish = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !showEnglish ? AppTheme.accentGold : Colors.transparent,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Center(child: Text('हिंदी', style: GoogleFonts.montserrat(color: !showEnglish ? Colors.white : AppTheme.accentGold, fontWeight: FontWeight.bold))),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        child: Text(
                          showEnglish ? (insight['english'] ?? '') : (insight['hindi'] ?? ''),
                          style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 15, height: 1.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = Provider.of<AuthProvider>(context);

    if (provider.isLoadingMyProfile && provider.myProfile == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentGold),
      );
    }

    final data = provider.myProfile ?? {};
    final birthTime = _safeStr(data, 'birthTime');
    final birthPlace = _safeStr(data, 'birthPlace');
    final dobStr = _safeStr(data, 'dob');
    
    // Auto-fetch insight if we have birth details but no insight yet
    if (data['astrologyInsight'] == null && !_isAutoFetchingInsight && birthTime.isNotEmpty && birthPlace.isNotEmpty && dobStr.isNotEmpty) {
      _isAutoFetchingInsight = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchAndShowAstrologyInsight(context, provider, dobStr, birthTime, birthPlace, showBottomSheet: false);
      });
    }

    if (provider.myProfileError != null && provider.myProfile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded,
                color: AppTheme.textMuted.withValues(alpha: 0.4), size: 56),
            const SizedBox(height: 16),
            Text(provider.myProfileError!,
                style: GoogleFonts.montserrat(
                    color: AppTheme.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: provider.fetchMyProfile,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accentGold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Retry',
                  style: GoogleFonts.montserrat(
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    final String name =
        '${_safeStr(data, 'firstName')} ${_safeStr(data, 'lastName')}';
    final int age = _safeInt(data, 'age');
    final String initials = _safeStr(data, 'initials', fallback: '?');
    final uploadedPhotos = data['photos'] as List<dynamic>? ?? [];
    final housePhoto = _safeStr(data, 'housePhoto', fallback: '');
    final hasPhoto = uploadedPhotos.isNotEmpty && uploadedPhotos[0] != null && uploadedPhotos[0].toString().isNotEmpty;

    // Gradient from stored gradientColors (if any)
    List<Color> gradientColors = [
      const Color(0xFFC5A059),
      const Color(0xFFDFBA73)
    ];
    if (data['gradientColors'] is List) {
      final raw = (data['gradientColors'] as List);
      if (raw.length >= 2) {
        gradientColors = raw.map((h) {
          final hex = h.toString().replaceAll('#', '');
          return Color(int.parse('FF$hex', radix: 16));
        }).toList();
      }
    }

    bool profileHidden = _safeBool(data, 'profileHidden');
    bool incomeHidden = _safeBool(data, 'incomeHidden');
    String photosVisibility =
        _safeStr(data, 'photosVisibility', fallback: 'All Matches');
    int connects = _safeInt(data, 'connects', fallback: 5);
    int superLikes = _safeInt(data, 'superLikes', fallback: 2);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
        // ══════════════════════════════════════════════════════
        // SECTION 1 · HERO HEADER (SliverAppBar)
        // ══════════════════════════════════════════════════════
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: AppTheme.cardWhite,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const EditProfileSheet(),
                );
              },
              tooltip: 'Edit Profile',
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Gradient background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradientColors[0].withValues(alpha: 0.9),
                        gradientColors[gradientColors.length > 1 ? 1 : 0]
                            .withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                // Decorative blurred orbs
                Positioned(
                  top: -40,
                  right: -40,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),

                // Avatar + identity
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      // Avatar circle
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: _managePhotos,
                            child: Container(
                              width: 104,
                              height: 104,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(52),
                                child: hasPhoto
                                    ? (uploadedPhotos.first.toString().startsWith('data:image/')
                                        ? (() {
                                            try {
                                              final String base64Data = uploadedPhotos.first.toString().split(',')[1];
                                              final Uint8List imageBytes = base64Decode(base64Data);
                                              return Image.memory(imageBytes, fit: BoxFit.cover, width: 96, height: 96);
                                            } catch (_) {
                                              return const Icon(Icons.broken_image, color: AppTheme.textMuted);
                                            }
                                          })()
                                        : Image.network(uploadedPhotos.first.toString(), fit: BoxFit.cover, width: 96, height: 96,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image, color: AppTheme.textMuted)))
                                    : Center(
                                        child: Text(
                                          initials,
                                          style: GoogleFonts.cinzel(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textCarbon,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _managePhotos,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppTheme.accentGold,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.black,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Name
                      Text(
                        name.trim().isEmpty ? 'Your Name' : name.trim(),
                        style: GoogleFonts.cinzel(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Age + Verified badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            age > 0 ? '$age Years' : '',
                            style: GoogleFonts.montserrat(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (age > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          // WhatsApp verified badge
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.white
                                          .withValues(alpha: 0.4),
                                      width: 0.5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified_rounded,
                                        color: Colors.white, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      'WA VERIFIED',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Premium counters row pinned at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 10),
                        color: Colors.white.withValues(alpha: 0.55),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCounterChip(
                                Icons.link_rounded,
                                '$connects',
                                'Connects',
                                AppTheme.accentGold),
                            Container(
                                width: 0.5,
                                height: 30,
                                color: AppTheme.glassBorderColor),
                            _buildCounterChip(
                                Icons.star_rounded,
                                '$superLikes',
                                'Super Likes',
                                const Color(0xFFE91E8C)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Collapsed title
          title: Text(
            name.trim().isEmpty ? 'My Profile' : name.trim(),
            style: GoogleFonts.cinzel(
              color: AppTheme.textCarbon,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),



        // ══════════════════════════════════════════════════════
        // SECTION 2 · BENTO GRID DATA RESUME
        // ══════════════════════════════════════════════════════
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Update Profile Button ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const EditProfileSheet(),
                          );
                        },
                        icon: const Icon(Icons.edit_rounded, size: 20),
                        label: Text(Provider.of<LanguageProvider>(context).translate('update_profile')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGold,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionLabel('PERSONAL INTEL'),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.cake_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('age_height'),
                          value: '${age > 0 ? age : '—'} yrs  ·  ${_safeStr(data, 'height')}',
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.location_on_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('lives_in'),
                          value: _safeStr(data, 'city'),
                          subValue: _safeStr(data, 'state'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.favorite_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('marital_status'),
                          value: _safeStr(data, 'maritalStatus'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.people_alt_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('clan_nukh'),
                          value: _safeStr(data, 'caste'),
                          accent: true,
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.accessibility_new_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('complexion_weight'),
                          value: _safeStr(data, 'complexion'),
                          subValue: _safeStr(data, 'weight', fallback: 'Not specified'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.wheelchair_pickup_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('disability'),
                          value: _safeStr(data, 'physicalDisability', fallback: 'None'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _bentoCard(
                      icon: Icons.format_quote_rounded,
                      label: Provider.of<LanguageProvider>(context).translate('bio'),
                      value: _safeStr(data, 'bio', fallback: 'No bio added yet.'),
                      fullWidth: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.monetization_on_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('monthly_income'),
                          value: _safeStr(data, 'monthlyIncome', fallback: 'Not specified'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.work_outline_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('job_title'),
                          value: _safeStr(data, 'jobPost', fallback: 'Not specified'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.home_work_outlined,
                          label: Provider.of<LanguageProvider>(context).translate('own_house'),
                          value: _safeStr(data, 'ownHouse', fallback: 'Not specified'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.map_outlined,
                          label: Provider.of<LanguageProvider>(context).translate('district'),
                          value: _safeStr(data, 'district', fallback: 'Not specified'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _bentoCard(
                      icon: Icons.location_on_outlined,
                      label: Provider.of<LanguageProvider>(context).translate('proper_address'),
                      value: _safeStr(data, 'properAddress', fallback: 'Not specified'),
                      fullWidth: true,
                    ),

                    const SizedBox(height: 28),
                    _sectionLabel('CONTACT & LOCATION DETAILS'),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.phone_android_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('whatsapp'),
                          value: _safeStr(data, 'whatsappNumber', fallback: 'Not provided'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.map_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('district'),
                          value: _safeStr(data, 'district', fallback: 'Not provided'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _bentoCard(
                      icon: Icons.home_rounded,
                      label: Provider.of<LanguageProvider>(context).translate('full_address'),
                      value: _safeStr(data, 'properAddress', fallback: 'Not provided'),
                      fullWidth: true,
                    ),

                    const SizedBox(height: 28),
                    _sectionLabel('ASTROLOGICAL INTEL'),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.calendar_today_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('date_of_birth'),
                          value: _safeStr(data, 'dob') != '' && _safeStr(data, 'dob').length > 10 ? _safeStr(data, 'dob').substring(0, 10) : _safeStr(data, 'dob', fallback: 'Not specified'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.access_time_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('birth_time'),
                          value: _safeStr(data, 'birthTime', fallback: 'Not specified'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.place_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('birth_place'),
                          value: _safeStr(data, 'birthPlace', fallback: 'Not specified'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.star_border_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('manglik_status'),
                          value: _safeStr(data, 'manglikStatus', fallback: 'Not specified'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _bentoCard(
                      icon: Icons.auto_awesome_rounded,
                      label: Provider.of<LanguageProvider>(context).translate('other_grah'),
                      value: _safeStr(data, 'otherGrah', fallback: 'None'),
                      fullWidth: true,
                    ),

                    const SizedBox(height: 28),
                    _sectionLabel('FAMILY INTEL'),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.family_restroom_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('family_type'),
                          value: _safeStr(data, 'familyType', fallback: 'Not specified'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.groups_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('siblings'),
                          value: _safeStr(data, 'siblingsCount', fallback: '0'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _bentoCard(
                      icon: Icons.info_outline_rounded,
                      label: Provider.of<LanguageProvider>(context).translate('siblings_details'),
                      value: _safeStr(data, 'siblingsDetails', fallback: 'Not provided'),
                      fullWidth: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.person_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('father'),
                          value: _safeStr(data, 'fatherStatus', fallback: 'Alive'),
                          subValue: _safeStr(data, 'fathersOccupation', fallback: 'Occupation not specified'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.pregnant_woman_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('mother'),
                          value: _safeStr(data, 'motherStatus', fallback: 'Alive'),
                          subValue: _safeStr(data, 'mothersOccupation', fallback: 'Occupation not specified'),
                        )),
                      ],
                    ),

                    const SizedBox(height: 28),
                    _sectionLabel('CAREER & WEALTH'),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.work_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('profession'),
                          value: _safeStr(data, 'profession'),
                          subValue: _safeStr(data, 'company'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.school_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('education'),
                          value: _safeStr(data, 'education'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.account_balance_wallet_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('monthly_income'),
                          value: incomeHidden ? 'Private' : _safeStr(data, 'monthlyIncome'),
                          accent: !incomeHidden,
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.badge_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('job_title'),
                          value: _safeStr(data, 'jobPost', fallback: 'Not working/Self'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _bentoCard(
                      icon: Icons.account_balance_rounded,
                      label: Provider.of<LanguageProvider>(context).translate('annual_income'),
                      value: incomeHidden ? 'Private' : _safeStr(data, 'incomeBracket'),
                      fullWidth: true,
                      accent: !incomeHidden,
                    ),

                    const SizedBox(height: 28),
                    _sectionLabel('FAMILY BACKGROUND'),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.family_restroom_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('family_type'),
                          value: _safeStr(data, 'familyType', fallback: 'Nuclear'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.place_rounded,
                          label: 'City of Origin',
                          value: _safeStr(data, 'cityOfOrigin', fallback: 'Not specified'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.person_rounded,
                          label: "Father",
                          value: _safeStr(data, 'fatherStatus', fallback: 'Alive'),
                          subValue: _safeStr(data, 'fathersOccupation', fallback: ''),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.pregnant_woman_rounded,
                          label: "Mother",
                          value: _safeStr(data, 'motherStatus', fallback: 'Alive'),
                          subValue: _safeStr(data, 'mothersOccupation', fallback: ''),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.people_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('siblings'),
                          value: _safeStr(data, 'siblingsCount', fallback: '0'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.house_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('own_house'),
                          value: _safeStr(data, 'ownHouse', fallback: 'No'),
                        )),
                      ],
                    ),
                    if (_safeStr(data, 'siblingsCount', fallback: '0') != '0' && _safeStr(data, 'siblingsCount', fallback: '0') != '0 ') ...[
                      const SizedBox(height: 12),
                      _bentoCard(
                        icon: Icons.info_outline_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('siblings_details'),
                        value: _safeStr(data, 'siblingsDetails', fallback: 'Not provided'),
                        fullWidth: true,
                      ),
                    ],

                    const SizedBox(height: 28),
                    _sectionLabel('IDENTITY & PREFERENCES'),
                    const SizedBox(height: 12),
                    _bentoCard(
                      icon: Icons.category_rounded,
                      label: 'Type of Sindhi',
                      value: _safeStr(data, 'sindhiType', fallback: 'Sindhi Hindu'),
                      fullWidth: true,
                    ),
                    const SizedBox(height: 12),
                    _bentoCard(
                      icon: Icons.list_alt_rounded,
                      label: 'Partner Requirements',
                      value: _safeStr(data, 'requirements', fallback: 'Not specified'),
                      fullWidth: true,
                    ),
                    const SizedBox(height: 12),
                    _bentoCard(
                      icon: Icons.card_giftcard_rounded,
                      label: 'What We Provide',
                      value: _safeStr(data, 'whatWeProvide', fallback: 'Not specified'),
                      fullWidth: true,
                    ),

                    const SizedBox(height: 32),
                    // ✨ Know About Yourself AI Insight Section
                    if (birthTime.isEmpty || birthPlace.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blue, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Know About Yourself', style: GoogleFonts.cinzel(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('Add your birth time & place to get a personalized AI insight.', style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showFillAstrologyDetailsPopup(context, provider),
                            )
                          ],
                        ),
                      )
                    else if (data['astrologyInsight'] != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('✨ AI Personality Insight', style: GoogleFonts.cinzel(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 18)),
                              IconButton(
                                icon: const Icon(Icons.edit, color: AppTheme.textMuted, size: 20),
                                onPressed: () => _showFillAstrologyDetailsPopup(context, provider),
                                tooltip: 'Edit Birth Details',
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _showAstrologyInsightBottomSheet(context, provider, data['astrologyInsight']),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.cardGray,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
                                boxShadow: [
                                  BoxShadow(color: AppTheme.accentGold.withValues(alpha: 0.1), blurRadius: 10)
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (data['astrologyInsight']['english'] as String?)?.split('\\n').first ?? 'Discover your astrological personality...',
                                    style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 14, height: 1.5),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text('Know more →', style: GoogleFonts.montserrat(color: AppTheme.accentGold, fontSize: 13, fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(color: AppTheme.accentGold),
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ══════════════════════════════════════════════════════
        // SECTION 3 · ACCOUNT ENGINE
        // ══════════════════════════════════════════════════════
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('PRIVACY & SETTINGS'),
                    const SizedBox(height: 16),

                    // Privacy toggles card
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.glassBorderColor, width: 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.025),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildToggleTile(
                            icon: Icons.visibility_off_rounded,
                            title: 'Hide My Profile',
                            subtitle:
                                'Your profile will not appear in search results',
                            value: profileHidden,
                            onChanged: (v) {
                              setState(() {
                                provider.myProfile?['profileHidden'] = v;
                                profileHidden = v;
                              });
                              Provider.of<AuthProvider>(context,
                                      listen: false)
                                  .updateProfileSettings(
                                      {'profileHidden': v});
                            },
                          ),
                          const Divider(height: 0.5, indent: 20),
                          _buildToggleTile(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'Hide Income',
                            subtitle:
                                'Income will show as "Private" to others',
                            value: incomeHidden,
                            onChanged: (v) {
                              setState(() {
                                provider.myProfile?['incomeHidden'] = v;
                                incomeHidden = v;
                              });
                              Provider.of<AuthProvider>(context,
                                      listen: false)
                                  .updateProfileSettings(
                                      {'incomeHidden': v});
                            },
                          ),
                          const Divider(height: 0.5, indent: 20),
                          _buildToggleTile(
                            icon: Icons.lock_outline_rounded,
                            title: 'Private WhatsApp Number',
                            subtitle: 'Only show number when you approve a request',
                            value: data['whatsappPrivacy'] == 'private',
                            onChanged: (v) {
                              setState(() {
                                provider.myProfile?['whatsappPrivacy'] = v ? 'private' : 'public';
                              });
                              Provider.of<AuthProvider>(context, listen: false)
                                  .updateProfileSettings({'whatsappPrivacy': v ? 'private' : 'public'});
                            },
                          ),
                          const Divider(height: 0.5, indent: 20),
                          _buildToggleTile(
                            icon: Icons.favorite_rounded,
                            title: 'Mark as Married / Settled',
                            subtitle: 'Hides your profile and sets status to Married',
                            value: data['maritalStatus'] == 'Married',
                            onChanged: (v) async {
                              bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppTheme.cardWhite,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: Text('Confirm Status Change', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: AppTheme.textCarbon)),
                                  content: Text(v 
                                    ? 'Marking yourself as Married/Settled will hide your profile from search feeds.\n\nAre you sure you want to proceed?'
                                    : 'This will unhide your profile and reset your status. Are you sure?', style: GoogleFonts.montserrat()),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(v ? 'Yes, Mark Married' : 'Yes, Unmark', style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final success = await Provider.of<AuthProvider>(context, listen: false)
                                    .updateProfileSettings({
                                      'maritalStatus': v ? 'Married' : 'Never Married',
                                      'profileHidden': v
                                    });
                                if (success && mounted) {
                                  setState(() {});
                                }
                              }
                            },
                          ),
                          const Divider(height: 0.5, indent: 20),
                          // Photos visibility
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGold
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.photo_library_rounded,
                                      color: AppTheme.accentGold, size: 20),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Photo Visibility',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textCarbon,
                                        ),
                                      ),
                                      Text(
                                        photosVisibility,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          color: AppTheme.accentGold,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  color: AppTheme.cardWhite,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  onSelected: (v) {
                                    setState(() => photosVisibility = v);
                                    Provider.of<AuthProvider>(context,
                                            listen: false)
                                        .updateProfileSettings(
                                            {'photosVisibility': v});
                                  },
                                  itemBuilder: (_) => [
                                    'All Matches',
                                    'Connected Only',
                                    'Nobody'
                                  ]
                                      .map((opt) => PopupMenuItem(
                                            value: opt,
                                            child: Text(opt,
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 13)),
                                          ))
                                      .toList(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGold
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: AppTheme.glassBorderGold,
                                          width: 0.5),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Change',
                                          style: GoogleFonts.montserrat(
                                              fontSize: 11,
                                              color: AppTheme.accentGold,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: AppTheme.accentGold,
                                            size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (provider.phoneNumber == '9413879444') ...[
                            const Divider(height: 0.5, indent: 20),
                            _buildToggleTile(
                              icon: Icons.transgender_rounded,
                              title: 'Dev: Change Gender',
                              subtitle: 'Switch between Male and Female',
                              value: data['gender'] == 'Female',
                              onChanged: (v) async {
                                final newGender = v ? 'Female' : 'Male';
                                setState(() {
                                  provider.myProfile?['gender'] = newGender;
                                });
                                final success = await Provider.of<AuthProvider>(context, listen: false)
                                    .updateProfileSettings({'gender': newGender});
                                if (success && mounted) {
                                  // Refresh the home feed with the new gender context
                                  Provider.of<AuthProvider>(context, listen: false)
                                      .fetchDailyPicks(refresh: true);
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    _sectionLabel('ACCOUNT'),
                    const SizedBox(height: 16),

                    // Subscription status
                    _buildActionTile(
                      icon: Icons.workspace_premium_rounded,
                      iconColor: const Color(0xFFE91E8C),
                      title: 'Premium Membership',
                      subtitle: 'Free Plan · Upgrade to Premium Elite',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppTheme.premiumGoldGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('UPGRADE',
                            style: GoogleFonts.cinzel(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 0.5)),
                      ),
                      onTap: () {
                        PremiumFeedback.show(
                          context: context,
                          icon: Icons.workspace_premium_rounded,
                          iconColor: const Color(0xFFE91E8C),
                          title: 'Coming Soon',
                          message:
                              'Premium Elite subscription is launching soon. You\'ll be the first to know!',
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // Language Selection
                    _buildActionTile(
                      icon: Icons.language_rounded,
                      iconColor: AppTheme.accentGold,
                      title: Provider.of<LanguageProvider>(context).translate('app_language') == 'app_language' ? 'Language / भाषा' : Provider.of<LanguageProvider>(context).translate('app_language'),
                      subtitle: Provider.of<LanguageProvider>(context).currentLanguage == 'hi' ? 'हिंदी (Hindi)' : 'English',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.glassBorderGold, width: 0.5),
                        ),
                        child: Text(
                          'CHANGE',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentGold,
                          ),
                        ),
                      ),
                      onTap: () {
                        final langProvider = Provider.of<LanguageProvider>(context, listen: false);
                        showDialog(
                          context: context,
                          builder: (dialogCtx) => AlertDialog(
                            backgroundColor: AppTheme.cardWhite,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                            title: Text(
                              'Choose Language / भाषा चुनें',
                              style: GoogleFonts.cinzel(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.textCarbon,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: Text('English', style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontWeight: FontWeight.bold)),
                                  trailing: langProvider.currentLanguage == 'en' ? const Icon(Icons.check_circle, color: AppTheme.accentGold) : null,
                                  onTap: () {
                                    langProvider.setLanguage('en');
                                    Navigator.pop(dialogCtx);
                                  },
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  title: Text('हिन्दी (Hindi)', style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontWeight: FontWeight.bold)),
                                  trailing: langProvider.currentLanguage == 'hi' ? const Icon(Icons.check_circle, color: AppTheme.accentGold) : null,
                                  onTap: () {
                                    langProvider.setLanguage('hi');
                                    Navigator.pop(dialogCtx);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // Blocked Users
                    _buildActionTile(
                      icon: Icons.block,
                      iconColor: Colors.red,
                      title: 'Blocked Users',
                      subtitle: 'Manage people you have blocked',
                      onTap: () {
                        _showBlockedUsersSheet(context);
                      },
                    ),

                    const SizedBox(height: 8),

                    // Partner Preferences
                    _buildActionTile(
                      icon: Icons.tune_rounded,
                      iconColor: AppTheme.accentGold,
                      title: 'Partner Preferences',
                      subtitle: 'What you\'re looking for',
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => const PartnerPreferencesSheet(),
                        );
                      },
                    ),

                    // Terms & Conditions
                    _buildActionTile(
                      icon: Icons.description_outlined,
                      iconColor: AppTheme.accentGold,
                      title: 'Terms & Conditions',
                      subtitle: 'UGC Policy & Terms of Service',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsAndConditionsScreen(),
                          ),
                        );
                      },
                    ),

                    // Change Password
                    _buildActionTile(
                      icon: Icons.lock_outline_rounded,
                      iconColor: AppTheme.accentGold,
                      title: 'Change Password',
                      subtitle: 'Update your account login password',
                      onTap: () => _showChangePasswordDialog(context),
                    ),

                    const SizedBox(height: 8),

                    // ── Rate & About ─────────────────────────────────────
                    _buildActionTile(
                      icon: Icons.star_rounded,
                      iconColor: const Color(0xFFFFC107),
                      title: '★  Rate Perfect Bandhan on Play Store',
                      subtitle: 'Your feedback helps us grow!',
                      onTap: () async {
                        final url = Uri.parse('https://play.google.com/store/apps/details?id=com.piyush.assudani');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),

                    _buildActionTile(
                      icon: Icons.support_agent_rounded,
                      iconColor: AppTheme.accentGold,
                      title: 'Support / Helpline',
                      subtitle: 'Call or WhatsApp us at +91 9413879444',
                      onTap: () async {
                        final url = Uri.parse('tel:+919413879444');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                    ),

                    _buildActionTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: AppTheme.accentGold,
                      title: 'About Perfect Bandhan',
                      subtitle: 'Developed by Piyush Assudani • Assudani Group',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    if (provider.isAdmin || provider.phoneNumber == '9413879444')
                      Column(
                        children: [
                          _buildActionTile(
                            icon: Icons.admin_panel_settings_rounded,
                            iconColor: const Color(0xFFE2B93B),
                            title: 'Admin Dashboard',
                            subtitle: 'Manage users, versions, and broadcasts',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminPanelScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),

                    // Logout
                    _buildActionTile(
                      icon: Icons.logout_rounded,
                      iconColor: AppTheme.textMuted,
                      title: 'Sign Out',
                      subtitle: 'You can log back in anytime',
                      onTap: () async {
                        await Provider.of<AuthProvider>(context, listen: false).logout();
                      },
                    ),

                    const SizedBox(height: 8),

                    // Delete account (required by App Store / Play Store)
                    _buildActionTile(
                      icon: Icons.delete_forever_rounded,
                      iconColor: const Color(0xFFFF3B30),
                      title: 'Delete Account',
                      subtitle:
                          'Permanently remove all your data',
                      titleColor: const Color(0xFFFF3B30),
                      onTap: () => _confirmDeleteAccount(context),
                    ),

                    const SizedBox(height: 24),
                    // ── Branded Footer ────────────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset('assets/logo.png', width: 44, height: 44),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'परफेक्ट बंधन | Perfect Bandhan',
                            style: GoogleFonts.cinzel(
                              color: AppTheme.accentGold,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'A Property of Assudani Group',
                            style: GoogleFonts.montserrat(
                              color: AppTheme.textMuted,
                              fontSize: 9,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Developed by Piyush Assudani',
                            style: GoogleFonts.montserrat(
                              color: AppTheme.accentGold.withValues(alpha: 0.6),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
        ),
      ),
    );
  }

  // ─── Small Widgets ─────────────────────────────────────────────────────────

  Widget _buildCounterChip(
      IconData icon, String count, String label, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: GoogleFonts.cinzel(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textCarbon),
            ),
            Text(
              label,
              style: GoogleFonts.montserrat(
                  fontSize: 9,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3),
            ),
          ],
        ),
      ],
    );
  }

  void _showBlockedUsersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Blocked Users', style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textCarbon)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: Provider.of<AuthProvider>(context, listen: false).getBlockedUsers(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
                        }
                        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No blocked users.'));
                        }
                        final users = snapshot.data!;
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.accentGold,
                                child: Text((user['name'] as String).substring(0,1).toUpperCase(), style: const TextStyle(color: Colors.white)),
                              ),
                              title: Text(user['name'] ?? ''),
                              subtitle: Text(user['phone'] ?? ''),
                              trailing: TextButton(
                                onPressed: () async {
                                  final success = await Provider.of<AuthProvider>(context, listen: false).unblockUser(user['phone']);
                                  if (success) {
                                    setState(() {}); // Refresh list
                                  }
                                },
                                child: const Text('Unblock', style: TextStyle(color: Colors.red)),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sectionLabel(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppTheme.glassBorderColor, height: 1),
        const SizedBox(height: 24),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppTheme.accentGold,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _bentoCard({
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
    bool accent = false,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent
              ? AppTheme.glassBorderGold
              : AppTheme.glassBorderColor,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 14,
                  color: accent
                      ? AppTheme.accentGold
                      : AppTheme.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cinzel(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: accent ? AppTheme.accentGold : AppTheme.textCarbon,
            ),
          ),
          if (subValue != null && subValue != '—') ...[
            const SizedBox(height: 2),
            Text(
              subValue,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    bool localValue = value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.accentGold, size: 20),
          ),
          const SizedBox(width: 14),
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
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          StatefulBuilder(
            builder: (context, setInnerState) {
              return Switch.adaptive(
                value: localValue,
                onChanged: (val) {
                  setInnerState(() {
                    localValue = val;
                  });
                  onChanged(val);
                },
                activeThumbColor: AppTheme.accentGold,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Color? titleColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(18),
          border:
              Border.all(color: AppTheme.glassBorderColor, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: titleColor ?? AppTheme.textCarbon,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
