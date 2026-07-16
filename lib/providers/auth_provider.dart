import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profile.dart';
import '../utils/storage_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthStatus {
  idle,
  loading,           // generic loading (replaces sendingOtp/verifyingOtp)
  sendingOtp,        // kept for legacy compat
  waitingForOtp,     // kept for legacy compat
  verifyingOtp,      // kept for legacy compat
  authenticatingGoogle,
  authenticated,
  error
}

void consoleLog(String message) {
  if (kDebugMode) {
    print(message);
  }
}

class AuthProvider extends ChangeNotifier {
  Timer? _configTimer;
  static const String baseUrl = 'https://humsafar.piyushassudani.in/api/v1'; // Live VPS Server
  static const String localAppVersion = '2.0.0';

  AuthStatus _status = AuthStatus.idle;
  String? _phoneNumber;
  String? _errorMessage;
  bool _isProfileComplete = false; 
  String? _token;
  String? _authProvider; // 'google' or 'mobile'
  String? _googleEmail;

  final List<Profile> _dailyPicks = [];
  bool _isLoadingDailyPicks = false;
  String? _dailyPicksError;
  bool _hasMoreDailyPicks = true;
  int _dailyPicksOffset = 0;

  final List<Profile> _searchResults = [];
  bool _isLoadingSearch = false;
  String? _searchError;
  bool _hasMoreSearch = true;
  int _searchOffset = 0;
  int _searchCount = 0;

  final Set<String> _shortlistedIds = {};
  final List<Profile> _shortlistedProfiles = [];
  
  int _profileVisits = 0;
  final List<Profile> _profileVisitsList = [];
  int _contactViews = 0;
  final List<Profile> _contactViewsList = [];
  final List<Profile> _sentInterests = [];
  final List<Profile> _acceptedInterests = [];
  bool _isLoadingActivity = false;

  final List<Profile> _incomingInterests = [];
  bool _isLoadingIncoming = false;
  String? _incomingError;

  Map<String, dynamic>? _myProfile;
  bool _isLoadingMyProfile = false;
  String? _myProfileError;

  final Map<String, dynamic> _localOnboardingData = {};

  Map<String, dynamic>? _appConfig;
  bool _isCheckingUpdate = false;

  bool _isAdmin = false;
  bool _isLoadingAdminUsers = false;
  List<dynamic> _adminUsers = [];
  String? _adminUsersError;
  
  final List<Profile> _conversations = [];
  bool _isLoadingConversations = false;
  String? _conversationsError;

  List<Map<String, dynamic>> _userNotifications = [];

  AuthStatus get status => _status;
  String? get phoneNumber => _phoneNumber;
  String? get errorMessage => _errorMessage;
  bool get isProfileComplete => _isProfileComplete;
  String? get token => _token;
  bool get isAuth => _token != null;
  String? get currentAuthProvider => _authProvider;
  String? get googleEmail => _googleEmail;
  bool get isAdmin => _isAdmin;
  List<dynamic> get adminUsers => _adminUsers;
  bool get isLoadingAdminUsers => _isLoadingAdminUsers;
  String? get adminUsersError => _adminUsersError;

  List<Profile> get dailyPicks => _dailyPicks;
  bool get isLoadingDailyPicks => _isLoadingDailyPicks;
  String? get dailyPicksError => _dailyPicksError;
  bool get hasMoreDailyPicks => _hasMoreDailyPicks;

  List<Profile> get searchResults => _searchResults;
  bool get isLoadingSearch => _isLoadingSearch;
  String? get searchError => _searchError;
  bool get hasMoreSearch => _hasMoreSearch;
  int get searchCount => _searchCount;

  Set<String> get shortlistedIds => _shortlistedIds;
  List<Profile> get shortlistedProfiles => _shortlistedProfiles;

  int get profileVisits => _profileVisits;
  List<Profile> get profileVisitsList => _profileVisitsList;
  int get contactViews => _contactViews;
  List<Profile> get contactViewsList => _contactViewsList;
  List<Profile> get sentInterests => _sentInterests;
  List<Profile> get acceptedInterests => _acceptedInterests;
  bool get isLoadingActivity => _isLoadingActivity;

  List<Profile> get incomingInterests => _incomingInterests;
  bool get isLoadingIncoming => _isLoadingIncoming;
  String? get incomingError => _incomingError;

  Map<String, dynamic>? get myProfile => _myProfile;
  bool get isLoadingMyProfile => _isLoadingMyProfile;
  String? get myProfileError => _myProfileError;

