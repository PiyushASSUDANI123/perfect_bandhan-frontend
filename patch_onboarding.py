import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/screens/profile_onboarding_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# 1. Fix Premature Data Destruction
submit_old = """    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // As per user request, flush local storage immediately regardless of DB success
    _clearOnboardingProgress();

    auth.completeOnboarding(finalPayload).then((success) {
      if (success && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => CongratulationsScreen(profileData: finalPayload),
          ),
          (Route<dynamic> route) => false,
        );
      } else if (!success && mounted) {"""

submit_new = """    final auth = Provider.of<AuthProvider>(context, listen: false);

    auth.completeOnboarding(finalPayload).then((success) {
      if (!mounted) return;
      if (success) {
        // FIX: Only delete draft if DB actually saved it
        _clearOnboardingProgress();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => CongratulationsScreen(profileData: finalPayload),
          ),
          (Route<dynamic> route) => false,
        );
      } else {"""

content = content.replace(submit_old, submit_new)

# 2. Fix Unhandled FormatException
date_old = """        if (data['dob'] != null) {
          _dob = DateTime.parse(data['dob']);
        }"""

date_new = """        if (data['dob'] != null && data['dob'].toString().trim().isNotEmpty) {
          _dob = DateTime.tryParse(data['dob'].toString());
        }"""

content = content.replace(date_old, date_new)

# 3. Fix Type Casting Exception
degrees_old = """        final List<dynamic>? degreesList = data['degrees'];
        if (degreesList != null && degreesList.isNotEmpty) {
          _degreeControllers.clear();
          for (var deg in degreesList) {
            _degreeControllers.add(TextEditingController(text: deg.toString()));
          }
        }"""

degrees_new = """        final dynamic degreesData = data['degrees'];
        if (degreesData is List && degreesData.isNotEmpty) {
          _degreeControllers.clear();
          for (var deg in degreesData) {
            _degreeControllers.add(TextEditingController(text: deg.toString()));
          }
        } else if (degreesData is String && degreesData.isNotEmpty) {
          _degreeControllers.clear();
          _degreeControllers.add(TextEditingController(text: degreesData));
        }"""

content = content.replace(degrees_old, degrees_new)

with open(file_path, 'w') as f:
    f.write(content)
print("profile_onboarding_screen.dart patched successfully.")
