import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/screens/dashboard_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Fix fetchDailyPicks call in scroll listener
old_picks_call = """        provider.fetchDailyPicks(
          offset: provider.dailyPicks.length,
          filters: _getHomeFilters(),
        );"""
new_picks_call = """        provider.fetchDailyPicks(
          filters: _getHomeFilters(),
        );"""
content = content.replace(old_picks_call, new_picks_call)

# Fix searchProfiles call in scroll listener
old_search_call = """        provider.searchProfiles(
          filters: _getActiveFilters(),
          offset: provider.searchResults.length,
        );"""
new_search_call = """        provider.searchProfiles(
          filters: _getActiveFilters(),
        );"""
content = content.replace(old_search_call, new_search_call)

with open(file_path, 'w') as f:
    f.write(content)
print("Dashboard updated successfully.")
