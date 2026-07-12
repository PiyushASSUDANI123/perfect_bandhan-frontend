import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/widgets/edit_profile_sheet.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Replace CustomTextFields with required parameters
replacements = {
    "                  labelText: 'First Name',\n                  controller: _firstNameController,\n                )": 
    "                  labelText: 'First Name',\n                  hintText: 'Enter First Name',\n                  prefixIcon: Icons.person_outline,\n                  controller: _firstNameController,\n                )",
    
    "                  labelText: 'Last Name',\n                  controller: _lastNameController,\n                )": 
    "                  labelText: 'Last Name',\n                  hintText: 'Enter Last Name',\n                  prefixIcon: Icons.person_outline,\n                  controller: _lastNameController,\n                )",

    "                  labelText: 'Phone',\n                  controller: _phoneController,\n                )": 
    "                  labelText: 'Phone',\n                  hintText: 'Enter Phone',\n                  prefixIcon: Icons.phone_outlined,\n                  controller: _phoneController,\n                )",
    
    "                  labelText: 'WhatsApp',\n                  controller: _whatsappNumberController,\n                )": 
    "                  labelText: 'WhatsApp',\n                  hintText: 'Enter WhatsApp',\n                  prefixIcon: Icons.chat_bubble_outline,\n                  controller: _whatsappNumberController,\n                )",
    
    "                  labelText: 'Height',\n                  controller: _heightController,\n                )": 
    "                  labelText: 'Height',\n                  hintText: 'Enter Height',\n                  prefixIcon: Icons.height,\n                  controller: _heightController,\n                )",
    
    "                  labelText: 'Caste',\n                  controller: _casteController,\n                )": 
    "                  labelText: 'Caste',\n                  hintText: 'Enter Caste',\n                  prefixIcon: Icons.group_outlined,\n                  controller: _casteController,\n                )",
    
    "                  labelText: 'Sindhi Type',\n                  controller: _sindhiTypeController,\n                )": 
    "                  labelText: 'Sindhi Type',\n                  hintText: 'Enter Sindhi Type',\n                  prefixIcon: Icons.group_outlined,\n                  controller: _sindhiTypeController,\n                )",
    
    "                  labelText: 'Father Occupation',\n                  controller: _fathersOccupationController,\n                )": 
    "                  labelText: 'Father Occupation',\n                  hintText: 'Enter Father Occupation',\n                  prefixIcon: Icons.work_outline,\n                  controller: _fathersOccupationController,\n                )",
    
    "                  labelText: 'Mother Occupation',\n                  controller: _mothersOccupationController,\n                )": 
    "                  labelText: 'Mother Occupation',\n                  hintText: 'Enter Mother Occupation',\n                  prefixIcon: Icons.work_outline,\n                  controller: _mothersOccupationController,\n                )",
    
    "                  labelText: 'Siblings Details',\n                  controller: _siblingsDetailsController,\n                )": 
    "                  labelText: 'Siblings Details',\n                  hintText: 'Enter Siblings Details',\n                  prefixIcon: Icons.family_restroom_outlined,\n                  controller: _siblingsDetailsController,\n                )"
}

for old, new in replacements.items():
    content = content.replace(old, new)

with open(file_path, 'w') as f:
    f.write(content)
print("File updated successfully.")
