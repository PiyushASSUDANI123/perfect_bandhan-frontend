import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class AdminUserSettingsSheet extends StatefulWidget {
  final Map<String, dynamic> adminEditUser;

  const AdminUserSettingsSheet({super.key, required this.adminEditUser});

  @override
  State<AdminUserSettingsSheet> createState() => _AdminUserSettingsSheetState();
}

class _AdminUserSettingsSheetState extends State<AdminUserSettingsSheet> {
  bool _isActive = true;
  bool _profileHidden = false;
  bool _isSeriousSeeker = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isActive = widget.adminEditUser['isActive'] ?? true;
    _profileHidden = widget.adminEditUser['profileHidden'] ?? false;
    _isSeriousSeeker = widget.adminEditUser['isSeriousSeeker'] ?? false;
  }

  Future<void> _updateSetting(String key, bool value) async {
    setState(() => _isSaving = true);
    
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final String uId = widget.adminEditUser['_id'] ?? widget.adminEditUser['id'] ?? '';
    
    bool success = await authProv.adminEditUser(uId, {key: value});
    
    if (success && mounted) {
      authProv.fetchAdminUsers();
      setState(() {
        if (key == 'isActive') _isActive = value;
        if (key == 'profileHidden') _profileHidden = value;
        if (key == 'isSeriousSeeker') _isSeriousSeeker = value;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Setting updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update setting.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Account Settings',
                  style: GoogleFonts.cinzel(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textCarbon,
                  ),
                ),
                if (_isSaving)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: AppTheme.accentGold, strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'Manage administrative flags for this profile.',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 24.0),
            
            // Is Active Toggle
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.glassColor,
                border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: SwitchListTile(
                title: Text('Account Active', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: AppTheme.textCarbon)),
                subtitle: Text('If disabled, the user cannot log in and will not be shown on the dashboard.', style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.textMuted)),
                value: _isActive,
                activeThumbColor: AppTheme.accentGold,
                activeTrackColor: AppTheme.accentGold.withValues(alpha: 0.3),
                onChanged: _isSaving ? null : (val) => _updateSetting('isActive', val),
              ),
            ),
            
            // Profile Hidden Toggle
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.glassColor,
                border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: SwitchListTile(
                title: Text('Profile Hidden', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: AppTheme.textCarbon)),
                subtitle: Text('If true, the profile is hidden from the main feed but the user can still use the app (Incognito mode).', style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.textMuted)),
                value: _profileHidden,
                activeThumbColor: AppTheme.accentGold,
                activeTrackColor: AppTheme.accentGold.withValues(alpha: 0.3),
                onChanged: _isSaving ? null : (val) => _updateSetting('profileHidden', val),
              ),
            ),

            // Serious Seeker Toggle
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.glassColor,
                border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: SwitchListTile(
                title: Text('Serious Seeker', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: AppTheme.textCarbon)),
                subtitle: Text('Shows a special badge on their profile indicating they are highly active and responsive.', style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.textMuted)),
                value: _isSeriousSeeker,
                activeThumbColor: AppTheme.accentGold,
                activeTrackColor: AppTheme.accentGold.withValues(alpha: 0.3),
                onChanged: _isSaving ? null : (val) => _updateSetting('isSeriousSeeker', val),
              ),
            ),
            
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
