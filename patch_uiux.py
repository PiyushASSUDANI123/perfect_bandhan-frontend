import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/screens/dashboard_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# 1. Add dart:math
if "import 'dart:math'" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'dart:math' as math;")

# 2. Fix Empty State in Daily Picks
picks_old = """            child: provider.dailyPicks.isEmpty && provider.isLoadingDailyPicks
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
                : Center(
                    child: ConstrainedBox("""

picks_new = """            child: provider.dailyPicks.isEmpty && provider.isLoadingDailyPicks
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
                : provider.dailyPicks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: AppTheme.textMuted),
                            const SizedBox(height: 16),
                            Text('No Matches Found', style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textCarbon)),
                            const SizedBox(height: 8),
                            Text('Try relaxing your partner preferences.', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
                          ],
                        ),
                      )
                    : Center(
                        child: ConstrainedBox("""

content = content.replace(picks_old, picks_new)

# 3. Fix Empty State in Search
search_old = """              child: provider.searchResults.isEmpty && provider.isLoadingSearch
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
                  : Center(
                      child: ConstrainedBox("""

search_new = """              child: provider.searchResults.isEmpty && provider.isLoadingSearch
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
                  : provider.searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_search_rounded, size: 64, color: AppTheme.textMuted),
                              const SizedBox(height: 16),
                              Text('No Profiles Found', style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textCarbon)),
                              const SizedBox(height: 8),
                              Text('Adjust your search filters to see more results.', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
                            ],
                          ),
                        )
                      : Center(
                          child: ConstrainedBox("""

content = content.replace(search_old, search_new)

# 4. Fix Hardcoded Negative Dimensions
extent_old = "mainAxisExtent: MediaQuery.of(context).size.width > 900 ? 650.0 : MediaQuery.of(context).size.height - 220,"
extent_new = "mainAxisExtent: MediaQuery.of(context).size.width > 900 ? 650.0 : math.max(400.0, MediaQuery.of(context).size.height - 220),"
content = content.replace(extent_old, extent_new)

# 5. Fix Accessibility Semantics in PremiumHeader
logo_old = """            // Logo as Drawer trigger
            GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer(); // assuming drawer exists
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset('assets/logo.png', height: 44, width: 44, fit: BoxFit.cover),
              ),
            ),"""

logo_new = """            // Logo as Drawer trigger
            Semantics(
              label: 'Open Navigation Menu',
              button: true,
              child: GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer(); // assuming drawer exists
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset('assets/logo.png', height: 44, width: 44, fit: BoxFit.cover),
                ),
              ),
            ),"""

content = content.replace(logo_old, logo_new)

prefs_old = """                  GestureDetector(
                    onTap: _showPartnerPreferencesSheet,
                    child: Row(
                      children: [
                        Flexible(
                          child: AutoSizeText(
                            'as per partner preferences ',
                            maxLines: 1,
                            minFontSize: 8,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentGold,
                            ),
                          ),
                        ),
                        const Icon(Icons.edit_note_rounded, color: AppTheme.accentGold, size: 14),
                      ],
                    ),
                  ),"""

prefs_new = """                  Semantics(
                    label: 'Edit Partner Preferences',
                    button: true,
                    child: GestureDetector(
                      onTap: _showPartnerPreferencesSheet,
                      child: Row(
                        children: [
                          Flexible(
                            child: AutoSizeText(
                              'as per partner preferences ',
                              maxLines: 1,
                              minFontSize: 8,
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentGold,
                              ),
                            ),
                          ),
                          const Icon(Icons.edit_note_rounded, color: AppTheme.accentGold, size: 14),
                        ],
                      ),
                    ),
                  ),"""

content = content.replace(prefs_old, prefs_new)

with open(file_path, 'w') as f:
    f.write(content)
print("dashboard_screen.dart patched successfully for UI/UX flaws.")
