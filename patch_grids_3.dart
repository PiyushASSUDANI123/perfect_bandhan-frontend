import 'dart:io';

void main() {
  var file = File('lib/screens/my_profile_screen.dart');
  var content = file.readAsStringSync();

  // Family Intel
  content = content.replaceFirst(
'''                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.family_restroom_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('family_type'),
                          value: _safeStr(data, 'familyType', fallback: 'Not specified'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.groups_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('siblings'),
                          value: _safeStr(data, 'siblingsCount', fallback: '0'),
                        )),
                      ],
                    ),''',
'''                    _buildResponsiveGrid(context, [
                      _bentoCard(
                        icon: Icons.family_restroom_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('family_type'),
                        value: _safeStr(data, 'familyType', fallback: 'Not specified'),
                      ),
                      _bentoCard(
                        icon: Icons.groups_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('siblings'),
                        value: _safeStr(data, 'siblingsCount', fallback: '0'),
                      ),
                    ]),'''
  );

  content = content.replaceFirst(
'''                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.person_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('father'),
                          value: _safeStr(data, 'fatherStatus', fallback: 'Alive'),
                          subValue: _safeStr(data, 'fathersOccupation', fallback: 'Occupation not specified'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.pregnant_woman_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('mother'),
                          value: _safeStr(data, 'motherStatus', fallback: 'Alive'),
                          subValue: _safeStr(data, 'mothersOccupation', fallback: 'Occupation not specified'),
                        )),
                      ],
                    ),''',
'''                    _buildResponsiveGrid(context, [
                      _bentoCard(
                        icon: Icons.person_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('father'),
                        value: _safeStr(data, 'fatherStatus', fallback: 'Alive'),
                        subValue: _safeStr(data, 'fathersOccupation', fallback: 'Occupation not specified'),
                      ),
                      _bentoCard(
                        icon: Icons.pregnant_woman_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('mother'),
                        value: _safeStr(data, 'motherStatus', fallback: 'Alive'),
                        subValue: _safeStr(data, 'mothersOccupation', fallback: 'Occupation not specified'),
                      ),
                    ]),'''
  );

  // Career
  content = content.replaceFirst(
'''                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.work_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('profession'),
                          value: _safeStr(data, 'profession'),
                          subValue: _safeStr(data, 'company'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.school_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('education'),
                          value: _safeStr(data, 'education'),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.account_balance_wallet_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('monthly_income'),
                          value: incomeHidden ? 'Private' : _safeStr(data, 'monthlyIncome'),
                          accent: !incomeHidden,
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _bentoCard(
                          icon: Icons.badge_rounded,
                          label: Provider.of<LanguageProvider>(context).translate('job_title'),
                          value: _safeStr(data, 'jobPost', fallback: 'Not working/Self'),
                        )),
                      ],
                    ),''',
'''                    _buildResponsiveGrid(context, [
                      _bentoCard(
                        icon: Icons.work_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('profession'),
                        value: _safeStr(data, 'profession'),
                        subValue: _safeStr(data, 'company'),
                      ),
                      _bentoCard(
                        icon: Icons.school_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('education'),
                        value: _safeStr(data, 'education'),
                      ),
                      _bentoCard(
                        icon: Icons.account_balance_wallet_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('monthly_income'),
                        value: incomeHidden ? 'Private' : _safeStr(data, 'monthlyIncome'),
                        accent: !incomeHidden,
                      ),
                      _bentoCard(
                        icon: Icons.badge_rounded,
                        label: Provider.of<LanguageProvider>(context).translate('job_title'),
                        value: _safeStr(data, 'jobPost', fallback: 'Not working/Self'),
                      ),
                    ]),'''
  );

  file.writeAsStringSync(content);
}
