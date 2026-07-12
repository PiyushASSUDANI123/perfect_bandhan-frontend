import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/models/profile.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Add pbId property
if "final String pbId;" not in content:
    content = content.replace("final String id;", "final String id;\n  final String pbId;")
    
    # Add to constructor
    content = content.replace("required this.id,", "required this.id,\n    this.pbId = '',")
    
    # Parse from JSON
    old_json = "id: json['_id']?.toString() ?? '',"
    new_json = "id: json['_id']?.toString() ?? '',\n      pbId: json['pbId']?.toString() ?? '',"
    content = content.replace(old_json, new_json)

with open(file_path, 'w') as f:
    f.write(content)
print("profile.dart patched successfully for pbId.")
