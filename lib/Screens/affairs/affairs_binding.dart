import 'package:get/get.dart';
import 'package:isapp/Screens/affairs/controller/affairs_controller.dart';

class AffairsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AffairsController());
  }
}