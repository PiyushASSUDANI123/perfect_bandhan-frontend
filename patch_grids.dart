import 'dart:io';

void main() {
  var file = File('lib/screens/my_profile_screen.dart');
  var content = file.readAsStringSync();

  // Replace PERSONAL INTEL
  content = content.replaceFirst(
'''                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.cake_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('age_height'),
                          value: '\${age > 0 ? age : '—'} yrs  ·  \${_safeStr(data, 'height')}',
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.location_on_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('lives_in'),
                          value: _safeStr(data, 'city'),
                          subValue: _safeStr(data, 'state'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.favorite_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('marital_status'),
                          value: _safeStr(data, 'maritalStatus'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.people_alt_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('clan_nukh'),
                          value: _safeStr(data, 'caste'),
                          accent: true,
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.accessibility_new_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('complexion_weight'),
                          value: _safeStr(data, 'complexion'),
                          subValue: _safeStr(data, 'weight', fallback: 'Not specified'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.wheelchair_pickup_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('disability'),
                          value: _safeStr(data, 'physicalDisability', fallback: 'None'),
                        )),
                      ],
                    ),''',
'''                    _buildResponsiveGrid(context, [
                      _bentoCard(
                        icon: Icons.cake_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('age_height'),
                        value: '\${age > 0 ? age : '—'} yrs  ·  \${_safeStr(data, 'height')}',
                      ),
                      _bentoCard(
                        icon: Icons.location_on_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('lives_in'),
                        value: _safeStr(data, 'city'),
                        subValue: _safeStr(data, 'state'),
                      ),
                      _bentoCard(
                        icon: Icons.favorite_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('marital_status'),
                        value: _safeStr(data, 'maritalStatus'),
                      ),
                      _bentoCard(
                        icon: Icons.people_alt_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('clan_nukh'),
                        value: _safeStr(data, 'caste'),
                        accent: true,
                      ),
                      _bentoCard(
                        icon: Icons.accessibility_new_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('complexion_weight'),
                        value: _safeStr(data, 'complexion'),
                        subValue: _safeStr(data, 'weight', fallback: 'Not specified'),
                      ),
                      _bentoCard(
                        icon: Icons.wheelchair_pickup_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('disability'),
                        value: _safeStr(data, 'physicalDisability', fallback: 'None'),
                      ),
                    ]),'''
  );

  file.writeAsStringSync(content);
}
