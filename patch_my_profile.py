import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/screens/my_profile_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Add PB ID below Name
old_name_ui = """                Text(
                  _profileData!['firstName'] + ' ' + _profileData!['lastName'],
                  style: GoogleFonts.cinzel(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textCarbon,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),"""

new_name_ui = """                Text(
                  _profileData!['firstName'] + ' ' + _profileData!['lastName'],
                  style: GoogleFonts.cinzel(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textCarbon,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_profileData!['pbId'] != null && _profileData!['pbId'].toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'ID: ${_profileData!['pbId']}',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 6),"""

content = content.replace(old_name_ui, new_name_ui)

# Update Share button in My Profile Screen
old_share_my = """      final shareUrl = 'https://app.perfectbandhan.in/profile/$id';
      Share.share('Check out my profile on Perfect Bandhan!\\n$shareUrl');"""

new_share_my = """      final shareId = _profileData!['pbId']?.toString().isNotEmpty == true ? _profileData!['pbId'] : id;
      final shareUrl = 'https://humsafar.piyushassudani.in/p/$shareId';
      Share.share('Check out my profile on Perfect Bandhan!\\n$shareUrl');"""

content = content.replace(old_share_my, new_share_my)

with open(file_path, 'w') as f:
    f.write(content)
print("my_profile_screen.dart patched successfully for pbId.")
