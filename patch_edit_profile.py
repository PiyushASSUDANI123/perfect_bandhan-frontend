import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/widgets/edit_profile_sheet.dart'
with open(file_path, 'r') as f:
    content = f.read()

# 1. Add controllers
controllers_code = """
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappNumberController;
  late TextEditingController _heightController;
  late TextEditingController _casteController;
  late TextEditingController _sindhiTypeController;
  late TextEditingController _fathersOccupationController;
  late TextEditingController _mothersOccupationController;
  late TextEditingController _siblingsDetailsController;
  
  String? _gender;
"""
content = content.replace('  String? _gender;', controllers_code)

# 2. Init controllers
init_code = """
    _firstNameController = TextEditingController(text: profile['firstName']?.toString() ?? '');
    _lastNameController = TextEditingController(text: profile['lastName']?.toString() ?? '');
    _phoneController = TextEditingController(text: profile['phone']?.toString() ?? '');
    _whatsappNumberController = TextEditingController(text: profile['whatsappNumber']?.toString() ?? '');
    _heightController = TextEditingController(text: profile['height']?.toString() ?? '');
    _casteController = TextEditingController(text: profile['caste']?.toString() ?? '');
    _sindhiTypeController = TextEditingController(text: profile['sindhiType']?.toString() ?? '');
    _fathersOccupationController = TextEditingController(text: profile['fathersOccupation']?.toString() ?? '');
    _mothersOccupationController = TextEditingController(text: profile['mothersOccupation']?.toString() ?? '');
    _siblingsDetailsController = TextEditingController(text: profile['siblingsDetails']?.toString() ?? '');
    
    _manglikStatus = profile['manglikStatus']?.toString();
"""
content = content.replace("    _manglikStatus = profile['manglikStatus']?.toString();", init_code)

# 3. Dispose controllers
dispose_code = """
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _whatsappNumberController.dispose();
    _heightController.dispose();
    _casteController.dispose();
    _sindhiTypeController.dispose();
    _fathersOccupationController.dispose();
    _mothersOccupationController.dispose();
    _siblingsDetailsController.dispose();
    super.dispose();
"""
content = content.replace('    super.dispose();', dispose_code)

# 4. Payload
payload_code = """
    final isDeveloper = provider.phoneNumber == '9413879444' || widget.adminEditUser != null;
    // If in admin mode, allow editing gender as well.
    if (isDeveloper && _gender != null) {
      payload['gender'] = _gender;
    }
    
    if (isDeveloper) {
      payload['firstName'] = _firstNameController.text.trim();
      payload['lastName'] = _lastNameController.text.trim();
      payload['phone'] = _phoneController.text.trim();
      payload['whatsappNumber'] = _whatsappNumberController.text.trim();
      payload['height'] = _heightController.text.trim();
      payload['caste'] = _casteController.text.trim();
      payload['sindhiType'] = _sindhiTypeController.text.trim();
      payload['fathersOccupation'] = _fathersOccupationController.text.trim();
      payload['mothersOccupation'] = _mothersOccupationController.text.trim();
      payload['siblingsDetails'] = _siblingsDetailsController.text.trim();
    }
"""
content = content.replace("""    // If in admin mode, allow editing gender as well.
    if ((provider.phoneNumber == '9413879444' || widget.adminEditUser != null) && _gender != null) {
      payload['gender'] = _gender;
    }""", payload_code)

# 5. UI Fields
ui_code = """
              if (isDeveloper) ...[
                Text(
                  'Core Details (Admin Only)',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppTheme.textCarbon,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(labelText: 'First Name', controller: _firstNameController),
                const SizedBox(height: 8),
                CustomTextField(labelText: 'Last Name', controller: _lastNameController),
                const SizedBox(height: 8),
                CustomTextField(labelText: 'Phone', controller: _phoneController),
                const SizedBox(height: 8),
                CustomTextField(labelText: 'WhatsApp', controller: _whatsappNumberController),
                const SizedBox(height: 8),
                CustomTextField(labelText: 'Height', controller: _heightController),
                const SizedBox(height: 8),
                CustomTextField(labelText: 'Caste', controller: _casteController),
                const SizedBox(height: 8),
                CustomTextField(labelText: 'Sindhi Type', controller: _sindhiTypeController),
                const SizedBox(height: 8),
                CustomTextField(labelText: 'Father Occupation', controller: _fathersOccupationController),
                const SizedBox(height: 8),
                CustomTextField(labelText: 'Mother Occupation', controller: _mothersOccupationController),
                const SizedBox(height: 8),
                CustomTextField(labelText: 'Siblings Details', controller: _siblingsDetailsController),
                const SizedBox(height: 16),
                
                Text(
                  'Gender (Admin Only)',
"""
content = content.replace("""              if (isDeveloper) ...[
                Text(
                  'Gender (Developer Only)',""", ui_code)

with open(file_path, 'w') as f:
    f.write(content)
print("File updated successfully.")
