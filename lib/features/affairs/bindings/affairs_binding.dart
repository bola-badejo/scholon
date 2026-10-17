import 'package:get/get.dart';
import 'package:isapp/features/affairs/controllers/affairs_controller.dart';

class AffairsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AffairsController());
  }
}