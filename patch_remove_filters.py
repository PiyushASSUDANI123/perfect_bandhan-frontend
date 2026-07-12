import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/screens/dashboard_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

old = """        _buildPremiumHeader(),
        _buildPremiumFiltersRow(),
        Expanded("""

new = """        _buildPremiumHeader(),
        Expanded("""

content = content.replace(old, new)

with open(file_path, 'w') as f:
    f.write(content)
print("Removed Filters row from dashboard_screen.dart")
