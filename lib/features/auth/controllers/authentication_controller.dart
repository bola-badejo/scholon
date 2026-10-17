import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:isapp/features/auth/models/user.dart';

class AuthService extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<dynamic> currentUser = Rx<dynamic>(null);
  final RxBool isLoading = false.obs;
  final RxString authError = ''.obs;
  StreamSubscription? _authSubscription;

  Future<dynamic> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) return null;

      return createUserFromMap(userDoc.data()!);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<void> _initializeUserConnections({
    required String userId,
    required String userType,
  }) async {
    try {
      print('Initializing connections for user: $userId');

      // Create empty connections document
      await _firestore.collection('connections').doc(userId).set({
        'userId': userId,
        'userType': userType,
        'connectedUsers': [],
        'schools': [],
        'teachers': [],
        'classmates': [],
        'parents': [],
        'courses': [],
        'jobs': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Connections initialized successfully');
    } catch (e) {
      print('Error initializing connections: $e');
    }
  }

  String getUserFirstName() {
    final user = currentUser.value;
    if (user == null || user.name.isEmpty) return 'User';

    final parts = user.name.split(' ');
    return parts.isNotEmpty ? parts[0] : 'User';
  }

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
      } else {
        currentUser.value = null;
      }
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        currentUser.value = createUserFromMap(doc.data()!);
      }
    } catch (e) {
      print('Error loading user data: $e');
      authError.value = 'Failed to load user data';
    }
  }

  // FIXED SIGN UP METHOD
  Future<(bool, String?, String?)> signUp({
    required String platform,
    required Map<String, dynamic> formData,
  }) async {
    try {
      isLoading.value = true;
      authError.value = '';

      print('=== SIGN UP DEBUG INFO ===');
      print('Platform: $platform');
      print('Form Data: $formData');

      final password = formData['password']?.toString() ?? '';
      final confirmPassword = formData['confirmPassword']?.toString() ?? '';

      if (password != confirmPassword) {
        print('Password mismatch error');
        return (false, 'Passwords do not match', null);
      }

      if (password.length < 6) {
        print('Password too short error');
        return (false, 'Password must be at least 6 characters', null);
      }

      String? email;
      String? phone;

      switch (platform) {
        case 'kidling':
          email =
              formData['parentEmail']?.toString() ??
              formData['email']?.toString();
          phone = formData['phone']?.toString();
          break;
        case 'istudyapp':
          email =
              formData['parentEmail']?.toString() ??
              formData['email']?.toString();
          phone =
              formData['parentPhone']?.toString() ??
              formData['phone']?.toString();
          break;
        default:
          email = formData['email']?.toString();
          phone = formData['phone']?.toString();
      }

      if (email == null || email.isEmpty) {
        print('No email found in form data');
        return (false, 'Email is required', null);
      }

      if (phone == null || phone.isEmpty) {
        print('No phone found in form data');
        return (false, 'Phone number is required', null);
      }

      final cleanedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
      if (!RegExp(r'^[0-9]{11}$').hasMatch(cleanedPhone)) {
        print('Invalid phone number error: $phone');
        return (false, 'Please enter a valid 11-digit phone number', null);
      }

      try {
        String normalizedEmail = email.trim().toLowerCase();
        print('Normalized email: $normalizedEmail');

        print('Creating Firebase Auth user...');
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: normalizedEmail,
              password: password,
            );

        print(
          'Firebase Auth user created successfully. UID: ${userCredential.user!.uid}',
        );

        final platformEnum = _getPlatformEnum(platform);
        final userType = _getUserTypeForPlatform(platform);

        final user = await _createPlatformUser(
          userId: userCredential.user!.uid,
          platform: platformEnum,
          userType: userType,
          formData: formData,
          email: normalizedEmail,
          phone: cleanedPhone,
        );

        print('Saving user to Firestore...');

        // Use the user's own toMap() method
        final userMap = user.toMap();
        
        // CRITICAL FIX: Override userType for Kidling platform
        if (platform == 'kidling') {
          userMap['userType'] = 'kidling';
          print('Overriding userType to: kidling');
        }

        // Debug: Print the map being saved
        print('=== USER MAP TO SAVE ===');
        userMap.forEach((key, value) {
          print('$key: $value (${value.runtimeType})');
        });

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userMap);

        print('User saved to Firestore successfully');

        await _initializeUserConnections(
          userId: userCredential.user!.uid,
          userType: platform == 'kidling' ? 'kidling' : userType.name,
        );

        await _createPlatformDetails(
          userId: userCredential.user!.uid,
          platform: platform,
          formData: formData,
        );

        currentUser.value = user;
        print('=== SIGN UP SUCCESSFUL ===');
        return (true, null, platform == 'kidling' ? 'kidling' : userType.name);
      } on FirebaseAuthException catch (e) {
        print('FirebaseAuthException: ${e.code} - ${e.message}');
        String errorMessage = 'Registration failed. ';
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'Password is too weak. Use at least 6 characters.';
            break;
          case 'email-already-in-use':
            errorMessage = 'An account already exists with this email.';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email format.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Email/password accounts are not enabled.';
            break;
          default:
            errorMessage = 'Registration failed. ${e.message}';
        }
        return (false, errorMessage, null);
      } on FirebaseException catch (e) {
        print('FirebaseException: ${e.code} - ${e.message}');
        return (false, 'Database error: ${e.message}', null);
      } catch (e) {
        print('General Exception: $e');
        return (false, 'An unexpected error occurred: $e', null);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // FIXED SIGN IN METHOD
  Future<(dynamic, String?, String?)> signIn(
    String identifier,
    String password,
  ) async {
    try {
      isLoading.value = true;

      String email;

      if (identifier.contains('@')) {
        email = identifier.trim().toLowerCase();
      } else {
        final cleanedIdentifier = identifier.replaceAll(RegExp(r'[^\d]'), '');
        final usersSnapshot = await _firestore
            .collection('users')
            .where('phoneNumber', isEqualTo: cleanedIdentifier)
            .limit(1)
            .get();

        if (usersSnapshot.docs.isEmpty) {
          return (null, 'No account found with this phone number.', null);
        }

        final userData = usersSnapshot.docs.first.data();
        email = userData['email']?.toString() ?? '';

        if (email.isEmpty) {
          return (
            null,
            'No email found for this account. Please use email to sign in.',
            null,
          );
        }
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return (null, 'User data not found. Please contact support.', null);
      }

      final userData = userDoc.data()!;
      
      // Check if this is a Kidling user (by platform or metadata)
      String actualUserType = userData['userType']?.toString() ?? 'student';
      final platform = userData['platform']?.toString() ?? '';
      
      // Override userType for Kidling platform
      if (platform == 'kidling') {
        actualUserType = 'kidling';
      }

      final appUser = createUserFromMap(userData);
      currentUser.value = appUser;

      bool hasValidSubscription = false;
      bool isOnTrial = false;

      // Check subscription based on user type
      if (appUser is StudentUser) {
        final subscription = appUser.currentSubscription;
        if (subscription != null) {
          hasValidSubscription =
              subscription.isActive && !subscription.hasExpired;
        }
        isOnTrial = appUser.isOnFreeTrial;
      } else if (appUser is TeacherUser) {
        final subscription = appUser.currentSubscription;
        if (subscription != null) {
          hasValidSubscription =
              subscription.isActive && !subscription.hasExpired;
        }
        isOnTrial = appUser.currentSubscription?.plan == SubscriptionPlan.trial;
      } else if (appUser is SchoolAdminUser) {
        final subscription = appUser.currentSubscription;
        if (subscription != null) {
          hasValidSubscription =
              subscription.isActive && !subscription.hasExpired;
        }
        isOnTrial = appUser.currentSubscription?.plan == SubscriptionPlan.trial;
      } else if (appUser is ParentUser) {
        // Check if this is a Kidling parent
        if (appUser.platform == Platform.kidling) {
          final subscription = appUser.kidlingSubscription;
          if (subscription != null) {
            hasValidSubscription =
                subscription.isActive && !subscription.hasExpired;
          }
          isOnTrial =
              appUser.kidlingSubscription?.kidlingPlan == KidlingPlan.free;
        } else {
          final subscription = appUser.currentSubscription;
          if (subscription != null) {
            hasValidSubscription =
                subscription.isActive && !subscription.hasExpired;
          }
          isOnTrial =
              appUser.currentSubscription?.plan ==
                  SubscriptionPlan.parentFree ||
              appUser.currentSubscription?.parentPlan == ParentPlan.free;
        }
      }

      String? subscriptionError;
      if (!hasValidSubscription && !isOnTrial) {
        subscriptionError =
            'Your subscription has expired. Please renew to continue.';
      }

      return (appUser, subscriptionError, actualUserType);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with these credentials.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
          break;
        default:
          errorMessage = 'Sign in failed. Please try again.';
      }
      return (null, errorMessage, null);
    } catch (e) {
      print('Sign in error: $e');
      return (null, 'An unexpected error occurred: $e', null);
    } finally {
      isLoading.value = false;
    }
  }

  // FORGOT PASSWORD
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
      return true;
    } catch (e) {
      print('Password reset error: $e');
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return false;

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      return true;
    } catch (e) {
      print('Change password error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      currentUser.value = null;
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<bool> checkSubscriptionStatus(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();

      if (data == null) {
        return false;
      }

      final userTypeString = data['userType'] as String? ?? 'student';
      final platform = data['platform'] as String? ?? '';
      
      UserType userType;
      if (platform == 'kidling') {
        userType = UserType.kidling;
      } else {
        userType = UserType.values.firstWhere(
          (e) => e.name == userTypeString,
          orElse: () => UserType.student,
        );
      }

      if (userType == UserType.kidling) {
        if (data['kidlingSubscription'] == null) return false;
        final subscription = KidlingSubscription.fromMap(
          Map<String, dynamic>.from(data['kidlingSubscription']),
        );
        return subscription.isActive && !subscription.hasExpired;
      }

      if (data['currentSubscription'] == null) {
        return false;
      }

      final subscription = createSubscriptionForUserType(
        userType,
        data['currentSubscription'],
      );
      return subscription.isActive && !subscription.hasExpired;
    } catch (e) {
      print('Error checking subscription: $e');
      return false;
    }
  }

  // HELPER METHODS
  Future<dynamic> _createPlatformUser({
    required String userId,
    required Platform platform,
    required UserType userType,
    required Map<String, dynamic> formData,
    required String email,
    required String phone,
  }) async {
    final now = DateTime.now();

    // Create subscription based on user type
    Subscription? subscription;
    try {
      switch (userType) {
        case UserType.student:
          subscription = StudentSubscription.create(plan: StudentPlan.trial);
          break;
        case UserType.teacher:
          subscription = TeacherSubscription.create(plan: TeacherPlan.trial);
          break;
        case UserType.schoolAdmin:
          subscription = SchoolSubscription.create(plan: SchoolPlan.trial);
          break;
        case UserType.parent:
          subscription = ParentSubscription.create(plan: ParentPlan.free);
          break;
        case UserType.kidling:
          subscription = KidlingSubscription.create(plan: KidlingPlan.free);
          break;
      }
    } catch (e) {
      print('Error creating subscription: $e');
      subscription = null;
    }

    switch (userType) {
      case UserType.student:
        DateTime? dob;
        try {
          if (formData['dateOfBirth'] != null) {
            dob = DateTime.parse(formData['dateOfBirth'].toString());
          }
        } catch (e) {
          print('Error parsing date of birth: $e');
          dob = null;
        }

        return StudentUser(
          uid: userId,
          email: email,
          name:
              formData['studentName']?.toString() ??
              formData['name']?.toString() ??
              '',
          platform: platform,
          createdAt: now,
          status: UserStatus.active,
          profileImageUrl: null,
          phoneNumber: phone,
          dateOfBirth: dob,
          gender: formData['gender']?.toString(),
          address: formData['address']?.toString(),
          metadata: null,
          classGrade:
              int.tryParse(formData['classGrade']?.toString() ?? '1') ?? 1,
          schoolName: formData['schoolName']?.toString() ?? '',
          educationCategory:
              formData['educationCategory']?.toString() ?? 'Basic Education',
          parentName: formData['parentName']?.toString() ?? '',
          parentPhone: formData['parentPhone']?.toString() ?? phone,
          parentEmail: formData['parentEmail']?.toString() ?? email,
          studentId:
              formData['studentId']?.toString() ?? userId.substring(0, 8),
          enrolledCourses: [],
          courseProgress: {},
          totalStudyTime: 0,
          quizScores: 0,
          completedLessons: 0,
          currentSubscription: subscription as StudentSubscription?,
        );

      case UserType.kidling:
        // Parse child age safely
        int childAge = 4;
        try {
          childAge = int.tryParse(formData['childAge']?.toString() ?? '4') ?? 4;
        } catch (e) {
          print('Error parsing child age: $e');
        }

        return ParentUser(
          uid: userId,
          email: email,
          name:
              formData['parentName']?.toString() ??
              formData['name']?.toString() ??
              '',
          platform: platform,
          createdAt: now,
          status: UserStatus.active,
          profileImageUrl: null,
          phoneNumber: phone,
          dateOfBirth: null,
          gender: formData['gender']?.toString(),
          address: formData['address']?.toString() ?? '',
          metadata: {
            'isKidlingParent': true,
            'childName': formData['childName']?.toString() ?? '',
            'childAge': childAge,
            'childGender':
                formData['childGender']?.toString() ??
                formData['gender']?.toString(),
            'learningInterest': formData['learningInterest']?.toString() ?? '',
            'preferredLearningTime':
                formData['preferredLearningTime']?.toString() ?? '',
            'referralSource': formData['referralSource']?.toString() ?? '',
          },
          relationship: 'Parent',
          studentName: formData['childName']?.toString() ?? '',
          studentId: userId.substring(0, 8),
          studentClass: 'Kidling',
          schoolName: 'Kidling Learning',
          children: [],
          notifications: [],
          currentSubscription: null,
          kidlingSubscription: subscription as KidlingSubscription?,
        );

      case UserType.teacher:
        DateTime? dob;
        try {
          if (formData['dateOfBirth'] != null) {
            dob = DateTime.parse(formData['dateOfBirth'].toString());
          }
        } catch (e) {
          print('Error parsing date of birth: $e');
          dob = null;
        }

        return TeacherUser(
          uid: userId,
          email: email,
          name:
              formData['teacherName']?.toString() ??
              formData['name']?.toString() ??
              '',
          platform: platform,
          createdAt: now,
          status: UserStatus.active,
          profileImageUrl: null,
          phoneNumber: phone,
          dateOfBirth: dob,
          gender: formData['gender']?.toString(),
          address: formData['address']?.toString(),
          metadata: null,
          qualification: formData['qualification']?.toString() ?? '',
          subjectSpecialization: formData['subject']?.toString() ?? '',
          yearsOfExperience: formData['experience']?.toString() ?? '',
          emergencyContact: formData['emergencyContact']?.toString() ?? phone,
          teacherId:
              formData['teacherId']?.toString() ?? userId.substring(0, 8),
          schoolName: formData['schoolName']?.toString() ?? '',
          schoolAddress: formData['schoolAddress']?.toString() ?? '',
          schoolPhone: formData['schoolPhone']?.toString() ?? phone,
          schoolEmail: formData['schoolEmail']?.toString() ?? email,
          createdResources: [],
          joinedCommunities: [],
          totalStudents: 0,
          currentSubscription: subscription as TeacherSubscription?,
        );

      case UserType.schoolAdmin:
        return SchoolAdminUser(
          uid: userId,
          email: email,
          name:
              formData['adminName']?.toString() ??
              formData['name']?.toString() ??
              '',
          platform: platform,
          createdAt: now,
          status: UserStatus.active,
          profileImageUrl: null,
          phoneNumber: phone,
          dateOfBirth: null,
          gender: formData['gender']?.toString(),
          address: formData['schoolAddress']?.toString() ?? '',
          metadata: null,
          schoolCode: formData['schoolCode']?.toString() ?? '',
          schoolName: formData['schoolName']?.toString() ?? '',
          schoolAddress: formData['schoolAddress']?.toString() ?? '',
          schoolPhone: formData['phone']?.toString() ?? phone,
          schoolEmail: formData['email']?.toString() ?? email,
          totalStudents: 0,
          totalTeachers: 0,
          totalClasses: 0,
          adminPosition:
              formData['adminPosition']?.toString() ?? 'Administrator',
          currentSubscription: subscription as SchoolSubscription?,
        );

      case UserType.parent:
        final isKidling = platform == Platform.kidling;

        return ParentUser(
          uid: userId,
          email: email,
          name:
              formData['parentName']?.toString() ??
              formData['name']?.toString() ??
              '',
          platform: platform,
          createdAt: now,
          status: UserStatus.active,
          profileImageUrl: null,
          phoneNumber: phone,
          dateOfBirth: null,
          gender: formData['gender']?.toString(),
          address: formData['address']?.toString() ?? '',
          metadata: isKidling
              ? {
                  'isKidlingParent': true,
                  'childName': formData['childName'],
                  'childAge': formData['childAge'],
                  'childGender': formData['childGender'],
                  'learningInterest': formData['learningInterest'],
                  'preferredLearningTime': formData['preferredLearningTime'],
                  'referralSource': formData['referralSource'],
                }
              : null,
          relationship: formData['relationship']?.toString() ?? 'Parent',
          studentName: isKidling
              ? formData['childName']?.toString() ?? ''
              : formData['studentName']?.toString() ?? '',
          studentId: formData['studentId']?.toString() ?? '',
          studentClass: formData['studentClass']?.toString() ?? '',
          schoolName: formData['schoolName']?.toString() ?? '',
          children: [],
          notifications: [],
          currentSubscription: isKidling ? null : subscription as ParentSubscription?,
          kidlingSubscription: isKidling ? subscription as KidlingSubscription? : null,
        );
    }
  }

  Platform _getPlatformEnum(String platform) {
    switch (platform.toLowerCase()) {
      case 'kidling':
        return Platform.kidling;
      case 'istudyapp':
        return Platform.istudyapp;
      case 'teachly':
        return Platform.teachly;
      case 'automated_school':
        return Platform.automatedSchool;
      case 'parents_portal':
        return Platform.parentsPortal;
      default:
        return Platform.istudyapp;
    }
  }

  UserType _getUserTypeForPlatform(String platform) {
    switch (platform.toLowerCase()) {
      case 'kidling':
        return UserType.kidling;
      case 'istudyapp':
        return UserType.student;
      case 'teachly':
        return UserType.teacher;
      case 'automated_school':
        return UserType.schoolAdmin;
      case 'parents_portal':
        return UserType.parent;
      default:
        return UserType.student;
    }
  }

  Future<void> _createPlatformDetails({
    required String userId,
    required String platform,
    required Map<String, dynamic> formData,
  }) async {
    print('Creating $platform details for user: $userId');

    Map<String, dynamic> details = {
      'userId': userId,
      'platform': platform,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
      'isActive': true,
    };

    try {
      switch (platform) {
        case 'kidling':
          details.addAll({
            'parentName': formData['parentName'] ?? formData['name'],
            'parentEmail': formData['parentEmail'] ?? formData['email'],
            'parentPhone': formData['phone'],
            'childName': formData['childName'],
            'childAge': formData['childAge'],
            'childGender': formData['childGender'],
            'learningInterest': formData['learningInterest'],
            'preferredLearningTime': formData['preferredLearningTime'],
            'referralSource': formData['referralSource'],
            'children': [],
            'activities': [],
            'progress': {},
            'totalLearningTime': 0,
            'completedActivities': 0,
            'achievements': [],
          });
          await _firestore
              .collection('kidling_details')
              .doc(userId)
              .set(details);
          break;

        case 'istudyapp':
          DateTime? dob;
          try {
            if (formData['dateOfBirth'] != null) {
              dob = DateTime.parse(formData['dateOfBirth'].toString());
            }
          } catch (e) {
            print('Error parsing date of birth for details: $e');
            dob = null;
          }

          details.addAll({
            'studentId': userId,
            'studentName': formData['studentName'] ?? formData['name'],
            'parentPhone': formData['parentPhone'] ?? formData['phone'],
            'parentName': formData['parentName'],
            'parentEmail': formData['parentEmail'] ?? formData['email'],
            'classGrade': formData['classGrade'] ?? 1,
            'schoolName': formData['schoolName'],
            'educationCategory':
                formData['educationCategory'] ?? 'Basic Education',
            'dateOfBirth': dob != null ? Timestamp.fromDate(dob) : null,
            'gender': formData['gender'],
            'enrolledCourses': [],
            'courseProgress': {},
            'totalStudyTime': 0,
            'quizScores': 0,
            'completedLessons': 0,
          });
          await _firestore
              .collection('student_details')
              .doc(userId)
              .set(details);
          break;

        case 'teachly':
          DateTime? teachDob;
          try {
            if (formData['dateOfBirth'] != null) {
              teachDob = DateTime.parse(formData['dateOfBirth'].toString());
            }
          } catch (e) {
            print('Error parsing date of birth for details: $e');
            teachDob = null;
          }

          details.addAll({
            'teacherName': formData['name'],
            'qualification': formData['qualification'],
            'subject': formData['subject'],
            'experience': formData['experience'],
            'address': formData['address'],
            'emergencyContact': formData['emergencyContact'],
            'schoolName': formData['schoolName'],
            'schoolAddress': formData['schoolAddress'],
            'schoolPhone': formData['schoolPhone'],
            'schoolEmail': formData['schoolEmail'],
            'dateOfBirth': teachDob != null
                ? Timestamp.fromDate(teachDob)
                : null,
            'gender': formData['gender'],
            'createdResources': [],
            'joinedCommunities': [],
            'totalStudents': 0,
          });
          await _firestore
              .collection('teacher_details')
              .doc(userId)
              .set(details);
          break;

        case 'automated_school':
          details.addAll({
            'schoolName': formData['schoolName'],
            'schoolCode': formData['schoolCode'],
            'adminName': formData['adminName'],
            'adminEmail': formData['adminEmail'],
            'schoolAddress': formData['schoolAddress'],
            'phone': formData['phone'],
            'totalStudents': 0,
            'totalTeachers': 0,
            'totalClasses': 0,
          });
          await _firestore
              .collection('school_details')
              .doc(userId)
              .set(details);
          break;

        case 'parents_portal':
          details.addAll({
            'parentName': formData['name'],
            'relationship': formData['relationship'],
            'address': formData['address'],
            'studentName': formData['studentName'],
            'studentId': formData['studentId'],
            'studentClass': formData['studentClass'],
            'schoolName': formData['schoolName'],
            'phone': formData['phone'],
            'email': formData['email'],
            'children': [],
            'notifications': [],
          });
          await _firestore
              .collection('parent_details')
              .doc(userId)
              .set(details);
          break;
      }

      print('$platform details created successfully');
    } catch (e) {
      print('Error creating platform details: $e');
    }
  }
}