import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/screens/dashboard_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# First, extract matches in _buildPremiumHeader
if "final matches = provider.matches;" not in content:
    content = content.replace("final profile = provider.myProfile;", "final profile = provider.myProfile;\n    final matches = provider.matches;")

old_ai_picks = """                // Stack of images (Placeholders for now)
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
                ),"""

new_ai_picks = """                // Stack of images from real matches or placeholders
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
                          backgroundImage: matches.length > 0 && matches[0].photos.isNotEmpty
                              ? NetworkImage(matches[0].photos[0]) as ImageProvider
                              : const AssetImage('assets/default_avatar.png'),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[400],
                          backgroundImage: matches.length > 1 && matches[1].photos.isNotEmpty
                              ? NetworkImage(matches[1].photos[0]) as ImageProvider
                              : const AssetImage('assets/default_avatar.png'),
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
                              matches.length > 2 ? '+${matches.length - 2}\\nMore' : '+12\\nMore',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF6B2B2B)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),"""

content = content.replace(old_ai_picks, new_ai_picks)

# Also update the onTap logic to open matches or show toast
old_on_tap = """        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No perfect match found for now, come back later! ✨', style: GoogleFonts.montserrat()),
                backgroundColor: AppTheme.accentGold,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },"""

new_on_tap = """        GestureDetector(
          onTap: () {
            if (matches.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('No perfect match found for now, come back later! ✨', style: GoogleFonts.montserrat()),
                  backgroundColor: AppTheme.accentGold,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            } else {
              // If we have matches, we could navigate to a dedicated AI Picks screen.
              // For now, since it's just suggesting real profiles, we can just scroll down or do nothing 
              // because matches are already shown below.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Showing ${matches.length} AI handpicked matches below!', style: GoogleFonts.montserrat()),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },"""

content = content.replace(old_on_tap, new_on_tap)

with open(file_path, 'w') as f:
    f.write(content)
print("dashboard_screen.dart patched successfully for real AI picks.")
