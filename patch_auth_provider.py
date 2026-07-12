import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/providers/auth_provider.dart'
with open(file_path, 'r') as f:
    content = f.read()

# fetchDailyPicks
old_fetch_daily = """  Future<void> fetchDailyPicks({bool refresh = false, Map<String, String>? filters}) async {
    if (_token == null) return;
    if (refresh) {
      _dailyPicks.clear();
      _hasMoreDailyPicks = true;
      _dailyPicksError = null;
      _dailyPicksOffset = 0;
    }
    if (!_hasMoreDailyPicks && !refresh) return;
    _isLoadingDailyPicks = true;
    notifyListeners();"""

new_fetch_daily = """  Future<void> fetchDailyPicks({bool refresh = false, Map<String, String>? filters}) async {
    if (_token == null) return;
    if (_isLoadingDailyPicks && !refresh) return;
    if (refresh) {
      _dailyPicks.clear();
      _hasMoreDailyPicks = true;
      _dailyPicksError = null;
      _dailyPicksOffset = 0;
    }
    if (!_hasMoreDailyPicks && !refresh) return;
    _isLoadingDailyPicks = true;
    notifyListeners();"""

content = content.replace(old_fetch_daily, new_fetch_daily)

# searchProfiles
old_search = """  Future<void> searchProfiles({Map<String, String>? filters, bool refresh = false, int offset = 0}) async {
    if (_token == null) return;
    if (refresh) {
      _searchResults.clear();
      _hasMoreSearch = true;
      _searchError = null;
      _searchCount = 0;
    }
    if (!_hasMoreSearch && !refresh) return;
    _isLoadingSearch = true;
    notifyListeners();"""

new_search = """  Future<void> searchProfiles({Map<String, String>? filters, bool refresh = false, int offset = 0}) async {
    if (_token == null) return;
    if (_isLoadingSearch && !refresh) return;
    if (refresh) {
      _searchResults.clear();
      _hasMoreSearch = true;
      _searchError = null;
      _searchCount = 0;
    }
    if (!_hasMoreSearch && !refresh) return;
    _isLoadingSearch = true;
    notifyListeners();"""

content = content.replace(old_search, new_search)


with open(file_path, 'w') as f:
    f.write(content)
print("AuthProvider patched with early returns.")
