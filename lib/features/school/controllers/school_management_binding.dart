import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';
import 'package:isapp/features/school/controllers/faculty_controller.dart';

class SchoolManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FacultyController());
  }
}
