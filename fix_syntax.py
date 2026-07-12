import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/screens/dashboard_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# 1. Fix ValueListenableBuilder syntax and _currentIndexNotifier
old_val_list = """              ValueListenableBuilder<int>(
                valueListenable: _currentIndexNotifier,
                builder: (context, currentIndex, child) {
                  return FloatingNavBar(
                    currentIndex: currentIndex,
                    onTap: (int index) {
                  final provider = Provider.of<AuthProvider>(context, listen: false);
                  if (index == 3 && provider.appConfig?['chatComingSoon'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chat is currently under development. Coming soon!'),
                        backgroundColor: Colors.blueAccent,
                      ),
                    );
                    return;
                  }
                  setState(() {
                    _currentIndex = index;
                  });
                  if (index == 4) {
                    provider.fetchMyProfile();
                  } else if (index == 2) {
                    provider.fetchActivityData();
                  } else if (index == 3) {
                    provider.fetchConversations();
                  }
                },
              ),
                  );
                },"""

new_val_list = """              ValueListenableBuilder<int>(
                valueListenable: _currentIndexNotifier,
                builder: (context, currentIndex, child) {
                  return FloatingNavBar(
                    currentIndex: currentIndex,
                    onTap: (int index) {
                      final provider = Provider.of<AuthProvider>(context, listen: false);
                      if (index == 3 && provider.appConfig?['chatComingSoon'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chat is currently under development. Coming soon!'),
                            backgroundColor: Colors.blueAccent,
                          ),
                        );
                        return;
                      }
                      _currentIndexNotifier.value = index;
                      if (index == 4) {
                        provider.fetchMyProfile();
                      } else if (index == 2) {
                        provider.fetchActivityData();
                      } else if (index == 3) {
                        provider.fetchConversations();
                      }
                    },
                  );
                },"""
content = content.replace(old_val_list, new_val_list)

# 2. Fix other _currentIndex references
content = content.replace("selectedIndex: _currentIndex,", "selectedIndex: _currentIndexNotifier.value,")
content = content.replace("setState(() {\n          _currentIndex = index;\n        });", "_currentIndexNotifier.value = index;")
content = content.replace("setState(() => _currentIndex = 1);", "_currentIndexNotifier.value = 1;")

# 3. Fix AppTheme.textDim to AppTheme.textMuted
content = content.replace("AppTheme.textDim", "AppTheme.textMuted")

# 4. Fix provider.matches to provider.dailyPicks
content = content.replace("final matches = provider.matches;", "final matches = provider.dailyPicks;")

# 5. Fix mounted to context.mounted inside SentRequestCard
old_mounted = """                                  if (!mounted) return;"""
new_mounted = """                                  if (!context.mounted) return;"""
content = content.replace(old_mounted, new_mounted)

with open(file_path, 'w') as f:
    f.write(content)
print("dashboard_screen.dart syntax fixed.")
