import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/manage_photos_sheet.dart';
import '../widgets/admin_user_settings_sheet.dart';
import '../widgets/admin_create_profile_sheet.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _searchController = TextEditingController();
  final _broadcastController = TextEditingController();
  final _adminCurrentPassController = TextEditingController();
  final _adminNewPassController = TextEditingController();
  // Version management controllers
  final _latestVersionController = TextEditingController();
  final _minVersionController = TextEditingController();
  final _updateMessageController = TextEditingController();
  final _downloadUrlController = TextEditingController();
  bool _forceUpdateToggle = false;
  bool _isSavingVersionConfig = false;
  
  final _formKey = GlobalKey<FormState>();

  String _searchQuery = "";
  bool _isSigningIn = false;
  bool _isBroadcasting = false;
  bool _isChangingPassword = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAdmin) {
        auth.fetchAdminUsers();
      }
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    _broadcastController.dispose();
    _adminCurrentPassController.dispose();
    _adminNewPassController.dispose();
    _latestVersionController.dispose();
    _minVersionController.dispose();
    _updateMessageController.dispose();
    _downloadUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSigningIn = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.loginWithPassword(
      _phoneController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSigningIn = false);
      if (success) {
        auth.fetchAdminUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome back, Administrator.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Access Denied.'),
            backgroundColor: const Color(0xFFFF453A),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ADMIN CONSOLE',
          style: GoogleFonts.cinzel(
            color: AppTheme.textCarbon,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.power_settings_new_rounded, color: Colors.redAccent),
              onPressed: () {
                auth.adminLogout();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out of Admin Portal.')),
                );
              },
            ),
        ],
      ),
      drawer: auth.isAdmin && MediaQuery.of(context).size.width < 800 ? Drawer(
        backgroundColor: AppTheme.backgroundBlack,
        child: _buildDesktopSidebar(),
      ) : null,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              gradient: AppTheme.darkMinimalBackground,
            ),
          ),
          SafeArea(
            child: auth.isAdmin ? _buildResponsiveAdminLayout(context, auth) : _buildLoginForm(size),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveAdminLayout(BuildContext context, AuthProvider auth) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;
    
    final Widget content = _buildSelectedPanelContent(auth);

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDesktopSidebar(),
          Expanded(child: content),
        ],
      );
    } else {
      return Column(
        children: [
          _buildMobileHeader(),
          Expanded(child: content),
        ],
      );
    }
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: AppTheme.glassColor,
        border: Border(bottom: BorderSide(color: AppTheme.glassBorderColor, width: 0.5)),
      ),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppTheme.textWhite),
              onPressed: () {
                Scaffold.of(ctx).openDrawer();
              },
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'ADMIN CONSOLE',
            style: GoogleFonts.cinzel(
              color: AppTheme.accentGold,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppTheme.glassColor,
        border: Border(right: BorderSide(color: AppTheme.glassBorderColor, width: 0.5)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            'ADMIN CONSOLE',
            style: GoogleFonts.cinzel(
              color: AppTheme.accentGold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 48),
          _buildSidebarItem(0, Icons.dashboard_outlined, 'Analytics Dashboard'),
          _buildSidebarItem(1, Icons.people_outline_rounded, 'User Profiles'),
          _buildSidebarItem(2, Icons.campaign_outlined, 'Broadcast'),
          _buildSidebarItem(3, Icons.system_update_alt_rounded, 'App Version'),
          _buildSidebarItem(4, Icons.security_rounded, 'Security'),
          _buildSidebarItem(5, Icons.notifications_active_outlined, 'Notifications'),
          _buildSidebarItem(6, Icons.flag_rounded, 'User Reports'),
          _buildSidebarItem(7, Icons.block, 'Block Logs'),
          _buildSidebarItem(8, Icons.settings_system_daydream_outlined, 'System Config'),
          _buildSidebarItem(9, Icons.phone_android_rounded, 'Phone Logs'),
          _buildSidebarItem(10, Icons.assignment_late_outlined, 'Onboarding Drop-offs'),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.accentGold : AppTheme.textMuted,
      ),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          color: isSelected ? AppTheme.accentGold : AppTheme.textMuted,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      tileColor: isSelected ? AppTheme.accentGold.withValues(alpha: 0.1) : Colors.transparent,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        // If on mobile, close the drawer when an item is tapped.
        if (MediaQuery.of(context).size.width < 800) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildSelectedPanelContent(AuthProvider auth) {
    switch (_selectedIndex) {
      case 0:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: _buildDashboardPanel(auth),
        );
      case 1:
        return _buildProfilesPanel(auth);
      case 2:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: _buildBroadcastPanel(auth),
        );
      case 3:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: _buildVersionManagementPanel(auth),
        );
      case 4:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: _buildChangePasswordPanel(auth),
        );
      case 5:
        return _buildNotificationsPanel(auth);
      case 6:
        return _buildReportsPanel(auth);
      case 7:
        return _buildBlockLogsPanel(auth);
      case 8:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: _buildSystemConfigPanel(auth),
        );
      case 9:
        return _buildPhoneLogsPanel(auth);
      case 10:
        return _buildOnboardingDropoffsPanel(auth);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Admin Login Form ---
  Widget _buildLoginForm(Size size) {
    final bool isDesktop = size.width > 600;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 450 : size.width,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            decoration: BoxDecoration(
              color: AppTheme.cardGray,
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.admin_panel_settings_outlined, color: AppTheme.accentGold, size: 36),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Center(
                    child: Text(
                      'ADMIN PORTAL',
                      style: GoogleFonts.cinzel(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textCarbon,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Center(
                    child: Text(
                      'Unlock system credentials for full database access.',
                      style: GoogleFonts.montserrat(
                        fontSize: 10.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  CustomTextField(
                    labelText: 'ADMIN PHONE NUMBER',
                    hintText: '10 digit number',
                    prefixIcon: Icons.phone_outlined,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Phone number is required';
                      return null;
                    },
                  ),
                  CustomTextField(
                    labelText: 'PASSWORD',
                    hintText: 'Admin password',
                    prefixIcon: Icons.lock_outline_rounded,
                    controller: _passwordController,
                    isPassword: true,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Password is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppTheme.premiumGoldGradient,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: ElevatedButton(
                      onPressed: _isSigningIn ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: _isSigningIn
                          ? const SizedBox(
                              height: 16.0,
                              width: 16.0,
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.0),
                            )
                          : Text(
                              'UNLOCK DASHBOARD',
                              style: GoogleFonts.cinzel(
                                color: AppTheme.backgroundBlack,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                fontSize: 12,
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
  }

  // --- Admin Dashboard (User Listings) ---
  Widget _buildProfilesPanel(AuthProvider auth) {
    if (auth.isLoadingAdminUsers) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
    }

    if (auth.adminUsersError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16.0),
              Text(
                auth.adminUsersError!,
                style: GoogleFonts.montserrat(color: AppTheme.textCarbon),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              OutlinedButton(
                onPressed: () => auth.fetchAdminUsers(),
                child: Text('Retry', style: GoogleFonts.montserrat(color: AppTheme.accentGold)),
              )
            ],
          ),
        ),
      );
    }

    // Client-side search filters
    final filteredUsers = auth.adminUsers.where((user) {
      final name = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.toLowerCase();
      final nukh = (user['nukh'] ?? '').toString().toLowerCase();
      final phone = (user['phone'] ?? '').toString().toLowerCase();

      return name.contains(_searchQuery) || nukh.contains(_searchQuery) || phone.contains(_searchQuery);
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
        children: [
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Manage Users', style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textCarbon)),
              ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AdminCreateProfileSheet(),
                  );
                },
                icon: const Icon(Icons.person_add_alt_1, size: 18),
                label: const Text('CREATE USER'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          // Search input bar
          Container(
            decoration: BoxDecoration(
              color: AppTheme.glassColor,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 14),
              cursorColor: AppTheme.accentGold,
              decoration: InputDecoration(
                hintText: 'Search by name, phone, or nukh...',
                hintStyle: GoogleFonts.montserrat(color: AppTheme.textMuted.withValues(alpha: 0.5), fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 18),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.textMuted, size: 16),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ALL REGISTERED PROFILES',
                style: GoogleFonts.cinzel(
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
              Text(
                '${filteredUsers.length} Users',
                style: GoogleFonts.montserrat(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          filteredUsers.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'No matching candidate profiles found.',
                        style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 13),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredUsers.length,
                    padding: const EdgeInsets.only(bottom: 24.0),
                    itemBuilder: (context, idx) {
                      final user = filteredUsers[idx];
                      final name = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}';
                      final phone = user['phone'] ?? '';
                      final caste = user['nukh'] ?? 'Not Specified';
                      final profession = user['profession'] ?? 'Not Specified';
                      final city = user['city'] ?? 'Not Specified';
                      final isComplete = user['firstName'] != null && user['gender'] != null;
                      final isDummy = user['isDummy'] == true;

                      return Card(
                        color: AppTheme.cardGray,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          side: const BorderSide(color: AppTheme.glassBorderColor, width: 0.5),
                        ),
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.glassColor,
                            backgroundImage: () {
                              final photos = (user['uploadedPhotos'] as List<dynamic>? ?? []);
                              if (photos.isNotEmpty && photos[0] != null && photos[0].toString().startsWith('http')) {
                                return NetworkImage(photos[0].toString()) as ImageProvider;
                              }
                              return null;
                            }(),
                            child: () {
                              final photos = (user['uploadedPhotos'] as List<dynamic>? ?? []);
                              if (photos.isEmpty) {
                                return Text(
                                  ((user['firstName'] ?? '') as String).isNotEmpty
                                      ? (user['firstName'] as String)[0].toUpperCase()
                                      : '?',
                                  style: GoogleFonts.cinzel(color: AppTheme.accentGold, fontWeight: FontWeight.bold),
                                );
                              }
                              return null;
                            }(),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: GoogleFonts.montserrat(
                                    color: AppTheme.textCarbon,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (!isComplete)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    'Incomplete',
                                    style: GoogleFonts.montserrat(color: Colors.redAccent, fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6.0),
                              Text(
                                'Phone: +91 $phone',
                                style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 12),
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                'Caste/Nukh: $caste • City: $city',
                                style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 11.5),
                              ),
                              Text(
                                'Work: $profession',
                                style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 11.5),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: user['isActive'] ?? true,
                                activeThumbColor: AppTheme.accentGold,
                                activeTrackColor: AppTheme.accentGold.withValues(alpha: 0.3),
                                inactiveThumbColor: AppTheme.textMuted,
                                inactiveTrackColor: AppTheme.glassBorderColor,
                                onChanged: (val) async {
                                  final authProv = Provider.of<AuthProvider>(context, listen: false);
                                  final String uId = user['_id'] ?? user['id'] ?? '';
                                  bool success = await authProv.adminEditUser(uId, {'isActive': val, 'profileHidden': !val});
                                  if (success && mounted) {
                                    authProv.fetchAdminUsers();
                                    if (val == false) {
                                      authProv.removeProfileLocally(uId);
                                    }
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textMuted, size: 16),
                            ],
                          ),
                          onTap: () => _showUserDetailsInspector(user),
                        ),
                      );
                    },
                  ),
        ],
      ),
    ),
        ),
      ),
    );
  }

  // --- Show Complete Details Inspector Sheet ---
  void _showUserDetailsInspector(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        final List<dynamic> photos = (user['uploadedPhotos'] as List<dynamic>? ?? [])
            .where((p) => p != null && p.toString().isNotEmpty)
            .toList();
        final String name = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}';
        final String housePhoto = user['housePhoto'] ?? '';
        final String disability = user['physicalDisability'] ?? 'None';

        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grab Handle
                  Center(
                    child: Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.glassBorderColor,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Header title
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'CANDIDATE DOSSIER',
                          style: GoogleFonts.cinzel(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentGold,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close dossier
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => EditProfileSheet(adminEditUser: user),
                          );
                        },
                        icon: const Icon(Icons.edit_note_rounded, size: 16, color: Colors.black),
                        label: Text('EDIT DETAILS', style: GoogleFonts.cinzel(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGold,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close dossier
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => ManagePhotosSheet(adminEditUser: user),
                          );
                        },
                        icon: const Icon(Icons.photo_library_outlined, size: 16, color: Colors.black),
                        label: Text('PHOTOS', style: GoogleFonts.cinzel(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGold,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close dossier
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => AdminUserSettingsSheet(adminEditUser: user),
                          );
                        },
                        icon: const Icon(Icons.settings_outlined, size: 16, color: Colors.white),
                        label: Text('SETTINGS', style: GoogleFonts.cinzel(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showBoostDialog(user);
                        },
                        icon: const Icon(Icons.rocket_launch_rounded, size: 16, color: Colors.white),
                        label: Text('BOOST', style: GoogleFonts.cinzel(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const Divider(color: AppTheme.glassBorderColor),

                  // Photos Carousel
                  if (photos.isNotEmpty) ...[
                    const SizedBox(height: 12.0),
                    Text(
                      'UPLODED PROFILE PHOTOS',
                      style: GoogleFonts.cinzel(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: photos.length,
                        itemBuilder: (context, idx) {
                          final String photo = photos[idx].toString();
                          final bool isBase64 = photo.startsWith('data:image/');
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: isBase64
                                  ? (() {
                                      try {
                                        final String base64Data = photo.split(',')[1];
                                        final Uint8List imageBytes = base64Decode(base64Data);
                                        return Image.memory(
                                          imageBytes,
                                          height: 150,
                                          width: 110,
                                          fit: BoxFit.cover,
                                        );
                                      } catch (_) {
                                        return const Icon(Icons.broken_image, color: Colors.white);
                                      }
                                    })()
                                  : Image.network(
                                      photo,
                                      height: 150,
                                      width: 110,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image, color: Colors.white),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20.0),
                  ],

                  // Bento box style details sections
                  _buildInspectorSectionTitle('Basics & Identity'),
                  _buildDetailRow('Profile For', user['profileFor']),
                  _buildDetailRow('Full Legal Name', name),
                  _buildDetailRow('Gender', user['gender']),
                  _buildDetailRow('Caste / Nukh', user['nukh'] ?? user['caste']),
                  _buildDetailRow('Skin Complexion', user['complexion']),
                  _buildDetailRow('Date of Birth', user['dob'] != null ? user['dob'].toString().split('T')[0] : null),
                  _buildDetailRow('Height', user['height']),
                  _buildDetailRow('Marital Status', user['maritalStatus']),

                  const SizedBox(height: 16.0),
                  _buildInspectorSectionTitle('Contact Details'),
                  _buildDetailRow('Mobile Phone', user['phone'] != null ? '+91 ${user['phone']}' : null),
                  _buildDetailRow('Email Address', user['email']),

                  const SizedBox(height: 16.0),
                  _buildInspectorSectionTitle('Address Details'),
                  _buildDetailRow('State', user['state']),
                  _buildDetailRow('District', user['district']),
                  _buildDetailRow('City', user['city']),
                  _buildDetailRow('Residential Address', user['properAddress']),

                  const SizedBox(height: 16.0),
                  _buildInspectorSectionTitle('Career & Wealth'),
                  _buildDetailRow('Highest Education', user['education']),
                  _buildDetailRow('Profession Sector', user['profession']),
                  _buildDetailRow('Job Title / Designation', user['jobPost']),
                  _buildDetailRow('Employer / Workplace', user['company']),
                  _buildDetailRow('Monthly Income', user['monthlyIncome']),
                  _buildDetailRow('Annual Income', user['yearlyIncome']),
                  _buildDetailRow('Fathers Occupation', user['fathersOccupation']),

                  const SizedBox(height: 16.0),
                  _buildInspectorSectionTitle('House Ownership'),
                  _buildDetailRow('Home Ownership', user['ownHouse'] == 'Yes' ? 'Yes (Owns House)' : 'No (Rented/Other)'),
                  if (housePhoto.isNotEmpty) ...[
                    const SizedBox(height: 8.0),
                    Text(
                      'RESIDENCE PHOTO',
                      style: GoogleFonts.cinzel(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6.0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        housePhoto,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16.0),
                  _buildInspectorSectionTitle('Physical Conditions / Kami'),
                  _buildDetailRow('Special Disability Status', disability),

                  const SizedBox(height: 16.0),
                  _buildInspectorSectionTitle('Personal Notes'),
                  _buildDetailRow('Candidate Bio', user['bio']),

                  
                  const SizedBox(height: 32.0),
                  const Divider(color: AppTheme.glassBorderColor),
                  const SizedBox(height: 16.0),
                  
                  // Delete Profile Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteConfirmation(context, user['_id'] ?? user['id'] ?? '', name),
                      icon: const Icon(Icons.delete_forever_rounded, color: AppTheme.primaryRed),
                      label: Text(
                        'DELETE PROFILE PERMANENTLY',
                        style: GoogleFonts.montserrat(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryRed, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String userId, String userName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardGray,
        title: Text(
          'Delete Profile?',
          style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold, color: AppTheme.primaryRed, fontSize: 24),
        ),
        content: Text(
          'Are you sure you want to permanently delete $userName? This action cannot be undone and will remove all their photos, chats, and data.',
          style: GoogleFonts.montserrat(color: AppTheme.textCarbon),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // close dialog
              final auth = Provider.of<AuthProvider>(context, listen: false);
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (c) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed)),
              );
              
              bool success = await auth.adminDeleteUser(userId);
              
              if (mounted) Navigator.pop(context); // close loader
              
              if (success) {
                auth.removeProfileLocally(userId);
                if (mounted) Navigator.pop(context); // close inspector sheet
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile deleted permanently.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
                  );
                  auth.fetchAdminUsers();
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete profile.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            child: Text('Delete Permanently', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectorSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.cinzel(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentGold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 2.0),
          Container(width: 40, height: 1.5, color: AppTheme.accentGold),
          const SizedBox(height: 6.0),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    final String displayVal = (value == null || value.toString().trim().isEmpty) ? 'Not Provided' : value.toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                color: AppTheme.textMuted,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            flex: 3,
            child: Text(
              displayVal,
              style: GoogleFonts.montserrat(
                color: AppTheme.textCarbon,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastPanel(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: AppTheme.glassColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BROADCAST PUSH NOTIFICATION',
            style: GoogleFonts.cinzel(
              color: AppTheme.accentGold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),
          TextField(
            controller: _broadcastController,
            style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Enter alert notification message...',
              hintStyle: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 12),
              filled: true,
              fillColor: AppTheme.cardWhite,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isBroadcasting ? null : _handleBroadcast,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              child: _isBroadcasting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : Text('DISPATCH BROADCAST', style: GoogleFonts.cinzel(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBroadcast() async {
    final text = _broadcastController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isBroadcasting = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.adminBroadcastPush(text);
    setState(() => _isBroadcasting = false);
    if (mounted) {
      if (success) {
        _broadcastController.clear();
        _showSimulatedPushNotification('New Admin Broadcast', text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Broadcast sent successfully!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to dispatch broadcast.'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Widget _buildChangePasswordPanel(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: AppTheme.glassColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHANGE ADMIN PASSWORD',
            style: GoogleFonts.cinzel(
              color: AppTheme.accentGold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),
          TextField(
            controller: _adminCurrentPassController,
            obscureText: true,
            style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Current Admin Password',
              hintStyle: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 12),
              filled: true,
              fillColor: AppTheme.cardWhite,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _adminNewPassController,
            obscureText: true,
            style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'New Admin Password',
              hintStyle: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 12),
              filled: true,
              fillColor: AppTheme.cardWhite,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isChangingPassword ? null : _handleChangeAdminPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              child: _isChangingPassword
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : Text('UPDATE PASSWORD', style: GoogleFonts.cinzel(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleChangeAdminPassword() async {
    final curr = _adminCurrentPassController.text.trim();
    final newP = _adminNewPassController.text.trim();
    if (curr.isEmpty || newP.isEmpty) return;
    setState(() => _isChangingPassword = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.adminChangePassword(curr, newP);
    setState(() => _isChangingPassword = false);
    if (mounted) {
      if (success) {
        _adminCurrentPassController.clear();
        _adminNewPassController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin password updated successfully!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update admin password. Check current password.'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Widget _buildVersionManagementPanel(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: AppTheme.glassColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'APP VERSION & UPDATE MANAGEMENT',
            style: GoogleFonts.cinzel(
              color: AppTheme.accentGold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Current app version: ${AuthProvider.localAppVersion}',
            style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 10),
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _latestVersionController,
                  style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Latest Version',
                    labelStyle: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 11),
                    hintText: '1.1.0',
                    hintStyle: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 11),
                    filled: true,
                    fillColor: AppTheme.cardWhite,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _minVersionController,
                  style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Min Required',
                    labelStyle: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 11),
                    hintText: '1.0.5',
                    hintStyle: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 11),
                    filled: true,
                    fillColor: AppTheme.cardWhite,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _updateMessageController,
            style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 12),
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Update Message',
              labelStyle: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 11),
              hintText: 'Enter the message shown to users...',
              hintStyle: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 11),
              filled: true,
              fillColor: AppTheme.cardWhite,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _downloadUrlController,
            style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Download URL',
              labelStyle: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 11),
              hintText: 'https://play.google.com/...',
              hintStyle: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 11),
              filled: true,
              fillColor: AppTheme.cardWhite,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Force Update (Block app until updated)',
                  style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 12),
                ),
              ),
              Switch(
                value: _forceUpdateToggle,
                onChanged: (v) => setState(() => _forceUpdateToggle = v),
                activeThumbColor: AppTheme.accentGold,
                activeTrackColor: AppTheme.accentGold.withValues(alpha: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSavingVersionConfig ? null : () => _handleSaveVersionConfig(auth),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              child: _isSavingVersionConfig
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : Text('SAVE VERSION CONFIG', style: GoogleFonts.cinzel(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSaveVersionConfig(AuthProvider auth) async {
    final latestV = _latestVersionController.text.trim();
    final minV = _minVersionController.text.trim();
    if (latestV.isEmpty || minV.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Latest version and minimum version are required.'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    setState(() => _isSavingVersionConfig = true);
    final config = {
      'latestVersion': latestV,
      'minVersion': minV,
      'forceUpdate': _forceUpdateToggle,
      if (_updateMessageController.text.trim().isNotEmpty) 'updateMessage': _updateMessageController.text.trim(),
      if (_downloadUrlController.text.trim().isNotEmpty) 'downloadUrl': _downloadUrlController.text.trim(),
    };
    final success = await auth.adminUpdateAppConfig(config);
    setState(() => _isSavingVersionConfig = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Version config saved successfully!' : 'Failed to save version config.'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
    }
  }
  void _showBoostDialog(Map<String, dynamic> user) {
    final TextEditingController scoreController = TextEditingController(text: (user['adminRankScore'] ?? 0).toString());
    
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardGray,
          title: Text('Boost Profile', style: GoogleFonts.cinzel(color: AppTheme.accentGold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter a boost score (higher score appears higher in search).', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 16),
              TextField(
                controller: scoreController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Rank Score',
                  labelStyle: TextStyle(color: AppTheme.accentGold),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.glassBorderColor)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accentGold)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold),
              onPressed: () async {
                Navigator.pop(ctx);
                final auth = Provider.of<AuthProvider>(context, listen: false);
                try {
                  final newScore = int.tryParse(scoreController.text.trim()) ?? 0;
                  final payload = {'adminRankScore': newScore};
                  await auth.adminEditUser(user['phone'], payload);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile boosted successfully!'), backgroundColor: Colors.green));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to boost profile: $e'), backgroundColor: Colors.red));
                }
              },
              child: const Text('BOOST', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      }
    );
  }

  Widget _buildDashboardStats(List<dynamic> users) {
    int total = users.length;
    int males = users.where((u) => u['gender'] == 'Male').length;
    int females = users.where((u) => u['gender'] == 'Female').length;
    int incomplete = users.where((u) => u['isProfileComplete'] != true).length;
    int inactive = users.where((u) => u['isActive'] == false).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = constraints.maxWidth > 1000 ? 5 : (constraints.maxWidth > 600 ? 3 : 2);
        double spacing = 12.0;
        double width = (constraints.maxWidth - (spacing * (columns - 1))) / columns;
        width = width.floorToDouble();

        final children = [
          _buildStatCard('Total Users', total.toString(), Icons.people_alt_outlined, Colors.blue),
          _buildStatCard('Male Profiles', males.toString(), Icons.man_outlined, Colors.orange),
          _buildStatCard('Female Profiles', females.toString(), Icons.woman_outlined, Colors.pink),
          _buildStatCard('Incomplete', incomplete.toString(), Icons.warning_amber_rounded, Colors.purple),
          _buildStatCard('Inactive', inactive.toString(), Icons.person_off_outlined, Colors.redAccent),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children.map((child) => SizedBox(width: width, child: child)).toList(),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.cardGray,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textCarbon),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textWhite),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardPanel(AuthProvider auth) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'PLATFORM ANALYTICS',
              style: GoogleFonts.cinzel(
                color: AppTheme.accentGold,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            _buildDashboardStats(auth.adminUsers),
          ],
        ),
      ),
    );
  }

  void _showSimulatedPushNotification(String title, String body) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Push',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24), // Dark notification bg
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 10)),
                ],
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.notifications_active_rounded, color: Colors.black, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Perfect Bandhan', style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text('now', style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(title, style: GoogleFonts.montserrat(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(body, style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -1), end: const Offset(0, 0)).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutBack)),
          child: child,
        );
      },
    );

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  // --- Notifications Panel ---
  Widget _buildNotificationsPanel(AuthProvider auth) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: auth.getAllNotifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
        }

        final notifications = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications Management',
                    style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textCarbon),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showNotificationDialog(auth, null),
                    icon: const Icon(Icons.add),
                    label: const Text('New Notification'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: notifications.isEmpty
                    ? const Center(child: Text('No notifications found.'))
                    : ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notif = notifications[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(notif['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notif['body'] ?? ''),
                                  if (notif['targetPhone'] != null)
                                    Text('Target: ${notif['targetPhone']}', style: const TextStyle(color: Colors.blue)),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.orange),
                                    onPressed: () => _showNotificationDialog(auth, notif),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteNotification(auth, notif['_id']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showNotificationDialog(AuthProvider auth, Map<String, dynamic>? notification) async {
    final titleController = TextEditingController(text: notification != null ? notification['title'] : '');
    final bodyController = TextEditingController(text: notification != null ? notification['body'] : '');
    final targetPhoneController = TextEditingController(text: notification != null ? notification['targetPhone'] : '');
    
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(notification == null ? 'New Notification' : 'Edit Notification'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyController,
                  decoration: const InputDecoration(labelText: 'Body'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: targetPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Target Phone (Optional)',
                    hintText: 'Leave empty for global',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final body = bodyController.text.trim();
                final targetPhone = targetPhoneController.text.trim();
                
                if (title.isEmpty || body.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and body required')));
                  return;
                }
                
                bool success;
                if (notification == null) {
                  success = await auth.createNotification(title, body, targetPhone.isEmpty ? null : targetPhone, 'info');
                } else {
                  success = await auth.updateNotification(notification['_id'], title, body, targetPhone.isEmpty ? null : targetPhone, 'info');
                }
                
                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    setState(() {}); // Refresh future builder
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save notification')));
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNotification(AuthProvider auth, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    
    if (confirm == true) {
      final success = await auth.deleteNotification(id);
      if (success && mounted) {
        setState(() {}); // Refresh future builder
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete notification')));
      }
    }
  }

  // --- Reports Panel ---
  Widget _buildReportsPanel(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'USER REPORTS',
            style: GoogleFonts.cinzel(
              color: AppTheme.accentGold,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: auth.getReports(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading reports.', style: TextStyle(color: Colors.white)));
              }
              final reports = snapshot.data ?? [];
              if (reports.isEmpty) {
                return const Center(child: Text('No reports found.', style: TextStyle(color: Colors.white70)));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  final createdAt = report['createdAt'] != null ? DateTime.parse(report['createdAt']).toLocal().toString().split('.')[0] : 'Unknown date';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: AppTheme.glassBorderGold, width: 0.5),
                    ),
                    child: ListTile(
                      title: Text(
                        'Reason: ${report['reason']}',
                        style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Reporter: ${report['reporterPhone']}  ->  Reported: ${report['reportedPhone']}',
                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          if (report['details'] != null && report['details'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text('Details: ${report['details']}', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                            ),
                          const SizedBox(height: 4),
                          Text('Date: $createdAt', style: const TextStyle(color: AppTheme.accentGold, fontSize: 12)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.block, color: Colors.redAccent),
                        tooltip: 'Block Reported User',
                        onPressed: () async {
                           final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Block User'),
                                content: Text('Are you sure you want to block ${report['reportedPhone']} globally?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Block', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                           );
                           if (confirm == true) {
                             final success = await auth.blockUser(report['reportedPhone'], 'Admin Action', 'Blocked from Admin Panel reports page');
                             if (success && mounted) {
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User blocked.')));
                             }
                           }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Block Logs Panel ---
  Widget _buildBlockLogsPanel(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'BLOCK LOGS',
            style: GoogleFonts.cinzel(
              color: AppTheme.accentGold,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: auth.getBlocks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading block logs.', style: TextStyle(color: Colors.white)));
              }
              final blocks = snapshot.data ?? [];
              if (blocks.isEmpty) {
                return const Center(child: Text('No block logs found.', style: TextStyle(color: Colors.white70)));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: blocks.length,
                itemBuilder: (context, index) {
                  final blockLog = blocks[index];
                  final createdAt = blockLog['createdAt'] != null ? DateTime.parse(blockLog['createdAt']).toLocal().toString().split('.')[0] : 'Unknown date';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: AppTheme.glassBorderGold, width: 0.5),
                    ),
                    child: ListTile(
                      title: Text(
                        'Reason: ${blockLog['reason']}',
                        style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Blocker: ${blockLog['blockerPhone']}  ->  Blocked: ${blockLog['blockedPhone']}',
                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          if (blockLog['details'] != null && blockLog['details'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text('Details: ${blockLog['details']}', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                            ),
                          const SizedBox(height: 4),
                          Text('Date: $createdAt', style: const TextStyle(color: AppTheme.accentGold, fontSize: 12)),
                        ],
                      ),
                      trailing: const Icon(Icons.block, color: Colors.redAccent),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }


  Widget _buildSystemConfigPanel(AuthProvider auth) {
    bool isMaintenance = auth.appConfig?['isMaintenanceMode'] == true;
    bool isBanner = auth.appConfig?['globalBannerEnabled'] == true;
    bool isChatComingSoon = auth.appConfig?['chatComingSoon'] == true;
    String maintMsg = auth.appConfig?['maintenanceMessage'] ?? '';
    String bannerMsg = auth.appConfig?['globalBannerMessage'] ?? '';

    return Card(
      color: AppTheme.glassColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_system_daydream, color: AppTheme.accentGold, size: 28),
              const SizedBox(width: 12),
              Text('Global System Configuration', style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.accentGold)),
            ],
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: Text('Maintenance Mode', style: GoogleFonts.cinzel(color: AppTheme.textCarbon, fontWeight: FontWeight.bold)),
            subtitle: Text('Instantly locks all users out of the app.', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
            value: isMaintenance,
            activeThumbColor: AppTheme.primaryRed,
            onChanged: (val) async {
              await auth.adminUpdateAppConfig({'isMaintenanceMode': val});
              auth.fetchAppConfig();
            },
          ),
          if (isMaintenance)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextFormField(
                initialValue: maintMsg,
                style: GoogleFonts.montserrat(color: AppTheme.textCarbon),
                decoration: const InputDecoration(
                  labelText: 'Maintenance Message',
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (val) async {
                  await auth.adminUpdateAppConfig({'maintenanceMessage': val});
                  auth.fetchAppConfig();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
                },
              ),
            ),
          const Divider(),
          SwitchListTile(
            title: Text('Chat - Coming Soon Mode', style: GoogleFonts.cinzel(color: AppTheme.textCarbon, fontWeight: FontWeight.bold)),
            subtitle: Text('Disables chat API and shows "coming soon".', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
            value: isChatComingSoon,
            activeThumbColor: AppTheme.accentGold,
            onChanged: (val) async {
              await auth.adminUpdateAppConfig({'chatComingSoon': val});
              auth.fetchAppConfig();
            },
          ),
          const Divider(),
          SwitchListTile(
            title: Text('Global Banner', style: GoogleFonts.cinzel(color: AppTheme.textCarbon, fontWeight: FontWeight.bold)),
            subtitle: Text('Displays a banner at the top of the screen for all users.', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
            value: isBanner,
            activeThumbColor: AppTheme.accentGold,
            onChanged: (val) async {
              await auth.adminUpdateAppConfig({'globalBannerEnabled': val});
              auth.fetchAppConfig();
            },
          ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: bannerMsg,
                      style: GoogleFonts.montserrat(color: AppTheme.textCarbon),
                      decoration: const InputDecoration(
                        labelText: 'Banner Message',
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (val) async {
                        await auth.adminUpdateAppConfig({'globalBannerMessage': val});
                        auth.fetchAppConfig();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Global Banner Image', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: AppTheme.textCarbon)),
                    const SizedBox(height: 4),
                    Text('Recommended size: 1200x400 (Aspect Ratio 3:1). Max size: 2MB.', style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.textMuted)),
                    const SizedBox(height: 4),
                    Text('Recommended size: 800x400 pixels (2:1 aspect ratio). Supported formats: JPG, PNG.', 
                      style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.textMuted)),
                    const SizedBox(height: 12),
                    if (auth.appConfig != null && auth.appConfig!['globalBannerImageUrl'] != null && auth.appConfig!['globalBannerImageUrl'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(auth.appConfig!['globalBannerImageUrl'], height: 120, width: double.infinity, fit: BoxFit.cover),
                        ),
                      ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          final bytes = await picked.readAsBytes();
                          final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading banner image...')));
                          await auth.adminUpdateAppConfig({'globalBannerImageUrl': base64String});
                          auth.fetchAppConfig();
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Banner Image Uploaded Successfully')));
                        }
                      },
                      icon: const Icon(Icons.upload_file, color: Colors.black),
                      label: Text('Upload Image', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold),
                    ),
                  ],
                ),
              ),
        ],
      ),
      ),
    );
  }

  Widget _buildPhoneLogsPanel(AuthProvider auth) {
    return FutureBuilder<List<dynamic>>(
      future: auth.fetchPhoneLogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading logs", style: TextStyle(color: Colors.red)));
        }
        
        final logs = snapshot.data ?? [];
        if (logs.isEmpty) {
          return const Center(child: Text("No phone logs found.", style: TextStyle(color: AppTheme.textWhite)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            final date = DateTime.tryParse(log['createdAt'] ?? '');
            final formattedDate = date != null ? '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}' : 'Unknown time';
            
            return Card(
              color: AppTheme.cardGray,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.phone, color: AppTheme.accentGold),
                title: Text('+91 ${log['phone']}', style: GoogleFonts.montserrat(color: AppTheme.textWhite, fontWeight: FontWeight.bold)),
                subtitle: Text('Attempted at: $formattedDate', style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 12)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOnboardingDropoffsPanel(AuthProvider auth) {
    return FutureBuilder<List<dynamic>>(
      future: auth.getOnboardingDropoffs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading drop-offs', style: GoogleFonts.montserrat(color: Colors.red)));
        }
        final dropoffs = snapshot.data ?? [];
        if (dropoffs.isEmpty) {
          return Center(child: Text('No onboarding drop-offs found.', style: GoogleFonts.montserrat(color: AppTheme.textMuted)));
        }
        return ListView.builder(
          itemCount: dropoffs.length,
          itemBuilder: (context, index) {
            final dropoff = dropoffs[index];
            final date = DateTime.tryParse(dropoff['lastActiveAt'] ?? '');
            final formattedDate = date != null ? '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}' : 'Unknown time';
            
            return Card(
              color: AppTheme.cardWhite,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.glassBorderColor, width: 0.5),
              ),
              child: ListTile(
                leading: const Icon(Icons.assignment_late_outlined, color: AppTheme.accentGold),
                title: Text('+91 ${dropoff['phone']}', style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dropped at: ${dropoff['stepName'] ?? 'Step ${dropoff['currentStep']}'}', style: GoogleFonts.montserrat(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                    Text('Last Active: $formattedDate', style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}