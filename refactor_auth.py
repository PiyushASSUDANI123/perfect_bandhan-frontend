import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/providers/auth_provider.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Fix 1: Add _dailyPicksOffset and _searchOffset
content = content.replace("bool _hasMoreDailyPicks = true;", "bool _hasMoreDailyPicks = true;\n  int _dailyPicksOffset = 0;")
content = content.replace("bool _hasMoreSearch = true;", "bool _hasMoreSearch = true;\n  int _searchOffset = 0;")

# Fix 2: fetchDailyPicks logic
fetch_picks_old = """  Future<void> fetchDailyPicks({bool refresh = false, Map<String, String>? filters, int offset = 0}) async {
    if (_token == null) return;
    if (refresh) {
      _dailyPicks.clear();
      _hasMoreDailyPicks = true;
      _dailyPicksError = null;
    }"""
fetch_picks_new = """  Future<void> fetchDailyPicks({bool refresh = false, Map<String, String>? filters}) async {
    if (_token == null) return;
    if (refresh) {
      _dailyPicks.clear();
      _hasMoreDailyPicks = true;
      _dailyPicksError = null;
      _dailyPicksOffset = 0;
    }"""
content = content.replace(fetch_picks_old, fetch_picks_new)

fetch_picks_url_old = "String url = '$baseUrl/user/profiles?recommendations=true&limit=$limit&offset=$offset';"
fetch_picks_url_new = "String url = '$baseUrl/user/profiles?recommendations=true&limit=$limit&offset=$_dailyPicksOffset';"
content = content.replace(fetch_picks_url_old, fetch_picks_url_new)

fetch_picks_parse_old = """        if (profilesJson.isEmpty) {
          _hasMoreDailyPicks = false;
        } else {"""
fetch_picks_parse_new = """        if (profilesJson.isEmpty || profilesJson.length < limit) {
          _hasMoreDailyPicks = false;
        }
        if (profilesJson.isNotEmpty) {
          _dailyPicksOffset += profilesJson.length;"""
content = content.replace(fetch_picks_parse_old, fetch_picks_parse_new)

# Fix 3: searchProfiles logic
search_old = """  Future<void> searchProfiles({Map<String, String>? filters, bool refresh = false, int offset = 0}) async {
    if (_token == null) return;
    if (refresh) {
      _searchResults.clear();
      _hasMoreSearch = true;
      _searchError = null;
    }"""
search_new = """  Future<void> searchProfiles({Map<String, String>? filters, bool refresh = false}) async {
    if (_token == null) return;
    if (refresh) {
      _searchResults.clear();
      _hasMoreSearch = true;
      _searchError = null;
      _searchOffset = 0;
    }"""
content = content.replace(search_old, search_new)

search_url_old = "String url = '$baseUrl/user/profiles?limit=$limit&offset=$offset';"
search_url_new = "String url = '$baseUrl/user/profiles?limit=$limit&offset=$_searchOffset';"
content = content.replace(search_url_old, search_url_new)

search_parse_old = """        if (profilesJson.isEmpty) {
          _hasMoreSearch = false;
        } else {"""
search_parse_new = """        if (profilesJson.isEmpty || profilesJson.length < limit) {
          _hasMoreSearch = false;
        }
        if (profilesJson.isNotEmpty) {
          _searchOffset += profilesJson.length;"""
content = content.replace(search_parse_old, search_parse_new)

# Fix 4: Add proper error handling to all methods that swallow errors.
# We will use regex to find all methods returning Future<bool> that do:
# } catch (e) { return false; }
# And change them to properly log and return false.

catch_block = """    } catch (e) {
      _errorMessage = 'Network error: Please check your connection.';
      notifyListeners();
      return false; 
    }"""
content = re.sub(r'\} catch \(e\) \{ return false; \}', catch_block, content)

# Also need to fix the case where response.statusCode == 200 is used but else branch doesn't set _errorMessage
# We will do a generic replacement for this specific pattern for adminEditUser and similar
admin_edit_old = """      final response = await http.put(
        Uri.parse('$baseUrl/user/admin/user/$userId'),
        headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return response.statusCode == 200;"""
admin_edit_new = """      final response = await http.put(
        Uri.parse('$baseUrl/user/admin/user/$userId'),
        headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        try {
          _errorMessage = jsonDecode(response.body)['message'] ?? 'Failed';
        } catch (_) {
          _errorMessage = 'Failed to update';
        }
        notifyListeners();
        return false;
      }"""
content = content.replace(admin_edit_old, admin_edit_new)


with open(file_path, 'w') as f:
    f.write(content)
print("File updated successfully.")
