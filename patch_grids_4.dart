import 'dart:io';

void main() {
  var file = File('lib/screens/my_profile_screen.dart');
  var content = file.readAsStringSync();

  // Family Background
  content = content.replaceFirst(
'''                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.family_restroom_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('family_type'),
                          value: _safeStr(data, 'familyType', fallback: 'Nuclear'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.place_rounded,
                          label: 'City of Origin',
                          value: _safeStr(data, 'cityOfOrigin', fallback: 'Not specified'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.person_rounded,
                          label: "Father",
                          value: _safeStr(data, 'fatherStatus', fallback: 'Alive'),
                          subValue: _safeStr(data, 'fathersOccupation', fallback: ''),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.pregnant_woman_rounded,
                          label: "Mother",
                          value: _safeStr(data, 'motherStatus', fallback: 'Alive'),
                          subValue: _safeStr(data, 'mothersOccupation', fallback: ''),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.people_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('siblings'),
                          value: _safeStr(data, 'siblingsCount', fallback: '0'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.house_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('own_house'),
                          value: _safeStr(data, 'ownHouse', fallback: 'No'),
                        )),
                      ],
                    ),''',
'''                    _buildResponsiveGrid(context, [
                      _bentoCard(
                        icon: Icons.family_restroom_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('family_type'),
                        value: _safeStr(data, 'familyType', fallback: 'Nuclear'),
                      ),
                      _bentoCard(
                        icon: Icons.place_rounded,
                        label: 'City of Origin',
                        value: _safeStr(data, 'cityOfOrigin', fallback: 'Not specified'),
                      ),
                      _bentoCard(
                        icon: Icons.person_rounded,
                        label: "Father",
                        value: _safeStr(data, 'fatherStatus', fallback: 'Alive'),
                        subValue: _safeStr(data, 'fathersOccupation', fallback: ''),
                      ),
                      _bentoCard(
                        icon: Icons.pregnant_woman_rounded,
                        label: "Mother",
                        value: _safeStr(data, 'motherStatus', fallback: 'Alive'),
                        subValue: _safeStr(data, 'mothersOccupation', fallback: ''),
                      ),
                      _bentoCard(
                        icon: Icons.people_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('siblings'),
                        value: _safeStr(data, 'siblingsCount', fallback: '0'),
                      ),
                      _bentoCard(
                        icon: Icons.house_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('own_house'),
                        value: _safeStr(data, 'ownHouse', fallback: 'No'),
                      ),
                    ]),'''
  );

  file.writeAsStringSync(content);
}
