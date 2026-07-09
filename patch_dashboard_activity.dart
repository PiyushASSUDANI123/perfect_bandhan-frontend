import 'dart:io';

void main() {
  var file = File('lib/screens/dashboard_screen.dart');
  var content = file.readAsStringSync();

  // Patch Received Tab
  content = content.replaceFirst(
'''                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              itemCount: provider.incomingInterests.length,
                              itemBuilder: (context, index) {
                                final p = provider.incomingInterests[index];
                                return ReceivedRequestCard(profile: p);
                              },
                            ),''',
'''                          : GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _getResponsiveLayout()['crossAxisCount'],
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: _getResponsiveLayout()['crossAxisCount'] > 1 ? 1.5 : 2.5,
                              ),
                              itemCount: provider.incomingInterests.length,
                              itemBuilder: (context, index) {
                                final p = provider.incomingInterests[index];
                                return ReceivedRequestCard(profile: p);
                              },
                            ),'''
  );

  // Patch Accepted Tab
  content = content.replaceFirst(
'''                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: provider.acceptedInterests.length,
                        itemBuilder: (context, index) {
                          final profile = provider.acceptedInterests[index];
                          return AcceptedRequestCard(profile: profile);
                        },
                      ),''',
'''                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _getResponsiveLayout()['crossAxisCount'],
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: _getResponsiveLayout()['crossAxisCount'] > 1 ? 1.5 : 2.5,
                        ),
                        itemCount: provider.acceptedInterests.length,
                        itemBuilder: (context, index) {
                          final profile = provider.acceptedInterests[index];
                          return AcceptedRequestCard(profile: profile);
                        },
                      ),'''
  );

  // Patch Sent Tab
  content = content.replaceFirst(
'''                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: provider.sentInterests.length,
                        itemBuilder: (context, index) {
                          final profile = provider.sentInterests[index];
                          return SentRequestCard(profile: profile);
                        },
                      ),''',
'''                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _getResponsiveLayout()['crossAxisCount'],
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: _getResponsiveLayout()['crossAxisCount'] > 1 ? 1.5 : 2.5,
                        ),
                        itemCount: provider.sentInterests.length,
                        itemBuilder: (context, index) {
                          final profile = provider.sentInterests[index];
                          return SentRequestCard(profile: profile);
                        },
                      ),'''
  );

  file.writeAsStringSync(content);
}
