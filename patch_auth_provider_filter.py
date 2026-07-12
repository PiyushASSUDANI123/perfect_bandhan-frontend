import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/providers/auth_provider.dart'
with open(file_path, 'r') as f:
    content = f.read()

old = """          final newProfiles = profilesJson
              .map((e) => Profile.fromJson(e))
              .where((p) => p.name.trim().toLowerCase() != 'new user')
              .toList();"""

new = """          final newProfiles = profilesJson
              .map((e) => Profile.fromJson(e))
              .toList();"""

content = content.replace(old, new)

with open(file_path, 'w') as f:
    f.write(content)
print("Removed 'new user' filter.")
