import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/screens/dashboard_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

old = """                    },
                  );
                },
            ],"""

new = """                    },
                  );
                },
              ),
            ],"""

content = content.replace(old, new)

with open(file_path, 'w') as f:
    f.write(content)
print("dashboard_screen.dart syntax fixed again.")
