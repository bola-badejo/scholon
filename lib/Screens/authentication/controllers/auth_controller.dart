import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/Kidling/screens/kidling_homescreen.dart';
import 'package:isapp/Screens/authentication/controllers/authentication_controller.dart';
import 'package:isapp/Screens/home/parent_home.dart';
import 'package:isapp/Screens/home/school_home.dart';
import 'package:isapp/Screens/home/teacher_home.dart';
import 'package:isapp/screens/home/home_page.dart';

enum AuthMode { signIn, signUp }

class AuthenticationController extends GetxController {
  final AuthService authService = Get.find();

  String selectedPlatform = 'istudyapp';
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Student specific controllers
  final TextEditingController classGradeController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();
  final TextEditingController parentNameController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController parentPhoneController = TextEditingController();
  final TextEditingController studentNameController = TextEditingController();

  // Teacher specific controllers
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController teacherAddressController =
      TextEditingController();
  final TextEditingController emergencyContactController =
      TextEditingController();
  final TextEditingController teacherSchoolNameController =
      TextEditingController();
  final TextEditingController schoolAddressController = TextEditingController();
  final TextEditingController schoolPhoneController = TextEditingController();
  final TextEditingController schoolEmailController = TextEditingController();

  // School admin specific controllers
  final TextEditingController schoolCodeController = TextEditingController();
  final TextEditingController adminNameController = TextEditingController();
  final TextEditingController adminEmailController = TextEditingController();
  final TextEditingController adminAddressController = TextEditingController();

  // Parent specific controllers
  final TextEditingController relationshipController = TextEditingController();
  final TextEditingController parentAddressController = TextEditingController();
  final TextEditingController childClassController = TextEditingController();

  // KIDLING SPECIFIC CONTROLLERS
  final TextEditingController childNameController = TextEditingController();
  final TextEditingController childAgeController = TextEditingController();
  final TextEditingController learningInterestController =
      TextEditingController();
  final TextEditingController referralSourceController =
      TextEditingController();

  // State variables
  final Rx<AuthMode> authMode = AuthMode.signIn.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxString selectedCategory = 'Basic Education'.obs;
  final RxString selectedGrade = '1'.obs;
  final RxString selectedGender = 'Male'.obs;
  final Rx<DateTime?> selectedDateOfBirth = Rx<DateTime?>(null);
  final RxBool isSubmitting = false.obs;

  // Kidling specific state variables
  final RxString selectedLearningInterest = ''.obs;
  final RxString preferredLearningTime = ''.obs;

  // Form validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxString emailError = ''.obs;
  final RxString phoneError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString confirmPasswordError = ''.obs;
  final RxString nameError = ''.obs;
  final RxString schoolNameError = ''.obs;
  final RxString parentNameError = ''.obs;
  final RxString qualificationError = ''.obs;
  final RxString subjectError = ''.obs;
  final RxString experienceError = ''.obs;
  final RxString addressError = ''.obs;
  final RxString studentNameError = ''.obs;
  final RxString studentIdError = ''.obs;
  final RxString schoolCodeError = ''.obs;
  final RxString adminNameError = ''.obs;
  final RxString relationshipError = ''.obs;
  final RxString emergencyContactError = ''.obs;
  final RxString dobError = ''.obs;

  // Kidling specific error messages
  final RxString childNameError = ''.obs;
  final RxString childAgeError = ''.obs;
  final RxString learningInterestError = ''.obs;

  // Available grades based on category
  final List<String> basicEducationGrades = List.generate(
    9,
    (index) => (index + 1).toString(),
  );
  final List<String> seniorSecondaryGrades = ['1', '2', '3'];

  @override
  void onInit() {
    super.onInit();
    setupTextControllers();
  }

  @override
  void onClose() {
    // Dispose all controllers
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    classGradeController.dispose();
    schoolNameController.dispose();
    parentNameController.dispose();
    studentIdController.dispose();
    dobController.dispose();
    parentPhoneController.dispose();
    qualificationController.dispose();
    studentNameController.dispose();
    subjectController.dispose();
    experienceController.dispose();
    teacherAddressController.dispose();
    emergencyContactController.dispose();
    teacherSchoolNameController.dispose();
    schoolAddressController.dispose();
    schoolPhoneController.dispose();
    schoolEmailController.dispose();
    schoolCodeController.dispose();
    adminNameController.dispose();
    adminEmailController.dispose();
    adminAddressController.dispose();
    relationshipController.dispose();
    parentAddressController.dispose();
    childClassController.dispose();

    // Dispose Kidling controllers
    childNameController.dispose();
    childAgeController.dispose();
    learningInterestController.dispose();
    referralSourceController.dispose();

    super.onClose();
  }

