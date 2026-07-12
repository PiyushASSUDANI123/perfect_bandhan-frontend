import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/screens/dashboard_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

old = """                            Text('No Matches Found', style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textCarbon)),
                            const SizedBox(height: 8),
                            Text('Try relaxing your partner preferences.', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),"""

new = """                            Text(provider.dailyPicksError ?? 'No Matches Found', style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textCarbon)),
                            const SizedBox(height: 8),
                            Text(provider.dailyPicksError != null ? 'Error fetching data. Check your network or token.' : 'Try relaxing your partner preferences.', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),"""

content = content.replace(old, new)

with open(file_path, 'w') as f:
    f.write(content)
print("Patched UI to show error.")
