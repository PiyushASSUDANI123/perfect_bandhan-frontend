import 'dart:io';

void main() {
  var file = File('lib/screens/my_profile_screen.dart');
  var content = file.readAsStringSync();

  // Contact
  content = content.replaceFirst(
'''                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.phone_android_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('whatsapp'),
                          value: _safeStr(data, 'whatsappNumber', fallback: 'Not provided'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.map_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('district'),
                          value: _safeStr(data, 'district', fallback: 'Not provided'),
                        )),
                      ],
                    ),''',
'''                    _buildResponsiveGrid(context, [
                      _bentoCard(
                        icon: Icons.phone_android_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('whatsapp'),
                        value: _safeStr(data, 'whatsappNumber', fallback: 'Not provided'),
                      ),
                      _bentoCard(
                        icon: Icons.map_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('district'),
                        value: _safeStr(data, 'district', fallback: 'Not provided'),
                      ),
                    ]),'''
  );

  // Astro
  content = content.replaceFirst(
'''                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.calendar_today_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('date_of_birth'),
                          value: _safeStr(data, 'dob') != '' && _safeStr(data, 'dob').length > 10 ? _safeStr(data, 'dob').substring(0, 10) : _safeStr(data, 'dob', fallback: 'Not specified'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.access_time_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('birth_time'),
                          value: _safeStr(data, 'birthTime', fallback: 'Not specified'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.place_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('birth_place'),
                          value: _safeStr(data, 'birthPlace', fallback: 'Not specified'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.star_border_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('manglik_status'),
                          value: _safeStr(data, 'manglikStatus', fallback: 'Not specified'),
                        )),
                      ],
                    ),''',
'''                    _buildResponsiveGrid(context, [
                      _bentoCard(
                        icon: Icons.calendar_today_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('date_of_birth'),
                        value: _safeStr(data, 'dob') != '' && _safeStr(data, 'dob').length > 10 ? _safeStr(data, 'dob').substring(0, 10) : _safeStr(data, 'dob', fallback: 'Not specified'),
                      ),
                      _bentoCard(
                        icon: Icons.access_time_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('birth_time'),
                        value: _safeStr(data, 'birthTime', fallback: 'Not specified'),
                      ),
                      _bentoCard(
                        icon: Icons.place_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('birth_place'),
                        value: _safeStr(data, 'birthPlace', fallback: 'Not specified'),
                      ),
                      _bentoCard(
                        icon: Icons.star_border_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('manglik_status'),
                        value: _safeStr(data, 'manglikStatus', fallback: 'Not specified'),
                      ),
                    ]),'''
  );

  file.writeAsStringSync(content);
}
