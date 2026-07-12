import re

# 1. profile_onboarding_screen.dart
file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/screens/profile_onboarding_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Remove the TextField widgets for partner requirements and what we provide
content = re.sub(r'// Partner Requirements\s*TextFormField\([\s\S]*?What We Provide\s*TextFormField\([\s\S]*?,\s*maxLines:\s*3,\s*\),', '', content)
# We also need to remove them from _buildCurrentStep if they exist in a separate page, let's check
with open(file_path, 'w') as f:
    f.write(content)

# 2. my_profile_screen.dart
file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/screens/my_profile_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()
# Removing from my profile...
content = re.sub(r'const SizedBox\(height: 16\),\s*_buildTextField\(\s*controller: _requirementsController,\s*label: \'Partner Requirements\',\s*maxLines: 3,\s*\),\s*const SizedBox\(height: 16\),\s*_buildTextField\(\s*controller: _whatWeProvideController,\s*label: \'What We Provide\',\s*maxLines: 3,\s*\),', '', content)
with open(file_path, 'w') as f:
    f.write(content)

print("Removed fields via script.")
