import 'dart:io';

void main() {
  var file = File('lib/screens/admin_panel_screen.dart');
  var content = file.readAsStringSync();

  var targetStr = '''    int crossAxisCount = MediaQuery.of(context).size.width > 1000 ? 5 : (MediaQuery.of(context).size.width > 600 ? 3 : 2);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12.0,
      mainAxisSpacing: 12.0,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard('Total Users', total.toString(), Icons.people_alt_outlined, Colors.blue),
        _buildStatCard('Male Profiles', males.toString(), Icons.man_outlined, Colors.orange),
        _buildStatCard('Female Profiles', females.toString(), Icons.woman_outlined, Colors.pink),
        _buildStatCard('Incomplete', incomplete.toString(), Icons.warning_amber_rounded, Colors.purple),
        _buildStatCard('Inactive', inactive.toString(), Icons.person_off_outlined, Colors.redAccent),
      ],
    );''';

  var replacementStr = '''    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = constraints.maxWidth > 1000 ? 5 : (constraints.maxWidth > 600 ? 3 : 2);
        double spacing = 12.0;
        double width = (constraints.maxWidth - (spacing * (columns - 1))) / columns;
        width = width.floorToDouble();

        final children = [
          _buildStatCard('Total Users', total.toString(), Icons.people_alt_outlined, Colors.blue),
          _buildStatCard('Male Profiles', males.toString(), Icons.man_outlined, Colors.orange),
          _buildStatCard('Female Profiles', females.toString(), Icons.woman_outlined, Colors.pink),
          _buildStatCard('Incomplete', incomplete.toString(), Icons.warning_amber_rounded, Colors.purple),
          _buildStatCard('Inactive', inactive.toString(), Icons.person_off_outlined, Colors.redAccent),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children.map((child) => SizedBox(width: width, child: child)).toList(),
        );
      },
    );''';

  content = content.replaceFirst(targetStr, replacementStr);
  file.writeAsStringSync(content);
}
