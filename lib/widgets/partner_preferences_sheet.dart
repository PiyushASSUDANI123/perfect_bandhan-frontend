import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class PartnerPreferencesSheet extends StatefulWidget {
  const PartnerPreferencesSheet({super.key});

  @override
  State<PartnerPreferencesSheet> createState() => _PartnerPreferencesSheetState();
}

class _PartnerPreferencesSheetState extends State<PartnerPreferencesSheet> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Form State
  RangeValues _ageRange = const RangeValues(22, 26);
  String _minHeight = "5'0\"";
  String _maxHeight = "5'10\"";
  String _country = "India";
  String _cityState = "All";
  final TextEditingController _cityController = TextEditingController(text: "All");

  String _excludeNukh = "";

  List<String> _selectedDegrees = ["Any Master's Degree", "Any Bachelor's Degree"];
  List<String> _selectedOccupations = [];
  String _minIncomeRupees = "₹ 0 and above";

  // Data lists
  final List<String> _citySuggestions = ['All', 'Rajasthan - All', 'Gujarat - All', 'Delhi - All', 'Madhya Pradesh - All', 'Maharashtra - All'];
  final List<String> _occupationOptions = ['Employed', 'Unemployed'];
  final List<String> _incomeOptions = ["₹ 0 and above", "₹ 3L and above", "₹ 5L and above", "₹ 10L and above", "₹ 20L and above"];
  final List<String> _degreeOptions = ["Any Master's Degree", "Any Bachelor's Degree", "Doctorate", "High School"];

  @override
  void initState() {
    super.initState();
    _loadExistingPreferences();
  }

  void _loadExistingPreferences() {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    final prefs = provider.myProfile?['partnerPreferences'];
    if (prefs != null) {
      if (prefs['minAge'] != null && prefs['maxAge'] != null) {
        _ageRange = RangeValues(prefs['minAge'].toDouble(), prefs['maxAge'].toDouble());
      }
      if (prefs['minHeight'] != null) _minHeight = prefs['minHeight'];
      if (prefs['maxHeight'] != null) _maxHeight = prefs['maxHeight'];
      if (prefs['country'] != null) _country = prefs['country'];
      if (prefs['state'] != null) {
        _cityState = prefs['state'];
        _cityController.text = _cityState;
      }

      if (prefs['excludeNukh'] != null) _excludeNukh = prefs['excludeNukh'];

      if (prefs['education'] != null) _selectedDegrees = List<String>.from(prefs['education']);
      if (prefs['professionSector'] != null) _selectedOccupations = List<String>.from(prefs['professionSector']);
      if (prefs['incomeRupees'] != null) _minIncomeRupees = prefs['incomeRupees'];
    }
  }

  void _nextPage() {
    if (_currentStep < 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _savePreferences();
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<AuthProvider>(context, listen: false);

    final prefs = {
      'minAge': _ageRange.start.toInt(),
      'maxAge': _ageRange.end.toInt(),
      'minHeight': _minHeight,
      'maxHeight': _maxHeight,
      'country': _country,
      'state': _cityController.text.trim(),
      'city': _cityController.text.trim(),
      'excludeNukh': _excludeNukh,
      'education': _selectedDegrees,
      'professionSector': _selectedOccupations,
      'incomeRupees': _minIncomeRupees,
    };

    final success = await provider.updatePartnerPreferences(prefs);
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences saved successfully!')));
      Navigator.pop(context, true); // Return true to indicate it was saved
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save preferences. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle and Skip button
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 16, left: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 60), // Balance the row
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false), // skip
                  child: Text(
                    'Skip',
                    style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          ),
          
          // Progress Bars (Only 2 steps now)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: List.generate(2, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 3,
                    decoration: BoxDecoration(
                      color: index <= _currentStep ? AppTheme.primaryRed : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildStep1(),
                _buildStep2(),
              ],
            ),
          ),

          // Bottom Navigation
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _prevPage,
                      child: Text(
                        'Back',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 60), // Placeholder
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isLoading ? null : _nextPage,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            _currentStep == 1 ? 'Save >' : 'Next >',
                            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Let's start with Partner's Basic Details",
            style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textCarbon),
          ),
          const SizedBox(height: 32),
          
          _buildLabel("Partner's Age"),
          Text("${_ageRange.start.round()}-${_ageRange.end.round()} Years", style: GoogleFonts.montserrat(fontSize: 16, color: AppTheme.textCarbon)),
          RangeSlider(
            values: _ageRange,
            min: 18,
            max: 70,
            activeColor: AppTheme.primaryRed,
            inactiveColor: Colors.grey.shade200,
            onChanged: (val) => setState(() => _ageRange = val),
          ),
          const Divider(),
          const SizedBox(height: 16),

          _buildLabel("Partner's Height"),
          Row(
            children: [
              Expanded(child: _buildDropdown(
                value: _minHeight, 
                items: ["4'0\"", "4'6\"", "5'0\"", "5'5\"", "6'0\""], 
                onChanged: (v) => setState(() => _minHeight = v!)
              )),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('to')),
              Expanded(child: _buildDropdown(
                value: _maxHeight, 
                items: ["5'0\"", "5'5\"", "5'10\"", "6'0\"", "6'5\""], 
                onChanged: (v) => setState(() => _maxHeight = v!)
              )),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),

          _buildLabel("Partner's Country"),
          _buildDropdown(
            value: _country, 
            items: ["India", "USA", "UK", "Canada", "Australia", "UAE"], 
            onChanged: (v) => setState(() => _country = v!)
          ),
          const Divider(),
          const SizedBox(height: 16),

          _buildLabel("Partner's City/State"),
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              hintText: 'e.g. All, Rajasthan, Delhi',
              border: InputBorder.none,
              isDense: true,
            ),
            style: GoogleFonts.montserrat(fontSize: 16, color: AppTheme.textCarbon),
          ),
          const Divider(),
          const SizedBox(height: 8),
          Text("Suggested City/State(s) to add:", style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _citySuggestions.map((c) => _buildSuggestionChip(c, () {
              setState(() {
                _cityController.text = c;
              });
            })).toList(),
          ),
          const SizedBox(height: 24),

          _buildLabel("Exclude Nukh"),
          TextFormField(
            initialValue: _excludeNukh,
            decoration: const InputDecoration(
              hintText: 'e.g. Rohira, Ahuja (Comma separated)',
              border: InputBorder.none,
              isDense: true,
            ),
            style: GoogleFonts.montserrat(fontSize: 16, color: AppTheme.textCarbon),
            onChanged: (v) => setState(() => _excludeNukh = v),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Partner's Education & Occupation",
            style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textCarbon),
          ),
          const SizedBox(height: 32),
          
          _buildLabel("Partner's Highest Degree"),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _degreeOptions.map((d) => _buildFilterChip(
              d, 
              _selectedDegrees.contains(d), 
              (sel) {
                setState(() {
                  if (sel) { _selectedDegrees.add(d); } else { _selectedDegrees.remove(d); }
                });
              }
            )).toList(),
          ),
          const Divider(),
          const SizedBox(height: 24),

          _buildLabel("Partner's Occupation"),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _occupationOptions.map((o) => _buildFilterChip(
              o, 
              _selectedOccupations.contains(o), 
              (sel) {
                setState(() {
                  if (sel) { _selectedOccupations.add(o); } else { _selectedOccupations.remove(o); }
                });
              }
            )).toList(),
          ),
          const Divider(),
          const SizedBox(height: 24),

          _buildLabel("Partner's Income (₹)"),
          _buildDropdown(
            value: _minIncomeRupees, 
            items: _incomeOptions, 
            onChanged: (v) => setState(() => _minIncomeRupees = v!)
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required void Function(String?) onChanged}) {
    // Ensure value exists in items to prevent DropdownButton error
    final safeValue = items.contains(value) ? value : items.first;
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: safeValue,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textMuted),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: GoogleFonts.montserrat(fontSize: 16)))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSuggestionChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.textMuted)),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade300)),
      onPressed: onTap,
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, Function(bool) onSelected) {
    return FilterChip(
      label: Text(label + (isSelected ? ' ✓' : ' +'), style: GoogleFonts.montserrat(
        fontSize: 13, 
        color: isSelected ? AppTheme.primaryRed : AppTheme.textMuted,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal
      )),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primaryRed.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), 
        side: BorderSide(color: isSelected ? AppTheme.primaryRed : Colors.grey.shade300)
      ),
      showCheckmark: false,
    );
  }
}