  Map<String, dynamic>? get appConfig => _appConfig;
  bool get isCheckingUpdate => _isCheckingUpdate;

  List<Profile> get conversations => _conversations;
  bool get isLoadingConversations => _isLoadingConversations;
  String? get conversationsError => _conversationsError;

  bool get updateAvailable {
    if (_appConfig == null) return false;
    final String serverVersion = _appConfig!['currentVersion'] ?? '1.0.0';
    return serverVersion.compareTo(localAppVersion) > 0;
  }

  bool get forceUpdateRequired {
    if (_appConfig == null) return false;
    final String minVersion = _appConfig!['minimumVersion'] ?? '1.0.0';
    return minVersion.compareTo(localAppVersion) > 0;
  }

  String get latestVersion => _appConfig?['currentVersion'] ?? localAppVersion;
  String get updateMessage => _appConfig?['updateMessage'] ?? "A new version of the app is available. Please update to continue.";
  String get updateDownloadUrl => _appConfig?['downloadUrl'] ?? "https://perfectbandhan.in";

  void _setErrorMessage(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _status = AuthStatus.idle;
    _phoneNumber = null;
    _errorMessage = null;
    _isProfileComplete = false;
    _token = null;
    _authProvider = null;
    _googleEmail = null;
    _isAdmin = false;
    _isProfileComplete = false;
    _myProfile = null;
    _dailyPicks.clear();
    _searchResults.clear();
    _shortlistedIds.clear();
    _shortlistedProfiles.clear();
    _incomingInterests.clear();
    _sentInterests.clear();
    _acceptedInterests.clear();
    _conversations.clear();
    notifyListeners();
  }

  void adminLogout() {
    _isAdmin = false;
    notifyListeners();
  }

  Future<void> logout() async {
    reset();
    await AppStorage.delete('token');
    await AppStorage.delete('phoneNumber');
    await AppStorage.delete('isAdmin');
    await AppStorage.delete('isProfileComplete');
    await AppStorage.delete('onboarding_progress');
    await AppStorage.delete('authProvider');
    await AppStorage.delete('googleEmail');
    await GoogleSignIn().signOut();
  }

  Future<void> tryAutoLogin() async {
    try {
      final savedToken = await AppStorage.get('token');
      final savedPhone = await AppStorage.get('phoneNumber');
      final savedIsAdmin = await AppStorage.get('isAdmin');
      final savedIsProfileComplete = await AppStorage.get('isProfileComplete');
      final savedAuthProvider = await AppStorage.get('authProvider');
      final savedGoogleEmail = await AppStorage.get('googleEmail');

      if (savedToken != null && savedToken.isNotEmpty) {
        _token = savedToken;
        _authProvider = savedAuthProvider;
        _googleEmail = savedGoogleEmail;
        _phoneNumber = savedPhone;
        _isAdmin = savedIsAdmin == 'true';
        _isProfileComplete = savedIsProfileComplete == 'true';
        
        _status = AuthStatus.authenticated;
        notifyListeners();
        
        await fetchMyProfile();
        // FCM token sync (Mobile only)
        if (!kIsWeb) {
          try {
            final fcmToken = await FirebaseMessaging.instance.getToken();
            if (fcmToken != null && _token != null) {
              await http.post(
                Uri.parse('$baseUrl/user/fcm-token'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $_token',
                },
                body: jsonEncode({'fcmToken': fcmToken}),
              );
            }
          } catch (e) {
            consoleLog('Failed to update FCM token: $e');
          }
        }
      }
    } catch (e) {
      consoleLog('Auto login error: $e');
    }
  }

  void startRegistration() {
    _isProfileComplete = false;
    _status = AuthStatus.idle;
    _phoneNumber = null;
    _errorMessage = null;
    _token = null;
    _localOnboardingData.clear();
    notifyListeners();
  }

  bool isValidPhoneNumber(String phone) {
    final RegExp phoneRegex = RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(phone);
  }