  void setupTextControllers() {
    // Set up listeners for real-time validation
    phoneController.addListener(
      () => validatePhoneNumber(phoneController.text),
    );
    emailController.addListener(() => validateEmail(emailController.text));
    passwordController.addListener(
      () => validatePassword(passwordController.text),
    );
    confirmPasswordController.addListener(
      () => validateConfirmPassword(confirmPasswordController.text),
    );
    nameController.addListener(() => validateName(nameController.text));
    schoolNameController.addListener(
      () => validateSchoolName(schoolNameController.text),
    );
    parentNameController.addListener(
      () => validateParentName(parentNameController.text),
    );
    qualificationController.addListener(
      () => validateQualification(qualificationController.text),
    );
    subjectController.addListener(
      () => validateSubject(subjectController.text),
    );
    experienceController.addListener(
      () => validateExperience(experienceController.text),
    );
    emergencyContactController.addListener(
      () => validateEmergencyContact(emergencyContactController.text),
    );
    studentIdController.addListener(
      () => validateStudentId(studentIdController.text),
    );
    schoolCodeController.addListener(
      () => validateSchoolCode(schoolCodeController.text),
    );
    adminNameController.addListener(
      () => validateAdminName(adminNameController.text),
    );
    relationshipController.addListener(
      () => validateRelationship(relationshipController.text),
    );

    // Kidling listeners
    childNameController.addListener(
      () => validateChildName(childNameController.text),
    );
    childAgeController.addListener(
      () => validateChildAge(childAgeController.text),
    );
  }

  // Category change handler
  void onCategoryChanged(String? value) {
    if (value != null) {
      selectedCategory.value = value;
      selectedGrade.value = '1';
    }
  }

  // Grade change handler
  void onGradeChanged(String? value) {
    if (value != null) {
      selectedGrade.value = value;
    }
  }

  // Gender change handler
  void onGenderChanged(String? value) {
    if (value != null) {
      selectedGender.value = value;
    }
  }

  // Date of birth selection
  Future<void> selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      selectedDateOfBirth.value = picked;
      dobController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  // Switch between sign in and sign up modes
  void switchAuthMode() {
    authMode.value = authMode.value == AuthMode.signIn
        ? AuthMode.signUp
        : AuthMode.signIn;
    clearAllErrors();
    clearForm();
    update(); // Notify listeners
  }

  // Clear all form fields
  void clearForm() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();

    // Clear platform-specific fields
    switch (selectedPlatform) {
      case 'kidling':
        childNameController.clear();
        childAgeController.clear();
        learningInterestController.clear();
        referralSourceController.clear();
        selectedLearningInterest.value = '';
        preferredLearningTime.value = '';
        break;
      case 'istudyapp':
        classGradeController.clear();
        schoolNameController.clear();
        parentNameController.clear();
        studentIdController.clear();
        dobController.clear();
        parentPhoneController.clear();
        studentNameController.clear();
        break;
      case 'teachly':
        qualificationController.clear();
        subjectController.clear();
        experienceController.clear();
        teacherAddressController.clear();
        emergencyContactController.clear();
        teacherSchoolNameController.clear();
        schoolAddressController.clear();
        schoolPhoneController.clear();
        schoolEmailController.clear();
        break;
      case 'automated_school':
        schoolCodeController.clear();
        adminNameController.clear();
        adminEmailController.clear();
        adminAddressController.clear();
        break;
      case 'parents_portal':
        parentNameController.clear();
        studentIdController.clear();
        relationshipController.clear();
        parentAddressController.clear();
        childClassController.clear();
        break;
    }

