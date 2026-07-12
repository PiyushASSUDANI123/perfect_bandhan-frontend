import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/screens/dashboard_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Add getGreeting helper
if "String _getGreeting()" not in content:
    content = content.replace("Widget _buildPremiumHeader() {", "String _getGreeting() {\n    var hour = DateTime.now().hour;\n    if (hour < 12) return 'Good Morning,';\n    if (hour < 17) return 'Good Afternoon,';\n    return 'Good Evening,';\n  }\n\n  Widget _buildPremiumHeader() {")

# Replace PB Matches header with Greeting + Name
old_header_text = """                  Text(
                    'PB Matches',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textCarbon,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showPartnerPreferencesSheet,
                    child: Row(
                      children: [
                        Flexible(
                          child: AutoSizeText(
                            'as per partner preferences ',
                            maxLines: 1,
                            minFontSize: 8,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: AppTheme.accentGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.edit_outlined, size: 12, color: AppTheme.accentGold),
                      ],
                    ),
                  ),"""

new_header_text = """                  Text(
                    _getGreeting(),
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textDim,
                    ),
                  ),
                  Text(
                    '${profile?['firstName'] ?? 'User'} 👋',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textCarbon,
                    ),
                  ),"""

content = content.replace(old_header_text, new_header_text)

# We need to wrap the header Row in a Column to add the AI picks below it.
# Wait, it's safer to just replace the child of SafeArea.
old_safe_area = """      child: SafeArea(
        bottom: false,
        child: Row("""

new_safe_area = """      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row("""

content = content.replace(old_safe_area, new_safe_area)

# And close the Row and add the AI Picks banner
old_end_row = """            const ProfileCompletionAppBarAction(), // Ring directly in AppBar
          ],
        ),
      ),
    );"""

new_end_row = """            const ProfileCompletionAppBarAction(), // Ring directly in AppBar
          ],
        ),
        const SizedBox(height: 16),
        // AI Picks for You Banner
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No perfect match found for now, come back later! ✨', style: GoogleFonts.montserrat()),
                backgroundColor: AppTheme.accentGold,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFCF5F0), // Light peach color
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0E0D6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF6B2B2B), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Picks for You',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6B2B2B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Handpicked matches based on\\nyour preferences',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textCarbon.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Stack of images (Placeholders for now)
                SizedBox(
                  width: 80,
                  height: 40,
                  child: Stack(
                    children: [
                      Positioned(
                        right: 40,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: const AssetImage('assets/default_avatar.png'),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[400],
                          backgroundImage: const AssetImage('assets/default_avatar.png'),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDF0E9),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '+12\\nMore',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF6B2B2B)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textCarbon),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
);"""

content = content.replace(old_end_row, new_end_row)

with open(file_path, 'w') as f:
    f.write(content)
print("dashboard_screen.dart patched successfully for AI Picks UI.")
