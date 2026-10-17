import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/controllers/connect_controller.dart';
import 'package:isapp/features/connect/models/nigerian_system_on_connect_controller.dart';

// ========== BINDINGS ==========
class ConnectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConnectController());
  }
}
