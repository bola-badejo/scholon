// lib/app_binding.dart
import 'package:get/get.dart';
import 'package:isapp/Screens/authentication/controllers/authentication_controller.dart';
import 'package:isapp/Screens/authentication/controllers/auth_controller.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthService(), fenix: true);
    Get.lazyPut(() => AuthenticationController(), fenix: true);
  }
}