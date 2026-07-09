import 'dart:io';

void main() {
  var file = File('lib/screens/my_profile_screen.dart');
  var content = file.readAsStringSync();

  // Replace max width 700 with 1200
  content = content.replaceFirst(
    'constraints: const BoxConstraints(maxWidth: 700),',
    'constraints: const BoxConstraints(maxWidth: 1200),'
  );

  // Re-write the "Update Profile" button to be constrained
  content = content.replaceFirst(
    'SizedBox(\n                      width: double.infinity,\n                      child: ElevatedButton.icon(',
    'Center(\n                      child: ConstrainedBox(\n                        constraints: const BoxConstraints(maxWidth: 400),\n                        child: SizedBox(\n                          width: double.infinity,\n                          child: ElevatedButton.icon('
  );
  content = content.replaceFirst(
    '                        ),\n                      ),\n                    ),\n                    const SizedBox(height: 24),',
    '                        ),\n                      ),\n                    ),\n                    ),\n                    const SizedBox(height: 24),'
  ); // adds closing for ConstrainedBox/Center

  file.writeAsStringSync(content);
}
