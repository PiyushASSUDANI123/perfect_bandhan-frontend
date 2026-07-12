import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/screens/dashboard_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

old1 = """                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: matches.length > 0 && matches[0].photos.isNotEmpty
                              ? NetworkImage(matches[0].photos[0]) as ImageProvider
                              : const AssetImage('assets/default_avatar.png'),
                        ),"""

new1 = """                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[400],
                          backgroundImage: matches.length > 0 && matches[0].photos.isNotEmpty
                              ? NetworkImage(matches[0].photos[0]) as ImageProvider
                              : null,
                          child: (matches.length > 0 && matches[0].photos.isNotEmpty) 
                              ? null 
                              : const Icon(Icons.person, color: Colors.white, size: 20),
                        ),"""

content = content.replace(old1, new1)

old2 = """                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[400],
                          backgroundImage: matches.length > 1 && matches[1].photos.isNotEmpty
                              ? NetworkImage(matches[1].photos[0]) as ImageProvider
                              : const AssetImage('assets/default_avatar.png'),
                        ),"""

new2 = """                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[400],
                          backgroundImage: matches.length > 1 && matches[1].photos.isNotEmpty
                              ? NetworkImage(matches[1].photos[0]) as ImageProvider
                              : null,
                          child: (matches.length > 1 && matches[1].photos.isNotEmpty)
                              ? null 
                              : const Icon(Icons.person, color: Colors.white, size: 20),
                        ),"""

content = content.replace(old2, new2)

with open(file_path, 'w') as f:
    f.write(content)
print("Avatar patched.")
