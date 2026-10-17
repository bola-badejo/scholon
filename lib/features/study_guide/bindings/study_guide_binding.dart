import 'package:get/get.dart';
import 'package:isapp/features/study_guide/controllers/study_guide_controller.dart';

class StudyGuideBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudyGuideController>(() => StudyGuideController());
  }
}