    clearAllErrors();
    selectedDateOfBirth.value = null;
    selectedCategory.value = 'Basic Education';
    selectedGrade.value = '1';
    selectedGender.value = 'Male';
  }

  // Clear all error messages
  void clearAllErrors() {
    emailError.value = '';
    phoneError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';
    nameError.value = '';
    schoolNameError.value = '';
    parentNameError.value = '';
    qualificationError.value = '';
    subjectError.value = '';
    experienceError.value = '';
    addressError.value = '';
    studentNameError.value = '';
    studentIdError.value = '';
    schoolCodeError.value = '';
    adminNameError.value = '';
    relationshipError.value = '';
    emergencyContactError.value = '';
    dobError.value = '';

    // Clear Kidling errors
    childNameError.value = '';
    childAgeError.value = '';
    learningInterestError.value = '';
  }

  // KIDLING VALIDATION METHODS
  String? validateChildName(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('Child name is required');
      return 'Child\'s name is required';
    }
    return null;
  }

  String? validateChildAge(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('Child age is required');
      return 'Child\'s age is required';
    }

    if (value != null && value.isNotEmpty) {
      final age = int.tryParse(value);
      if (age == null) {
        print('Valid age is required');
        return 'Please enter a valid age';
      }
      if (age < 2 || age > 6) {
        print('Age must be between 2 and 6');
        return 'Kidling is designed for children ages 2-6';
      }
    }

    return null;
  }

  String? validateLearningInterest(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('Learning interest is required');
      return 'Please select a learning interest';
    }
    return null;
  }

  // Validation methods (UPDATED FOR BETTER ERROR HANDLING)
  String? validateEmail(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('Email is required');
      return 'Email is required';
    }

    if (value != null && value.isNotEmpty) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        print('valid Email is required');
        return 'Enter a valid email address';
      }
    }

    return null;
  }

  String? validatePhoneNumber(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('phone number is required');
      return 'Phone number is required';
    }

    if (value != null && value.isNotEmpty) {
      final cleanedNumber = value.replaceAll(RegExp(r'[^\d]'), '');
      if (!RegExp(r'^[0-9]{11}$').hasMatch(cleanedNumber)) {
        print('Valid Phone Number is required');
        return 'Enter a valid 11-digit phone number';
      }
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      print('password is required');
      return 'Password is required';
    }

    if (value.length < 6) {
      print('> 6 character password is required');
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      print('Passwor confirmation is required');
      return 'Please confirm your password';
    }

    if (value != passwordController.text) {
      print('Matching password is required');
      return 'Passwords do not match';
    }

    return null;
  }

  String? validateName(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('Name is required');
      return 'Name is required';
    }

    if (value != null && value.isNotEmpty) {
      if (value.trim().split(' ').length < 2) {
        print('full name is required');
        return 'Please enter full name (first and last)';
      }
    }

    return null;
  }

  String? validateSchoolName(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('school name is required');
      return 'School name is required';
    }
    return null;
  }

  String? validateParentName(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('Parent name is required');
      return 'Parent name is required';
    }
    return null;
  }

  String? validateQualification(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('qualification is required');
      return 'Qualification is required';
    }
    return null;
  }

  String? validateSubject(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('subject specialization is required');
      return 'Subject specialization is required';
    }
    return null;
  }

  String? validateExperience(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('years of experience is required');
      return 'Years of experience is required';
    }

    if (value != null && value.isNotEmpty) {
      final years = int.tryParse(value);
      if (years == null || years < 0) {
        print('Valid years of experience is required');
        return 'Enter valid years of experience';
      }
    }

    return null;
  }

  String? validateAddress(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('address is required');
      return 'Address is required';
    }
    return null;
  }

  String? validateStudentName(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('student name is required');
      return 'Student name is required';
    }
    return null;
  }

  String? validateStudentId(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('student id is required');
      return 'Student ID is required';
    }
    return null;
  }

  String? validateSchoolCode(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('sxchool cde is required');
      return 'School code is required';
    }
    return null;
  }

  String? validateAdminName(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('Admin name is required');
      return 'Admin name is required';
    }
    return null;
  }

  String? validateRelationship(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('Relationship is required');
      return 'Relationship is required';
    }
    return null;
  }

  String? validateEmergencyContact(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('Emergency Contact is required');
      return 'Emergency contact is required';
    }

    if (value != null && value.isNotEmpty) {
      final cleanedNumber = value.replaceAll(RegExp(r'[^\d]'), '');
      if (!RegExp(r'^[0-9]{11}$').hasMatch(cleanedNumber)) {
        print('valid 11 digit is required');
        return 'Enter a valid 11-digit phone number';
      }
    }

    return null;
  }

  String? validateDOB(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      print('DOB is required');
      return 'Date of birth is required';
    }

    if (selectedDateOfBirth.value != null) {
      final age =
          DateTime.now().difference(selectedDateOfBirth.value!).inDays ~/ 365;
      if (age < 5) {
        print('Older than 5 is required');
        return 'Must be at least 5 years old';
      }
    }

    return null;
  }

  // Validate entire form based on platform - FIXED VERSION
  bool validateForm() {
    clearAllErrors();
    bool isValid = true;

    // For Sign In mode
    if (authMode.value == AuthMode.signIn) {
      // Validate email/phone - for iStudyApp and Kidling use email, others can use phone or email
      String? identifier = emailController.text.trim();
      if (identifier.isEmpty &&
          (selectedPlatform == 'istudyapp' || selectedPlatform == 'kidling')) {
        emailError.value = 'Email is required';
        isValid = false;
      } else if (identifier.isEmpty) {
        // For other platforms, check phone too
        if (phoneController.text.trim().isEmpty) {
          phoneError.value = 'Email or phone is required';
          isValid = false;
        }
      } else {
        // Validate email format if email is provided
        if (identifier.contains('@')) {
          final emailError = validateEmail(identifier);
          if (emailError != null) {
            this.emailError.value = emailError;
            isValid = false;
          }
        }
      }

      // Validate password
      final passwordError = validatePassword(passwordController.text);
      if (passwordError != null) {
        this.passwordError.value = passwordError;
        isValid = false;
      }
    }
    // For Sign Up mode
    else {
      final nameError = validateName(nameController.text);
      if (nameError != null) {
        this.nameError.value = nameError;
        isValid = false;
      }

      // Validate email
      final emailError = validateEmail(emailController.text);
      if (emailError != null) {
        this.emailError.value = emailError;
        isValid = false;
      }

      // Validate phone
      final phoneError = validatePhoneNumber(phoneController.text);
      if (phoneError != null) {
        this.phoneError.value = phoneError;
        isValid = false;
      }

      // Validate password
      final passwordError = validatePassword(passwordController.text);
      if (passwordError != null) {
        this.passwordError.value = passwordError;
        isValid = false;
      }

      // Validate confirm password
      final confirmPasswordError = validateConfirmPassword(
        confirmPasswordController.text,
      );
      if (confirmPasswordError != null) {
        this.confirmPasswordError.value = confirmPasswordError;
        isValid = false;
      }

      // PLATFORM-SPECIFIC VALIDATIONS
      switch (selectedPlatform) {
        case 'kidling':
          final childNameError = validateChildName(childNameController.text);
          if (childNameError != null) {
            this.childNameError.value = childNameError;
            isValid = false;
          }

          final childAgeError = validateChildAge(childAgeController.text);
          if (childAgeError != null) {
            this.childAgeError.value = childAgeError;
            isValid = false;
          }

          final learningInterestError = validateLearningInterest(
            selectedLearningInterest.value,
          );
          if (learningInterestError != null) {
            this.learningInterestError.value = learningInterestError;
            isValid = false;
          }
          break;

        case 'istudyapp':
          final schoolNameError = validateSchoolName(schoolNameController.text);
          if (schoolNameError != null) {
            this.schoolNameError.value = schoolNameError;
            isValid = false;
          }

          final parentNameError = validateParentName(parentNameController.text);
          if (parentNameError != null) {
            this.parentNameError.value = parentNameError;
            isValid = false;
          }

          final dobError = validateDOB(dobController.text);
          if (dobError != null) {
            this.dobError.value = dobError;
            isValid = false;
          }
          break;

        case 'teachly':
          final qualificationError = validateQualification(
            qualificationController.text,
          );
          if (qualificationError != null) {
            this.qualificationError.value = qualificationError;
            isValid = false;
          }

          final subjectError = validateSubject(subjectController.text);
          if (subjectError != null) {
            this.subjectError.value = subjectError;
            isValid = false;
          }

          final experienceError = validateExperience(experienceController.text);
          if (experienceError != null) {
            this.experienceError.value = experienceError;
            isValid = false;
          }

          final emergencyContactError = validateEmergencyContact(
            emergencyContactController.text,
          );
          if (emergencyContactError != null) {
            this.emergencyContactError.value = emergencyContactError;
            isValid = false;
          }

          final teacherSchoolNameError = validateSchoolName(
            teacherSchoolNameController.text,
          );
          if (teacherSchoolNameError != null) {
            this.schoolNameError.value = teacherSchoolNameError;
            isValid = false;
          }
          break;

        case 'automated_school':
          final adminNameError = validateAdminName(adminNameController.text);
          if (adminNameError != null) {
            this.adminNameError.value = adminNameError;
            isValid = false;
          }

          final nameError = validateName(nameController.text);
          if (nameError != null) {
            this.nameError.value = nameError;
            isValid = false;
          }

          final schoolCodeError = validateSchoolCode(schoolCodeController.text);
          if (schoolCodeError != null) {
            this.schoolCodeError.value = schoolCodeError;
            isValid = false;
          }

          final schoolNameError = validateSchoolName(schoolNameController.text);
          if (schoolNameError != null) {
            this.schoolNameError.value = schoolNameError;
            isValid = false;
          }
          break;

        case 'parents_portal':
          final relationshipError = validateRelationship(
            relationshipController.text,
          );
          if (relationshipError != null) {
            this.relationshipError.value = relationshipError;
            isValid = false;
          }

          final studentNameError = validateStudentName(
            studentNameController.text,
          );
          if (studentNameError != null) {
            this.studentNameError.value = studentNameError;
            isValid = false;
          }

          final studentIdError = validateStudentId(studentIdController.text);
          if (studentIdError != null) {
            this.studentIdError.value = studentIdError;
            isValid = false;
          }
          break;
      }
    }

    return isValid;
  }

  // Get class grade as integer
  int getClassGrade() {
    return int.tryParse(selectedGrade.value) ?? 1;
  }

  // Get available grades for current category
  List<String> getAvailableGrades() {
    return selectedCategory.value == 'Basic Education'
        ? basicEducationGrades
        : seniorSecondaryGrades;
  }

  // Get grade display name
  String getGradeDisplayName(String grade) {
    return selectedCategory.value == 'Basic Education'
        ? 'Basic $grade'
        : 'SS $grade';
  }

  // Get form data for specific platform
  Map<String, dynamic> getFormDataForPlatform() {
    final data = {
      'platform': selectedPlatform,
      'authMode': authMode.value.name,
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'password': passwordController.text.trim(),
      'confirmPassword': confirmPasswordController.text.trim(),
    };

    // Add email based on platform
    switch (selectedPlatform) {
      case 'kidling':
        data['email'] = emailController.text.trim().toLowerCase();
        data['parentEmail'] = emailController.text.trim().toLowerCase();
        break;
      case 'istudyapp':
        data['email'] = emailController.text.trim().toLowerCase();
        data['parentEmail'] = emailController.text.trim().toLowerCase();
        break;
      case 'teachly':
        data['email'] = emailController.text.trim().toLowerCase();
        break;
      case 'automated_school':
        data['email'] = emailController.text.trim().toLowerCase();
        data['adminEmail'] = emailController.text.trim().toLowerCase();
        break;
      case 'parents_portal':
        data['email'] = emailController.text.trim().toLowerCase();
        break;
    }

    if (authMode.value == AuthMode.signUp) {
      switch (selectedPlatform) {
        case 'kidling':
          data.addAll({
            'parentName': nameController.text.trim(),
            'childName': childNameController.text.trim(),
            'childAge': (int.tryParse(childAgeController.text.trim()) ?? 4)
                .toString(),
            'childGender': selectedGender.value,
            'learningInterest': selectedLearningInterest.value,
            'preferredLearningTime': preferredLearningTime.value.isNotEmpty
                ? preferredLearningTime.value
                : 'Flexible',
            'referralSource': referralSourceController.text.trim().isNotEmpty
                ? referralSourceController.text.trim()
                : 'Direct',
          });
          break;

        case 'istudyapp':
          data.addAll({
            'studentName': nameController.text.trim(),
            'classGrade': getClassGrade().toString(),
            'schoolName': schoolNameController.text.trim(),
            'parentName': parentNameController.text.trim(),
            'parentPhone': parentPhoneController.text.isNotEmpty
                ? parentPhoneController.text.trim()
                : phoneController.text.trim(),
            'studentId': studentIdController.text.trim(),
            'dateOfBirth': selectedDateOfBirth.value != null
                ? selectedDateOfBirth.value!.toIso8601String()
                : DateTime.now()
                      .subtract(const Duration(days: 365 * 10))
                      .toIso8601String(),
            'gender': selectedGender.value,
            'educationCategory': selectedCategory.value,
          });
          break;

        case 'teachly':
          data.addAll({
            'teacherName': nameController.text.trim(),
            'qualification': qualificationController.text.trim(),
            'subject': subjectController.text.trim(),
            'experience': experienceController.text.trim(),
            'address': teacherAddressController.text.trim(),
            'emergencyContact': emergencyContactController.text.trim(),
            'schoolName': teacherSchoolNameController.text.trim(),
            'schoolAddress': schoolAddressController.text.trim(),
            'schoolPhone': schoolPhoneController.text.trim(),
            'schoolEmail': schoolEmailController.text.trim(),
            'dateOfBirth': selectedDateOfBirth.value != null
                ? selectedDateOfBirth.value!.toIso8601String()
                : DateTime.now()
                      .subtract(const Duration(days: 365 * 25))
                      .toIso8601String(),
            'gender': selectedGender.value,
          });
          break;

        case 'automated_school':
          data.addAll({
            'schoolName': schoolNameController.text.trim(),
            'schoolCode': schoolCodeController.text.trim(),
            'adminName': adminNameController.text.trim(),
            'schoolAddress': adminAddressController.text.trim(),
          });
          break;

        case 'parents_portal':
          data.addAll({
            'parentName': nameController.text.trim(),
            'relationship': relationshipController.text.trim(),
            'address': parentAddressController.text.trim(),
            'studentName': studentNameController.text.trim(),
            'studentId': studentIdController.text.trim(),
            'studentClass': childClassController.text.trim(),
            'gender': selectedGender.value,
          });
          break;
      }
    }

    return data;
  }

  // Submit form based on auth mode and platform - FIXED VERSION
  Future<void> submitForm() async {
    // Clear all errors first
    clearAllErrors();

    // Validate form
    if (!validateForm()) {
      Get.snackbar(
        'Validation Error',
        'Please fix all errors before submitting',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;

    try {
      if (authMode.value == AuthMode.signUp) {
        await handleSignUp();
      } else {
        await handleSignIn();
      }
    } catch (e) {
      print('Submit form error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> handleSignUp() async {
    final formData = getFormDataForPlatform();

    final (success, error, userType) = await authService.signUp(
      platform: selectedPlatform,
      formData: formData,
    );

    if (success) {
      _navigateBasedOnUserType(userType, selectedPlatform);

      Get.snackbar(
        'Welcome!',
        'Your account has been created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } else {
      Get.snackbar(
        'Registration Failed',
        error ?? 'Please try again',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> handleSignIn() async {
    // Determine what to use as identifier
    String identifier;

    if (selectedPlatform == 'istudyapp' || selectedPlatform == 'kidling') {
      // For iStudyApp and Kidling, always use email
      identifier = emailController.text.trim();
    } else {
      // For other platforms, try email first, then phone
      identifier = emailController.text.trim().isNotEmpty
          ? emailController.text.trim()
          : phoneController.text.trim();
    }

    if (identifier.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter email or phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final (user, error, userType) = await authService.signIn(
      identifier,
      passwordController.text.trim(),
    );

    if (user != null) {
      if (error != null) {
        Get.snackbar(
          'Subscription Expired',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }

      // Use platform for navigation if userType is not kidling
      _navigateBasedOnUserType(userType, selectedPlatform);
    } else {
      Get.snackbar(
        'Sign In Failed',
        error ?? 'Please check your credentials and try again',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // FIXED: Helper method to navigate based on user type
  void _navigateBasedOnUserType(String? userType, String platform) {
    print('=== NAVIGATION DEBUG ===');
    print('UserType: $userType');
    print('Platform: $platform');
    
    // For Kidling platform, ALWAYS go to KidlingHomePage regardless of userType
    if (platform == 'kidling') {
      print('Navigating to KidlingHomePage (platform override)');
      Get.offAll(() => KidlingHomePage());
      return;
    }

    if (userType == null) {
      print('UserType is null, using platform fallback');
      _navigateByPlatform(platform);
      return;
    }

    switch (userType.toLowerCase()) {
      case 'kidling':
        print('Navigating to KidlingHomePage');
        Get.offAll(() => KidlingHomePage());
        break;
      case 'student':
        print('Navigating to HomeScreen');
        Get.offAll(() => HomeScreen());
        break;
      case 'teacher':
        print('Navigating to TeacherHomeScreen');
        Get.offAll(() => TeacherHomeScreen());
        break;
      case 'school_admin':
        print('Navigating to SchoolHomeScreen');
        Get.offAll(() => SchoolHomeScreen());
        break;
      case 'parent':
        print('Navigating to ParentHomeScreen');
        Get.offAll(() => ParentHomeScreen());
        break;
      default:
        print('Unknown userType: $userType, using platform fallback');
        _navigateByPlatform(platform);
    }
  }

  void _navigateByPlatform(String platform) {
    switch (platform) {
      case 'kidling':
        Get.offAll(() => KidlingHomePage());
        break;
      case 'istudyapp':
        Get.offAll(() => HomeScreen());
        break;
      case 'teachly':
        Get.offAll(() => TeacherHomeScreen());
        break;
      case 'automated_school':
        Get.offAll(() => SchoolHomeScreen());
        break;
      case 'parents_portal':
        Get.offAll(() => ParentHomeScreen());
        break;
      default:
        Get.offAll(() => HomeScreen());
    }
  }

  // FORGOT PASSWORD FUNCTION
  Future<void> handleForgotPassword() async {
    String email = '';

    if (emailController.text.trim().isNotEmpty) {
      email = emailController.text.trim();
    } else {
      // Show dialog to enter email
      final result = await Get.dialog<String>(
        Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text('Enter your email to receive a reset link'),
                const SizedBox(height: 20),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => email = value,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => Get.back(result: email),
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (result == null || result.isEmpty) return;
      email = result;
    }

    // Send reset email
    final success = await authService.sendPasswordResetEmail(email);

    if (success) {
      Get.snackbar(
        'Email Sent',
        'Check your inbox for password reset instructions',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to send reset email. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool get hasErrors {
    return emailError.isNotEmpty ||
        phoneError.isNotEmpty ||
        passwordError.isNotEmpty ||
        confirmPasswordError.isNotEmpty ||
        nameError.isNotEmpty ||
        schoolNameError.isNotEmpty ||
        parentNameError.isNotEmpty ||
        qualificationError.isNotEmpty ||
        subjectError.isNotEmpty ||
        experienceError.isNotEmpty ||
        addressError.isNotEmpty ||
        studentNameError.isNotEmpty ||
        studentIdError.isNotEmpty ||
        schoolCodeError.isNotEmpty ||
        adminNameError.isNotEmpty ||
        relationshipError.isNotEmpty ||
        emergencyContactError.isNotEmpty ||
        dobError.isNotEmpty ||
        childNameError.isNotEmpty ||
        childAgeError.isNotEmpty ||
        learningInterestError.isNotEmpty;
  }

  // Get current form validation status
  Map<String, bool> get validationStatus {
    final status = {
      'email': emailError.isEmpty,
      'phone': phoneError.isEmpty,
      'password': passwordError.isEmpty,
      'confirmPassword': confirmPasswordError.isEmpty,
      'name': nameError.isEmpty,
    };

    // Add platform-specific validations
    if (selectedPlatform == 'kidling') {
      status.addAll({
        'childName': childNameError.isEmpty,
        'childAge': childAgeError.isEmpty,
        'learningInterest': learningInterestError.isEmpty,
      });
    } else if (selectedPlatform == 'istudyapp') {
      status.addAll({
        'schoolName': schoolNameError.isEmpty,
        'parentName': parentNameError.isEmpty,
        'dob': dobError.isEmpty,
      });
    } else if (selectedPlatform == 'teachly') {
      status.addAll({
        'qualification': qualificationError.isEmpty,
        'subject': subjectError.isEmpty,
        'experience': experienceError.isEmpty,
        'address': addressError.isEmpty,
        'emergencyContact': emergencyContactError.isEmpty,
        'dob': dobError.isEmpty,
      });
    }

    return status;
  }

  void resetAll() {
    clearForm();
    selectedPlatform = 'istudyapp';
    authMode.value = AuthMode.signIn;
    selectedCategory.value = 'Basic Education';
    selectedGrade.value = '1';
    selectedGender.value = 'Male';
    selectedDateOfBirth.value = null;
    selectedLearningInterest.value = '';
    preferredLearningTime.value = '';
    update();
  }
}