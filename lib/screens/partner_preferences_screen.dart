import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_textfield.dart';

class PartnerPreferencesScreen extends StatefulWidget {
  const PartnerPreferencesScreen({super.key});

  @override
  State<PartnerPreferencesScreen> createState() => _PartnerPreferencesScreenState();
}

class _PartnerPreferencesScreenState extends State<PartnerPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Form State
  RangeValues _ageRange = const RangeValues(18, 50);
  String _maritalStatus = 'Any';
  String _education = 'Any';
  String _professionSector = 'Any';
  final _cityController = TextEditingController();

  final List<String> _maritalOptions = ['Any', 'Never Married', 'Divorced', 'Widowed'];
  final List<String> _educationOptions = ['Any', 'Graduate', 'Postgraduate', 'Doctorate', 'High School'];
  final List<String> _professionOptions = ['Any', 'Corporate Job', 'Business Owner', 'Government', 'Not Working'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      final data = provider.myProfile?['partnerPreferences'] as Map<String, dynamic>?;
      if (data != null) {
        setState(() {
          final minAge = (data['minAge'] as num?)?.toDouble() ?? 18.0;
          final maxAge = (data['maxAge'] as num?)?.toDouble() ?? 50.0;
          _ageRange = RangeValues(minAge, maxAge);
          _maritalStatus = data['maritalStatus'] ?? 'Any';
          _education = data['education'] ?? 'Any';
          _professionSector = data['professionSector'] ?? 'Any';
          _cityController.text = data['city'] ?? 'Any';
        });
      }
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _savePreferences() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = Provider.of<AuthProvider>(context, listen: false);

    final prefsPayload = {
      'partnerPreferences': {
        'minAge': _ageRange.start.round(),
        'maxAge': _ageRange.end.round(),
        'maritalStatus': _maritalStatus,
        'education': _education,
        'professionSector': _professionSector,
        'city': _cityController.text.trim().isEmpty ? 'Any' : _cityController.text.trim(),
      }
    };

    final success = await provider.updateProfileSettings(prefsPayload);
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Preferences updated successfully!' : 'Failed to save preferences.'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'PARTNER PREFERENCES',
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            color: AppTheme.textCarbon,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.cardWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textCarbon, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isSaving
            ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  physics: const BouncingScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ideal Partner Match Rules',
                            style: GoogleFonts.cinzel(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentGold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Configure the rules used to compute your compatibility scores and filter Perfect Bandhan matches.',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32.0),

                          // 1. Age Range Slider
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'PREFERRED AGE RANGE',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textMuted,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              Text(
                                '${_ageRange.start.round()} - ${_ageRange.end.round()} Years',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentGold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          RangeSlider(
                            values: _ageRange,
                            min: 18,
                            max: 60,
                            divisions: 42,
                            activeColor: AppTheme.accentGold,
                            inactiveColor: AppTheme.glassBorderColor,
                            labels: RangeLabels(
                              '${_ageRange.start.round()}',
                              '${_ageRange.end.round()}',
                            ),
                            onChanged: (values) {
                              setState(() => _ageRange = values);
                            },
                          ),
                          const SizedBox(height: 24.0),

                          // 2. Marital Status Options
                          _buildChipSelector(
                            label: 'PREFERRED MARITAL STATUS',
                            options: _maritalOptions,
                            selected: _maritalStatus,
                            onSelected: (val) => setState(() => _maritalStatus = val),
                          ),
                          const SizedBox(height: 24.0),

                          // 3. Education Preference
                          _buildChipSelector(
                            label: 'MINIMUM EDUCATION REQUIREMENT',
                            options: _educationOptions,
                            selected: _education,
                            onSelected: (val) => setState(() => _education = val),
                          ),
                          const SizedBox(height: 24.0),

                          // 4. Profession Sector Preference
                          _buildChipSelector(
                            label: 'PREFERRED PROFESSION SECTOR',
                            options: _professionOptions,
                            selected: _professionSector,
                            onSelected: (val) => setState(() => _professionSector = val),
                          ),
                          const SizedBox(height: 24.0),

                          // 5. Preferred City
                          CustomTextField(
                            labelText: 'PREFERRED CITY',
                            hintText: 'E.g., Mumbai, Pune, or "Any"',
                            prefixIcon: Icons.location_city_rounded,
                            controller: _cityController,
                          ),
                          const SizedBox(height: 40.0),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.textCarbon,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _savePreferences,
                              child: Text(
                                'SAVE PREFERENCES',
                                style: GoogleFonts.cinzel(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildChipSelector({
    required String label,
    required List<String> options,
    required String selected,
    required Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppTheme.textMuted,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: options.map((opt) {
            final isSelected = selected == opt;
            return ChoiceChip(
              label: Text(opt),
              selected: isSelected,
              onSelected: (sel) {
                if (sel) onSelected(opt);
              },
              backgroundColor: AppTheme.glassColor,
              selectedColor: AppTheme.accentGold.withValues(alpha: 0.15),
              labelStyle: GoogleFonts.montserrat(
                color: isSelected ? AppTheme.accentGold : AppTheme.textCarbon,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                  color: isSelected ? AppTheme.accentGold : AppTheme.glassBorderColor,
                  width: 0.5,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
