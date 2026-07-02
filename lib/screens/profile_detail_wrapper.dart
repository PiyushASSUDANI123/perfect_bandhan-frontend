import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_details_sheet.dart';
import 'login_screen.dart';

class ProfileDetailWrapper extends StatefulWidget {
  final String profileId;

  const ProfileDetailWrapper({super.key, required this.profileId});

  @override
  State<ProfileDetailWrapper> createState() => _ProfileDetailWrapperState();
}

class _ProfileDetailWrapperState extends State<ProfileDetailWrapper> {
  Profile? _profile;
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProfile();
    });
  }

  Future<void> _fetchProfile() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuth) {
      // Must login first
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    try {
      final profile = await auth.fetchProfileById(widget.profileId);
      if (profile != null) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
      );
    }

    if (_isError || _profile == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundLight,
          elevation: 0,
          leading: const BackButton(color: AppTheme.textCarbon),
        ),
        body: const Center(
          child: Text('Profile not found or unavailable.', style: TextStyle(color: AppTheme.textCarbon)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: ProfileDetailsSheet(profile: _profile!),
    );
  }
}
