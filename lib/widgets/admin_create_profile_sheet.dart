import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/custom_textfield.dart';

class AdminCreateProfileSheet extends StatefulWidget {
  const AdminCreateProfileSheet({super.key});

  @override
  State<AdminCreateProfileSheet> createState() => _AdminCreateProfileSheetState();
}

class _AdminCreateProfileSheetState extends State<AdminCreateProfileSheet> {
  int _currentStep = 1; // 1 = Phone, 2 = OTP, 3 = Password, 4 = Success
  
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      setState(() => _errorMessage = 'Enter a valid 10-digit mobile number.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    bool success = await authProv.sendOtp(phone, reset: false);
    
    setState(() => _isLoading = false);

    if (success) {
      setState(() => _currentStep = 2);
    } else {
      setState(() => _errorMessage = authProv.errorMessage ?? 'Failed to send OTP.');
    }
  }

  Future<void> _verifyOtp() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();
    
    if (otp.isEmpty) {
      setState(() => _errorMessage = 'Enter the OTP received by the user.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    
    // We call the API directly to verifyOTP to avoid overwriting the Admin's JWT token
    // in the authProvider.
    try {
      final response = await http.post(
        Uri.parse('${AuthProvider.baseUrl}/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );
      
      final data = jsonDecode(response.body);
      setState(() => _isLoading = false);

      if (response.statusCode == 200 && data['status'] == 'success') {
        setState(() => _currentStep = 3);
      } else {
        setState(() => _errorMessage = data['message'] ?? 'Invalid OTP.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Network error verifying OTP.';
      });
    }
  }

  Future<void> _setPassword() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.post(
        Uri.parse('${AuthProvider.baseUrl}/auth/set-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );
      
      final data = jsonDecode(response.body);
      setState(() => _isLoading = false);

      if (response.statusCode == 200 && data['status'] == 'success') {
        setState(() => _currentStep = 4);
      } else {
        setState(() => _errorMessage = data['message'] ?? 'Failed to set password.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Network error setting password.';
      });
    }
  }

  void _openEditProfile() {
    Navigator.pop(context); // Close this sheet
    
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    authProv.fetchAdminUsers().then((_) {
      final user = authProv.adminUsers.firstWhere(
        (u) => u['phone'] == _phoneController.text.trim(),
        orElse: () => <String, dynamic>{},
      );
      
      if (user.isNotEmpty && mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => EditProfileSheet(adminEditUser: user),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
      ),
      padding: EdgeInsets.only(
        left: 24.0, right: 24.0, top: 24.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                height: 5, width: 40,
                decoration: BoxDecoration(color: AppTheme.glassBorderColor, borderRadius: BorderRadius.circular(2.5)),
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Create New User',
              style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textCarbon),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(_errorMessage, style: GoogleFonts.montserrat(color: Colors.red.shade800, fontSize: 13)),
              ),

            // STEP 1
            if (_currentStep == 1) ...[
              CustomTextField(
                controller: _phoneController,
                labelText: 'User Mobile Number',
                hintText: 'Enter 10-digit number',
                prefixIcon: Icons.phone_android,
                keyboardType: TextInputType.phone,
                inputFormatters: [LengthLimitingTextInputFormatter(10)],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOtp,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('SEND OTP TO USER', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],

            // STEP 2
            if (_currentStep == 2) ...[
              Text('OTP sent to +91 ${_phoneController.text}', style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _otpController,
                labelText: 'Enter OTP Received',
                hintText: 'Enter 4-digit OTP',
                prefixIcon: Icons.message,
                keyboardType: TextInputType.number,
                inputFormatters: [LengthLimitingTextInputFormatter(4)],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('VERIFY OTP', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],

            // STEP 3
            if (_currentStep == 3) ...[
              Text('OTP Verified! Set a password for this user.', style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Account Password',
                hintText: 'Enter at least 6 characters',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _setPassword,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('CREATE ACCOUNT', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],

            // STEP 4
            if (_currentStep == 4) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text('Account Created Successfully!', style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Now you can complete their profile details and upload photos.', style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _openEditProfile,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('CONTINUE TO PROFILE SETUP', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