  Future<bool> checkPhoneRegistration(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/check-phone'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isRegistered'] == true;
      }
      return false;
    } catch (e) {
      consoleLog('Check phone error: $e');
      return false;
    }
  }

  Future<bool> sendOtp(String phone, {bool reset = false}) async {
    if (!isValidPhoneNumber(phone)) {
      _setErrorMessage("Invalid phone number. Must be exactly 10 digits.");
      return false;
    }

    _status = AuthStatus.sendingOtp;
    _phoneNumber = phone;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'phone': phone, 'reset': reset}),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 403 && responseData['status'] == 'registered') {
        _status = AuthStatus.error;
        _setErrorMessage(responseData['message'] ?? "You are already registered. Please login using your Password.");
        return false;
      }

      if (response.statusCode == 200) {
        _status = AuthStatus.waitingForOtp;
        notifyListeners();
        return true;
      } else {
        _setErrorMessage(responseData['message'] ?? "Unable to send OTP at the moment. Try again.");
        return false;
      }
    } catch (e) {
      consoleLog('Network error during sendOtp: $e');
      _setErrorMessage("Unable to send OTP at the moment. Try again.");
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (_phoneNumber == null) {
      _setErrorMessage("Session expired. Please enter phone number again.");
      return false;
    }

    _status = AuthStatus.verifyingOtp;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'phone': _phoneNumber,
          'otp': otp,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _token = responseData['token'];
        _isProfileComplete = responseData['isProfileComplete'] ?? false;
        _authProvider = 'mobile';
        
        await AppStorage.save('token', _token!);
        await AppStorage.save('authProvider', 'mobile');
        await AppStorage.save('phoneNumber', _phoneNumber!);
        await AppStorage.save('isProfileComplete', _isProfileComplete ? 'true' : 'false');
        
        _status = AuthStatus.authenticated;
        notifyListeners();
        await fetchMyProfile();
        return true;
      } else {
        _setErrorMessage(responseData['message'] ?? "Invalid OTP.");
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _setErrorMessage("Network error.");
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ─── Forgot Password — Email-based ───────────────────────────────────────

  /// Step 1: Get masked email hint for a phone number
  /// Returns masked email string on success, null on failure
  Future<String?> getEmailHint(String phone) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/get-email-hint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      final data = jsonDecode(response.body);
      _status = AuthStatus.idle;
      notifyListeners();

      if (response.statusCode == 200) {
        return data['maskedEmail'] as String?;
      } else {
        _setErrorMessage(data['message'] ?? 'No account found with this number.');
        return null;
      }
    } catch (e) {
      consoleLog('getEmailHint error: $e');
      _setErrorMessage('Network error. Please check your connection.');
      _status = AuthStatus.error;
      notifyListeners();
      return null;
    }
  }

  /// Step 2: Verify real email and set new password
  Future<bool> resetPasswordWithEmail(String phone, String email, String newPassword) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password-with-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'email': email.trim(),
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _status = AuthStatus.idle;
        notifyListeners();
        return true;
      } else {
        _setErrorMessage(data['message'] ?? 'Could not reset password. Try again.');
        return false;
      }
    } catch (e) {
      consoleLog('resetPasswordWithEmail error: $e');
      _setErrorMessage('Network error. Please check your connection.');
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }
  
  /// Create a skeleton account with a password for new users
  Future<bool> registerNewUserWithPassword(String phone, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/set-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _status = AuthStatus.idle;
        notifyListeners();
        return true;
      } else {
        _setErrorMessage(data['message'] ?? 'Could not set password. Try again.');
        return false;
      }
    } catch (e) {
      consoleLog('setPassword error: $e');
      _setErrorMessage('Network error. Please check your connection.');
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _status = AuthStatus.authenticatingGoogle;
    _errorMessage = null;
    notifyListeners();

    try {
      final String webClientId = '901626431984-etl37j0go12oc7u034uk2qe9p0aho1lh.apps.googleusercontent.com';
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId: kIsWeb ? webClientId : null,
        serverClientId: kIsWeb ? null : webClientId,
      ).signIn();
      if (googleUser == null) {
        _status = AuthStatus.idle;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _errorMessage = 'Failed to retrieve Google token.';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _token = responseData['token'];
        _isProfileComplete = responseData['isProfileComplete'] ?? false;
        _authProvider = 'google';
        _googleEmail = googleUser.email;

        await AppStorage.save('token', _token!);
        await AppStorage.save('authProvider', 'google');
        await AppStorage.save('googleEmail', googleUser.email);
        await AppStorage.save('isProfileComplete', _isProfileComplete ? 'true' : 'false');
        
        _status = AuthStatus.authenticated;
        notifyListeners();
        
        if (_isProfileComplete) {
          fetchMyProfile();
        }
        return true;
      } else {
        _errorMessage = responseData['message'] ?? 'Google login failed';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      consoleLog('Google login exception: $e');
      _errorMessage = 'Google Login Error: $e';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  void _startConfigPolling() {
    _configTimer?.cancel();
    fetchAppConfig();
    _configTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchAppConfig();
    });
  }

  @override
  void dispose() {
    _configTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchAppConfig() async {
    _isCheckingUpdate = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/app-config'));
      if (response.statusCode == 200) {
        _appConfig = jsonDecode(response.body)['data'];
      }
    } catch (e) {}
    _isCheckingUpdate = false;
    notifyListeners();
  }

  Future<void> fetchActivityData() async {
    if (_token == null) return;
    _isLoadingActivity = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/activity'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] ?? jsonDecode(response.body);
        _profileVisits = data['profileVisits'] ?? 0;
        _contactViews = data['contactViews'] ?? 0;
        
        final List<dynamic> pList = data['profileVisitsList'] ?? [];
        _profileVisitsList.clear();
        _profileVisitsList.addAll(pList.map((e) => Profile.fromJson(e)).toList());

        final List<dynamic> cList = data['contactViewsList'] ?? [];
        _contactViewsList.clear();
        _contactViewsList.addAll(cList.map((e) => Profile.fromJson(e)).toList());
        
        final List<dynamic> sent = data['sentInterests'] ?? [];
        _sentInterests.clear();
        _sentInterests.addAll(sent.map((e) => Profile.fromJson(e['receiver'] ?? e)).toList());

        final List<dynamic> acc = data['acceptedInterests'] ?? [];
        _acceptedInterests.clear();
        _acceptedInterests.addAll(acc.map((e) => Profile.fromJson(e['sender'] ?? e)).toList());
        
        // Also fetch incoming interests so the Incoming tab is not empty
        await fetchIncomingInterests();
      }
    } catch (e) {}
    _isLoadingActivity = false;
    notifyListeners();
  }

  Future<void> fetchMyProfile() async {
    if (_token == null) return;
    _isLoadingMyProfile = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile/me'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        _myProfile = decoded['data'] ?? decoded;
      } else {
        _myProfileError = "Failed to load profile";
      }
    } catch (e) {
      _myProfileError = e.toString();
    }
    _isLoadingMyProfile = false;
    notifyListeners();
  }
  Future<Profile?> fetchProfileById(String id) async {
    if (_token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile/$id'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          return Profile.fromJson(decoded['data']);
        }
      }
    } catch (e) {
      print('Error fetching profile by ID: $e');
    }
    return null;
  }

  Future<List<dynamic>> fetchPhoneLogs() async {
    if (_token == null || !isAdmin) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/admin/phone-logs'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 'success') {
          return decoded['data'] ?? [];
        }
      }
    } catch (e) {
      print('Error fetching phone logs: $e');
    }
    return [];
  }


  Future<void> fetchDailyPicks({bool refresh = false, Map<String, String>? filters}) async {
    if (_token == null) return;
    if (_isLoadingDailyPicks) return;
    if (refresh) {
      _dailyPicks.clear();
      _hasMoreDailyPicks = true;
      _dailyPicksError = null;
      _dailyPicksOffset = 0;
    }
    if (!_hasMoreDailyPicks && !refresh) return;
    _isLoadingDailyPicks = true;
    notifyListeners();

    try {
      int limit = 10;
      // int offset handled by param
      String url = '$baseUrl/user/profiles?recommendations=true&limit=$limit&offset=$_dailyPicksOffset';
      if (filters != null) {
        filters.forEach((key, value) {
          if (value.isNotEmpty) url += '&$key=${Uri.encodeComponent(value)}';
        });
      }
      final response = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $_token'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> profilesJson = data['data'] ?? [];
        if (profilesJson.isEmpty || profilesJson.length < limit) {
          _hasMoreDailyPicks = false;
        }
        if (profilesJson.isNotEmpty) {
          _dailyPicksOffset += profilesJson.length;
          final newProfiles = profilesJson
              .map((e) => Profile.fromJson(e))
              .toList();
          for (var p in newProfiles) {
            if (!_dailyPicks.any((existing) => existing.id == p.id)) {
              _dailyPicks.add(p);
            }
          }
        }
      } else {
        _dailyPicksError = "Failed to load feed";
      }
    } catch (e) {
      _dailyPicksError = "Network error";
    }
    _isLoadingDailyPicks = false;
    notifyListeners();
  }

  Future<void> searchProfiles({Map<String, String>? filters, bool refresh = false, int offset = 0}) async {
    if (_token == null) return;
    if (_isLoadingSearch) return;
    if (refresh) {
      _searchResults.clear();
      _hasMoreSearch = true;
      _searchError = null;
      _searchCount = 0;
    }
    if (!_hasMoreSearch && !refresh) return;
    _isLoadingSearch = true;
    notifyListeners();

    try {
      int limit = 10;
      // int offset handled by param
      String url = '$baseUrl/user/profiles?limit=$limit&offset=$_searchOffset';
      if (filters != null) {
        filters.forEach((key, value) {
          if (value.isNotEmpty) url += '&$key=${Uri.encodeComponent(value)}';
        });
      }
      final response = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $_token'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> profilesJson = data['data'] ?? [];
        _searchCount = data['pagination']?['total'] ?? 0;
        if (profilesJson.isEmpty || profilesJson.length < limit) {
          _hasMoreSearch = false;
        }
        if (profilesJson.isNotEmpty) {
          _searchOffset += profilesJson.length;
          final newProfiles = profilesJson
              .map((e) => Profile.fromJson(e))
              .toList();
          for (var p in newProfiles) {
            if (!_searchResults.any((existing) => existing.id == p.id)) {
              _searchResults.add(p);
            }
          }
        }
      } else {
        _searchError = "Failed to load search results";
      }
    } catch (e) {
      _searchError = "Network error";
    }
    _isLoadingSearch = false;
    notifyListeners();
  }

  void toggleShortlist(Profile profile) {
    if (_shortlistedIds.contains(profile.id)) {
      _shortlistedIds.remove(profile.id);
      _shortlistedProfiles.removeWhere((p) => p.id == profile.id);
      consoleLog('Profile ${profile.name} removed from shortlists.');
    } else {
      _shortlistedIds.add(profile.id);
      _shortlistedProfiles.add(profile);
      consoleLog('Profile ${profile.name} added to shortlists.');
    }
    notifyListeners();
  }

  void removeProfileLocally(String profileId) {
    _dailyPicks.removeWhere((p) => p.id == profileId);
    _searchResults.removeWhere((p) => p.id == profileId);
    notifyListeners();
  }

  void _updateProfileInterest(String profileId, String status) {
    for (var p in _dailyPicks) { if (p.id == profileId) p.interestStatus = status; }
    for (var p in _searchResults) { if (p.id == profileId) p.interestStatus = status; }
    for (var p in _shortlistedProfiles) { if (p.id == profileId) p.interestStatus = status; }
    for (var p in _profileVisitsList) { if (p.id == profileId) p.interestStatus = status; }
    for (var p in _contactViewsList) { if (p.id == profileId) p.interestStatus = status; }
    notifyListeners();
  }

  Future<bool> sendInterest(String targetPhone, String profileId) async {
    if (_token == null) return false;
    _updateProfileInterest(profileId, 'pending');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/interest'),
        headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
        body: jsonEncode({'toPhone': targetPhone}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchActivityData();
        return true;
      }
      _updateProfileInterest(profileId, 'none'); // revert on fail
      return false;
    } catch (e) {
      _updateProfileInterest(profileId, 'none'); // revert on fail
      return false;
    }
  }

  Future<bool> cancelInterest(String targetPhone, String profileId) async {
    if (_token == null) return false;
    _updateProfileInterest(profileId, 'none');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/interest/cancel'),
        headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
        body: jsonEncode({'targetPhone': targetPhone}),
      );
      if (response.statusCode == 200) {
        _sentInterests.removeWhere((p) => p.id == profileId);
        notifyListeners();
        return true;
      }
      _updateProfileInterest(profileId, 'pending'); // revert on fail
      return false;
    } catch (e) {
      _updateProfileInterest(profileId, 'pending'); // revert on fail
      return false;
    }
  }

  Future<bool> rejectInterest(String targetPhone, String profileId) async {
    try {
      if (_token == null) return false;

      final url = Uri.parse('$baseUrl/user/interest/reject');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
        body: jsonEncode({'fromPhone': targetPhone}),
      );

      if (response.statusCode == 200) {
        // Remove from pending lists
        _dailyPicks.removeWhere((p) => p.id == profileId);
        _incomingInterests.removeWhere((p) => p.id == profileId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Reject Interest Error: $e');
    }
    return false;
  }

  Future<List<String>> fetchIcebreakers(String targetPhone) async {
    try {
      if (_token == null) return [];

      final url = Uri.parse('$baseUrl/user/chat/icebreakers/$targetPhone');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['icebreakers'] != null) {
          return List<String>.from(data['icebreakers']);
        }
      }
    } catch (e) {
      print('Fetch Icebreakers Error: $e');
    }
    return [];
  }

  Future<bool> acceptInterest(String targetPhone, String profileId) async {
    if (_token == null) return false;
    _updateProfileInterest(profileId, 'accepted');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/interest/accept'),
        headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
        body: jsonEncode({'fromPhone': targetPhone}),
      );
      if (response.statusCode == 200) {
        // Move from incoming to accepted
        final index = _incomingInterests.indexWhere((p) => p.id == profileId);
        if (index != -1) {
          final profile = _incomingInterests.removeAt(index);
          profile.interestStatus = 'accepted';
          _acceptedInterests.insert(0, profile);
          notifyListeners();
        }
        return true;
      }
      _updateProfileInterest(profileId, 'incoming'); // revert on fail
      return false;
    } catch (e) {
      _updateProfileInterest(profileId, 'incoming'); // revert on fail
      return false;
    }
  }

  Future<void> fetchIncomingInterests() async {
    if (_token == null) return;
    if (_isLoadingIncoming) return;
    _isLoadingIncoming = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/interests?type=incoming'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> interests = data['data'] ?? [];
        _incomingInterests.clear();
        _incomingInterests.addAll(interests.map((e) => Profile.fromJson(e['sender'] ?? e)).toList());
      }
    } catch (e) {}
    _isLoadingIncoming = false;
    notifyListeners();
  }

  Future<void> fetchConversations() async {
    if (_token == null) return;
    if (_isLoadingConversations) return;
    _isLoadingConversations = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/chats'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> chats = data['data'] ?? [];
        _conversations.clear();
        _conversations.addAll(chats.map((e) => Profile.fromJson(e['profile'] ?? e)).toList());
      }
    } catch (e) {}
    _isLoadingConversations = false;
    notifyListeners();
  }

  Future<bool> completeOnboarding(Map<String, dynamic> payload) async {
    if (_token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/profile'),
        headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        _isProfileComplete = true;
        await AppStorage.save('isProfileComplete', 'true');
        await fetchMyProfile();
        notifyListeners();
        return true;
      } else {
        _errorMessage = jsonDecode(response.body)['message'] ?? 'Failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Network error";
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfileSettings(Map<String, dynamic> data) async {
    if (_token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/profile'),
        headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchMyProfile();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> generateBio(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/generate-bio'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['bio'] ?? jsonDecode(response.body)['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> loginWithPassword(String phone, String password) async {
    _status = AuthStatus.verifyingOtp; 
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login-pass'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _token = responseData['token'];
        _phoneNumber = phone;
        _isAdmin = responseData['isAdmin'] ?? false;
        _isProfileComplete = responseData['isProfileComplete'] ?? true;
        await AppStorage.save('token', _token!);
        await AppStorage.save('phoneNumber', _phoneNumber!);
        await AppStorage.save('isAdmin', _isAdmin ? 'true' : 'false');
        await AppStorage.save('isProfileComplete', _isProfileComplete ? 'true' : 'false');
        
        _status = AuthStatus.authenticated;
        notifyListeners();
        await fetchMyProfile();
        return true;
      } else {
        _setErrorMessage(responseData['message'] ?? 'Login failed');
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _setErrorMessage('Network error');
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> setPassword(String password) async {
    if (_phoneNumber == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/set-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': _phoneNumber, 'password': password}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchChatHistory(String targetUserId) async {
    if (_token == null) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/chat/$targetUserId'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List<dynamic>;
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> sendChatMessage(String targetUserId, String text) async {
    if (_token == null) return {};
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/chat/send'),
        headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
        body: jsonEncode({'targetUserId': targetUserId, 'text': text}),
      );
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<bool> updatePartnerPreferences(Map<String, dynamic> preferences) async {
    if (_token == null) return false;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/partner-preferences'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode(preferences),
      );
      if (response.statusCode == 200) {
        if (_myProfile != null) {
          _myProfile!['partnerPreferences'] = preferences;
        }
        notifyListeners();
        return true;
      }
      return false;
        } catch (e) {
      _errorMessage = 'Network error: Please check your connection.';
      notifyListeners();
      return false; 
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_token == null) return false;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({'currentPassword': currentPassword, 'newPassword': newPassword}),
      );
      return response.statusCode == 200;
        } catch (e) {
      _errorMessage = 'Network error: Please check your connection.';
      notifyListeners();
      return false; 
    }
  }

  Future<bool> deleteAccount() async {
    if (_token == null) return false;
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user/account'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        await logout();
        return true;
      }
      return false;
        } catch (e) {
      _errorMessage = 'Network error: Please check your connection.';
      notifyListeners();
      return false; 
    }
  }

  bool get hasUnreadNotifications {
    if (_phoneNumber == null) return false;
    for (var notif in _userNotifications) {
      final readBy = notif['readBy'] as List<dynamic>? ?? [];
      if (!readBy.contains(_phoneNumber)) {
        return true;
      }
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> getUserNotifications() async {
    if (_token == null) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        _userNotifications = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        notifyListeners();
        return _userNotifications;
      }
      return [];
    } catch (e) { return []; }
  }

  Future<bool> markAllNotificationsAsRead() async {
    if (_token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        if (_phoneNumber != null) {
          for (var notif in _userNotifications) {
            final readBy = notif['readBy'] as List<dynamic>? ?? [];
            if (!readBy.contains(_phoneNumber)) {
              readBy.add(_phoneNumber);
              notif['readBy'] = readBy;
            }
          }
          notifyListeners();
        }
        return true;
      }
      return false;
        } catch (e) {
      _errorMessage = 'Network error: Please check your connection.';
      notifyListeners();
      return false; 
    }
  }

  Future<bool> deleteUserNotification(String id) async {
    if (_token == null) return false;
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/$id'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        _userNotifications.removeWhere((n) => n['_id'] == id);
        notifyListeners();
        return true;
      }
      return false;
        } catch (e) {
      _errorMessage = 'Network error: Please check your connection.';
      notifyListeners();
      return false; 
    }
  }

  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    if (_token == null || !_isAdmin) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/admin'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) { return []; }
  }

  Future<bool> createNotification(String title, String body, String? targetPhone, String type) async {
    if (_token == null || !_isAdmin) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/admin'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({'title': title, 'body': body, 'targetPhone': targetPhone, 'type': type}),
      );
      return response.statusCode == 201;
        } catch (e) {
      _errorMessage = 'Network error: Please check your connection.';
      notifyListeners();
      return false; 
    }
  }

  Future<bool> updateNotification(String id, String title, String body, String? targetPhone, String type) async {
    if (_token == null || !_isAdmin) return false;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/admin/$id'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({'title': title, 'body': body, 'targetPhone': targetPhone, 'type': type}),
      );
      return response.statusCode == 200;
        } catch (e) {
      _errorMessage = 'Network error: Please check your connection.';
      notifyListeners();
      return false; 
    }
  }

  Future<bool> deleteNotification(String id) async {
    if (_token == null || !_isAdmin) return false;
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/admin/$id'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      return response.statusCode == 200;
        } catch (e) {
      _errorMessage = 'Network error: Please check your connection.';
      notifyListeners();
      return false; 
    }
  }

  Future<bool> blockUser(String targetPhone, String reason, String details) async {
    if (_token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/block'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({'targetPhone': targetPhone, 'reason': reason, 'details': details}),
      );
      return response.statusCode == 200;
        } catch (e) {
      _errorMessage = 'Network error: Please check your connection.';
      notifyListeners();
      return false; 
    }
  }

  Future<bool> unblockUser(String targetPhone) async {
    if (_token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/unblock'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({'targetPhone': targetPhone}),
      );
      return response.statusCode == 200;
        } catch (e) {
      _errorMessage = 'Network error: Please check your connection.';
      notifyListeners();
      return false; 
    }
  }

  Future<List<Map<String, dynamic>>> getBlockedUsers() async {
    if (_token == null) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/blocked'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List<dynamic>;
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) { return []; }
  }

  Future<bool> reportUser(String targetPhone, String reason, String details) async {
    if (_token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/report'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({'targetPhone': targetPhone, 'reason': reason, 'details': details}),
      );
      return response.statusCode == 200;
        } catch (e) {
      _errorMessage = 'Network error: Please check your connection.';
      notifyListeners();
      return false; 
    }
  }

  Future<List<Map<String, dynamic>>> getReports() async {
    if (_token == null || !_isAdmin) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/reports'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List<dynamic>;
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) { return []; }
  }

  Future<List<Map<String, dynamic>>> getBlocks() async {
    if (_token == null || !_isAdmin) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/blocks'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List<dynamic>;
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) { return []; }
  }

  Future<void> fetchAdminUsers() async {
    if (_token == null || !_isAdmin) return;
    _isLoadingAdminUsers = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/admin/users'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _adminUsers = responseData['data'] ?? [];
        _isLoadingAdminUsers = false;
        notifyListeners();
      } else {
        _adminUsersError = responseData['message'] ?? 'Failed to load users.';
        _isLoadingAdminUsers = false;
        notifyListeners();
      }
    } catch (e) {
      _adminUsersError = 'Network error.';
      _isLoadingAdminUsers = false;
      notifyListeners();
    }
  }

  // Admin Portal Operations
  Future<bool> createDeveloperProfile(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/create-developer'),
        headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> adminEditUser(String userId, Map<String, dynamic> data) async {
    if (_token == null || !_isAdmin) return false;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/admin/user/$userId'),
        headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        try {
          _errorMessage = jsonDecode(response.body)['message'] ?? 'Failed';
        } catch (_) {
          _errorMessage = 'Failed to update';
        }
        notifyListeners();
        return false;
      }
        } catch (e) {
      _errorMessage = 'Network error: Please check your connection.';
      notifyListeners();
      return false; 
    }
  }

  Future<bool> adminBroadcastPush(String text) async {
    if (_token == null || !_isAdmin) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/admin/push'),
        headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
        body: jsonEncode({'message': text}),
      );
      return response.statusCode == 200;
        } catch (e) {
      _errorMessage = 'Network error: Please check your connection.';
      notifyListeners();
      return false; 
    }
  }

  Future<bool> adminChangePassword(String curr, String newP) async {
    if (_token == null || !_isAdmin) return false;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/admin/change-password'),
        headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
        body: jsonEncode({'currentPassword': curr, 'newPassword': newP}),
      );
      return response.statusCode == 200;
        } catch (e) {
      _errorMessage = 'Network error: Please check your connection.';
      notifyListeners();
      return false; 
    }
  }

  Future<bool> adminUpdateAppConfig(Map<String, dynamic> config) async {
    if (_token == null || !_isAdmin) return false;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/admin/app-config'),
        headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
        body: jsonEncode(config),
      );
      return response.statusCode == 200;
        } catch (e) {
      _errorMessage = 'Network error: Please check your connection.';
      notifyListeners();
      return false; 
    }
  }

  // Admin: Delete a user permanently
  Future<bool> adminDeleteUser(String userId) async {
    if (_token == null || !_isAdmin) return false;
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user/admin/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Admin Delete User Error: $e");
      return false;
    }
  }

  Future<void> trackActivity(String targetPhone, String type) async {
    if (_token == null) return;
    try {
      await http.post(
        Uri.parse('$baseUrl/user/track-activity'),
        headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
        body: jsonEncode({'targetPhone': targetPhone, 'type': type}),
      );
    } catch (e) {}
  }

  // --- WhatsApp & Safety Features ---

  Future<void> requestWhatsappUnlock(String targetUserId) async {
    try {
      if (_token == null) return;
      final res = await http.post(
        Uri.parse('$baseUrl/user/whatsapp/request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'targetUserId': targetUserId}),
      );
      if (res.statusCode != 200) {
        throw Exception('Failed to request WhatsApp unlock');
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  Future<void> approveWhatsappUnlock(String requesterUserId) async {
    try {
      if (_token == null) return;
      final res = await http.post(
        Uri.parse('$baseUrl/user/whatsapp/approve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'requesterUserId': requesterUserId}),
      );
      if (res.statusCode != 200) {
        throw Exception('Failed to approve WhatsApp unlock');
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  Future<void> reportUserWithDump(String reportedPhone, String reason, List<Map<String, dynamic>> chatDump) async {
    try {
      if (_token == null) return;
      final res = await http.post(
        Uri.parse('$baseUrl/user/report'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'targetPhone': reportedPhone,
          'reason': reason,
          'chatDump': chatDump
        }),
      );
      if (res.statusCode != 200) {
        throw Exception('Failed to report user');
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  Future<void> updateMessageStatus(String messageId, String status) async {
    // If backend implements it, otherwise a no-op placeholder for read receipts
  }

  Future<void> saveOnboardingProgress(int step, Map<String, dynamic> data) async {
    if (_token == null) return;
    try {
      await http.post(
        Uri.parse('$baseUrl/user/onboarding-progress'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'step': step,
          'stepName': 'Step $step',
          'data': data,
        }),
      );
    } catch (e) {
      debugPrint('Error saving onboarding progress: $e');
    }
  }

  Future<List<dynamic>> getOnboardingDropoffs() async {
    if (_token == null || !isAdmin) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/admin/onboarding-progress'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 'success') {
          return decoded['data'] ?? [];
        }
      }
    } catch (e) {
      debugPrint('Error fetching onboarding dropoffs: $e');
    }
    return [];
  }
}

