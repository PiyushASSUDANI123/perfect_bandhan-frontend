import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/providers/auth_provider.dart'
with open(file_path, 'r') as f:
    content = f.read()

old = """      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> profilesJson = data['data'] ?? [];
        if (profilesJson.isEmpty || profilesJson.length < limit) {"""

new = """      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> profilesJson = data['data'] ?? [];
        print("DEBUG: Fetched ${profilesJson.length} profiles from DB.");
        if (profilesJson.isEmpty || profilesJson.length < limit) {"""

content = content.replace(old, new)

old2 = """          for (var p in newProfiles) {
            if (!_dailyPicks.any((existing) => existing.id == p.id)) {
              _dailyPicks.add(p);
            }
          }
        }
      } else {"""

new2 = """          for (var p in newProfiles) {
            if (!_dailyPicks.any((existing) => existing.id == p.id)) {
              _dailyPicks.add(p);
            }
          }
          print("DEBUG: Added profiles to dailyPicks. Total now: ${_dailyPicks.length}");
        }
      } else {"""

content = content.replace(old2, new2)

old3 = """    } catch (e) {
      _dailyPicksError = "Network error";
    }"""

new3 = """    } catch (e) {
      print("DEBUG: Exception in fetchDailyPicks: $e");
      _dailyPicksError = "Network error";
    }"""

content = content.replace(old3, new3)

with open(file_path, 'w') as f:
    f.write(content)
