import 'package:flutter/material.dart';
import '../utils/storage_helper.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en'; // 'en' or 'hi'
  bool _hasPrompted = false;

  String get currentLanguage => _currentLanguage;
  bool get hasPrompted => _hasPrompted;

  LanguageProvider() {
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    try {
      final lang = await AppStorage.get('app_language');
      if (lang != null && (lang == 'en' || lang == 'hi')) {
        _currentLanguage = lang;
        _hasPrompted = true;
      } else {
        _currentLanguage = 'en';
        _hasPrompted = false;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    _hasPrompted = true;
    notifyListeners();
    try {
      await AppStorage.save('app_language', languageCode);
    } catch (_) {}
  }

  // ─── Complete Bilingual Dictionary ───────────────────────────────────────
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // ── App Identity ──────────────────────────────────────────────────────
      'app_name': 'Perfect Bandhan',
      'tagline': 'Made for All India Sindhi Samaj Only',
      'assudani_group': 'A Property of Assudani Group',
      'developed_by': 'Developed by Piyush Assudani',
      'version': 'Version',

      // ── Auth / Login ──────────────────────────────────────────────────────
      'language': 'Language',
      'otp_login': 'OTP LOGIN',
      'password_login': 'PASSWORD LOGIN',
      'mobile_number': 'MOBILE NUMBER',
      'enter_mobile': 'Enter your 10-digit number',
      'password': 'PASSWORD',
      'enter_password': 'Enter account password',
      'login_btn': 'UNLOCK DASHBOARD',
      'send_otp': 'SEND OTP',
      'sign_in': 'SIGN IN',
      'new_to_perfectbandhan': 'New to Perfect Bandhan?',
      'register_free': 'REGISTER FREE',
      'forgot_password': 'Forgot Password? Reset via OTP',
      'admin_portal': 'ADMIN PORTAL',

      // ── Dashboard / Navigation ────────────────────────────────────────────
      'home': 'Home',
      'search': 'Search',
      'interests': 'Interests',
      'messages': 'Messages',
      'profile': 'Profile',
      'daily_picks': 'PB MATCHES',
      'search_profiles': 'SEARCH PROFILES',
      'connections': 'CONNECTIONS',
      'chat': 'CHAT',
      'shortlisted': 'Shortlisted',
      'all_profiles': 'FOUND ELITE PROFILES',
      'compat_profile': 'COMPATIBILITY PROFILE',
      'search_placeholder': 'Search by name, city, nukh...',
      'no_results': 'No profiles found.',
      'load_more': 'Load More',
      'loading': 'Loading...',
      'refresh': 'Refresh',

      // ── Filters ───────────────────────────────────────────────────────────
      'filters': 'Filters',
      'apply_filters': 'Apply Filters',
      'reset_filters': 'Reset',
      'age_range': 'Age Range',
      'height_range': 'Height Range',
      'city': 'City',
      'select_all': 'All (Any)',
      'any_city': 'Any City',
      'any_income': 'Any Income',

      // ── Profile Actions ───────────────────────────────────────────────────
      'interest_sent': 'INTEREST SENT',
      'interest_accept': 'ACCEPT INTEREST',
      'interest_decline': 'DECLINE',
      'view_details': 'VIEW DETAILS',
      'premium_badge': 'VERIFIED',
      'send_interest': 'SEND INTEREST',
      'chat_on_whatsapp': 'CONNECT ON WHATSAPP',
      'whatsapp_locked': 'WhatsApp contact locked. Send Interest to initiate mutual connection handshake.',
      'shortlist': 'Shortlist',
      'remove_shortlist': 'Remove from Shortlist',
      'interest_incoming': 'INTERESTED IN YOU',
      'mutual_connected': 'CONNECTED',

      // ── Profile Details ───────────────────────────────────────────────────
      'basics_identity': 'BASICS & IDENTITY',
      'career_financials': 'CAREER & FINANCIALS',
      'family_clan': 'FAMILY & CLAN HERITAGE',
      'personal_details': 'PERSONAL DETAILS',
      'family_details': 'FAMILY DETAILS',
      'caste_nukh': 'Clan (Caste)',
      'clan_nukh': 'Clan Nukh',
      'father_business': 'Father\'s Business',
      'family_origin': 'Family Origin',
      'education': 'Education',
      'job_title': 'Job Title',
      'company': 'Company',
      'annual_income': 'Annual Income',
      'monthly_income': 'Monthly Income',
      'age': 'Age',
      'height': 'Height',
      'location': 'Location',
      'marital_status': 'Marital Status',
      'weight': 'Weight',
      'complexion': 'Complexion',
      'disability': 'Physical Disability',
      'sindhi_type': 'Sindhi Type',
      'father_status': 'Father\'s Status',
      'mother_status': 'Mother\'s Status',
      'mother_occupation': 'Mother\'s Occupation',
      'siblings': 'Brothers & Sisters',
      'siblings_marriage': 'Sibling Marriage Details',
      'requirements': 'Requirements / Expectations',
      'what_we_provide': 'What We Provide',
      'own_house': 'Own House',
      'mobile_number_label': 'Mobile Number',
      'whatsapp_label': 'WhatsApp Number',
      'not_provided': 'Not Provided',
      
      // ── New Onboarding Fields ─────────────────────────────────────────────
      'father_occupation': 'Father\'s Occupation',
      'other_specify': 'Please specify (Other)',
      'other': 'Other',
      'add_degree': '+ Add Another Degree',
      'skip': 'Skip',
      'motivational_1': 'Great start! Let\'s proceed.',
      'motivational_2': 'Almost there! Keep going.',
      'motivational_3': 'Just a few more details.',
      'bio_ai_loading': 'PB AI Generating Bio...',
      'fill_all_fields': 'Please fill all required fields correctly before proceeding.',

      // ── Status Words ──────────────────────────────────────────────────────
      'unmarried': 'Unmarried',
      'married': 'Married',
      'alive': 'Alive',
      'passed_away': 'Passed Away',
      'private': 'Private',
      'none': 'None',
      'yes': 'Yes',
      'no': 'No',

      // ── My Profile / Settings ─────────────────────────────────────────────
      'my_profile': 'My Profile',
      'edit_profile': 'Edit Profile',
      'privacy_settings': 'PRIVACY & SETTINGS',
      'hide_profile': 'Hide My Profile',
      'hide_profile_desc': 'Your profile will not appear in search results',
      'hide_income': 'Hide Income',
      'hide_income_desc': 'Income will show as "Private" to others',
      'mark_married': 'Mark as Married / Settled',
      'mark_married_desc': 'Hides your profile and sets status to Married',
      'sign_out': 'Sign Out',
      'sign_out_desc': 'You can log back in anytime',
      'partner_preferences': 'Partner Preferences',
      'partner_preferences_desc': 'What you\'re looking for',

      // ── About / Legal ─────────────────────────────────────────────────────
      'about': 'About Perfect Bandhan',
      'about_developer': 'About the Developer',
      'rate_app': 'Rate Us on Play Store ★★★★★',
      'privacy_policy': 'Privacy Policy',
      'terms_conditions': 'Terms & Conditions',
      'open_playstore': 'Open on Play Store',

      // ── Buttons ───────────────────────────────────────────────────────────
      'save_btn': 'SAVE',
      'cancel_btn': 'CANCEL',
      'next_btn': 'Next',
      'back_btn': 'Back',
      'done_btn': 'Done',
      'submit_btn': 'Submit',
      'update_btn': 'Update',
      'delete_btn': 'Delete',

      // ── Messages ──────────────────────────────────────────────────────────
      'error_network': 'Network error. Please check your connection.',
      'error_generic': 'Something went wrong. Please try again.',
      'success_saved': 'Saved successfully!',
      'success_interest': 'Interest sent successfully!',
    },
    'hi': {
      // ── App Identity ──────────────────────────────────────────────────────
      'app_name': 'परफेक्ट बंधन',
      'tagline': 'केवल अखिल भारतीय सिंधी समाज के लिए',
      'assudani_group': 'असुदानी ग्रुप की एक पहल',
      'developed_by': 'पियूष असुदानी द्वारा निर्मित',
      'version': 'संस्करण',

      // ── Auth / Login ──────────────────────────────────────────────────────
      'language': 'भाषा',
      'otp_login': 'ओटीपी लॉगिन',
      'password_login': 'पासवर्ड लॉगिन',
      'mobile_number': 'मोबाइल नंबर',
      'enter_mobile': 'अपना 10-अंकीय नंबर दर्ज करें',
      'password': 'पासवर्ड',
      'enter_password': 'खाते का पासवर्ड दर्ज करें',
      'login_btn': 'डैशबोर्ड खोलें',
      'send_otp': 'ओटीपी भेजें',
      'sign_in': 'लॉगिन करें',
      'new_to_perfectbandhan': 'परफेक्ट बंधन पर नए हैं?',
      'register_free': 'मुफ़्त पंजीकरण',
      'forgot_password': 'पासवर्ड भूल गए? ओटीपी से बदलें',
      'admin_portal': 'एडमिन पोर्टल',

      // ── Dashboard / Navigation ────────────────────────────────────────────
      'home': 'होम',
      'search': 'खोज',
      'interests': 'रुचियाँ',
      'messages': 'संदेश',
      'profile': 'प्रोफ़ाइल',
      'daily_picks': 'PB MATCHES',
      'search_profiles': 'प्रोफ़ाइल खोजें',
      'connections': 'कनेक्शन',
      'chat': 'चैट',
      'shortlisted': 'पसंदीदा',
      'all_profiles': 'खोजे गए प्रोफाइल',
      'compat_profile': 'संगतता प्रोफाइल',
      'search_placeholder': 'नाम, शहर, नख द्वारा खोजें...',
      'no_results': 'कोई प्रोफ़ाइल नहीं मिली।',
      'load_more': 'और देखें',
      'loading': 'लोड हो रहा है...',
      'refresh': 'रिफ्रेश',

      // ── Filters ───────────────────────────────────────────────────────────
      'filters': 'फ़िल्टर',
      'apply_filters': 'फ़िल्टर लागू करें',
      'reset_filters': 'रीसेट',
      'age_range': 'आयु सीमा',
      'height_range': 'कद सीमा',
      'city': 'शहर',
      'select_all': 'सभी (कोई भी)',
      'any_city': 'कोई भी शहर',
      'any_income': 'कोई भी आय',

      // ── Profile Actions ───────────────────────────────────────────────────
      'interest_sent': 'रुचि भेजी गई',
      'interest_accept': 'रुचि स्वीकार करें',
      'interest_decline': 'अस्वीकार करें',
      'view_details': 'विवरण देखें',
      'premium_badge': 'सत्यापित',
      'send_interest': 'रुचि भेजें',
      'chat_on_whatsapp': 'व्हाट्सएप पर जुड़ें',
      'whatsapp_locked': 'व्हाट्सएप संपर्क लॉक है। आपसी संबंध शुरू करने के लिए रुचि भेजें।',
      'shortlist': 'पसंदीदा में जोड़ें',
      'remove_shortlist': 'पसंदीदा से हटाएं',
      'interest_incoming': 'आपमें रुचि है',
      'mutual_connected': 'जुड़े हुए',

      // ── Profile Details ───────────────────────────────────────────────────
      'basics_identity': 'बुनियादी जानकारी',
      'career_financials': 'करियर और वित्तीय स्थिति',
      'family_clan': 'पारिवारिक पृष्ठभूमि',
      'personal_details': 'व्यक्तिगत विवरण',
      'family_details': 'पारिवारिक विवरण',
      'caste_nukh': 'जाति',
      'clan_nukh': 'नख',
      'father_business': 'पिता का व्यवसाय',
      'family_origin': 'पारिवारिक मूल',
      'education': 'शिक्षा',
      'job_title': 'पद',
      'company': 'कंपनी',
      'annual_income': 'वार्षिक आय',
      'monthly_income': 'मासिक आय',
      'age': 'आयु',
      'height': 'कद',
      'location': 'स्थान',
      'marital_status': 'वैवाहिक स्थिति',
      'weight': 'वजन',
      'complexion': 'रंग',
      'disability': 'शारीरिक अक्षमता',
      'sindhi_type': 'सिंधी प्रकार',
      'father_status': 'पिता की स्थिति',
      'mother_status': 'माता की स्थिति',
      'mother_occupation': 'माता का व्यवसाय',
      'siblings': 'भाई और बहन',
      'siblings_marriage': 'भाई-बहनों की शादी के विवरण',
      'requirements': 'आवश्यकताएं / अपेक्षाएं',
      'what_we_provide': 'हम क्या देते हैं',
      'own_house': 'स्वयं का घर',
      'mobile_number_label': 'मोबाइल नंबर',
      'whatsapp_label': 'व्हाट्सएप नंबर',
      'not_provided': 'उपलब्ध नहीं',

      // ── New Onboarding Fields ─────────────────────────────────────────────
      'father_occupation': 'पिता का व्यवसाय',
      'other_specify': 'कृपया निर्दिष्ट करें (अन्य)',
      'other': 'अन्य',
      'add_degree': '+ एक और डिग्री जोड़ें',
      'skip': 'स्किप करें',
      'motivational_1': 'शानदार शुरुआत! आगे बढ़ें।',
      'motivational_2': 'बस थोड़ा और! आगे बढ़ते रहें।',
      'motivational_3': 'बस कुछ और विवरण।',
      'bio_ai_loading': 'PB AI बायो बना रहा है...',
      'fill_all_fields': 'कृपया आगे बढ़ने से पहले सभी आवश्यक फ़ील्ड भरें।',

      // ── Status Words ──────────────────────────────────────────────────────
      'unmarried': 'अविवाहित',
      'married': 'विवाहित',
      'alive': 'जीवित',
      'passed_away': 'स्वर्गवासी',
      'private': 'निजी',
      'none': 'कोई नहीं',
      'yes': 'हाँ',
      'no': 'नहीं',

      // ── My Profile / Settings ─────────────────────────────────────────────
      'my_profile': 'मेरा प्रोफ़ाइल',
      'edit_profile': 'प्रोफ़ाइल संपादित करें',
      'privacy_settings': 'गोपनीयता और सेटिंग्स',
      'hide_profile': 'मेरा प्रोफाइल छुपाएं',
      'hide_profile_desc': 'आपका प्रोफाइल खोज परिणामों में नहीं दिखेगा',
      'hide_income': 'आय छुपाएं',
      'hide_income_desc': 'आय दूसरों को "निजी" के रूप में दिखाई देगी',
      'mark_married': 'शादीशुदा / सेटल के रूप में चिह्नित करें',
      'mark_married_desc': 'आपका प्रोफाइल छुपाता है और स्थिति को विवाहित पर सेट करता है',
      'sign_out': 'साइन आउट',
      'sign_out_desc': 'आप किसी भी समय वापस लॉग इन कर सकते हैं',
      'partner_preferences': 'जीवनसाथी की प्राथमिकताएं',
      'partner_preferences_desc': 'आप क्या खोज रहे हैं',

      // ── About / Legal ─────────────────────────────────────────────────────
      'about': 'परफेक्ट बंधन के बारे में',
      'about_developer': 'डेवलपर के बारे में',
      'rate_app': 'Play Store पर रेट करें ★★★★★',
      'privacy_policy': 'गोपनीयता नीति',
      'terms_conditions': 'उपयोग की शर्तें',
      'open_playstore': 'Play Store पर खोलें',

      // ── Buttons ───────────────────────────────────────────────────────────
      'save_btn': 'सहेजें',
      'cancel_btn': 'रद्द करें',
      'next_btn': 'आगे',
      'back_btn': 'वापस',
      'done_btn': 'हो गया',
      'submit_btn': 'जमा करें',
      'update_btn': 'अपडेट करें',
      'delete_btn': 'हटाएं',

      // ── Messages ──────────────────────────────────────────────────────────
      'error_network': 'नेटवर्क त्रुटि। कृपया अपना कनेक्शन जांचें।',
      'error_generic': 'कुछ गलत हो गया। कृपया पुनः प्रयास करें।',
      'success_saved': 'सफलतापूर्वक सहेजा गया!',
      'success_interest': 'रुचि सफलतापूर्वक भेजी गई!',
    }
  };

  String translate(String key) {
    return _localizedValues[_currentLanguage]?[key] ?? key;
  }
}
