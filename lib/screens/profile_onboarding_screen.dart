import '../utils/image_picker_helper.dart';

import 'dart:convert';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../utils/image_picker_helper.dart';
import '../utils/image_picker_helper.dart';
import '../utils/image_picker_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/custom_textfield.dart';
import '../utils/india_locations.dart';
import '../widgets/premium_feedback.dart';
import 'congratulations_screen.dart';
import 'dashboard_screen.dart';
import '../utils/image_picker_helper.dart';
import '../utils/storage_helper.dart';
import '../widgets/animated_field_reveal.dart';

class ProfileOnboardingScreen extends StatefulWidget {
  const ProfileOnboardingScreen({super.key});

  @override
  State<ProfileOnboardingScreen> createState() => _ProfileOnboardingScreenState();
}

class _ProfileOnboardingScreenState extends State<ProfileOnboardingScreen> {
  int _currentStep = 0;
  final int _totalSteps = 10;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  
  bool _acceptedTerms = false;
  bool _acceptedInfoTrue = false;
  bool _isAiLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentAuthProvider == 'google') {
      _emailController.text = auth.googleEmail ?? '';
    } else {
      _mobileNumberController.text = auth.phoneNumber ?? '';
    }
    
    _loadOnboardingProgress().then((_) {
      if (auth.currentAuthProvider == 'google' && _emailController.text.isEmpty) {
        _emailController.text = auth.googleEmail ?? '';
      } else if (auth.currentAuthProvider != 'google' && _mobileNumberController.text.isEmpty) {
        _mobileNumberController.text = auth.phoneNumber ?? '';
      }
      _attachFieldListeners();
    });
  }

  Future<void> _saveOnboardingProgress() async {
    try {
      final Map<String, dynamic> data = {
        'currentStep': _currentStep,
        'profileFor': 'Self',
        'gender': _gender,
        'mobileNumber': _mobileNumberController.text,
        'whatsappNumber': _whatsappNumberController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'surname': _surnameController.text,
        'email': _emailController.text,
        'complexion': _complexion,
        'dob': _dob?.toIso8601String(),
        'calculatedAge': _calculatedAge,
        'height': _height,
        'city': _cityController.text,
        'state': _selectedState,
        'district': _selectedDistrict,
        'properAddress': _properAddressController.text,
        'maritalStatus': _maritalStatus,
        'degrees': _degreeControllers.map((c) => c.text).toList(),
        'profession': _profession,
        'monthlyIncome': _monthlyIncomeController.text,
        'yearlyIncome': _yearlyIncomeController.text,
        'nukh': _nukhController.text,
        'company': _companyController.text,
        'jobPost': _jobPostController.text,
        'fathersOccupation': _fathersOccupationController.text,
        'weight': _weightController.text,
        'fatherStatus': _fatherStatus,
        'fatherName': _fatherNameController.text,
        'motherStatus': _motherStatus,
        'motherName': _motherNameController.text,
        'mothersOccupation': _mothersOccupationController.text,
        'siblingsCount': _siblingsCountController.text,
        'siblingsDetails': _siblingsDetailsController.text,
        'sindhiType': _sindhiType,
        'otherSindhiType': _otherSindhiTypeController.text,
        'ownHouse': _ownHouse,
        'housePhoto': _housePhoto,
        'hasDisability': _hasDisability,
        'disabilityType': _disabilityType,
        'otherDisability': _otherDisabilityController.text,
        'bio': _bioController.text,
        'uploadedPhotos': _uploadedPhotos,
        'requirements': _requirementsController.text,
        'whatWeProvide': _whatWeProvideController.text,
        'manglikStatus': _manglikStatus,
        'otherGrah': _otherGrahController.text,
        'medicalFit': _medicalFit,
        'medicalIssue': _medicalIssueController.text,
        'liveWithFamily': _liveWithFamily,
        'liveWithWhom': _liveWithWhomController.text,
        'aboutFamily': _aboutFamilyController.text,
      };
      await AppStorage.save('onboarding_progress', jsonEncode(data));
    } catch (e) {
      debugPrint('[Save Progress Error]: $e');
    }
  }

  Future<void> _loadOnboardingProgress() async {
    try {
      final String? rawData = await AppStorage.get('onboarding_progress');
      if (rawData == null) return;
      final Map<String, dynamic> data = jsonDecode(rawData);
      setState(() {
        _currentStep = data['currentStep'] ?? 0;
        _gender = data['gender'];
        _mobileNumberController.text = data['mobileNumber'] ?? '';
        _whatsappNumberController.text = data['whatsappNumber'] ?? '';
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _surnameController.text = data['surname'] ?? '';
        _emailController.text = data['email'] ?? '';
        _complexion = data['complexion'];
        if (data['dob'] != null) {
          _dob = DateTime.parse(data['dob']);
        }
        _calculatedAge = data['calculatedAge'];
        _height = data['height'];
        _cityController.text = data['city'] ?? '';
        _selectedState = data['state'];
        _selectedDistrict = data['district'];
        _properAddressController.text = data['properAddress'] ?? '';
        _maritalStatus = data['maritalStatus'];

        final List<dynamic>? degreesList = data['degrees'];
        if (degreesList != null && degreesList.isNotEmpty) {
          _degreeControllers.clear();
          for (var deg in degreesList) {
            _degreeControllers.add(TextEditingController(text: deg.toString()));
          }
        }

        _profession = data['profession'];
        _monthlyIncomeController.text = data['monthlyIncome'] ?? '';
        _yearlyIncomeController.text = data['yearlyIncome'] ?? '';
        _nukhController.text = data['nukh'] ?? '';
        _companyController.text = data['company'] ?? '';
        _jobPostController.text = data['jobPost'] ?? '';
        _fathersOccupationController.text = data['fathersOccupation'] ?? '';
        _weightController.text = data['weight'] ?? '';
        _fatherStatus = data['fatherStatus'] ?? 'Alive';
        _fatherNameController.text = data['fatherName'] ?? '';
        _motherStatus = data['motherStatus'] ?? 'Alive';
        _motherNameController.text = data['motherName'] ?? '';
        _mothersOccupationController.text = data['mothersOccupation'] ?? '';
        _siblingsCountController.text = data['siblingsCount'] ?? '0';
        _siblingsDetailsController.text = data['siblingsDetails'] ?? '';
        _sindhiType = data['sindhiType'] ?? 'Sindhi Hindu';
        _otherSindhiTypeController.text = data['otherSindhiType'] ?? '';
        _ownHouse = data['ownHouse'];
        _housePhoto = data['housePhoto'];
        _hasDisability = data['hasDisability'];
        _disabilityType = data['disabilityType'];
        _otherDisabilityController.text = data['otherDisability'] ?? '';
        _bioController.text = data['bio'] ?? '';

        final List<dynamic>? photos = data['uploadedPhotos'];
        if (photos != null) {
          for (int i = 0; i < _uploadedPhotos.length && i < photos.length; i++) {
            _uploadedPhotos[i] = photos[i];
          }
        }

        _requirementsController.text = data['requirements'] ?? '';
        _whatWeProvideController.text = data['whatWeProvide'] ?? '';
        _manglikStatus = data['manglikStatus'] ?? 'Not Manglik';
        _otherGrahController.text = data['otherGrah'] ?? '';
        _medicalFit = data['medicalFit'] ?? 'Yes';
        _medicalIssueController.text = data['medicalIssue'] ?? '';
        _liveWithFamily = data['liveWithFamily'] ?? 'Yes';
        _liveWithWhomController.text = data['liveWithWhom'] ?? '';
        _aboutFamilyController.text = data['aboutFamily'] ?? '';
      });
    } catch (e) {
      debugPrint('[Load Progress Error]: $e');
    }
  }

  Future<void> _clearOnboardingProgress() async {
    try {
      await AppStorage.delete('onboarding_progress');
    } catch (e) {
      debugPrint('[Clear Progress Error]: $e');
    }
  }

  void _attachFieldListeners() {
    _mobileNumberController.addListener(_saveOnboardingProgress);
    _whatsappNumberController.addListener(_saveOnboardingProgress);
    _firstNameController.addListener(_saveOnboardingProgress);
    _lastNameController.addListener(_saveOnboardingProgress);
    _surnameController.addListener(_saveOnboardingProgress);
    _emailController.addListener(_saveOnboardingProgress);
    _cityController.addListener(_saveOnboardingProgress);
    _properAddressController.addListener(_saveOnboardingProgress);
    _monthlyIncomeController.addListener(_saveOnboardingProgress);
    _yearlyIncomeController.addListener(_saveOnboardingProgress);
    _nukhController.addListener(_saveOnboardingProgress);
    _companyController.addListener(_saveOnboardingProgress);
    _jobPostController.addListener(_saveOnboardingProgress);
    _fathersOccupationController.addListener(_saveOnboardingProgress);
    _weightController.addListener(_saveOnboardingProgress);
    _mothersOccupationController.addListener(_saveOnboardingProgress);
    _siblingsCountController.addListener(_saveOnboardingProgress);
    _siblingsDetailsController.addListener(_saveOnboardingProgress);
    _otherSindhiTypeController.addListener(_saveOnboardingProgress);
    _otherDisabilityController.addListener(_saveOnboardingProgress);
    _bioController.addListener(_saveOnboardingProgress);
    _requirementsController.addListener(_saveOnboardingProgress);
    _whatWeProvideController.addListener(_saveOnboardingProgress);
    _otherGrahController.addListener(_saveOnboardingProgress);
    _medicalIssueController.addListener(_saveOnboardingProgress);
    _liveWithWhomController.addListener(_saveOnboardingProgress);
    _aboutFamilyController.addListener(_saveOnboardingProgress);

    for (var controller in _degreeControllers) {
      controller.addListener(_saveOnboardingProgress);
    }
  }

  void _updateOnboardingState(VoidCallback callback) {
    if (!mounted) return;
    setState(callback);
    _saveOnboardingProgress();
  }

  // Form keys for individual steps
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();
  final _step5Key = GlobalKey<FormState>();
  // --- Phase 1: Core Identity Fields ---
  String? _gender;      // Male, Female
  final _mobileNumberController = TextEditingController();
  final _whatsappNumberController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController(); // Also acts as surname
  final _surnameController = TextEditingController();  // Explicit Surname field
  final _emailController = TextEditingController();
  String? _complexion; // Fair, Very Fair, Wheatish, Dark

  // --- Phase 2: Dealbreakers Fields ---
  DateTime? _dob;
  int? _calculatedAge;
  String? _height; // feet/inches
  final _cityController = TextEditingController();
  String? _selectedState;
  String? _selectedDistrict;
  final _properAddressController = TextEditingController();
  String? _maritalStatus; // Never Married, Divorced, Awaiting Divorce, Widowed

  // --- Phase 3: Sindhi Practicality ---
  final _educationController = TextEditingController();
  final List<TextEditingController> _degreeControllers = [TextEditingController()];
  String? _profession; // Business, Corporate Job, Government Job, Not Working
  final _monthlyIncomeController = TextEditingController();
  final _yearlyIncomeController = TextEditingController();
  final _nukhController = TextEditingController(); // Sindhi Surname/Nukh
  final _companyController = TextEditingController();
  final _jobPostController = TextEditingController();
  final _fathersOccupationController = TextEditingController();
  
  // House details
  String? _ownHouse; // Yes, No
  String? _housePhoto; // Base64 encoding of house image

  // Disability check
  String? _hasDisability; // Yes, No
  String? _disabilityType; // Physical, Visual, Hearing, Cognitive, Other
  final _otherDisabilityController = TextEditingController();

  final _bioController = TextEditingController();

  // --- New additions ---
  String _manglikStatus = 'Not Manglik';
  final _otherGrahController = TextEditingController();
  
  String _medicalFit = 'Yes';
  final _medicalIssueController = TextEditingController();
  
  String _liveWithFamily = 'Yes';
  final _liveWithWhomController = TextEditingController();
  
  final _aboutFamilyController = TextEditingController();

  // --- New physical & family background details ---
  final _weightController = TextEditingController();
  String _fatherStatus = 'Alive'; // Alive, Passed Away
  final _fatherNameController = TextEditingController();
  String _motherStatus = 'Alive'; // Alive, Passed Away
  final _motherNameController = TextEditingController();
  final _mothersOccupationController = TextEditingController();
  final _siblingsCountController = TextEditingController(text: '0');
  final _siblingsDetailsController = TextEditingController();
  String _sindhiType = 'Sindhi Hindu';
  final _otherSindhiTypeController = TextEditingController();

  // --- Phase 4: Photos & Requirements & Hobbies ---
  final List<String?> _uploadedPhotos = List.generate(3, (_) => null);
  final List<String> _availableHobbies = ['None', 'Reading', 'Traveling', 'Cooking', 'Music', 'Sports', 'Photography', 'Art', 'Dance', 'Movies', 'Gaming', 'Other'];
  List<String> _selectedHobbies = [];
  final _otherHobbiesController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _whatWeProvideController = TextEditingController();
  bool _hasShownPhotoGuide = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _mobileNumberController.dispose();
    _whatsappNumberController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _properAddressController.dispose();
    _educationController.dispose();
    for (var c in _degreeControllers) {
      c.dispose();
    }
    _monthlyIncomeController.dispose();
    _yearlyIncomeController.dispose();
    _nukhController.dispose();
    _companyController.dispose();
    _jobPostController.dispose();
    _fathersOccupationController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _weightController.dispose();
    _mothersOccupationController.dispose();
    _siblingsCountController.dispose();
    _siblingsDetailsController.dispose();
    _otherSindhiTypeController.dispose();
    _otherDisabilityController.dispose();
    _bioController.dispose();
    _requirementsController.dispose();
    _whatWeProvideController.dispose();
    _otherGrahController.dispose();
    _medicalIssueController.dispose();
    _liveWithWhomController.dispose();
    _aboutFamilyController.dispose();
    super.dispose();
  }



  // Calculate age from DOB
  void _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    _updateOnboardingState(() {
      _dob = birthDate;
      _calculatedAge = age;
    });
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 22)), // Default 22 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // At least 18 yrs
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentGold,
              onPrimary: Colors.black,
              surface: AppTheme.cardGray,
              onSurface: AppTheme.textCarbon,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _calculateAge(picked);
    }
  }

  Future<void> _pickAndCompressPhoto(int index, ImageSource source) async {
    try {
      final Uint8List? originalBytes = await selectImage();
      if (originalBytes == null) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading image...'),
            duration: Duration(seconds: 1),
            backgroundColor: AppTheme.accentGold,
          ),
        );
      }

      late final Uint8List finalBytes;
      late final String sizeInfo;

      if (kIsWeb) {
        // flutter_image_compress is NOT supported on web.
        // image_picker already constrains dimensions via maxWidth/maxHeight.
        // We encode the raw bytes directly — still far smaller than the
        // original HEIC/RAW file the browser received.
        finalBytes = originalBytes;
        sizeInfo = '${(originalBytes.length / 1024).round()}KB (web)';
      } else {
        // Native path: compress on-device before uploading
        final Uint8List compressedBytes = await FlutterImageCompress.compressWithList(
          originalBytes,
          minWidth: 1080,
          minHeight: 1080,
          quality: 80,
        );
        finalBytes = compressedBytes;
        sizeInfo =
            '${(originalBytes.length / 1024).round()}KB → ${(compressedBytes.length / 1024).round()}KB';
      }

      final String base64Image = base64Encode(finalBytes);
      final String dataUri = 'data:image/jpeg;base64,$base64Image';

      setState(() {
        _uploadedPhotos[index] = dataUri;
      });
      _saveOnboardingProgress();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo loaded! ($sizeInfo)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('[Compress Error] pick/compress failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image selection failed: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF453A),
          ),
        );
      }
    }
  }

  Future<void> _pickHousePhoto(ImageSource source) async {
    try {
      final Uint8List? originalBytes = await selectImage();
      if (originalBytes == null) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading house image...'),
            duration: Duration(seconds: 1),
            backgroundColor: AppTheme.accentGold,
          ),
        );
      }

      late final Uint8List finalBytes;
      late final String sizeInfo;

      if (kIsWeb) {
        finalBytes = originalBytes;
        sizeInfo = '${(originalBytes.length / 1024).round()}KB (web)';
      } else {
        final Uint8List compressedBytes = await FlutterImageCompress.compressWithList(
          originalBytes,
          minWidth: 1080,
          minHeight: 1080,
          quality: 80,
        );
        finalBytes = compressedBytes;
        sizeInfo = '${(originalBytes.length / 1024).round()}KB → ${(compressedBytes.length / 1024).round()}KB';
      }

      final String base64Image = base64Encode(finalBytes);
      final String dataUri = 'data:image/jpeg;base64,$base64Image';

      setState(() {
        _housePhoto = dataUri;
      });
      _saveOnboardingProgress();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('House photo loaded! ($sizeInfo)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('[House Photo Error] pick/compress failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image selection failed: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF453A),
          ),
        );
      }
    }
  }

  void _simulateHousePhotoUpload() {
    if (kIsWeb) {
      _pickHousePhoto(ImageSource.gallery);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppTheme.accentGold),
                title: Text('Take Photo (Camera)', style: GoogleFonts.montserrat(color: AppTheme.textCarbon)),
                onTap: () {
                  Navigator.pop(context);
                  _pickHousePhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppTheme.accentGold),
                title: Text('Choose from Gallery', style: GoogleFonts.montserrat(color: AppTheme.textCarbon)),
                onTap: () {
                  Navigator.pop(context);
                  _pickHousePhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Photo upload selector
  void _simulatePhotoUpload(int index) {
    // On web, camera is not reliably supported — skip the bottom sheet and
    // go straight to the file-picker (gallery/file system).
    if (kIsWeb) {
      _pickAndCompressPhoto(index, ImageSource.gallery);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppTheme.accentGold),
                title: Text('Take Photo (Camera)', style: GoogleFonts.montserrat(color: AppTheme.textCarbon)),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndCompressPhoto(index, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppTheme.accentGold),
                title: Text('Choose from Gallery', style: GoogleFonts.montserrat(color: AppTheme.textCarbon)),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndCompressPhoto(index, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  void _scrollToTop() {
    if (_scrollController.hasClients) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }
  }

  void _showErrorSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(msg, style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final double progress = (_pageController.hasClients && _pageController.page != null) 
        ? (_pageController.page! + 1) / _totalSteps 
        : (_currentStep + 1) / _totalSteps;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: AppTheme.accentGold, size: 18),
                      onPressed: _prevStep,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 8),
                  Text(
                    'STEP ${_currentStep + 1} OF $_totalSteps',
                    style: GoogleFonts.cinzel(
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (_currentStep == 6 || _currentStep == 8)
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                          _scrollToTop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.accentGold),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Skip',
                            style: GoogleFonts.montserrat(
                              color: AppTheme.accentGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.montserrat(
                      color: AppTheme.textCarbon,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.glassBorderColor,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
              minHeight: 6,
            ),
          ),

          if (_isSubmitting)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: AppTheme.backgroundBlack.withValues(alpha: 0.6),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: AppTheme.accentGold),
                        const SizedBox(height: 16),
                        Text('Saving Profile...', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildProgressIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (idx) {
                      setState(() {
                        _currentStep = idx;
                      });
                      if (idx == 9 && !_hasShownPhotoGuide) {
                        _hasShownPhotoGuide = true;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _showPhotoGuidelinesDialog();
                        });
                      }
                    },
                    children: [
                      _buildPage1(),
                      _buildPage2(),
                      _buildPage3(),
                      _buildPage4(),
                      _buildPage5(),
                      _buildPage6(),
                      _buildPage7(),
                      _buildPage8(),
                      _buildPage9(),
                      _buildPage10(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isAiLoading)
            Container(
              color: AppTheme.backgroundBlack.withValues(alpha: 0.9),
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text('PB', style: GoogleFonts.cinzel(fontSize: 72, color: AppTheme.accentGold, fontWeight: FontWeight.bold, letterSpacing: 4.0)),
                   const SizedBox(height: 32),
                   const CircularProgressIndicator(color: AppTheme.accentGold),
                   const SizedBox(height: 24),
                   Text(Provider.of<LanguageProvider>(context).translate('bio_ai_loading') ?? 'PB AI Generating Bio...', style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 16)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSaveAndContinueButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 40.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                shadowColor: AppTheme.accentGold.withValues(alpha: 0.4),
              ),
              onPressed: _nextStep,
              child: Text(
                'Save & Continue',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (_currentStep > 0 && _currentStep < 9)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    if (_currentStep < 9) {
                      _currentStep++;
                      _scrollToTop();
                    }
                  });
                },
                child: Text(
                  'Skip for now',
                  style: GoogleFonts.montserrat(
                    color: AppTheme.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Lottie.asset(
              'assets/animations/identity.json', // Identity animation placeholder
              height: 150,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.badge_outlined, size: 80, color: AppTheme.accentGold),
            ),
          ),
          const SizedBox(height: 16),
          Text('Identity Details', style: GoogleFonts.cinzel(fontSize: 24, color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Text('I am looking for a', style: GoogleFonts.cinzel(fontSize: 16, color: AppTheme.accentGold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _gender = 'Male'),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _gender == 'Male' ? AppTheme.accentGold.withOpacity(0.1) : AppTheme.glassColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _gender == 'Male' ? AppTheme.accentGold : AppTheme.glassBorderColor),
                    ),
                    alignment: Alignment.center,
                    child: Text('Male', style: GoogleFonts.montserrat(color: _gender == 'Male' ? AppTheme.accentGold : AppTheme.textCarbon, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _gender = 'Female'),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _gender == 'Female' ? AppTheme.accentGold.withOpacity(0.1) : AppTheme.glassColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _gender == 'Female' ? AppTheme.accentGold : AppTheme.glassBorderColor),
                    ),
                    alignment: Alignment.center,
                    child: Text('Female', style: GoogleFonts.montserrat(color: _gender == 'Female' ? AppTheme.accentGold : AppTheme.textCarbon, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedFieldReveal(
            isVisible: _gender != null,
            child: CustomTextField(
              controller: _firstNameController,
              labelText: 'First Name',
              hintText: 'First Name',
              prefixIcon: Icons.person_outline,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _firstNameController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _surnameController,
              labelText: 'Surname',
              hintText: 'Surname',
              prefixIcon: Icons.badge_outlined,
              onChanged: (_) => setState(() {}),
            ),
          ),
            _buildSaveAndContinueButton()
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact Details', style: GoogleFonts.cinzel(fontSize: 24, color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _emailController,
            readOnly: Provider.of<AuthProvider>(context).currentAuthProvider == 'google',
            helperText: Provider.of<AuthProvider>(context).currentAuthProvider == 'google' 
                ? 'Linked securely via Google.' 
                : 'We will send important matches and updates here.',
            labelText: 'Email Address',
            hintText: 'Email Address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
          ),
          AnimatedFieldReveal(
            isVisible: _emailController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _mobileNumberController,
              readOnly: Provider.of<AuthProvider>(context).currentAuthProvider == 'mobile' || Provider.of<AuthProvider>(context).currentAuthProvider == null,
              helperText: Provider.of<AuthProvider>(context).currentAuthProvider == 'google'
                  ? 'A valid Indian mobile number is strictly required.'
                  : 'Linked securely from login verification.',
              labelText: 'Phone Number',
              hintText: 'Phone Number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Mobile number is required';
                if (value.length != 10) return 'Must be exactly 10 digits';
                if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) return 'Enter a valid Indian mobile number (starts with 6-9)';
                if (RegExp(r'^(\d)\1{9}$').hasMatch(value)) return 'Invalid mobile number format';
                return null;
              },
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _mobileNumberController.text.trim().length >= 10,
            child: CustomTextField(
              controller: _whatsappNumberController,
          helperText: 'For direct communication with verified matches.',
              labelText: 'WhatsApp Number',
              hintText: 'WhatsApp Number',
              prefixIcon: Icons.chat_bubble_outline,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value != null && value.isNotEmpty && value.length < 10) return 'Must be exactly 10 digits';
                return null;
              },
            ),
          ),
            _buildSaveAndContinueButton()
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Location', style: GoogleFonts.cinzel(fontSize: 24, color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          Text('State', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textCarbon)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.glassColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.glassBorderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedState,
                isExpanded: true,
                hint: Text('Select State', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
                icon: const Icon(Icons.arrow_drop_down, color: AppTheme.accentGold),
                dropdownColor: AppTheme.backgroundBlack,
                items: IndiaLocations.statesAndDistricts.keys.map((String state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state, style: GoogleFonts.montserrat(color: AppTheme.textCarbon)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedState = newValue;
                    _selectedDistrict = null; // Reset district when state changes
                  });
                  _saveOnboardingProgress();
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          AnimatedFieldReveal(
            isVisible: _selectedState != null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('District', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textCarbon)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.glassColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.glassBorderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDistrict,
                      isExpanded: true,
                      hint: Text('Select District', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
                      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.accentGold),
                      dropdownColor: AppTheme.backgroundBlack,
                      items: (_selectedState != null ? IndiaLocations.statesAndDistricts[_selectedState]! : <String>[]).map((String district) {
                        return DropdownMenuItem<String>(
                          value: district,
                          child: Text(district, style: GoogleFonts.montserrat(color: AppTheme.textCarbon)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDistrict = newValue;
                        });
                        _saveOnboardingProgress();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          AnimatedFieldReveal(
            isVisible: _selectedDistrict != null,
            child: CustomTextField(
              controller: _cityController,
              labelText: 'City',
              hintText: 'City',
              prefixIcon: Icons.location_city_outlined,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _cityController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _properAddressController,
              labelText: 'Proper Address',
              hintText: 'Proper Address',
              prefixIcon: Icons.home_outlined,
              onChanged: (_) => setState(() {}),
            ),
          ),
          
          _buildSaveAndContinueButton(),
        ],
      ),
    );
  }

  Widget _buildPage4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Physical Details', style: GoogleFonts.cinzel(fontSize: 24, color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime(DateTime.now().year - 18, DateTime.now().month, DateTime.now().day),
                firstDate: DateTime(1950),
                lastDate: DateTime(DateTime.now().year - 18, DateTime.now().month, DateTime.now().day),
              );
              if (date != null) {
                setState(() {
                  _dob = date;
                  _calculatedAge = DateTime.now().year - date.year;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.glassColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: AppTheme.textMuted, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _dob != null ? "${_dob!.day}/${_dob!.month}/${_dob!.year} ($_calculatedAge yrs)" : "Select Date of Birth",
                    style: GoogleFonts.montserrat(color: _dob != null ? AppTheme.textCarbon : AppTheme.textMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedFieldReveal(
            isVisible: _dob != null,
            child: DropdownButtonFormField<String>(
              value: _height,
              hint: Text('Height', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
              decoration: _dropdownDeco(Icons.height),
              items: _generateHeights().map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
              onChanged: (v) => setState(() => _height = v),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _height != null,
            child: CustomTextField(
              controller: _weightController,
              labelText: '',
              hintText: 'Weight (kg)',
              prefixIcon: Icons.monitor_weight_outlined,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _weightController.text.trim().isNotEmpty,
            child: _buildLabeledDropdown(
            labelText: 'Complexion',
            hintText: 'Complexion',
            prefixIcon: Icons.face_outlined,
            value: _complexion,
            items: ['Very Fair', 'Fair', 'Wheatish', 'Dark'],
            onChanged: (v) => setState(() => _complexion = v),
          ),
          ),
          AnimatedFieldReveal(
            isVisible: _complexion != null,
            child: _buildLabeledDropdown(
            labelText: 'Physical Disability?',
            hintText: 'Physical Disability?',
            prefixIcon: Icons.accessible_forward_outlined,
            value: _hasDisability,
            items: ['No', 'Yes'],
            onChanged: (v) => setState(() => _hasDisability = v),
          ),
          ),
          AnimatedFieldReveal(
            isVisible: _hasDisability == 'Yes',
            child: _buildLabeledDropdown(
            labelText: 'Type of Disability',
            hintText: 'Type of Disability',
            prefixIcon: Icons.accessible_outlined,
            value: _disabilityType,
            items: ['Visual Impairment', 'Hearing Impairment', 'Locomotor Disability', 'Other'],
            onChanged: (v) => setState(() => _disabilityType = v),
          ),
          ),
          AnimatedFieldReveal(
            isVisible: _disabilityType == 'Other',
            child: CustomTextField(
              controller: _otherDisabilityController,
              labelText: '',
              hintText: Provider.of<LanguageProvider>(context).translate('other_specify') ?? 'Please specify (Other)',
              prefixIcon: Icons.info_outline,
              onChanged: (_) => setState(() {}),
            ),
          ),
            _buildSaveAndContinueButton()
        ],
      ),
    );
  }

  Widget _buildPage5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Background', style: GoogleFonts.cinzel(fontSize: 24, color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildLabeledDropdown(
            labelText: 'Marital Status',
            hintText: 'Marital Status',
            prefixIcon: Icons.favorite_outline,
            value: _maritalStatus,
            items: ['Never Married', 'Awaiting Divorce', 'Divorced', 'Widowed'],
            onChanged: (v) => setState(() => _maritalStatus = v),
          ),
          const SizedBox(height: 24),
          AnimatedFieldReveal(
            isVisible: _maritalStatus != null,
            child: _buildLabeledDropdown(
            labelText: 'Manglik Status',
            hintText: 'Manglik Status',
            prefixIcon: Icons.star_outline,
            value: _manglikStatus,
            items: ['Not Manglik', 'Manglik', 'Anshik Manglik', 'Other'],
            onChanged: (v) => setState(() => _manglikStatus = v ?? ""),
          ),
          ),
          AnimatedFieldReveal(
            isVisible: _manglikStatus == 'Other',
            child: CustomTextField(
              controller: _otherGrahController,
              labelText: '',
              hintText: Provider.of<LanguageProvider>(context).translate('other_specify') ?? 'Please specify (Other)',
              prefixIcon: Icons.star_outline,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _manglikStatus != null,
            child: _buildLabeledDropdown(
            labelText: 'Medically Fit?',
            hintText: 'Medically Fit?',
            prefixIcon: Icons.health_and_safety_outlined,
            value: _medicalFit,
            items: ['Yes', 'No'],
            onChanged: (v) => setState(() => _medicalFit = v ?? ""),
          ),
          ),
          AnimatedFieldReveal(
            isVisible: _medicalFit == 'No',
            child: CustomTextField(
              controller: _medicalIssueController,
              labelText: '',
              hintText: Provider.of<LanguageProvider>(context).translate('other_specify') ?? 'Please specify Medical Issue',
              prefixIcon: Icons.medical_information_outlined,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _medicalFit != null,
            child: _buildLabeledDropdown(
            labelText: 'Sindhi Sub-Sect',
            hintText: 'Sindhi Sub-Sect',
            prefixIcon: Icons.category_outlined,
            value: _sindhiType,
            items: ['Sindhi Hindu', 'Amil', 'Bhaiband', 'Lohana', 'Larai', 'Lasi', 'Dahri', 'Sufi', 'Other'],
            onChanged: (v) => setState(() => _sindhiType = v ?? ""),
          ),
          ),
          AnimatedFieldReveal(
            isVisible: _sindhiType == 'Other',
            child: CustomTextField(
              controller: _otherSindhiTypeController,
              labelText: '',
              hintText: Provider.of<LanguageProvider>(context).translate('other_specify') ?? 'Please specify (Other)',
              prefixIcon: Icons.group_outlined,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _sindhiType != null,
            child: CustomTextField(
              controller: _nukhController,
              labelText: '',
              hintText: 'Nukh (Gotra)',
              prefixIcon: Icons.diversity_3_outlined,
              onChanged: (_) => setState(() {}),
            ),
          ),
            _buildSaveAndContinueButton()
        ],
      ),
    );
  }

  Widget _buildPage6() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Career & Education', style: GoogleFonts.cinzel(fontSize: 24, color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ..._degreeControllers.asMap().entries.map((entry) {
            final idx = entry.key;
            final controller = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: controller,
                      labelText: 'Education ${idx + 1}',
                      hintText: 'Education ${idx + 1}',
                      prefixIcon: Icons.school_outlined,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  if (idx > 0)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _degreeControllers.removeAt(idx);
                        });
                      },
                    ),
                ],
              ),
            );
          }),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _degreeControllers.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add, color: AppTheme.accentGold),
              label: Text(
                Provider.of<LanguageProvider>(context).translate('add_degree') ?? '+ Add Another Degree',
                style: GoogleFonts.montserrat(color: AppTheme.accentGold, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedFieldReveal(
            isVisible: _degreeControllers.isNotEmpty && _degreeControllers[0].text.trim().isNotEmpty,
            child: _buildLabeledDropdown(
            labelText: 'Profession',
            hintText: 'Profession',
            prefixIcon: Icons.work_outline,
            value: _profession,
            items: ['Private Company', 'Government Job', 'Business/Self-Employed', 'Not Working'],
            onChanged: (v) => setState(() => _profession = v),
          ),
          ),
          AnimatedFieldReveal(
            isVisible: _profession != null && _profession != 'Not Working',
            child: CustomTextField(
              controller: _companyController,
              labelText: 'Company Name',
              hintText: 'Company Name',
              prefixIcon: Icons.business_outlined,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _profession != null && _profession != 'Not Working' && _companyController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _jobPostController,
          helperText: 'Be specific (e.g. Senior Software Engineer)',
              labelText: 'Job Title / Designation',
              hintText: 'Job Title / Designation',
              prefixIcon: Icons.badge_outlined,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _profession != null && _profession != 'Not Working' && _jobPostController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _monthlyIncomeController,
          helperText: 'In Indian Rupees (INR)',
              labelText: 'Monthly Income',
              hintText: 'Monthly Income',
              prefixIcon: Icons.currency_rupee_outlined,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _monthlyIncomeController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _yearlyIncomeController,
          helperText: 'In Indian Rupees (INR) per annum',
              labelText: 'Yearly Income',
              hintText: 'Yearly Income',
              prefixIcon: Icons.account_balance_wallet_outlined,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
            _buildSaveAndContinueButton()
        ],
      ),
    );
  }

  Widget _buildPage7() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Lottie.asset(
              'assets/animations/family.json', // Family animation
              height: 150,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.family_restroom, size: 80, color: AppTheme.accentGold),
            ),
          ),
          const SizedBox(height: 16),
          Text('Family Structure', style: GoogleFonts.cinzel(fontSize: 24, color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildLabeledDropdown(
            labelText: 'Father Status',
            hintText: 'Father Status',
            prefixIcon: Icons.person_outline,
            value: _fatherStatus,
            items: ['Alive', 'Passed Away'],
            onChanged: (v) => setState(() => _fatherStatus = v ?? ""),
          ),
          const SizedBox(height: 16),
          AnimatedFieldReveal(
            isVisible: _fatherStatus.isNotEmpty,
            child: CustomTextField(
              controller: _fatherNameController,
              labelText: 'Father Name',
              hintText: 'Father Name',
              prefixIcon: Icons.person,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _fatherNameController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _fathersOccupationController,
              labelText: 'Father\'s Occupation',
              hintText: 'Father\'s Occupation',
              prefixIcon: Icons.work_outline,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedFieldReveal(
            isVisible: _fatherStatus.isNotEmpty && _fatherNameController.text.trim().isNotEmpty && _fathersOccupationController.text.trim().isNotEmpty,
            child: _buildLabeledDropdown(
            labelText: 'Mother Status',
            hintText: 'Mother Status',
            prefixIcon: Icons.person_2_outlined,
            value: _motherStatus,
            items: ['Alive', 'Passed Away'],
            onChanged: (v) => setState(() => _motherStatus = v ?? ""),
          ),
          ),
          const SizedBox(height: 16),
          AnimatedFieldReveal(
            isVisible: _motherStatus.isNotEmpty,
            child: CustomTextField(
              controller: _motherNameController,
              labelText: 'Mother Name',
              hintText: 'Mother Name',
              prefixIcon: Icons.person_2,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _motherNameController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _mothersOccupationController,
              labelText: 'Mother\'s Occupation',
              hintText: 'Mother\'s Occupation',
              prefixIcon: Icons.work_outline,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _mothersOccupationController.text.trim().isNotEmpty || _motherNameController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _siblingsCountController,
              labelText: 'Number of Siblings',
              hintText: 'Number of Siblings',
              prefixIcon: Icons.people_outline,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _siblingsCountController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _siblingsDetailsController,
              labelText: '',
              hintText: 'Siblings Details (Married/Unmarried)',
              prefixIcon: Icons.info_outline,
              maxLines: 2,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _siblingsDetailsController.text.trim().isNotEmpty,
            child: _buildLabeledDropdown(
            labelText: 'Live with Family?',
            hintText: 'Live with Family?',
            prefixIcon: Icons.home_outlined,
            value: _liveWithFamily,
            items: ['Yes', 'No'],
            onChanged: (v) => setState(() => _liveWithFamily = v ?? ""),
          ),
          ),
          AnimatedFieldReveal(
            isVisible: _liveWithFamily != null,
            child: CustomTextField(
              controller: _aboutFamilyController,
              labelText: '',
              hintText: 'About Family (Optional but recommended)',
              prefixIcon: Icons.family_restroom_outlined,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
            ),
          ),
            _buildSaveAndContinueButton()
        ],
      ),
    );
  }

  Widget _buildPage8() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assets & Hobbies', style: GoogleFonts.cinzel(fontSize: 24, color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildLabeledDropdown(
            labelText: 'Own House?',
            hintText: 'Own House?',
            prefixIcon: Icons.home_work_outlined,
            value: _ownHouse,
            items: ['Yes', 'No'],
            onChanged: (v) => setState(() => _ownHouse = v ?? ""),
          ),
          AnimatedFieldReveal(
            isVisible: _ownHouse != null,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.glassColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentGold.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _ownHouse == 'Yes' ? Icons.home_rounded : Icons.apartment_rounded,
                      color: AppTheme.accentGold,
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _ownHouse == 'Yes' 
                            ? 'Great! Having your own house is a big plus.' 
                            : 'No worries! Many prefer renting or living with family.',
                        style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _ownHouse != null,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('House/Property Photo (Optional)', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textCarbon)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: AppTheme.cardGray,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                        builder: (BuildContext context) {
                          return SafeArea(
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt_outlined, color: AppTheme.accentGold),
                                  title: Text('Take Photo (Camera)', style: GoogleFonts.montserrat(color: AppTheme.textCarbon)),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickHousePhoto(ImageSource.camera);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library_outlined, color: AppTheme.accentGold),
                                  title: Text('Choose from Gallery', style: GoogleFonts.montserrat(color: AppTheme.textCarbon)),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickHousePhoto(ImageSource.gallery);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.glassColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _housePhoto != null ? AppTheme.accentGold : AppTheme.glassBorderColor),
                        image: _housePhoto != null && _housePhoto!.startsWith('data:image/')
                            ? DecorationImage(
                                image: MemoryImage(base64Decode(_housePhoto!.split(',').last)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _housePhoto == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_a_photo_outlined, color: AppTheme.accentGold, size: 40),
                                const SizedBox(height: 8),
                                Text('Upload Photo', style: GoogleFonts.montserrat(color: AppTheme.textCarbon)),
                              ],
                            )
                          : Stack(
                              children: [
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _housePhoto = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedFieldReveal(
            isVisible: _ownHouse != null,
            child: Text('Hobbies', style: GoogleFonts.cinzel(fontSize: 16, color: AppTheme.accentGold)),
          ),
          AnimatedFieldReveal(
            isVisible: _ownHouse != null,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableHobbies.map((hobby) {
                final isSelected = _selectedHobbies.contains(hobby);
                return FilterChip(
                  label: Text(hobby, style: GoogleFonts.montserrat(color: isSelected ? Colors.black : AppTheme.textCarbon)),
                  selected: isSelected,
                  selectedColor: AppTheme.accentGold,
                  backgroundColor: AppTheme.glassColor,
                  onSelected: (val) {
                    setState(() {
                      if (hobby == 'None') {
                        if (val) {
                          _selectedHobbies.clear();
                          _selectedHobbies.add('None');
                        } else {
                          _selectedHobbies.remove('None');
                        }
                      } else {
                        _selectedHobbies.remove('None');
                        if (val) {
                          _selectedHobbies.add(hobby);
                        } else {
                          _selectedHobbies.remove(hobby);
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedFieldReveal(
            isVisible: _selectedHobbies.contains('Other'),
            child: CustomTextField(
              controller: _otherHobbiesController,
              labelText: '',
              hintText: Provider.of<LanguageProvider>(context).translate('other_specify') ?? 'Please specify (Other)',
              prefixIcon: Icons.star_outline,
              onChanged: (_) => setState(() {}),
            ),
          ),
            _buildSaveAndContinueButton()
        ],
      ),
    );
  }

  Widget _buildPage9() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Partner Preferences & Bio', style: GoogleFonts.cinzel(fontSize: 24, color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _requirementsController,
            labelText: 'Partner Requirements',
              hintText: 'Partner Requirements',
            prefixIcon: Icons.favorite_outline,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
          ),
          AnimatedFieldReveal(
            isVisible: _requirementsController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _whatWeProvideController,
              labelText: 'What We Provide',
              hintText: 'What We Provide',
              prefixIcon: Icons.handshake_outlined,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _whatWeProvideController.text.trim().isNotEmpty,
            child: _buildStep5Bio(), // Reuse the existing bio generator widget
          ),
          const SizedBox(height: 16),
          _buildSaveAndContinueButton(),
        ],
      ),
    );
  }

  void _showPhotoGuidelinesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.cardGray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You\'re Almost There!',
                style: GoogleFonts.cinzel(fontSize: 22, color: AppTheme.accentGold, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                'Upload your photos',
                style: GoogleFonts.montserrat(fontSize: 14, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              // For profile photo section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.glassBorderColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('For profile photo', style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                    ),
                    Expanded(child: Divider(color: AppTheme.glassBorderColor)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE8F5E9),
                            border: Border.all(color: Colors.green.shade300, width: 2),
                          ),
                          child: const Icon(Icons.person, size: 40, color: Colors.green),
                        ),
                        const SizedBox(height: 6),
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(height: 4),
                        Text('Add a clear,\nsolo photo', textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 11, color: AppTheme.textCarbon, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFEBEE),
                            border: Border.all(color: Colors.red.shade300, width: 2),
                          ),
                          child: const Icon(Icons.person_off, size: 40, color: Colors.red),
                        ),
                        const SizedBox(height: 6),
                        const Icon(Icons.cancel, color: Colors.red, size: 20),
                        const SizedBox(height: 4),
                        Text('No side face\nphotos', textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 11, color: AppTheme.textCarbon, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // For other photos section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.glassBorderColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('For other photos', style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                    ),
                    Expanded(child: Divider(color: AppTheme.glassBorderColor)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE8F5E9),
                            border: Border.all(color: Colors.green.shade300, width: 2),
                          ),
                          child: const Icon(Icons.family_restroom, size: 36, color: Colors.green),
                        ),
                        const SizedBox(height: 6),
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(height: 4),
                        Text('Add some\nfamily photos', textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 11, color: AppTheme.textCarbon, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE8F5E9),
                            border: Border.all(color: Colors.green.shade300, width: 2),
                          ),
                          child: const Icon(Icons.sports_tennis, size: 36, color: Colors.green),
                        ),
                        const SizedBox(height: 6),
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(height: 4),
                        Text('Show your\nlifestyle & hobbies', textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 11, color: AppTheme.textCarbon, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.burgundyButtonGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Upload Photos', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage10() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upload Photos', style: GoogleFonts.cinzel(fontSize: 24, color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildStep6Photos(), // Premium photo layout
          
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: _acceptedTerms,
                activeColor: AppTheme.accentGold,
                checkColor: Colors.black,
                onChanged: (val) {
                  setState(() {
                    _acceptedTerms = val ?? false;
                  });
                },
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: AppTheme.cardGray,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (_) => Container(
                        padding: const EdgeInsets.all(24.0),
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Terms & Conditions', style: GoogleFonts.cinzel(fontSize: 20, color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  '''Welcome to Perfect Bandhan, an exclusive Sindhi Matrimony platform. By using our platform, you agree to the following terms and conditions:

1. Eligibility
• You must be at least 18 years old (for females) or 21 years old (for males) to register.
• This platform is strictly exclusively for the Sindhi Samaj.

2. Accuracy of Information
• You agree to provide 100% true, accurate, and current information.
• Any fake, duplicate, or misleading profiles will be permanently banned without prior notice.

3. Privacy & Security
• Your photos and personal data are strictly secured and will only be shared with matches as per your privacy settings.
• You are responsible for keeping your account credentials secure.

4. Code of Conduct
• Users must communicate respectfully. Harassment, abusive language, or inappropriate behavior will result in an immediate ban.
• You will not use the platform for commercial or promotional purposes.

5. Verification and Liability
• Perfect Bandhan acts only as a bridge to connect families. We do not perform official background checks.
• Users are strongly advised to independently verify the background, credentials, and details of matches before proceeding with any matrimonial alliance.

6. Subscription & Premium
• All premium memberships and connects purchased are non-refundable.

By clicking "I Understand", you acknowledge that you have read, understood, and agreed to be bound by these Terms & Conditions. Jai Jhulelal!''',
                                  style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 13, height: 1.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold, padding: const EdgeInsets.symmetric(vertical: 16)),
                                child: Text('I Understand', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'I accept all the strict and regulated ',
                      style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.textWhite),
                      children: [
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.accentGold, decoration: TextDecoration.underline),
                        ),
                        TextSpan(
                          text: ' of Perfect Bandhan.',
                          style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.textWhite),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          CheckboxListTile(
            title: Text(
              'I accept that the provided information is 100% true. If anything is found incorrect, I am fully responsible for the consequences.',
              style: GoogleFonts.montserrat(fontSize: 12, color: AppTheme.textWhite),
            ),
            value: _acceptedInfoTrue,
            activeColor: AppTheme.accentGold,
            checkColor: Colors.black,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (val) {
              setState(() {
                _acceptedInfoTrue = val ?? false;
              });
            },
          ),
          
          const SizedBox(height: 32),
            _buildSaveAndContinueButton() // In page 10 this will trigger the final submission
        ],
      ),
    );
  }


  Widget _buildLabeledDropdown({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (value != null && value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
            child: Text(
              labelText,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textCarbon,
                letterSpacing: 0.5,
              ),
            ),
          ),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hintText, style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
          decoration: _dropdownDeco(prefixIcon),
          items: items.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.montserrat(color: AppTheme.textCarbon)))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  InputDecoration _dropdownDeco(IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: AppTheme.glassColor,
      prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: const BorderSide(color: AppTheme.glassBorderColor, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: const BorderSide(color: AppTheme.accentGold, width: 0.5),
      ),
    );
  }

  List<String> _generateHeights() {
    List<String> heights = [];
    for (int ft = 4; ft <= 7; ft++) {
      for (int inch = 0; inch < 12; inch++) {
        heights.add("$ft'$inch\"");
      }
    }
    return heights;
  }
  Future<void> _submitProfile() async {
    setState(() {
      _isSubmitting = true;
    });

    if (!_acceptedTerms || !_acceptedInfoTrue) {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorSnackBar("You must accept the Terms & Conditions and confirm your information is true.");
      return;
    }

    int nonNullPhotos = _uploadedPhotos.where((p) => p != null && p.isNotEmpty).length;
    if (nonNullPhotos == 0) {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorSnackBar("At least 1 photo is mandatory.");
      return;
    }

    final Map<String, dynamic> finalPayload = {
      'profileFor': 'Self',
      'gender': _gender,
      'phone': _mobileNumberController.text.trim(),
      'whatsappNumber': _whatsappNumberController.text.trim(),
      'firstName': _firstNameController.text.trim(),
      'lastName': _surnameController.text.trim(),
      'email': _emailController.text.trim(),
      'dob': _dob != null ? _dob!.toIso8601String() : '',
      'height': _height,
      'city': _cityController.text.trim(),
      'state': _selectedState ?? '',
      'maritalStatus': _maritalStatus,
      'education': _degreeControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).join(', '),
      'profession': _profession,
      'company': _profession == 'Not Working' ? '' : _companyController.text.trim(),
      'fathersOccupation': _fathersOccupationController.text.trim(),
      'nukh': _nukhController.text.trim(),
      'bio': _bioController.text.trim(),
      'uploadedPhotos': _uploadedPhotos,
      'hobbies': _selectedHobbies,
      'monthlyIncome': _profession == 'Not Working' ? '0' : _monthlyIncomeController.text.trim(),
      'yearlyIncome': _profession == 'Not Working' ? '0' : _yearlyIncomeController.text.trim(),
      'district': _selectedDistrict ?? '',
      'properAddress': _properAddressController.text.trim(),
      'jobPost': _profession == 'Not Working' ? '' : _jobPostController.text.trim(),
      'ownHouse': _ownHouse,
      'housePhoto': _housePhoto,
      'surname': _surnameController.text.trim(),
      'requirements': _requirementsController.text.trim(),
      'whatWeProvide': _whatWeProvideController.text.trim(),
      'physicalDisability': _hasDisability == 'No' ? 'None' : (_disabilityType == 'Other' ? _otherDisabilityController.text.trim() : _disabilityType),
      'complexion': _complexion,
      'weight': _weightController.text.trim(),
      'fatherStatus': _fatherStatus,
      'fatherName': _fatherNameController.text.trim(),
      'motherStatus': _motherStatus,
      'motherName': _motherNameController.text.trim(),
      'mothersOccupation': _mothersOccupationController.text.trim(),
      'siblingsCount': _siblingsCountController.text.trim(),
      'siblingsDetails': _siblingsDetailsController.text.trim(),
      'sindhiType': _sindhiType == 'Other' ? _otherSindhiTypeController.text.trim() : _sindhiType,
      'manglikStatus': _manglikStatus,
      'otherGrah': _manglikStatus == 'Other' ? _otherGrahController.text.trim() : '',
      'medicalFit': _medicalFit,
      'medicalIssue': _medicalFit == 'No' ? _medicalIssueController.text.trim() : '',
      'liveWithFamily': _liveWithFamily,
      'liveWithWhom': _liveWithWhomController.text.trim(),
      'aboutFamily': _aboutFamilyController.text.trim(),
    };

    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.completeOnboarding(finalPayload).then((success) {
      if (success && mounted) {
        _clearOnboardingProgress();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => CongratulationsScreen(profileData: finalPayload),
          ),
          (Route<dynamic> route) => false,
        );
      } else if (!success && mounted) {
        setState(() {
          _isSubmitting = false;
        });
        PremiumFeedback.showError(
          context: context,
          title: "Submission Failed",
          message: auth.errorMessage ?? "Failed to save profile. Please review fields and try again.",
        );
      }
    });
  }

  void _showMotivationalPopup(int step) {
    if (!mounted) return;
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    String? message;
    if (step == 2) message = lang.translate('motivational_1');
    else if (step == 5) message = lang.translate('motivational_2');
    else if (step == 7) message = lang.translate('motivational_3');
    
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.accentGold,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )
      );
    }
  }


  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_gender == null || _firstNameController.text.trim().isEmpty || _surnameController.text.trim().isEmpty) return false;
        break;
      case 1:
        if (_emailController.text.trim().isEmpty || 
            _mobileNumberController.text.trim().isEmpty || 
            _mobileNumberController.text.trim().length != 10 ||
            !RegExp(r'^[6-9]\d{9}$').hasMatch(_mobileNumberController.text.trim()) ||
            RegExp(r'^(\d)\1{9}$').hasMatch(_mobileNumberController.text.trim()) ||
            _whatsappNumberController.text.trim().length < 10) {
          return false;
        }
        break;
      case 2:
        if (_selectedState == null || _cityController.text.trim().isEmpty || _selectedDistrict == null || _properAddressController.text.trim().isEmpty) return false;
        break;
      case 3:
        if (_dob == null || _height == null || _weightController.text.trim().isEmpty || _complexion == null || _hasDisability == null) return false;
        if (_hasDisability == 'Yes' && (_disabilityType == null || (_disabilityType == 'Other' && _otherDisabilityController.text.trim().isEmpty))) return false;
        break;
      case 4:
        if (_maritalStatus == null || _manglikStatus == null || _medicalFit == null || _sindhiType == null || _nukhController.text.trim().isEmpty) return false;
        if (_manglikStatus == 'Other' && _otherGrahController.text.trim().isEmpty) return false;
        if (_medicalFit == 'No' && _medicalIssueController.text.trim().isEmpty) return false;
        if (_sindhiType == 'Other' && _otherSindhiTypeController.text.trim().isEmpty) return false;
        break;
      case 5:
        if (_degreeControllers.isEmpty || _degreeControllers[0].text.trim().isEmpty || _profession == null) return false;
        if (_profession != 'Not Working') {
          if (_companyController.text.trim().isEmpty || _jobPostController.text.trim().isEmpty) return false;
          if (_monthlyIncomeController.text.trim().isEmpty || _yearlyIncomeController.text.trim().isEmpty) return false;
        }
        break;
      case 6:
        if (_fatherStatus == null || _motherStatus == null || _siblingsCountController.text.trim().isEmpty || _siblingsDetailsController.text.trim().isEmpty || _liveWithFamily == null) return false;
        if (_fatherStatus != null && _fatherNameController.text.trim().isEmpty) return false;
        if (_motherStatus != null && _motherNameController.text.trim().isEmpty) return false;
        break;
      case 7:
        if (_ownHouse == null || _selectedHobbies.isEmpty) return false;
        if (_selectedHobbies.contains('Other') && _otherHobbiesController.text.trim().isEmpty) return false;
        break;
      case 8:
        break;
      case 9:
        if (!_acceptedTerms || !_acceptedInfoTrue) return false;
        int nonNullPhotos = _uploadedPhotos.where((p) => p != null && p!.isNotEmpty).length;
        if (nonNullPhotos == 0) return false;
        break;
    }
    return true;
  }

  void _nextStep() {
    if (!_validateCurrentStep()) {
      _showErrorSnackBar(Provider.of<LanguageProvider>(context, listen: false).translate('fill_all_fields') ?? 'Please fill all required fields correctly before proceeding.');
      return;
    }

    _saveOnboardingProgress();
    
    _showMotivationalPopup(_currentStep);

    if (_currentStep == 9) {
      _submitProfile();
      return;
    }

    if (_currentStep < 9) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
    _scrollToTop();
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _saveOnboardingProgress();
      _scrollToTop();
    }
  }
  Widget _buildStep5Bio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Lottie.asset(
            'assets/animations/bio_typing.json', // Bio typing animation
            height: 120,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.description_outlined, size: 80, color: AppTheme.accentGold),
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _bioController,
          labelText: '',
          hintText: 'About Yourself (Bio)',
          prefixIcon: Icons.description_outlined,
          maxLines: 4,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () async {
            // Simplified bio generation without Gemini using the new backend
            setState(() {
              _isAiLoading = true;
            });
            final auth = Provider.of<AuthProvider>(context, listen: false);
            try {
              final bio = await auth.generateBio({
                'firstName': _firstNameController.text,
                'city': _cityController.text,
                'profession': _profession ?? 'Not Working',
                'jobPost': _jobPostController.text,
                'education': _degreeControllers.isNotEmpty ? _degreeControllers.first.text : '',
                'gender': _gender,
                'aboutFamily': _aboutFamilyController.text,
              });
              if (bio != null) {
                setState(() {
                  _bioController.text = bio;
                });
              }
            } catch (e) {
              debugPrint("Bio generation failed: $e");
            } finally {
              if (mounted) {
                setState(() {
                  _isAiLoading = false;
                });
              }
            }
          },
          icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
          label: Text('Write Bio with AI', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentGold,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep6Photos() {
    return Column(
      children: [
        // Main large photo (Profile Photo)
        GestureDetector(
          onTap: () => _pickPhoto(0),
          child: Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: AppTheme.glassColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _uploadedPhotos[0] != null ? AppTheme.accentGold : AppTheme.glassBorderColor,
                width: _uploadedPhotos[0] != null ? 2 : 1,
              ),
              boxShadow: [
                if (_uploadedPhotos[0] != null)
                  BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
              ],
            ),
            child: _uploadedPhotos[0] != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(_uploadedPhotos[0]!, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('MAIN PHOTO', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accentGold.withValues(alpha: 0.1),
                        ),
                        child: const Icon(Icons.add_a_photo_outlined, color: AppTheme.accentGold, size: 36),
                      ),
                      const SizedBox(height: 12),
                      Text('Add Profile Photo', style: GoogleFonts.montserrat(color: AppTheme.accentGold, fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('This will be your main display photo', style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
        // Two smaller photos side by side
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _pickPhoto(1),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppTheme.glassColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _uploadedPhotos[1] != null ? AppTheme.accentGold : AppTheme.glassBorderColor,
                      width: _uploadedPhotos[1] != null ? 2 : 1,
                    ),
                  ),
                  child: _uploadedPhotos[1] != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(_uploadedPhotos[1]!, fit: BoxFit.cover),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.edit, color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo_outlined, color: AppTheme.textMuted, size: 28),
                            const SizedBox(height: 8),
                            Text('Photo 2', style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => _pickPhoto(2),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppTheme.glassColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _uploadedPhotos[2] != null ? AppTheme.accentGold : AppTheme.glassBorderColor,
                      width: _uploadedPhotos[2] != null ? 2 : 1,
                    ),
                  ),
                  child: _uploadedPhotos[2] != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(_uploadedPhotos[2]!, fit: BoxFit.cover),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.edit, color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo_outlined, color: AppTheme.textMuted, size: 28),
                            const SizedBox(height: 8),
                            Text('Photo 3', style: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickPhoto(int index) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Photo',
            toolbarColor: AppTheme.backgroundBlack,
            toolbarWidgetColor: AppTheme.accentGold,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Edit Photo',
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _uploadedPhotos[index] = croppedFile.path;
        });
        _saveOnboardingProgress();
      }
    }
  }

}
