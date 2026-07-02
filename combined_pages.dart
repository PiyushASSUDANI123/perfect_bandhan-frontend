  Widget _buildSaveAndContinueButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 40.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentGold,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            shadowColor: AppTheme.accentGold.withOpacity(0.4),
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
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              label: 'First Name',
              icon: Icons.person_outline,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _firstNameController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _surnameController,
              label: 'Surname',
              icon: Icons.badge_outlined,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _surnameController.text.trim().isNotEmpty,
            child: _buildSaveAndContinueButton(),
          ),
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
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
          ),
          AnimatedFieldReveal(
            isVisible: _emailController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _mobileNumberController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _mobileNumberController.text.trim().length >= 10,
            child: CustomTextField(
              controller: _whatsappNumberController,
              label: 'WhatsApp Number',
              icon: Icons.chat_bubble_outline,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _whatsappNumberController.text.trim().length >= 10,
            child: _buildSaveAndContinueButton(),
          ),
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
          CustomTextField(
            controller: _stateController,
            label: 'State',
            icon: Icons.map_outlined,
            onChanged: (_) => setState(() {}),
          ),
          AnimatedFieldReveal(
            isVisible: _stateController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _cityController,
              label: 'City',
              icon: Icons.location_city_outlined,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _cityController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _districtController,
              label: 'District',
              icon: Icons.landscape_outlined,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _districtController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _properAddressController,
              label: 'Proper Address',
              icon: Icons.home_outlined,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _properAddressController.text.trim().isNotEmpty,
            child: _buildSaveAndContinueButton(),
          ),
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
                initialDate: DateTime(2000),
                firstDate: DateTime(1950),
                lastDate: DateTime.now().subtract(const Duration(days: 6570)),
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
              label: 'Weight (kg)',
              icon: Icons.monitor_weight_outlined,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _weightController.text.trim().isNotEmpty,
            child: DropdownButtonFormField<String>(
              value: _complexion,
              hint: Text('Complexion', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
              decoration: _dropdownDeco(Icons.face_outlined),
              items: ['Very Fair', 'Fair', 'Wheatish', 'Dark'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _complexion = v),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _complexion != null,
            child: DropdownButtonFormField<String>(
              value: _hasDisability,
              hint: Text('Physical Disability?', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
              decoration: _dropdownDeco(Icons.accessible_forward_outlined),
              items: ['No', 'Yes'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _hasDisability = v),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _hasDisability == 'Yes',
            child: DropdownButtonFormField<String>(
              value: _disabilityType,
              hint: Text('Type of Disability', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
              decoration: _dropdownDeco(Icons.accessible_outlined),
              items: ['Visual Impairment', 'Hearing Impairment', 'Locomotor Disability', 'Other'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _disabilityType = v),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _hasDisability == 'No' || (_disabilityType != null && _disabilityType != 'Other') || (_disabilityType == 'Other' && _otherDisabilityController.text.isNotEmpty),
            child: _buildSaveAndContinueButton(),
          ),
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
          DropdownButtonFormField<String>(
            value: _maritalStatus,
            hint: Text('Marital Status', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
            decoration: _dropdownDeco(Icons.favorite_outline),
            items: ['Never Married', 'Awaiting Divorce', 'Divorced', 'Widowed'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _maritalStatus = v),
          ),
          const SizedBox(height: 24),
          AnimatedFieldReveal(
            isVisible: _maritalStatus != null,
            child: DropdownButtonFormField<String>(
              value: _manglikStatus,
              hint: Text('Manglik Status', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
              decoration: _dropdownDeco(Icons.star_outline),
              items: ['Not Manglik', 'Manglik', 'Anshik Manglik', 'Other'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _manglikStatus = v),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _manglikStatus != null,
            child: DropdownButtonFormField<String>(
              value: _medicalFit,
              hint: Text('Medically Fit?', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
              decoration: _dropdownDeco(Icons.health_and_safety_outlined),
              items: ['Yes', 'No'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _medicalFit = v),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _medicalFit != null,
            child: DropdownButtonFormField<String>(
              value: _sindhiType,
              hint: Text('Sindhi Sub-Sect', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
              decoration: _dropdownDeco(Icons.category_outlined),
              items: ['Sindhi Hindu', 'Amil', 'Bhaiband', 'Lohana', 'Larai', 'Lasi', 'Dahri', 'Sufi', 'Other'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _sindhiType = v),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _sindhiType != null,
            child: CustomTextField(
              controller: _nukhController,
              label: 'Nukh (Gotra)',
              icon: Icons.diversity_3_outlined,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _nukhController.text.trim().isNotEmpty,
            child: _buildSaveAndContinueButton(),
          ),
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
          CustomTextField(
            controller: _degreeControllers[0],
            label: 'Highest Education',
            icon: Icons.school_outlined,
            onChanged: (_) => setState(() {}),
          ),
          AnimatedFieldReveal(
            isVisible: _degreeControllers[0].text.trim().isNotEmpty,
            child: DropdownButtonFormField<String>(
              value: _profession,
              hint: Text('Profession', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
              decoration: _dropdownDeco(Icons.work_outline),
              items: ['Private Company', 'Government Job', 'Business/Self-Employed', 'Not Working'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _profession = v),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _profession != null && _profession != 'Not Working',
            child: CustomTextField(
              controller: _companyController,
              label: 'Company Name',
              icon: Icons.business_outlined,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _profession != null && _profession != 'Not Working' && _companyController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _jobPostController,
              label: 'Job Title / Designation',
              icon: Icons.badge_outlined,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _profession == 'Not Working' || (_profession != null && _jobPostController.text.trim().isNotEmpty),
            child: CustomTextField(
              controller: _monthlyIncomeController,
              label: 'Monthly Income',
              icon: Icons.currency_rupee_outlined,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _monthlyIncomeController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _yearlyIncomeController,
              label: 'Yearly Income',
              icon: Icons.account_balance_wallet_outlined,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _yearlyIncomeController.text.trim().isNotEmpty,
            child: _buildSaveAndContinueButton(),
          ),
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
          Text('Family Structure', style: GoogleFonts.cinzel(fontSize: 24, color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _fatherStatus,
            hint: Text('Father Status', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
            decoration: _dropdownDeco(Icons.person_outline),
            items: ['Alive', 'Passed Away'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _fatherStatus = v),
          ),
          const SizedBox(height: 24),
          AnimatedFieldReveal(
            isVisible: _fatherStatus != null,
            child: DropdownButtonFormField<String>(
              value: _motherStatus,
              hint: Text('Mother Status', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
              decoration: _dropdownDeco(Icons.person_2_outlined),
              items: ['Alive', 'Passed Away'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _motherStatus = v),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _motherStatus != null,
            child: CustomTextField(
              controller: _siblingsCountController,
              label: 'Number of Siblings',
              icon: Icons.people_outline,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _siblingsCountController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _siblingsDetailsController,
              label: 'Siblings Details (Married/Unmarried)',
              icon: Icons.info_outline,
              maxLines: 2,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _siblingsDetailsController.text.trim().isNotEmpty,
            child: DropdownButtonFormField<String>(
              value: _liveWithFamily,
              hint: Text('Live with Family?', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
              decoration: _dropdownDeco(Icons.home_outlined),
              items: ['Yes', 'No'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _liveWithFamily = v),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _liveWithFamily != null,
            child: CustomTextField(
              controller: _aboutFamilyController,
              label: 'About Family (Optional but recommended)',
              icon: Icons.family_restroom_outlined,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _liveWithFamily != null,
            child: _buildSaveAndContinueButton(),
          ),
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
          DropdownButtonFormField<String>(
            value: _ownHouse,
            hint: Text('Own House?', style: GoogleFonts.montserrat(color: AppTheme.textMuted)),
            decoration: _dropdownDeco(Icons.home_work_outlined),
            items: ['Yes', 'No'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _ownHouse = v),
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
                      if (val) _selectedHobbies.add(hobby);
                      else _selectedHobbies.remove(hobby);
                    });
                  },
                );
              }).toList(),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _ownHouse != null && _selectedHobbies.isNotEmpty,
            child: _buildSaveAndContinueButton(),
          ),
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
            label: 'Partner Requirements',
            icon: Icons.favorite_outline,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
          ),
          AnimatedFieldReveal(
            isVisible: _requirementsController.text.trim().isNotEmpty,
            child: CustomTextField(
              controller: _whatWeProvideController,
              label: 'What We Provide',
              icon: Icons.handshake_outlined,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
            ),
          ),
          AnimatedFieldReveal(
            isVisible: _whatWeProvideController.text.trim().isNotEmpty,
            child: _buildStep5Bio(), // Reuse the existing bio generator widget
          ),
          AnimatedFieldReveal(
            isVisible: _bioController.text.trim().isNotEmpty,
            child: _buildSaveAndContinueButton(),
          ),
        ],
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
          _buildStep6Photos(), // Reuse the existing photos grid
          
          const SizedBox(height: 40),
          AnimatedFieldReveal(
            isVisible: _uploadedPhotos.where((p) => p != null).isNotEmpty,
            child: _buildSaveAndContinueButton(), // In page 10, this will trigger the final submission
          ),
        ],
      ),
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
