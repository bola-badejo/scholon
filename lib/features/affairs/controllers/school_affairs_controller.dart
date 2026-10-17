// school_affairs_controller.dart
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isapp/features/auth/models/user.dart';

class SchoolAffairsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final RxString schoolId = ''.obs;
  final RxString schoolName = ''.obs;
  final RxString schoolCode = ''.obs;
  final RxBool isLoading = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadSchoolAdminData();
  }
  
  Future<void> _loadSchoolAdminData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      // School admin's UID is typically their school ID
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final schoolAdmin = createUserFromMap(userData) as SchoolAdminUser;
        
        schoolId.value = user.uid; // School admin's UID is the school ID
        schoolName.value = schoolAdmin.schoolName ?? '';
        schoolCode.value = schoolAdmin.schoolCode ?? '';
        
        print('School Admin Data Loaded:');
        print('  School ID: ${schoolId.value}');
        print('  School Name: ${schoolName.value}');
        print('  School Code: ${schoolCode.value}');
      }
    } catch (e) {
      print('Error loading school admin data: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Helper method to get school data as Map
  Map<String, dynamic> getSchoolData() {
    return {
      'id': schoolId.value,
      'name': schoolName.value,
      'code': schoolCode.value,
      'type': 'school',
      'isAdmin': true,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}