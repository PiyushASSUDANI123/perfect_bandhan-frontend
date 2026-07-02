import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'custom_textfield.dart';
import 'premium_feedback.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _bioController;
  late TextEditingController _weightController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _professionController;
  late TextEditingController _educationController;
  late TextEditingController _companyController;
  late TextEditingController _maritalStatusController;
  
  String? _gender;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AuthProvider>(context, listen: false);
    final profile = provider.myProfile ?? {};
    
    _bioController = TextEditingController(text: profile['bio']?.toString() ?? '');
    _weightController = TextEditingController(text: profile['weight']?.toString() ?? '');
    _cityController = TextEditingController(text: profile['city']?.toString() ?? '');
    _stateController = TextEditingController(text: profile['state']?.toString() ?? '');
    _professionController = TextEditingController(text: profile['profession']?.toString() ?? '');
    _educationController = TextEditingController(text: profile['education']?.toString() ?? '');
    _companyController = TextEditingController(text: profile['company']?.toString() ?? '');
    _maritalStatusController = TextEditingController(text: profile['maritalStatus']?.toString() ?? '');
    _gender = profile['gender']?.toString();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _weightController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _professionController.dispose();
    _educationController.dispose();
    _companyController.dispose();
    _maritalStatusController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdates() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    
    final provider = Provider.of<AuthProvider>(context, listen: false);
    
    final Map<String, dynamic> payload = {
      'bio': _bioController.text.trim(),
      'weight': _weightController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'profession': _professionController.text.trim(),
      'education': _educationController.text.trim(),
      'company': _companyController.text.trim(),
      'maritalStatus': _maritalStatusController.text.trim(),
    };
    
    // Only pass gender if it's the developer account
    if (provider.phoneNumber == '9413879444' && _gender != null) {
      payload['gender'] = _gender;
    }

    final success = await provider.completeOnboarding(payload);
    
    setState(() => _isSubmitting = false);
    
    if (success && mounted) {
      await provider.fetchMyProfile(); // Refresh profile 
      if (mounted) {
        Navigator.pop(context);
        PremiumFeedback.showSuccess(
          context: context,
          title: 'Profile Updated',
          message: 'Your profile details have been successfully updated.',
        );
      }
    } else if (mounted) {
      PremiumFeedback.showError(
        context: context,
        title: 'Update Failed',
        message: provider.errorMessage ?? 'Could not update profile at this time.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    final isDeveloper = provider.phoneNumber == '9413879444';

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Update Profile',
                    style: GoogleFonts.cinzel(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textCarbon,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              if (isDeveloper) ...[
                Text(
                  'Gender (Developer Only)',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppTheme.textCarbon,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _gender,
                  dropdownColor: AppTheme.cardWhite,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.accentGold, width: 2),
                    ),
                  ),
                  items: ['Male', 'Female'].map((String val) {
                    return DropdownMenuItem(value: val, child: Text(val));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _gender = val;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
              
              CustomTextField(
                labelText: 'Bio',
                hintText: 'Tell us a bit about yourself...',
                controller: _bioController,
                prefixIcon: Icons.format_quote_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                labelText: 'Weight',
                hintText: 'e.g. 65 kg',
                controller: _weightController,
                prefixIcon: Icons.monitor_weight_rounded,
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                labelText: 'City',
                hintText: 'Current City',
                controller: _cityController,
                prefixIcon: Icons.location_city_rounded,
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                labelText: 'State',
                hintText: 'Current State',
                controller: _stateController,
                prefixIcon: Icons.map_rounded,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                labelText: 'Profession',
                hintText: 'Your job or profession',
                controller: _professionController,
                prefixIcon: Icons.work_rounded,
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                labelText: 'Company',
                hintText: 'Company name',
                controller: _companyController,
                prefixIcon: Icons.business_rounded,
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                labelText: 'Education',
                hintText: 'Highest degree',
                controller: _educationController,
                prefixIcon: Icons.school_rounded,
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                labelText: 'Marital Status',
                hintText: 'e.g. Never Married',
                controller: _maritalStatusController,
                prefixIcon: Icons.favorite_rounded,
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitUpdates,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : Text(
                        'Save Updates',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
