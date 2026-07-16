import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/providers/language_provider.dart'

with open(file_path, 'r') as f:
    content = f.read()

en_keys = """
      'fill_details_now': 'Fill your detail now',
      'know_about_yourself': '✨ Know About Yourself',
      'retry_btn': 'Retry',
      'my_gallery': '✨ My Gallery',
      'house': 'House',
      'know_about_yourself_blue': 'Know About Yourself',
      'add_birth_details_ai': 'Add your birth time & place to get a personalized AI insight.',
      'ai_personality_insight': '✨ AI Personality Insight',
      'know_more': 'Know more →',
      'confirm_status_change': 'Confirm Status Change',
      'yes_mark_married': 'Yes, Mark Married',
      'yes_unmark': 'Yes, Unmark',
      'upgrade_btn': 'UPGRADE',
      'blocked_users': 'Blocked Users',
      'no_blocked_users': 'No blocked users.',
      'unblock_btn': 'Unblock',
      'change_btn': 'CHANGE',
      'choose_language': 'Choose Language / भाषा चुनें',
"""

hi_keys = """
      'fill_details_now': 'अपनी जानकारी भरें',
      'know_about_yourself': '✨ अपने बारे में जानें',
      'retry_btn': 'पुनः प्रयास करें',
      'my_gallery': '✨ मेरी गैलरी',
      'house': 'घर',
      'know_about_yourself_blue': 'अपने बारे में जानें',
      'add_birth_details_ai': 'वैयक्तिकृत एआई इनसाइट प्राप्त करने के लिए अपना जन्म समय और स्थान जोड़ें।',
      'ai_personality_insight': '✨ एआई व्यक्तित्व इनसाइट',
      'know_more': 'और जानें →',
      'confirm_status_change': 'स्थिति परिवर्तन की पुष्टि करें',
      'yes_mark_married': 'हाँ, विवाहित चिह्नित करें',
      'yes_unmark': 'हाँ, अनमार्क करें',
      'upgrade_btn': 'अपग्रेड करें',
      'blocked_users': 'ब्लॉक किए गए उपयोगकर्ता',
      'no_blocked_users': 'कोई ब्लॉक किया गया उपयोगकर्ता नहीं।',
      'unblock_btn': 'अनब्लॉक करें',
      'change_btn': 'बदलें',
      'choose_language': 'Choose Language / भाषा चुनें',
"""

# Insert English keys before the end of the English dictionary
# Find the end of 'en': { ... },
# We can just insert before the first occurence of 'hi': {
content = content.replace("    'hi': {", en_keys + "\n    'hi': {")

# Insert Hindi keys before the end of the localized values map
# Find the end of 'hi': { ... }, which is the last closing brace before static const Map ends
content = content.replace("    }\n  };", hi_keys + "\n    }\n  };")

with open(file_path, 'w') as f:
    f.write(content)

print("Updated language_provider.dart")
